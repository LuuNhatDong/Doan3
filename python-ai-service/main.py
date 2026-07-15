from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import JSONResponse
from PIL import Image, ExifTags
import imagehash
import pytesseract
import cv2
import numpy as np
import io
import os
import re
import traceback
import unicodedata
from datetime import datetime
from difflib import SequenceMatcher

app = FastAPI()

tesseract_path = os.getenv('TESSERACT_PATH', '').strip()
default_tesseract_path = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
if tesseract_path and os.path.isfile(tesseract_path):
    pytesseract.pytesseract.tesseract_cmd = tesseract_path
elif os.path.isfile(default_tesseract_path):
    pytesseract.pytesseract.tesseract_cmd = default_tesseract_path

# =========================================================================
# 1. HÀM BỔ TRỢ (NLP & KIỂM TRA NGÀY)
# =========================================================================
def normalize_vietnamese(text: str) -> str:
    if not text: return ""
    text = text.lower()
    text = unicodedata.normalize('NFKD', text).encode('ASCII', 'ignore').decode('utf-8')
    text = re.sub(r'[^a-z0-9\s]', ' ', text)
    return " ".join(text.split())

def fuzzy_match_token(target_token: str, word_list: list, threshold: float = 0.75) -> bool:
    for word in word_list:
        if SequenceMatcher(None, target_token, word).ratio() >= threshold:
            return True
    return False

def extract_dates_from_text(text: str) -> list:
    date_patterns = [r'\b\d{1,2}/\d{1,2}/\d{4}\b', r'\b\d{1,2}-\d{1,2}-\d{4}\b']
    found_dates = []
    text_clean = normalize_vietnamese(text.lower())
    
    # Bắt chữ: ngày ... tháng ... năm ...
    text_date_match = re.findall(r'ngay\s+(\d{1,2})\s+thang\s+(\d{1,2})\s+nam\s+(\d{4})', text_clean)
    for m in text_date_match:
        try: found_dates.append(datetime(int(m[2]), int(m[1]), int(m[0])))
        except: pass

    # Bắt số: dd/mm/yyyy
    for pattern in date_patterns:
        matches = re.findall(pattern, text_clean)
        for m in matches:
            try:
                sep = '/' if '/' in m else '-'
                parts = m.split(sep)
                found_dates.append(datetime(int(parts[2]), int(parts[1]), int(parts[0])))
            except: pass
    return found_dates

# =========================================================================
# 2. HÀM CHỐNG FAKE ẢNH (KIỂM TRA EXIF METADATA)
# =========================================================================
def check_image_tampering(pil_img: Image) -> bool:
    """Trả về True nếu phát hiện dấu hiệu dùng phần mềm chỉnh sửa (Photoshop, Canva, v.v)"""
    try:
        exif = pil_img._getexif()
        if exif:
            for tag, value in exif.items():
                decoded = ExifTags.TAGS.get(tag, tag)
                if decoded == "Software" and isinstance(value, str):
                    suspicious_software = ['photoshop', 'canva', 'illustrator', 'gimp']
                    if any(sw in value.lower() for sw in suspicious_software):
                        return True
    except:
        pass
    return False

# =========================================================================
# 3. API PHÂN TÍCH CHÍNH
# =========================================================================
@app.post("/api/analyze-proof")
async def analyze_proof(
    proof_image: UploadFile = File(...),
    mssv: str = Form(""),
    student_name: str = Form(""),
    event_name: str = Form(""),
    event_date: str = Form(""), 
    sample_proof_image: UploadFile = File(None)
):
    try:
        contents = await proof_image.read()
        pil_img = Image.open(io.BytesIO(contents))
        
        # 1. Băm ảnh (pHash) và kiểm tra giả mạo (Metadata)
        calculated_hash = str(imagehash.phash(pil_img, hash_size=16))
        is_edited_fake = check_image_tampering(pil_img)
        
        nparr = np.frombuffer(bytearray(contents), np.uint8)
        cv_img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if cv_img is None:
            return JSONResponse(status_code=400, content={"status": "error", "message": "Ảnh không hợp lệ."})
        
        # 2. Xử lý OCR
        gray = cv2.cvtColor(cv_img, cv2.COLOR_BGR2GRAY)
        _, thresh = cv2.threshold(gray, 130, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)
        raw_text = pytesseract.image_to_string(thresh, lang='vie+eng', config=r'--oem 3 --psm 1')
        clean_extracted_text = normalize_vietnamese(raw_text)
        extracted_words = clean_extracted_text.split()
        
        # Nhận diện ảnh bối cảnh (hội trường, slide)
        is_context_photo = False
        if len(extracted_words) > 80 and not (normalize_vietnamese(mssv) in clean_extracted_text):
            is_context_photo = True

        score = 0
        ai_notes = []
        missing_fields = []
        
        # TIÊU CHÍ 1: HỌ TÊN (Tối đa 40 điểm)
        if student_name:
            name_tokens = normalize_vietnamese(student_name).split()
            matched_name = sum(1 for t in name_tokens if fuzzy_match_token(t, extracted_words, 0.75))
            if name_tokens and (matched_name / len(name_tokens)) >= 0.50:
                score += 40
            else: missing_fields.append("Tên sinh viên")
                
        # TIÊU CHÍ 2: Tên sự kiện (Tối đa 40 điểm)
        if event_name:
            event_tokens = [w for w in normalize_vietnamese(event_name).split() if len(w) > 2]
            matched_event = sum(1 for t in event_tokens if fuzzy_match_token(t, extracted_words, 0.80))
            if event_tokens and (matched_event / len(event_tokens)) >= 0.50:
                score += 40
            else: missing_fields.append("Sự kiện")

        # TIÊU CHÍ 3: Ngày tháng (Tối đa 20 điểm)
        if event_date:
            try:
                target_date = datetime.strptime(event_date.split('T')[0], "%Y-%m-%d")
                extracted_dates = extract_dates_from_text(raw_text)
                if extracted_dates:
                    min_diff = min([abs((d - target_date).days) for d in extracted_dates])
                    if min_diff <= 3: # Lệch không quá 3 ngày
                        score += 20
                    else:
                        missing_fields.append("Lệch ngày diễn ra")
                else: missing_fields.append("Không tìm thấy ngày")
            except: pass

        # THƯỞNG: MSSV (+10đ nhưng không vượt quá 100đ)
        if mssv and normalize_vietnamese(mssv) in clean_extracted_text:
            score += 10
            
        final_score = min(score, 100)

        # Trả kết quả JSON phân nhánh rõ ràng
        return JSONResponse(content={
            "status": "success",
            "image_hash": calculated_hash,
            "ocr_match_percent": final_score,
            "is_edited": is_edited_fake,
            "is_context": is_context_photo,
            "missing_fields": missing_fields,
            "extracted_text": raw_text
        })
        
    except Exception as e:
        traceback.print_exc()
        return JSONResponse(status_code=500, content={"status": "error", "message": str(e)})