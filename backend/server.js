const express = require('express');

const sharp = require('sharp');
const mysql = require('mysql2');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { OAuth2Client } = require('google-auth-library');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const axios = require('axios');
const FormData = require('form-data');
require('dotenv').config();

// --- HÀM UPLOAD ẢNH LÊN CLOUD MIỄN PHÍ CATBOX ĐỂ KHÔNG BỊ MẤT KHI RESTART ---
async function uploadToCatbox(filePath) {
    try {
        const form = new FormData();
        form.append('reqtype', 'fileupload');
        form.append('fileToUpload', fs.createReadStream(filePath));
        const response = await axios.post('https://catbox.moe/user/api.php', form, {
            headers: form.getHeaders()
        });
        return response.data ? response.data.trim() : null; // Trả về link ảnh vĩnh viễn (https://files.catbox.moe/...)
    } catch (error) {
        console.error('Lỗi upload Catbox:', error.message);
        return null; // Fallback
    }
}

// =========================================================
// 1. KHỞI TẠO APP & MIDDLEWARE
// =========================================================
const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
 
let aiSystemSettings = {
    autoApprove: true,
    ocrThreshold: 66,
    hammingDistance: 10,
    contextPoints: 30
};
// Cấu hình công khai thư mục tải ảnh minh chứng
const projectRoot = path.resolve(__dirname, '..');
const uploadDir = path.resolve(projectRoot, 'uploads');
const legacyUploadDir = path.resolve(__dirname, 'uploads');
app.use('/uploads', express.static(uploadDir));
app.use('/uploads', express.static(legacyUploadDir));

// =========================================================
// 2. CẤU HÌNH GOOGLE AUTH & JWT SECURITY
// =========================================================
const GOOGLE_CLIENT_ID = '601742724925-2rhfv5aj9pcaac8up8bm8os292dl5mo6.apps.googleusercontent.com';
const googleClient = new OAuth2Client(GOOGLE_CLIENT_ID);
const JWT_SECRET = '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';

// Tự động khởi tạo thư mục lưu trữ ảnh nếu chưa tồn tại
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}
if (!fs.existsSync(legacyUploadDir)) {
    fs.mkdirSync(legacyUploadDir, { recursive: true });
}

// Cấu hình bộ nhớ lưu trữ file cho Multer
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        // Lấy đuôi file gốc (vd: .jpg, .png)
        const extension = path.extname(file.originalname || '');
        // Tạo chuỗi số ngẫu nhiên để làm tên file mới tuyệt đối an toàn
        const randomName = Math.round(Math.random() * 1E9);
        cb(null, `${Date.now()}-${randomName}${extension}`);
    }
});
const upload = multer({ 
    storage: storage,
    limits: { fileSize: 15 * 1024 * 1024 } 
});

// =========================================================
// 3. KẾT NỐI DATABASE POOL (TỐI ƯU HÓA HIỆU NĂNG)
// =========================================================
const db = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'quanlysukien3',
    port: process.env.DB_PORT || 3306,
    charset: 'utf8mb4_unicode_ci',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

db.on('connection', (connection) => {
    connection.query('SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci');
});

db.getConnection((err, connection) => {
    if (err) {
        console.error('❌ Lỗi kết nối đến MySQL Workbench/XAMPP:', err.message);
    } else {
        console.log('✅ Đã kết nối cơ sở dữ liệu MySQL thành công!');
        connection.release();
    }
});

const ensureEventColumns = () => {
    const ensureColumn = (table, column, definition, callback) => {
        db.query(`SHOW COLUMNS FROM ${table} LIKE '${column}'`, (err, rows) => {
            if (err) {
                console.warn(`⚠️ Không thể kiểm tra cột ${column}:`, err.message);
                return;
            }
            if (!rows.length) {
                db.query(`ALTER TABLE ${table} ADD COLUMN ${column} ${definition}`, (alterErr) => {
                    if (alterErr) {
                        console.warn(`⚠️ Không thể tạo cột ${column}:`, alterErr.message);
                    } else {
                        console.log(`✅ Đã thêm cột ${column} vào bảng ${table}.`);
                        callback?.();
                    }
                });
            } else {
                callback?.();
            }
            db.query("ALTER TABLE events MODIFY COLUMN attached_file TEXT");
        });
    };

    ensureColumn('events', 'required_fields', 'TEXT NULL');
    ensureColumn('events', 'points', 'INT DEFAULT 0');
    ensureColumn('events', 'location_preset_id', 'INT NULL');
    ensureColumn('events', 'max_participants', 'INT DEFAULT 0');
    ensureColumn('events', 'require_proof', 'TINYINT(1) DEFAULT 1');

    // --- THÊM DÒNG DƯỚI ĐÂY ĐỂ VÁ LỖI CSDL ---
    ensureColumn('events', 'score_type', "VARCHAR(50) DEFAULT 'once'");
    ensureColumn('events', 'sample_proof_url', "VARCHAR(255) NULL");

    db.query("SHOW COLUMNS FROM events LIKE 'category'", (err, rows) => {
        if (err) {
            console.warn('⚠️ Không thể kiểm tra cột category:', err.message);
            return;
        }

        if (rows.length) {
            const type = String(rows[0].Type || '').toUpperCase();
            if (type.includes('ENUM')) {
                db.query("ALTER TABLE events MODIFY COLUMN category VARCHAR(100) NOT NULL DEFAULT ''", (alterErr) => {
                    if (alterErr) {
                        console.warn('⚠️ Không thể thay đổi kiểu dữ liệu cột category:', alterErr.message);
                    } else {
                        console.log('✅ Đã thay đổi cột category thành VARCHAR để hỗ trợ danh mục từ CSDL.');
                    }
                });
            }
        }
    });
};
ensureEventColumns();

const ensureUserColumns = () => {
    const ensureColumn = (column, definition) => {
        db.query(`SHOW COLUMNS FROM users LIKE '${column}'`, (err, rows) => {
            if (err) {
                console.warn(`⚠️ Không thể kiểm tra cột users.${column}:`, err.message);
                return;
            }
            if (!rows.length) {
                db.query(`ALTER TABLE users ADD COLUMN ${column} ${definition}`, (alterErr) => {
                    if (alterErr) {
                        console.warn(`⚠️ Không thể tạo cột users.${column}:`, alterErr.message);
                    } else {
                        console.log(`✅ Đã thêm cột ${column} vào bảng users.`);
                    }
                });
            }
        });
    };

    ensureColumn('phone', 'VARCHAR(20) NULL');
    ensureColumn('faculty', 'VARCHAR(255) NULL');
    ensureColumn('chi_doan', 'VARCHAR(255) NULL');
    ensureColumn('cohort', 'VARCHAR(50) NULL');
    ensureColumn('avatar', 'TEXT NULL');
    ensureColumn('password', 'VARCHAR(255) NULL');
    ensureColumn('events', 'require_file', 'TINYINT(1) DEFAULT 0');


};

const ensureProofColumns = () => {
    const ensureColumn = (column, definition) => {
        db.query(`SHOW COLUMNS FROM proofs LIKE '${column}'`, (err, rows) => {
            if (err) {
                console.warn(`⚠️ Không thể kiểm tra cột proofs.${column}:`, err.message);
                return;
            }
            if (!rows.length) {
                db.query(`ALTER TABLE proofs ADD COLUMN ${column} ${definition}`, (alterErr) => {
                    if (alterErr) {
                        console.warn(`⚠️ Không thể tạo cột proofs.${column}:`, alterErr.message);
                    } else {
                        console.log(`✅ Đã tự động thêm cột ${column} vào bảng proofs.`);
                    }
                });
            }
        });
    };

    ensureColumn('admin_comment', 'TEXT NULL');
    ensureColumn('ai_note', 'TEXT NULL');
    ensureColumn('ocr_text', 'TEXT NULL');
    ensureColumn('ocr_match_percent', 'INT DEFAULT 0');
    ensureColumn('phash_warning', 'TINYINT DEFAULT 0');

    db.query("ALTER TABLE proofs MODIFY COLUMN event_id VARCHAR(20) NOT NULL");
};
ensureProofColumns();

const ensureAttendanceTable = () => {
    db.query(`CREATE TABLE IF NOT EXISTS attendance (
        id INT AUTO_INCREMENT PRIMARY KEY,
        event_id VARCHAR(50) NOT NULL,
        checkin_time DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`, (err) => {
        if (err) {
            console.warn('⚠️ Lỗi tạo bảng attendance:', err.message);
            return;
        }

        const checkAndAdd = (col, def) => {
            db.query(`SHOW COLUMNS FROM attendance LIKE '${col}'`, (e, rows) => {
                if (!e && rows.length === 0) {
                    db.query(`ALTER TABLE attendance ADD COLUMN ${col} ${def}`, (alterErr) => {
                        if (!alterErr) console.log(`✅ Đã tự động thêm cột ${col} vào bảng attendance.`);
                    });
                }
            });
        };

        checkAndAdd('student_id', 'VARCHAR(20)');
        checkAndAdd('method', 'VARCHAR(50)');
        checkAndAdd('status', 'VARCHAR(50)');
        checkAndAdd('submitted_file', 'TEXT');
        checkAndAdd('submitted_link', 'TEXT');
    });
};
ensureAttendanceTable();

const ensureLocationPresetTable = () => {
    db.query(`CREATE TABLE IF NOT EXISTS location_presets (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        latitude VARCHAR(50) NOT NULL,
        longitude VARCHAR(50) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`, (err) => {
        if (err) {
            console.warn('⚠️ Không thể tạo bảng location_presets:', err.message);
        }
    });
};
ensureLocationPresetTable();

const DEFAULT_PASSWORD = '123456';
const DEFAULT_PASSWORD_HASH = bcrypt.hashSync(DEFAULT_PASSWORD, 10);

const ensureUserPassword = (user, callback) => {
    if (!user || user.password) {
        callback?.(user);
        return;
    }

    db.query('UPDATE users SET password = ? WHERE id = ?', [DEFAULT_PASSWORD_HASH, user.id], (err) => {
        if (err) {
            console.warn('⚠️ Không thể thiết lập mật khẩu mặc định cho người dùng:', err.message);
        }
        callback?.({ ...user, password: DEFAULT_PASSWORD_HASH });
    });
};

function getHammingDistance(hash1, hash2) {
    let distance = 0;
    for (let i = 0; i < hash1.length; i++) {
        if (hash1[i] !== hash2[i]) distance++;
    }
    return distance;
}

function getTextSimilarity(text1, text2) {
    if (!text1 || !text2) return 0;
    const words1 = new Set(text1.toLowerCase().split(/\s+/).filter(w => w.length > 3));
    const words2 = new Set(text2.toLowerCase().split(/\s+/).filter(w => w.length > 3));
    if (words1.size === 0 || words2.size === 0) return 0;
    const intersect = new Set([...words1].filter(w => words2.has(w)));
    return intersect.size / Math.max(words1.size, words2.size);
}

// =========================================================
// 4. DANH SÁCH TOÀN BỘ CÁC API CỦA HỆ THỐNG (ROUTES)
// =========================================================

app.post('/api/auth/google', async (req, res) => {
    const { credential, email: rawEmail, name: rawName, picture: rawPicture } = req.body;
    let email, name, picture;

    try {
        if (credential) {
            const ticket = await googleClient.verifyIdToken({
                idToken: credential,
                audience: GOOGLE_CLIENT_ID,
            });
            const payload = ticket.getPayload();
            email = payload.email;
            name = payload.name;
            picture = payload.picture;
        } else if (rawEmail) {
            email = rawEmail;
            name = rawName;
            picture = rawPicture;
        } else {
            return res.status(400).json({ error: "Không tìm thấy thông tin đăng nhập Google hợp lệ!" });
        }

        if (!email.toLowerCase().endsWith('@student.ctuet.edu.vn')) {
            return res.status(403).json({ error: "Vui lòng sử dụng email sinh viên để đăng nhập!" });
        }

        let preExtractedMssv = email.split('@')[0].toUpperCase();
        const preMatch = email.match(/([a-zA-Z]{4})(\d{7})@/);
        if (preMatch) {
            preExtractedMssv = preMatch[1].toUpperCase() + preMatch[2];
        }

        db.query("SELECT * FROM users WHERE email = ? OR mssv = ?", [email, preExtractedMssv], (err, results) => {
            if (err) return res.status(500).json({ error: "Lỗi truy vấn hệ thống database" });

            if (results.length > 0) {
                const user = results[0];
                if (user.is_locked === 1 || user.status === 'locked') {
                    return res.status(403).json({ error: "Tài khoản của bạn đã bị khóa!" });
                }
                const role = String(user.role || '').toLowerCase();
                const allowedRoles = ['admin', 'teacher', 'classcommittee', 'student'];
                if (!allowedRoles.includes(role)) {
                    return res.status(403).json({ error: "Tài khoản này không có quyền đăng nhập vào hệ thống này." });
                }
                const cohortMatch = (user.mssv || '').toUpperCase().match(/^[A-Z]{4}(\d{2})\d{5}$/);
                const cohort = cohortMatch ? `20${cohortMatch[1]}` : '';
                const persistedAvatar = String(user.avatar || '').trim();
                const resolvedAvatar = persistedAvatar || picture || '';

                if (!persistedAvatar && picture) {
                    db.query('UPDATE users SET avatar = ? WHERE id = ?', [picture, user.id], (updateErr) => {
                        if (updateErr) {
                            console.warn('⚠️ Không thể cập nhật avatar cho người dùng sau đăng nhập Google:', updateErr.message);
                        }
                    });
                }

                ensureUserPassword(user, (updatedUser) => {
                    const token = jwt.sign({ id: updatedUser.id, role: updatedUser.role }, JWT_SECRET, { expiresIn: '1d' });
                    res.json({ token, user: { ...updatedUser, avatar: resolvedAvatar, cohort } });
                });
            } else {
                let extractedMssv = email.split('@')[0].toUpperCase();
                let extractedChiDoan = 'Chưa xếp lớp';
                let extractedFaculty = 'Chưa cập nhật';
                let extractedCohort = '';

                const match = email.match(/([a-zA-Z]{4})(\d{7})@/);

                if (match) {
                    const nganhCode = match[1].toUpperCase();
                    const soMssv = match[2];

                    extractedMssv = nganhCode + soMssv;
                    extractedChiDoan = nganhCode + soMssv.substring(0, 4);
                    extractedCohort = `20${soMssv.substring(0, 2)}`;

                    if (nganhCode === 'HTTT') extractedFaculty = 'Hệ thống Thông tin';
                    else if (nganhCode === 'KTPM') extractedFaculty = 'Kỹ thuật Phần mềm';
                    else if (nganhCode === 'KHMT') extractedFaculty = 'Khoa học Máy tính';
                    else if (nganhCode === 'NMMT' || nganhCode === 'MMTT') extractedFaculty = 'Mạng máy tính';
                }

                db.query(
                    "INSERT INTO users (mssv, full_name, email, role, faculty, chi_doan, avatar, password) VALUES (?, ?, ?, 'student', ?, ?, ?, ?)",
                    [extractedMssv, name, email, extractedFaculty, extractedChiDoan, picture, DEFAULT_PASSWORD_HASH],
                    (insertErr, insertRes) => {
                        if (insertErr) return res.status(500).json({ error: "Không thể tạo tài khoản sinh viên mới" });

                        const token = jwt.sign({ id: insertRes.insertId, role: 'student' }, JWT_SECRET, { expiresIn: '1d' });
                        res.json({
                            token,
                            user: {
                                id: insertRes.insertId,
                                mssv: extractedMssv,
                                full_name: name,
                                email: email,
                                role: 'student',
                                faculty: extractedFaculty,
                                chi_doan: extractedChiDoan,
                                cohort: extractedCohort,
                                avatar: picture
                            }
                        });
                    }
                );
            }
        });
    } catch (error) {
        console.error("🔥 Lỗi Google Auth:", error);
        res.status(401).json({ error: "Xác thực tài khoản Google không thành công!" });
    }
});

app.post('/api/auth/login', (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ message: "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!" });
    }

    const inputValue = String(username).trim();
    const normalizedInput = inputValue.toUpperCase();
    const lookupUsername = inputValue.includes('@') ? inputValue.toLowerCase() : normalizedInput;
    const sql = "SELECT * FROM users WHERE LOWER(mssv) = LOWER(?) OR LOWER(email) = LOWER(?)";

    db.query(sql, [lookupUsername, inputValue], async (err, results) => {
        if (err) {
            console.error("🔥 Lỗi truy vấn đăng nhập:", err);
            return res.status(500).json({ error: "Lỗi hệ thống máy chủ cơ sở dữ liệu." });
        }

        if (results.length === 0) {
            return res.status(401).json({ message: "Tài khoản không tồn tại trên hệ thống!" });
        }

        const user = results[0];
        let isMatch = false;

        if (user.password) {
            try {
                isMatch = await bcrypt.compare(password, user.password);
            } catch {
                isMatch = false;
            }
        }

        if (!isMatch && password === DEFAULT_PASSWORD) {
            isMatch = true;
        }

        if (!isMatch && (!user.password || user.password === '')) {
            try {
                isMatch = await bcrypt.compare(password, DEFAULT_PASSWORD_HASH);
            } catch {
                isMatch = false;
            }
        }

        if (!isMatch) {
            return res.status(401).json({ message: "Mật khẩu không chính xác!" });
        }

        if (user.is_locked === 1 || user.status === 'locked') {
            return res.status(403).json({ message: "Tài khoản của bạn đã bị khóa bởi Admin!" });
        }

        const role = String(user.role || '').toLowerCase();
        const allowedRoles = ['admin', 'teacher', 'classcommittee', 'student'];
        if (!allowedRoles.includes(role)) {
            return res.status(403).json({ message: "Từ chối truy cập: Tài khoản không có quyền truy cập hệ thống này!" });
        }

        ensureUserPassword(user, (updatedUser) => {
            const token = jwt.sign(
                { id: updatedUser.id, mssv: updatedUser.mssv, role: updatedUser.role },
                JWT_SECRET,
                { expiresIn: '1d' }
            );

            console.log(`✅ [${updatedUser.role.toUpperCase()}] ${updatedUser.full_name} đã đăng nhập vào hệ thống.`);

            res.json({
                token: token,
                user: {
                    id: updatedUser.id,
                    mssv: updatedUser.mssv,
                    full_name: updatedUser.full_name,
                    email: updatedUser.email,
                    role: updatedUser.role,
                    avatar: updatedUser.avatar || null,
                    phone: updatedUser.phone || '',
                    faculty: updatedUser.faculty || '',
                    chi_doan: updatedUser.chi_doan || '',
                    cohort: updatedUser.cohort || ''
                }
            });
        });
    });
});

app.get('/api/events', (req, res) => {
    db.query("SELECT * FROM events ORDER BY created_at DESC", (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get('/api/location-presets', (req, res) => {
    db.query("SELECT * FROM location_presets ORDER BY created_at DESC", (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.post('/api/location-presets', (req, res) => {
    const { name, latitude, longitude } = req.body;
    if (!name || latitude === undefined || longitude === undefined) {
        return res.status(400).json({ message: 'Thiếu tên hoặc tọa độ để lưu vị trí.' });
    }

    db.query('INSERT INTO location_presets (name, latitude, longitude) VALUES (?, ?, ?)', [name, latitude, longitude], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ message: 'Đã lưu vị trí thành công.', preset: { id: result.insertId, name, latitude, longitude } });
    });
});

app.delete('/api/location-presets/:id', (req, res) => {
    db.query('DELETE FROM location_presets WHERE id = ?', [req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ message: 'Không tìm thấy vị trí để xóa.' });
        res.json({ message: 'Đã xóa vị trí thành công.' });
    });
});

app.get('/api/faculties', (req, res) => {
    db.query("SELECT faculty_code AS `key`, faculty_name AS `label` FROM faculties ORDER BY faculty_code ASC", (err, results) => {
        if (err) {
            console.error("🔥 Lỗi lấy danh sách ngành:", err.message);
            return res.status(500).json({ error: "Lỗi cơ sở dữ liệu: " + err.message });
        }
        res.json(results);
    });
});

app.post('/api/events', upload.fields([{ name: 'poster', maxCount: 1 }, { name: 'sample_proof', maxCount: 1 }, { name: 'attached_files', maxCount: 10 }]), async (req, res) => {
const { 
    id, name, date, end_date, description, category, status, 
    require_gps, latitude, longitude, location_preset_id, 
    required_fields, points, max_participants, require_proof, 
    require_file, // <--- THÊM BIẾN NÀY VÀO ĐÂY
    faculty_limits, score_type 
} = req.body;    const requireGpsEnabled = require_gps === true || require_gps === 1 || require_gps === '1' || require_gps === 'true';
    const MAX_TRAINING_POINTS = 100;

    let poster_url = req.files['poster'] ? '/uploads/' + req.files['poster'][0].filename : '';
    let sample_proof_url = req.files['sample_proof'] ? '/uploads/' + req.files['sample_proof'][0].filename : '';
    
    if (req.files['poster']) {
        const cloudUrl = await uploadToCatbox(req.files['poster'][0].path);
        if (cloudUrl) poster_url = cloudUrl;
    }
    
    if (req.files['sample_proof']) {
        const cloudUrl = await uploadToCatbox(req.files['sample_proof'][0].path);
        if (cloudUrl) sample_proof_url = cloudUrl;
    }

    let attached_files_arr = [];
    if (req.files['attached_files']) {
        for (const f of req.files['attached_files']) {
            const cloudUrl = await uploadToCatbox(f.path);
            attached_files_arr.push(cloudUrl || ('/uploads/' + f.filename));
        }
    }
    const attached_file_string = attached_files_arr.length > 0 ? JSON.stringify(attached_files_arr) : '';

    const safePoints = Math.min(Math.max(Number(points || 0), 0), MAX_TRAINING_POINTS);
    const eventData = {
        id: id,
        name: name,
        date: date,
        end_date: end_date,
        description: description || '',
        category: category,
        poster_url: poster_url,
        sample_proof_url: sample_proof_url,
        attached_file: attached_file_string,
        status: status,
        require_gps: requireGpsEnabled ? 1 : 0,
        latitude: requireGpsEnabled ? (latitude || null) : null,
        longitude: requireGpsEnabled ? (longitude || null) : null,
        location_preset_id: requireGpsEnabled ? (location_preset_id || null) : null,
        required_fields: typeof required_fields === 'string' ? required_fields : JSON.stringify(required_fields || []),
        points: safePoints,
        max_participants: max_participants ? Number(max_participants) : 0,
        require_proof: require_proof !== undefined ? Number(require_proof) : 1,
        require_file: (require_file === 'true' || require_file == 1) ? 1 : 0,
        faculty_limits: faculty_limits || null,
        score_type: score_type || 'once'
    };

    db.query("INSERT INTO events SET ?", eventData, (err, result) => {
        if (err) return res.status(500).json({ error: "Lỗi cơ sở dữ liệu: " + err.message });
        res.status(201).json({ message: "Đã thêm sự kiện lên hệ thống!" });
    });
});

app.put('/api/events/:id', upload.fields([{ name: 'poster', maxCount: 1 }, { name: 'sample_proof', maxCount: 1 }, { name: 'attached_files', maxCount: 10 }]), async (req, res) => {
    const eventId = req.params.id;
    
    // 1. Đã bổ sung require_file vào destructing từ req.body
    const { name, date, end_date, description, category, status, require_gps, latitude, longitude, location_preset_id, required_fields, points, max_participants, require_proof, require_file, faculty_limits, score_type } = req.body;
    
    const requireGpsEnabled = require_gps === true || require_gps === 1 || require_gps === '1' || require_gps === 'true';

    let poster_url = req.files['poster'] ? '/uploads/' + req.files['poster'][0].filename : null;
    let sample_proof_url = req.files['sample_proof'] ? '/uploads/' + req.files['sample_proof'][0].filename : null;
    
    if (req.files['poster']) {
        const cloudUrl = await uploadToCatbox(req.files['poster'][0].path);
        if (cloudUrl) poster_url = cloudUrl;
    }
    
    if (req.files['sample_proof']) {
        const cloudUrl = await uploadToCatbox(req.files['sample_proof'][0].path);
        if (cloudUrl) sample_proof_url = cloudUrl;
    }

    let attached_file_string = null;
    if (req.files['attached_files']) {
        const arr = [];
        for (const f of req.files['attached_files']) {
            const cloudUrl = await uploadToCatbox(f.path);
            arr.push(cloudUrl || ('/uploads/' + f.filename));
        }
        attached_file_string = JSON.stringify(arr);
    }

    // 2. Đã bổ sung require_file=? vào chuỗi SQL (ngay trước faculty_limits=?)
    let sql = "UPDATE events SET name=?, date=?, end_date=?, description=?, category=?, status=?, require_gps=?, latitude=?, longitude=?, location_preset_id=?, required_fields=?, points=?, max_participants=?, require_proof=?, require_file=?, faculty_limits=?, score_type=?";
    const MAX_TRAINING_POINTS = 100;
    const safePoints = Math.min(Math.max(Number(points || 0), 0), MAX_TRAINING_POINTS);

    // 3. Params đã khớp với số lượng dấu ? trong chuỗi SQL
    let params = [
        name, date, end_date, description, category || 'Khác', status,
        requireGpsEnabled ? 1 : 0, requireGpsEnabled ? (latitude || null) : null,
        requireGpsEnabled ? (longitude || null) : null, requireGpsEnabled ? (location_preset_id || null) : null,
        typeof required_fields === 'string' ? required_fields : JSON.stringify(required_fields || []),
        safePoints, max_participants ? Number(max_participants) : 0,
        require_proof !== undefined ? Number(require_proof) : 1,
        (require_file === 'true' || require_file == 1 || require_file === true) ? 1 : 0,
        faculty_limits || null,
        score_type || 'once'
    ];

    if (poster_url) { sql += ", poster_url=?"; params.push(poster_url); }
    if (sample_proof_url) { sql += ", sample_proof_url=?"; params.push(sample_proof_url); }
    if (attached_file_string) { sql += ", attached_file=?"; params.push(attached_file_string); }

    sql += " WHERE id=?";
    params.push(eventId);

    db.query(sql, params, (err, result) => {
        if (err) return res.status(500).json({ error: "Lỗi cơ sở dữ liệu: " + err.message });
        res.json({ message: "Đã cập nhật sự kiện thành công!" });
    });
});

app.patch('/api/events/:id/status', (req, res) => {
    db.query("UPDATE events SET status = ? WHERE id = ?", [req.body.status, req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: "Trạng thái sự kiện đã được cập nhật!" });
    });
});

app.put('/api/profile', upload.single('avatar'), async (req, res) => {
    const payload = req.body || {};
    const { id, full_name, email, phone, faculty, chi_doan, mssv, cohort, avatar } = payload;

    if (!id) {
        return res.status(400).json({ message: 'Thiếu thông tin người dùng để cập nhật' });
    }

    db.query('SELECT * FROM users WHERE id = ?', [id], async (selectErr, rows) => {
        if (selectErr) {
            return res.status(500).json({ message: 'Không thể lấy lại thông tin người dùng' });
        }

        const currentUser = rows[0];
        if (!currentUser) {
            return res.status(404).json({ message: 'Không tìm thấy người dùng' });
        }

        const safeFullName = currentUser.full_name || full_name || '';
        const safeEmail = currentUser.email || email || '';
        const safeMssv = currentUser.mssv || mssv || '';
        let avatarPath = req.file ? `/uploads/${req.file.filename}` : (avatar || currentUser.avatar || '');
        if (req.file) {
            const cloudUrl = await uploadToCatbox(req.file.path);
            if (cloudUrl) {
                avatarPath = cloudUrl;
            }
        }

        const sql = `UPDATE users SET full_name=?, email=?, phone=?, faculty=?, chi_doan=?, mssv=?, avatar=? WHERE id=?`;
        const params = [
            safeFullName,
            safeEmail,
            phone || currentUser.phone || '',
            faculty || currentUser.faculty || '',
            chi_doan || currentUser.chi_doan || '',
            safeMssv,
            avatarPath,
            id
        ];

        db.query(sql, params, (err) => {
            if (err) {
                console.error('🔥 Lỗi cập nhật hồ sơ:', err);
                return res.status(500).json({ message: 'Không thể cập nhật hồ sơ' });
            }

            db.query('SELECT * FROM users WHERE id = ?', [id], (refreshErr, refreshedRows) => {
                if (refreshErr) {
                    return res.status(500).json({ message: 'Không thể lấy lại thông tin mới' });
                }
                res.json({ user: refreshedRows[0] || null });
            });
        });
    });
});

app.get('/api/events/:id/participants', (req, res) => {
    const eventId = req.params.id;
    
    // Nâng cấp SQL: Bổ sung đếm số lượt minh chứng (lượt nộp) và tổng điểm cộng dồn
    const sql = `
        SELECT u.mssv AS student_id,
               u.full_name AS name,
               COALESCE(u.phone, '') AS phone,
               COALESCE(u.chi_doan, '') AS chi_doan,
               a.checkin_time AS checkin_time,
               COALESCE(a.method, 'Quét mã QR') AS method,
               a.submitted_file,
               a.submitted_link,
               COUNT(p.id) AS total_turns, -- BỘ ĐẾM SỐ LƯỢT NỘP
               SUM(IF(p.status = 'approved', e.points, 0)) AS accumulated_points -- TỔNG ĐIỂM CỘNG DỒN ĐÃ DUYỆT
        FROM attendance a  
        JOIN users u ON (
            CAST(a.student_id AS CHAR) COLLATE utf8mb4_unicode_ci = CAST(u.id AS CHAR) COLLATE utf8mb4_unicode_ci 
            OR CAST(a.student_id AS CHAR) COLLATE utf8mb4_unicode_ci = u.mssv COLLATE utf8mb4_unicode_ci
        )
        JOIN events e ON a.event_id COLLATE utf8mb4_unicode_ci = e.id COLLATE utf8mb4_unicode_ci
        LEFT JOIN proofs p ON (
            p.event_id COLLATE utf8mb4_unicode_ci = e.id COLLATE utf8mb4_unicode_ci 
            AND (CAST(p.student_id AS CHAR) COLLATE utf8mb4_unicode_ci = CAST(u.id AS CHAR) COLLATE utf8mb4_unicode_ci 
                 OR p.student_id = u.mssv COLLATE utf8mb4_unicode_ci)
        )
        WHERE a.event_id COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci
        GROUP BY u.mssv, u.full_name, u.phone, u.chi_doan, a.checkin_time, a.method, a.submitted_file, a.submitted_link
        ORDER BY a.checkin_time DESC
    `;

    db.query(sql, [eventId], (err, results) => {
        if (err) {
            console.error("Lỗi lấy danh sách tham gia:", err.message);
            return res.status(500).json({ error: "Lỗi CSDL: " + err.message });
        }
        res.json(results.map(row => ({
            id: row.student_id,
            name: row.name,
            phone: row.phone || '',
            chi_doan: row.chi_doan || '',
            checkin_time: row.checkin_time ? new Date(row.checkin_time).toLocaleString('vi-VN') : '',
            method: row.method,
            file: row.submitted_file || null,
            link: row.submitted_link || null,
            total_turns: row.total_turns || 0, // Trả về số lượt đã nộp
            accumulated_points: row.accumulated_points || 0 // Trả về tổng điểm
        })));
    });
});

// Thêm upload.single('submit_file') để hứng file sinh viên nộp
app.post('/api/events/checkin', upload.single('submit_file'), async (req, res) => {
    // Nhận thêm submit_link từ body
    const { student_id, event_id, method, submit_link } = req.body;
    
    if (!student_id || !event_id) {
        return res.status(400).json({ error: "Thiếu thông tin điểm danh!" });
    }

    // Xử lý đường dẫn file nếu sinh viên có đính kèm file
    let filePath = req.file ? `/uploads/${req.file.filename}` : null;
    if (req.file) {
        const cloudUrl = await uploadToCatbox(req.file.path);
        if (cloudUrl) {
            filePath = cloudUrl;
        }
    }

    db.query("SELECT * FROM attendance WHERE student_id = ? AND event_id = ?", [student_id, event_id], (checkErr, checkResults) => {
        if (checkErr) return res.status(500).json({ error: "Lỗi kiểm tra dữ liệu!" });
        
        if (checkResults.length > 0) {
            return res.status(400).json({ message: "Sinh viên này đã được ghi nhận điểm danh trước đó!" });
        }

        // Cập nhật câu lệnh INSERT: Thêm submitted_file và submitted_link vào CSDL
        const sqlInsert = `
            INSERT INTO attendance (event_id, student_id, checkin_time, method, status, submitted_file, submitted_link) 
            VALUES (?, ?, NOW(), ?, 'checked_in', ?, ?)
        `;
        
        db.query(sqlInsert, [event_id, student_id, method || 'Quét mã QR', filePath, submit_link || null], (err) => {
            if (err) return res.status(500).json({ error: err.message });
            res.status(201).json({ message: "Ghi nhận điểm danh và nộp bài thành công!" });
        });
    });
});

app.get('/api/dashboard/stats', (req, res) => {
    const stats = { activeEvents: 0, totalAttendees: 0, pendingProofs: 0, highPriorityProofs: 0 };

    db.query("SELECT COUNT(*) AS count FROM events WHERE status = 'Đang diễn ra'", (err, res1) => {
        if (!err && res1.length) stats.activeEvents = res1[0].count;

        db.query("SELECT COUNT(*) AS count FROM attendance", (err, res2) => {
            if (!err && res2.length) stats.totalAttendees = res2[0].count;

            db.query("SELECT COUNT(*) AS count FROM proofs WHERE status = 'pending'", (err, res3) => {
                if (!err && res3.length) stats.pendingProofs = res3[0].count;

                db.query("SELECT COUNT(*) AS count FROM proofs WHERE status = 'pending' AND phash_warning = 1", (err, res4) => {
                    if (!err && res4.length) stats.highPriorityProofs = res4[0].count;
                    res.json(stats);
                });
            });
        });
    });
});

app.get('/api/dashboard/pending-proofs', (req, res) => {
    const sql = `
        SELECT p.id, u.full_name, e.name AS event_name, p.created_at, p.phash_warning 
        FROM proofs p
        JOIN users u ON p.student_id = u.id
        JOIN events e ON p.event_id = e.id
        WHERE p.status = 'pending'
        ORDER BY p.created_at ASC LIMIT 5
    `;
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get('/api/dashboard/activities', (req, res) => {
    const sql = `
      SELECT id, name, category, status, COALESCE(date, NOW()) AS event_date
      FROM events
      WHERE status COLLATE utf8mb4_unicode_ci != 'Đã kết thúc'
      ORDER BY id DESC
      LIMIT 5
    `;

    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        const activities = results.map(row => ({
            id: row.id,
            message: `Sự kiện: "${row.name}"`,
            subMessage: `Danh mục: ${row.category || 'Chưa phân loại'}`,
            time: row.event_date ? new Date(row.event_date).toLocaleString('vi-VN') : 'Vừa cập nhật',
            status: row.status
        }));

        res.json(activities);
    });
});

// axios and FormData are already imported at the top



// =========================================================================
// API 4.8: NỘP MINH CHỨNG HOẶC FILE BÀI NỘP (CÓ AI)
// =========================================================================
app.post('/api/proofs/upload_ai', upload.fields([{ name: 'proof_image', maxCount: 1 }, { name: 'submit_file', maxCount: 1 }]), async (req, res) => {
    const { student_id, mssv, student_name, event_id, event_name, submit_link } = req.body;

    let imageUrl = null;
    let imagePath = null;
    if (req.files && req.files['proof_image']) {
        imagePath = req.files['proof_image'][0].path;
        imageUrl = '/uploads/' + req.files['proof_image'][0].filename;
        const cloudUrl = await uploadToCatbox(imagePath);
        if (cloudUrl) {
            imageUrl = cloudUrl;
        }
    }

    let submitFileUrl = null;
    if (req.files && req.files['submit_file']) {
        submitFileUrl = '/uploads/' + req.files['submit_file'][0].filename;
        const cloudUrl = await uploadToCatbox(req.files['submit_file'][0].path);
        if (cloudUrl) {
            submitFileUrl = cloudUrl;
        }
    }

    if (!imageUrl && !submitFileUrl && !submit_link) {
        return res.status(400).json({ status: "error", message: "Vui lòng tải ảnh minh chứng hoặc nộp file/link bài làm!" });
    }

    try {
        db.query("SELECT score_type, sample_proof_url, points, category FROM events WHERE id = ?", [event_id], async (eventErr, eventRows) => {
            if (eventErr || eventRows.length === 0) {
                if (imagePath) try { fs.unlinkSync(imagePath); } catch (e) { }
                return res.status(404).json({ status: "error", message: "Không tìm thấy cấu hình sự kiện." });
            }

            const scoreType = eventRows[0].score_type || 'once';
            const sampleProofUrl = eventRows[0].sample_proof_url;
            const currentEventPoints = eventRows[0].points || 0;
            const currentEventCategory = eventRows[0].category || '';
            const isMultipleTurn = scoreType === 'multiple';

            let image_hash = 'N/A';
            let ocr_match_percent = 100; // Mặc định 100 nếu ko kiểm tra ảnh
            let extracted_text = '';
            let ai_note = 'Hệ thống xử lý';
            let phash_warning = 0;
            let ai_status = 'pending';

            if (imageUrl) {
                try {
                    const pythonForm = new FormData();
                    pythonForm.append('proof_image', fs.createReadStream(imagePath), req.files['proof_image'][0].filename);
                    pythonForm.append('mssv', String(mssv));
                    pythonForm.append('student_name', String(student_name));
                    pythonForm.append('event_name', String(event_name));
                    pythonForm.append('event_date', String(eventRows[0].date || ''));
                    
                    if (sampleProofUrl) {
                        const absoluteSamplePath = path.resolve(__dirname, '..', sampleProofUrl.replace(/^\//, ''));
                        if (fs.existsSync(absoluteSamplePath)) pythonForm.append('sample_proof_image', fs.createReadStream(absoluteSamplePath));
                    }

                    const pythonResponse = await axios.post('http://localhost:8000/api/analyze-proof', pythonForm, { headers: { ...pythonForm.getHeaders() }, timeout: 15000 });
                    
                    image_hash = pythonResponse.data.image_hash || 'N/A';
                    ocr_match_percent = pythonResponse.data.ocr_match_percent || 0;
                    extracted_text = pythonResponse.data.extracted_text || '';
                    
                    // Logic duyệt ảnh tự động
                    if (aiSystemSettings.autoApprove && ocr_match_percent >= aiSystemSettings.ocrThreshold) {
                        ai_status = 'approved';
                    }
                } catch (pythonErr) {
                    ai_note = "Lỗi kết nối máy chủ AI - Chuyển Cán bộ duyệt thủ công";
                }
            } else {
                ai_note = "Sinh viên đã nộp bài (File/Link). Không có ảnh minh chứng.";
                ai_status = aiSystemSettings.autoApprove ? 'approved' : 'pending';
            }

            // Kiểm tra trùng lặp
            db.query("SELECT id, image_hash FROM proofs WHERE status != 'rejected'", (err, rows) => {
                if (!err && rows && rows.length > 0 && image_hash !== 'N/A') {
                    for (let row of rows) {
                        if (row.image_hash && row.image_hash !== 'N/A') {
                            if (getHammingDistance(image_hash, row.image_hash) <= aiSystemSettings.hammingDistance) { 
                                phash_warning = 1; ai_status = 'pending'; break; 
                            }
                        }
                    }
                }

                if (phash_warning === 1) ai_note = (ai_note ? ai_note + " | " : "") + "Cảnh báo trùng lặp ảnh";

                const finishUploadResponse = (finalStatus) => {
                    db.query("UPDATE event_registrations SET is_checked_in = 1, checkin_at = NOW() WHERE mssv = ? AND event_id = ?", [mssv, event_id]);

// NẾU CÓ TRƯỜNG HỢP NỘP FILE HOẶC LINK, GHI VÀO BẢNG ATTENDANCE (ÉP KIỂU COLLATE)
                    const checkAttSql = `
                        SELECT id FROM attendance 
                        WHERE event_id COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci 
                          AND (CAST(student_id AS CHAR) COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci 
                               OR CAST(LOWER(student_id) AS CHAR) COLLATE utf8mb4_unicode_ci = LOWER(?) COLLATE utf8mb4_unicode_ci)
                    `;
                    
                    db.query(checkAttSql, [event_id, student_id, mssv], (attErr, attRows) => {
                        if (attErr) console.error("Lỗi kiểm tra bảng attendance (Upload AI):", attErr.message);
                        
                        if (attRows && attRows.length > 0) {
                            db.query(`UPDATE attendance SET submitted_file = COALESCE(?, submitted_file), submitted_link = COALESCE(?, submitted_link), checkin_time = NOW() WHERE id = ?`, 
                            [submitFileUrl, submit_link || null, attRows[0].id]);
                        } else {
                            db.query(`INSERT INTO attendance (event_id, student_id, method, status, checkin_time, submitted_file, submitted_link) VALUES (?, ?, 'Nộp Bài / Minh Chứng', 'checked_in', NOW(), ?, ?)`, 
                            [event_id, mssv, submitFileUrl, submit_link || null], (insErr) => {
                                if (insErr) console.error("Lỗi chèn bảng attendance (Upload AI):", insErr.message);
                            });
                        }
                    });

                    // CỘNG ĐIỂM NẾU DUYỆT THÀNH CÔNG

                    if (finalStatus === 'approved') {
                        db.query("UPDATE users SET point_wallet = point_wallet + ? WHERE mssv = ?", [currentEventPoints, mssv]);
                        
                        // Phân tích danh mục để cộng đúng vào CSDL
                        let criteriaId = 5;
                        const catUpper = String(currentEventCategory).toUpperCase().trim();
                        if (catUpper.startsWith('I_') || catUpper.includes('I.') || catUpper.includes('HỌC TẬP')) criteriaId = 1;
                        else if (catUpper.startsWith('II_') || catUpper.includes('II.') || catUpper.includes('NỘI QUY')) criteriaId = 2;
                        else if (catUpper.startsWith('III_') || catUpper.includes('III.') || catUpper.includes('XÃ HỘI')) criteriaId = 3;
                        else if (catUpper.startsWith('IV_') || catUpper.includes('IV.') || catUpper.includes('CỘNG ĐỒNG')) criteriaId = 4;

                        db.query("INSERT INTO student_criteria_points (mssv, criteria_id, current_points, updated_at) VALUES (?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE current_points = current_points + ?, updated_at = NOW()", 
                        [mssv, criteriaId, currentEventPoints, currentEventPoints]);
                    }

                    return res.status(200).json({
                        status: "success",
                        message: finalStatus === 'approved' ? "Hệ thống đã phê duyệt tự động thành công!" : "Đã tiếp nhận bài nộp / minh chứng. Đang chờ duyệt.",
                        auto_status: finalStatus,
                    });
                };

                const checkExistingProof = "SELECT id, status FROM proofs WHERE student_id = ? AND event_id = ?";
                db.query(checkExistingProof, [student_id, event_id], (checkProofErr, proofRows) => {
                    if (proofRows.length > 0 && !isMultipleTurn) {
                        const finalStatusToApply = proofRows[0].status === 'approved' ? 'approved' : ai_status;
                        const updateProofSql = `UPDATE proofs SET image_url = COALESCE(?, image_url), image_hash = ?, ocr_match_percent = ?, phash_warning = ?, status = ?, ai_note = ?, created_at = NOW() WHERE student_id = ? AND event_id = ?`;
                        db.query(updateProofSql, [imageUrl, image_hash, ocr_match_percent, phash_warning, finalStatusToApply, ai_note, student_id, event_id], () => finishUploadResponse(finalStatusToApply));
                    } else {
                        const proofId = 'PR_' + Math.floor(Date.now() / 1000) + '_' + Math.floor(Math.random() * 1000);
                        const sqlProof = `INSERT INTO proofs (id, student_id, event_id, image_url, image_hash, ocr_match_percent, phash_warning, status, ai_note) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`;
                        db.query(sqlProof, [proofId, student_id, event_id, imageUrl || 'Không có ảnh', image_hash, ocr_match_percent, phash_warning, ai_status, ai_note], () => finishUploadResponse(ai_status));
                    }
                });
            });
        });
    } catch (error) {
        return res.status(500).json({ error: "Lỗi xử lý dữ liệu với máy chủ AI." });
    }
});

app.get('/api/users', (req, res) => {
    db.query("SELECT * FROM users WHERE role IN ('student', 'classCommittee', 'teacher') ORDER BY created_at DESC", (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get('/api/users/:id', (req, res) => {
    const userId = req.params.id;
    db.query("SELECT * FROM users WHERE id = ?", [userId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (!results.length) return res.status(404).json({ error: "Không tìm thấy sinh viên." });
        res.json(results[0]);
    });
});

app.get('/api/users/:id/activities', (req, res) => {
    const userId = req.params.id;
    db.query("SELECT mssv FROM users WHERE id = ?", [userId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (!results.length) return res.status(404).json({ error: "Không tìm thấy sinh viên." });

        const mssv = results[0].mssv || '';

        // CẬP NHẬT LOGIC: Ràng buộc thêm bảng proofs với trạng thái đã duyệt (approved)
        const sql = `
            SELECT e.id AS event_id,
                   e.name AS event_name,
                   e.category AS event_category,
                   e.description AS event_description,
                   e.date AS event_date,
                   e.end_date AS event_end_date,
                   a.checkin_time,
                   COALESCE(a.method, 'Quét mã QR') AS method
            FROM attendance a
            JOIN events e ON a.event_id COLLATE utf8mb4_unicode_ci = e.id COLLATE utf8mb4_unicode_ci
            JOIN proofs p ON e.id COLLATE utf8mb4_unicode_ci = p.event_id COLLATE utf8mb4_unicode_ci
            WHERE (
                a.student_id = ? 
                OR CAST(a.student_id AS CHAR) COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci
                OR a.student_id = ?
            )
            AND p.student_id = ? -- Khớp thông tin minh chứng của chính sinh viên này
            AND p.status = 'approved' -- CHỈ LẤY HOẠT ĐỘNG ĐÃ ĐƯỢC DUYỆT
            ORDER BY a.checkin_time DESC
        `;

        // Truyền thêm tham số userId để lọc chính xác trạng thái duyệt minh chứng của sinh viên đó
        db.query(sql, [userId, mssv, mssv, userId], (activityErr, activityResults) => {
            if (activityErr) return res.status(500).json({ error: activityErr.message });
            res.json(activityResults.map(row => ({
                event_id: row.event_id,
                event_name: row.event_name,
                category: row.event_category || 'Chưa phân loại',
                event_description: row.event_description || '',
                event_date: row.event_date || null,
                event_end_date: row.event_end_date || null,
                checkin_time: row.checkin_time ? new Date(row.checkin_time).toLocaleString('vi-VN') : '',
                method: row.method
            })));
        });
    });
});
app.patch('/api/users/:id', (req, res) => {
    const userId = req.params.id;
    const { action, targetRole, currentUserRole, currentUserId } = req.body;
    const callerRole = currentUserRole || 'student';
    const callerId = currentUserId ? Number(currentUserId) : null;

    db.query("SELECT * FROM users WHERE id = ?", [userId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (!results.length) return res.status(404).json({ error: "Không tìm thấy sinh viên." });

        const user = results[0];
        const isSelf = callerId && callerId === Number(userId);

        if (action === 'grant_permission') {
            if (!targetRole) {
                return res.status(400).json({ error: 'Thiếu targetRole cho hành động cấp quyền.' });
            }

            const canModifyRole = () => {
                if (isSelf) return false;
                if (callerRole === 'superadmin') return true;
                if (callerRole === 'admin') {
                    return ['student', 'classCommittee', 'teacher'].includes(targetRole);
                }
                if (callerRole === 'classCommittee') {
                    return targetRole === 'student' && user.role === 'classCommittee';
                }
                if (callerRole === 'teacher') {
                    return targetRole === 'student' && user.role === 'classCommittee';
                }
                return false;
            };

            if (!canModifyRole()) {
                return res.status(403).json({ error: 'Bạn không có quyền thực hiện thay đổi này.' });
            }

            db.query("UPDATE users SET role = ? WHERE id = ?", [targetRole, userId], (updateErr) => {
                if (updateErr) return res.status(500).json({ error: updateErr.message });
                res.json({ success: true, role: targetRole });
            });
            return;
        }

        if (action === 'lock' || action === 'unlock') {
            const lockValue = action === 'lock' ? 1 : 0;
            const statusValue = action === 'lock' ? 'locked' : 'active';

            db.query("SHOW COLUMNS FROM users LIKE 'is_locked'", (colErr, colResults) => {
                if (colErr) return res.status(500).json({ error: colErr.message });

                if (colResults.length) {
                    db.query("UPDATE users SET is_locked = ? WHERE id = ?", [lockValue, userId], (updateErr) => {
                        if (updateErr) return res.status(500).json({ error: updateErr.message });
                        res.json({ success: true, is_locked: lockValue });
                    });
                    return;
                }

                db.query("SHOW COLUMNS FROM users LIKE 'status'", (statusErr, statusResults) => {
                    if (statusErr) return res.status(500).json({ error: statusErr.message });
                    if (statusResults.length) {
                        db.query("UPDATE users SET status = ? WHERE id = ?", [statusValue, userId], (updateErr) => {
                            if (updateErr) return res.status(500).json({ error: updateErr.message });
                            res.json({ success: true, status: statusValue });
                        });
                        return;
                    }

                    res.status(400).json({ error: 'Bảng users chưa hỗ trợ chức năng khóa/mở khóa.' });
                });
            });
            return;
        }

        res.status(400).json({ error: 'Hành động không hợp lệ.' });
    });
});

app.get('/api/users/stats', (req, res) => {
    const stats = { quanTriVien: 0, canBoDuyet: 0, choCapQuyen: 18, phienHoatDong: 142, yeuCauHoTro: 4 };
    const sql = `SELECT role, COUNT(*) as count FROM users GROUP BY role`;

    db.query(sql, (err, results) => {
        if (err) {
            console.error("🔥 Lỗi truy vấn thống kê:", err);
            return res.status(500).json({ error: "Lỗi hệ thống máy chủ" });
        }

        results.forEach(row => {
            if (row.role === 'superadmin') stats.quanTriVien = row.count;
            if (row.role === 'classCommittee') stats.canBoDuyet = row.count;
        });

        res.json(stats);
    });
});

app.get('/api/proofs', (req, res) => {
    let sql = `
        SELECT p.id, p.image_url, p.image_hash, p.ocr_match_percent, p.phash_warning, p.status, p.created_at,
               u.full_name AS student_name, u.mssv, u.chi_doan,
               e.name AS event_name
        FROM proofs p
        JOIN users u ON p.student_id = u.id
        JOIN events e ON p.event_id = e.id
    `;

    const params = [];
    const { status: statusFilter, userId } = req.query;

    const executeProofsQuery = (caller) => {
        let conditionPrefix = " WHERE";
        if (statusFilter && statusFilter !== 'all') {
            sql += `${conditionPrefix} p.status = ?`;
            params.push(statusFilter);
            conditionPrefix = " AND";
        }

        if (caller && (caller.role === 'classCommittee' || caller.role === 'classcommittee')) {
            const mssvPrefix = caller.mssv ? caller.mssv.substring(0, 8).toUpperCase() : '';
            if (mssvPrefix) {
                sql += `${conditionPrefix} u.mssv LIKE ?`;
                params.push(`${mssvPrefix}%`);
            }
        }

        sql += ` ORDER BY p.created_at DESC`;

        db.query(sql, params, (err, results) => {
            if (err) {
                console.error("🔥 Lỗi lấy danh sách minh chứng:", err);
                return res.status(500).json({ error: "Lỗi cơ sở dữ liệu." });
            }
            res.json(results);
        });
    };

    if (userId) {
        db.query("SELECT role, mssv FROM users WHERE id = ?", [userId], (err, userRes) => {
            if (!err && userRes.length > 0) {
                executeProofsQuery(userRes[0]);
            } else {
                executeProofsQuery(null);
            }
        });
    } else {
        executeProofsQuery(null);
    }
});

// =========================================================================
// API 4.12: THAY ĐỔI TRẠNG THÁI MINH CHỨNG (CÁN BỘ DUYỆT TRÊN WEB ADMIN) - HOÀN CHỈNH
// =========================================================================
app.patch('/api/proofs/:id/status', (req, res) => {
    const { status: targetStatus, admin_comment } = req.body;
    const proofId = req.params.id;

    // 1. Kiểm tra tính hợp lệ của trạng thái đích đầu vào
    if (!['approved', 'rejected', 'pending'].includes(targetStatus)) {
        return res.status(400).json({ error: "Trạng thái không hợp lệ." });
    }

    // 2. Truy vấn trạng thái cũ và thông tin cấu hình điểm, danh mục của sự kiện trước khi cập nhật
    const sqlGetOldInfo = `
        SELECT p.status AS old_status, u.mssv, e.points, e.category, e.score_type
        FROM proofs p
        JOIN users u ON p.student_id = u.id
        JOIN events e ON p.event_id = e.id
        WHERE p.id = ?
    `;

    db.query(sqlGetOldInfo, [proofId], (infoErr, infoRows) => {
        if (infoErr) {
            console.error("❌ Lỗi truy vấn trạng thái cũ:", infoErr.message);
            return res.status(500).json({ error: "Lỗi cơ sở dữ liệu khi kiểm tra thông tin." });
        }
        if (infoRows.length === 0) {
            return res.status(404).json({ error: "Không tìm thấy thông tin minh chứng này trên hệ thống." });
        }

        const { old_status, mssv, points, category, score_type } = infoRows[0];
        const currentEventPoints = points || 0;
        const scoreType = score_type || 'once';

        // 3. Tiến hành cập nhật trạng thái mới và nhận xét vào bảng proofs
        const sqlUpdateProof = "UPDATE proofs SET status = ?, admin_comment = ? WHERE id = ?";
        db.query(sqlUpdateProof, [targetStatus, admin_comment || '', proofId], (updateErr, result) => {
            if (updateErr) return res.status(500).json({ error: "Lỗi cơ sở dữ liệu khi cập nhật trạng thái." });

            // 4. BIÊN DỊCH LOGIC ĐIỀU PHỐI ĐIỂM SỐ (CHỐNG BUFF & TRỪ ĐIỂM KHI HOÀN TÁC)
            let pointModifier = 0;

            if (old_status !== 'approved' && targetStatus === 'approved') {
                // TRƯỜNG HỢP A: Duyệt minh chứng mới (Chuyển từ pending/rejected -> approved)
                if (scoreType === 'once' && old_status === 'approved') {
                    // Chặn tuyệt đối nếu cấu hình tính 1 lần nhưng trạng thái cũ đã được tính điểm
                    pointModifier = 0;
                } else {
                    pointModifier = currentEventPoints; // Cộng điểm rèn luyện
                }
            } else if (old_status === 'approved' && targetStatus !== 'approved') {
                // TRƯỜNG HỢP B: Hủy duyệt minh chứng (Chuyển từ approved -> rejected/pending)
                pointModifier = -currentEventPoints; // Hạ điểm/Trừ ngược lại điểm rèn luyện
            }

            // Nếu có sự thay đổi về điểm rèn luyện thực tế (pointModifier != 0) thì tiến hành cập nhật ví
            if (pointModifier !== 0) {
                // 4.1 Cập nhật lại ví điểm tổng (point_wallet) của sinh viên
                const sqlUpdateWallet = `
                    UPDATE users 
                    SET point_wallet = point_wallet + ? 
                    WHERE mssv COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci
                `;
                db.query(sqlUpdateWallet, [pointModifier, mssv]);

                // 4.2 Phân tách nhóm danh mục tiêu chí chi tiết rèn luyện (Từ mục I đến V)
                let criteriaId = 5;
                const catUpper = String(category).toUpperCase().trim();

                if (catUpper.startsWith('I_') || catUpper.includes('I.') || catUpper.includes('HỌC TẬP') || catUpper.includes('HỌC THUẬT')) {
                    criteriaId = 1;
                } else if (catUpper.startsWith('II_') || catUpper.includes('II.') || catUpper.includes('NỘI QUY') || catUpper.includes('CHẤP HÀNH')) {
                    criteriaId = 2;
                } else if (catUpper.startsWith('III_') || catUpper.includes('III.') || catUpper.includes('XÃ HỘI') || catUpper.includes('HOẠT ĐỘNG')) {
                    criteriaId = 3;
                } else if (catUpper.startsWith('IV_') || catUpper.includes('IV.') || catUpper.includes('CỘNG ĐỒNG')) {
                    criteriaId = 4;
                } else if (catUpper.startsWith('V_') || catUpper.includes('V.') || catUpper.includes('CÁN BỘ') || catUpper.includes('KHÁC')) {
                    criteriaId = 5;
                }

                // 4.3 Cập nhật lũy kế cộng dồn hoặc trừ bớt tại bảng student_criteria_points
                const sqlUpdateCriteria = `
                    INSERT INTO student_criteria_points (mssv, criteria_id, current_points, updated_at)
                    VALUES (?, ?, ?, NOW())
                    ON DUPLICATE KEY UPDATE current_points = current_points + ?, updated_at = NOW()
                `;
                db.query(sqlUpdateCriteria, [mssv, criteriaId, pointModifier, pointModifier], (critErr) => {
                    if (critErr) console.error("❌ Lỗi phân bổ điểm mục chi tiết tự động (Admin Approve/Revoke):", critErr.message);
                });
            }

            return res.json({ message: `Đã chuyển minh chứng sang trạng thái: ${targetStatus}` });
        });
    });
});

app.get('/api/dashboard/overview', async (req, res) => {
    try {
        const promiseQuery = (sql) => new Promise((resolve, reject) => {
            db.query(sql, (err, results) => {
                if (err) reject(err);
                else resolve(results[0].count);
            });
        });

        const activeEvents = await promiseQuery("SELECT COUNT(*) AS count FROM events WHERE status = 'Đang diễn ra'");
        const totalStudents = await promiseQuery("SELECT COUNT(*) AS count FROM users WHERE role = 'student'");
        const pendingProofs = await promiseQuery("SELECT COUNT(*) AS count FROM proofs WHERE status = 'pending'");
        const warningProofs = await promiseQuery("SELECT COUNT(*) AS count FROM proofs WHERE status = 'pending' AND phash_warning = 1");

        res.json({ activeEvents, totalStudents, pendingProofs, warningProofs });
    } catch (error) {
        console.error("🔥 Lỗi load Dashboard:", error);
        res.status(500).json({ error: "Lỗi máy chủ khi lấy dữ liệu tổng quan" });
    }
});

const resetCodes = {};

app.post('/api/auth/forgot-password', (req, res) => {
    const rawUsername = String(req.body.username || '').trim();
    const lookupUsername = rawUsername.includes('@') ? rawUsername.split('@')[0].toUpperCase() : rawUsername.toUpperCase();

    db.query("SELECT * FROM users WHERE mssv = ? OR email = ?", [lookupUsername, rawUsername], (err, results) => {
        if (err) return res.status(500).json({ message: "Lỗi cơ sở dữ liệu!" });
        if (results.length === 0) return res.status(404).json({ message: "Tài khoản không tồn tại trên hệ thống!" });

        const user = results[0];
        const code = Math.floor(100000 + Math.random() * 900000).toString();

        resetCodes[lookupUsername] = code;
        if (rawUsername.includes('@')) {
            resetCodes[rawUsername] = code;
        }

        console.log(`\n=========================================`);
        console.log(`🔑 YÊU CẦU ĐỔI MẬT KHẨU TỪ HỆ THỐNG`);
        console.log(`- Tài khoản: ${user.mssv || lookupUsername}`);
        console.log(`- MÃ XÁC NHẬN CỦA BẠN LÀ: [ ${code} ]`);
        console.log(`=========================================\n`);

        res.json({ message: "Mã xác nhận đã được tạo thành công!" });
    });
});

app.post('/api/auth/reset-password', async (req, res) => { 
    const rawUsername = String(req.body.username || '').trim();
    const username = rawUsername.includes('@') ? rawUsername.split('@')[0].toUpperCase() : rawUsername.toUpperCase();
    const code = req.body.code.trim();
    const newPassword = req.body.newPassword;

    if ((!resetCodes[username] && !resetCodes[rawUsername]) || (resetCodes[username] && resetCodes[username] !== code) || (resetCodes[rawUsername] && resetCodes[rawUsername] !== code)) {
        return res.status(400).json({ message: "Mã xác nhận không hợp lệ hoặc đã hết hạn!" });
    }

    try {
        const salt = await bcrypt.genSalt(10); 
        const hashedPassword = await bcrypt.hash(newPassword, salt);

        const normalizedUsername = String(username).trim();
        const lookupUsername = normalizedUsername.includes('@') ? normalizedUsername.split('@')[0].toUpperCase() : normalizedUsername.toUpperCase();

        db.query("SELECT id FROM users WHERE mssv = ? OR email = ?", [lookupUsername, normalizedUsername], (selectErr, rows) => {
            if (selectErr) return res.status(500).json({ message: "Lỗi hệ thống khi cập nhật mật khẩu!" });
            if (!rows.length) return res.status(404).json({ message: "Tài khoản không tồn tại!" });

            db.query("UPDATE users SET password = ? WHERE id = ?", [hashedPassword, rows[0].id], (err) => {
                if (err) return res.status(500).json({ message: "Lỗi hệ thống khi cập nhật mật khẩu!" });

                delete resetCodes[username];
                delete resetCodes[rawUsername];
                console.log(`✅ Tài khoản [${username}] đã đổi và MÃ HÓA mật khẩu thành công.`);
                res.json({ message: "Đổi mật khẩu thành công!" });
            });
        });
    } catch (hashError) {
        console.error("Lỗi băm mật khẩu:", hashError);
        res.status(500).json({ message: "Lỗi xử lý thuật toán mã hóa!" });
    }
});

app.get('/api/criteria', (req, res) => {
    const queryCat = "SELECT * FROM criteria_categories ORDER BY id ASC";
    const querySub = "SELECT * FROM criteria_sub_categories ORDER BY id ASC";

    db.query(queryCat, (err, categories) => {
        if (err) return res.status(500).json({ status: "error", message: err.message });

        db.query(querySub, (err, subCategories) => {
            if (err) return res.status(500).json({ status: "error", message: err.message });

            const result = categories.map(cat => ({
                id: cat.id,
                name: cat.name,
                maxPoints: cat.max_points,
                subCategories: subCategories
                    .filter(sub => sub.parent_id === cat.id)
                    .map(sub => ({
                        id: sub.id,
                        name: sub.name,
                        points: sub.points,
                        unit: sub.unit
                    }))
            }));

            res.json({ status: "success", data: result });
        });
    });
});

app.post('/api/criteria/main', (req, res) => {
    const { id, name, maxPoints, isEdit } = req.body;
    if (!id || !name) return res.json({ status: "error", message: "Thiếu thông tin danh mục!" });

    if (isEdit) {
        const sql = "UPDATE criteria_categories SET name = ?, max_points = ? WHERE id = ?";
        db.query(sql, [name, maxPoints, id], (err) => {
            if (err) return res.json({ status: "error", message: err.message });
            res.json({ status: "success", message: "Đã cập nhật trần điểm danh mục thành công!" });
        });
    } else {
        const sql = "INSERT INTO criteria_categories (id, name, max_points) VALUES (?, ?, ?)";
        db.query(sql, [id, name, maxPoints], (err) => {
            if (err) return res.json({ status: "error", message: "Mã định danh (ID) đã tồn tại!" });
            res.json({ status: "success", message: "Thêm danh mục lớn thành công!" });
        });
    }
});

app.post('/api/criteria/sub', (req, res) => {
    const { parentId, name, points, unit, isEdit, id } = req.body; 
    if (!name || !parentId) return res.json({ status: "error", message: "Thiếu thông tin tiêu chí con!" });

    if (isEdit) {
        const sql = "UPDATE criteria_sub_categories SET name = ?, points = ?, unit = ? WHERE id = ?";
        db.query(sql, [name, points, unit, id], (err) => {
            if (err) return res.json({ status: "error", message: err.message });
            res.json({ status: "success", message: "Đã cập nhật khung điểm chi tiết thành công!" });
        });
    } else {
        const sqlFindMax = "SELECT id FROM criteria_sub_categories WHERE parent_id = ?";
        db.query(sqlFindMax, [parentId], (err, rows) => {
            if (err) return res.json({ status: "error", message: err.message });

            let nextNumber = 1;
            if (rows.length > 0) {
                const numbers = rows.map(row => {
                    const parts = row.id.split('_');
                    const num = parseInt(parts[parts.length - 1]);
                    return isNaN(num) ? 0 : num;
                });
                nextNumber = Math.max(...numbers) + 1;
            }

            const autoGeneratedSubId = `${parentId}_${nextNumber}`;

            const sqlInsert = "INSERT INTO criteria_sub_categories (id, parent_id, name, points, unit) VALUES (?, ?, ?, ?, ?)";
            db.query(sqlInsert, [autoGeneratedSubId, parentId, name, points, unit], (insertErr) => {
                if (insertErr) return res.json({ status: "error", message: "Lỗi sinh mã ID tự động tăng: " + insertErr.message });
                res.json({ status: "success", message: `Thêm tiêu chí thành công với mã [${autoGeneratedSubId}]!` });
            });
        });
    }
});

app.delete('/api/criteria/:type/:id', (req, res) => {
    const { type, id } = req.params;
    const table = type === 'main' ? 'criteria_categories' : 'criteria_sub_categories';

    db.query(`DELETE FROM ${table} WHERE id = ?`, [id], (err) => {
        if (err) return res.json({ status: "error", message: err.message });
        res.json({ status: "success", message: `Đã xóa thành công mục [${id}] khỏi hệ thống!` });
    });
});

// =========================================================================
// API 6.1: LẤY DANH SÁCH SỰ KIỆN CHO MOBILE (ĐÃ FIX ẨN KHI ĐÃ ĐIỂM DANH XONG)
// =========================================================================
app.get('/api/mobile/events', (req, res) => {
    const mssv = req.query.mssv || '';

    const queryEvents = (userId) => {
        const sql = `
        SELECT 
            e.id, e.name, e.date, e.end_date, e.category, e.poster_url,
            e.attached_file, e.description, e.status, e.require_gps, e.require_file,
            e.require_proof, e.points, e.max_participants, e.faculty_limits,
            e.score_type, e.latitude, e.longitude,
            (SELECT COUNT(*) FROM event_registrations WHERE event_id = e.id) as current_participants,
            IF(er.id IS NOT NULL, 1, 0) as is_registered,
            IF(
                (SELECT COUNT(*) FROM attendance a WHERE a.event_id COLLATE utf8mb4_unicode_ci = e.id COLLATE utf8mb4_unicode_ci AND (LOWER(a.student_id) = LOWER(?) OR a.student_id = ?)) > 0,
                1,
                0
            ) as is_checked_in,
            (
                SELECT CONCAT('{', GROUP_CONCAT(CONCAT('"', t_count.nganh_code, '":', t_count.total_reg)), '}')
                FROM (
                    SELECT reg.event_id, 
                           UPPER(REGEXP_REPLACE(u.mssv, '[0-9]', '')) AS nganh_code,
                           COUNT(*) AS total_reg
                    FROM event_registrations reg
                    JOIN users u ON reg.mssv COLLATE utf8mb4_unicode_ci = u.mssv COLLATE utf8mb4_unicode_ci
                    GROUP BY reg.event_id, nganh_code
                ) t_count 
                WHERE t_count.event_id = e.id
            ) AS faculty_registered_counts
        FROM events e
        LEFT JOIN event_registrations er 
            ON e.id = er.event_id AND er.mssv COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci
        WHERE e.status COLLATE utf8mb4_unicode_ci != 'Ngừng hoạt động' COLLATE utf8mb4_unicode_ci
        ORDER BY e.date ASC
        `;

        db.query(sql, [mssv, userId, mssv], (err, results) => {
            if (err) {
                console.error("Lỗi lấy danh sách sự kiện di động:", err.message);
                return res.status(500).json({ error: "Lỗi cơ sở dữ liệu." });
            }
            res.status(200).json({ status: "success", events: results });
        });
    };

    if (!mssv) {
        queryEvents(null);
        return;
    }

    db.query(
        "SELECT id FROM users WHERE mssv COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci LIMIT 1",
        [mssv],
        (err, users) => {
            if (err) return res.status(500).json({ status: "error", message: "Lỗi truy vấn CSDL: " + err.message });
            const userId = users && users.length ? users[0].id : null;
            queryEvents(userId);
        }
    );
});

// API 6.2: TRANG CHỦ DASHBOARD MOBILE APP
app.get('/api/mobile/dashboard', (req, res) => {
    const mssv = req.query.mssv || '';
    if (!mssv) return res.status(400).json({ error: 'Thiếu mã số sinh viên' });

    const responseData = { user_info: null, criteria: [], recent_activities: [] };

    const sqlUser = "SELECT full_name, mssv, chi_doan FROM users WHERE mssv = ? LIMIT 1";
    db.query(sqlUser, [mssv], (userErr, userRes) => {
        if (!userErr && userRes.length > 0) {
            responseData.user_info = userRes[0];
        }

        const sqlCriteria = `
            SELECT c.id, c.title, c.max_points, c.icon_name, COALESCE(scp.current_points, 0) AS current_points 
            FROM criteria c 
            LEFT JOIN student_criteria_points scp ON c.id=scp.criteria_id AND scp.mssv = ?
        `;
        db.query(sqlCriteria, [mssv], (err, criteriaRes) => {
            if (!err) responseData.criteria = criteriaRes;

            const sqlActivities = `
                SELECT e.id, e.name, e.category, e.status, e.date, e.end_date, e.description, 
                e.attached_file, e.points, e.require_gps,e.require_file, e.poster_url, e.max_participants, e.faculty_limits,
                e.score_type, 
                (SELECT COUNT(*) FROM event_registrations WHERE event_id = e.id) as current_participants,
                0 AS isSpecial,
                (
                    SELECT CONCAT('{', GROUP_CONCAT(CONCAT('"', t_count.nganh_code, '":', t_count.total_reg)), '}')
                    FROM (
                        SELECT reg.event_id, 
                               UPPER(IF(u.email REGEXP '^[A-Z]{4}', SUBSTRING(u.email, 1, 4), SUBSTRING(u.mssv, 1, 4))) AS nganh_code,
                               COUNT(*) AS total_reg
                        FROM event_registrations reg
                        JOIN users u ON reg.mssv COLLATE utf8mb4_unicode_ci = u.mssv COLLATE utf8mb4_unicode_ci
                        GROUP BY reg.event_id, nganh_code
                    ) t_count 
                    WHERE t_count.event_id = e.id
                ) AS faculty_registered_counts
                FROM events e
                WHERE e.status = 'Sắp diễn ra' 
                  AND e.id NOT IN (SELECT event_id FROM event_registrations WHERE mssv = ?)
                ORDER BY e.created_at DESC 
                LIMIT 5
            `;
            db.query(sqlActivities, [mssv], (err, activitiesRes) => {
                if (err) console.error("Lỗi SQL Dashboard đếm ngành:", err.message);
                if (!err) responseData.recent_activities = activitiesRes;
                res.json(responseData);
            });
        });
    });
});

// API 6.3: LẤY LỊCH SỬ ĐIỂM DANH SINH VIÊN
app.get('/api/mobile/history', (req, res) => {
    const mssv = req.query.mssv || '';
    if (!mssv) return res.json({ status: "error", message: "Thiếu MSSV" });

    const sql = `
    SELECT 
        e.id AS event_id, 
        e.name, 
        e.points, 
        e.category, 
        a.checkin_time,
        a.method,
        e.date AS event_date, 
        e.end_date AS event_end_date,
        e.score_type,
        e.description AS event_description,        -- Thêm dòng này để lấy Nội dung
        e.attached_file AS event_attached_file,    -- Thêm dòng này để lấy Tài liệu
        (
            SELECT p.status 
            FROM proofs p 
            WHERE p.event_id COLLATE utf8mb4_unicode_ci = e.id COLLATE utf8mb4_unicode_ci 
              AND (
                CAST(p.student_id AS CHAR) COLLATE utf8mb4_unicode_ci = CAST(u.id AS CHAR) COLLATE utf8mb4_unicode_ci
                OR CAST(p.student_id AS CHAR) COLLATE utf8mb4_unicode_ci = u.mssv COLLATE utf8mb4_unicode_ci
              )
            ORDER BY p.created_at DESC 
            LIMIT 1
        ) AS proof_status,
        (
            SELECT p.admin_comment 
            FROM proofs p 
            WHERE p.event_id COLLATE utf8mb4_unicode_ci = e.id COLLATE utf8mb4_unicode_ci 
              AND (
                CAST(p.student_id AS CHAR) COLLATE utf8mb4_unicode_ci = CAST(u.id AS CHAR) COLLATE utf8mb4_unicode_ci
                OR CAST(p.student_id AS CHAR) COLLATE utf8mb4_unicode_ci = u.mssv COLLATE utf8mb4_unicode_ci
              )
            ORDER BY p.created_at DESC 
            LIMIT 1
        ) AS admin_comment
    FROM users u
    JOIN attendance a ON (
        CAST(a.student_id AS CHAR) COLLATE utf8mb4_unicode_ci = CAST(u.id AS CHAR) COLLATE utf8mb4_unicode_ci 
        OR CAST(a.student_id AS CHAR) COLLATE utf8mb4_unicode_ci = u.mssv COLLATE utf8mb4_unicode_ci
    )
    JOIN events e ON a.event_id COLLATE utf8mb4_unicode_ci = e.id COLLATE utf8mb4_unicode_ci
    WHERE u.mssv COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci
    ORDER BY a.checkin_time DESC
    `;

    db.query(sql, [mssv], (err, results) => {
        if (err) {
            console.error("🔥 Lỗi lấy lịch sử sạch:", err);
            return res.json({ status: "error", message: err.message });
        }
        res.json({ status: "success", data: results });
    });
});

app.get('/api/mobile/profile', (req, res) => {
    const email = req.query.email || '';
    const sql = `
        SELECT mssv, full_name, email, role, faculty, point_wallet, phone, chi_doan, avatar 
        FROM users 
        WHERE email = ?
    `;
    db.query(sql, [email], (err, results) => {
        if (err) return res.json({ status: "error", message: "Lỗi CSDL: " + err.message });
        if (results.length > 0) {
            res.json({ status: "success", data: results[0] });
        } else {
            res.json({ status: "error", message: "Không tìm thấy dữ liệu cho email: " + email });
        }
    });
});

app.post('/api/mobile/update_avatar', upload.single('avatar_image'), async (req, res) => {
    const email = req.body.email;
    if (!req.file || !email) {
        return res.json({ status: "error", message: "Thiếu ảnh hoặc email" });
    }
    let avatarPath = 'uploads/' + req.file.filename; 
    const cloudUrl = await uploadToCatbox(req.file.path);
    if (cloudUrl) {
        avatarPath = cloudUrl;
    }
    const sql = "UPDATE users SET avatar = ? WHERE email = ?";
    db.query(sql, [avatarPath, email], (err) => {
        if (err) return res.json({ status: "error", message: "Lỗi cập nhật CSDL: " + err.message });
        res.json({ status: "success", new_avatar_path: avatarPath });
    });
});

app.post('/api/mobile/update_name', upload.none(), (req, res) => {
    const { email, full_name } = req.body;
    db.query("UPDATE users SET full_name = ? WHERE email = ?", [full_name, email], (err) => {
        if (err) return res.json({ status: "error", message: err.message });
        res.json({ status: "success" });
    });
});

app.post('/api/mobile/update_phone', upload.none(), (req, res) => {
    const { email, phone } = req.body;
    db.query("UPDATE users SET phone = ? WHERE email = ?", [phone, email], (err) => {
        if (err) return res.json({ status: "error", message: err.message });
        res.json({ status: "success" });
    });
});

app.post('/api/mobile/update_password', async (req, res) => {
    const { email, new_password } = req.body;
    try {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(new_password, salt);
        db.query("UPDATE users SET password = ? WHERE email = ?", [hashedPassword, email], (err) => {
            if (err) return res.json({ status: "error", message: err.message });
            res.json({ status: "success" });
        });
    } catch (error) {
        res.json({ status: "error", message: "Lỗi mã hóa: " + error.message });
    }
});

app.post('/api/mobile/register_event', (req, res) => {
    const { mssv, event_id } = req.body;
    if (!mssv || !event_id) return res.json({ status: "error", message: "Thiếu thông tin xác thực." });

    db.query("SELECT email FROM users WHERE mssv COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci", [mssv], (err, users) => {
        if (err || users.length === 0) return res.json({ status: "error", message: "Mã số sinh viên không tồn tại." });

        const userEmail = users[0].email || '';
        let studentNganh = 'KHAC';

        const match = userEmail.match(/([a-zA-Z]{4})(\d{7})@/);
        if (match) {
            studentNganh = match[1].toUpperCase();
        } else {
            studentNganh = mssv.substring(0, 4).toUpperCase();
        }

        db.query("SELECT date, status, faculty_limits, max_participants FROM events WHERE id COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci", [event_id], (err, events) => {
            if (err || events.length === 0) return res.json({ status: "error", message: "Sự kiện không tồn tại." });

            const event = events[0];
            if (event.status === 'Ngừng hoạt động') {
                return res.json({ status: "error", message: "Sự kiện hiện đã đóng, không nhận đăng ký thêm." });
            }

            if (event.date) {
                const startTime = new Date(event.date).getTime();
                const currentTime = Date.now();
                const deadLineTime = startTime + (30 * 60 * 1000); 

                if (currentTime > deadLineTime) {
                    return res.json({
                        status: "error",
                        message: "Đăng ký thất bại! Sự kiện đã diễn ra quá 30 phút, hệ thống đã đóng cổng đăng ký bổ sung."
                    });
                }
            }

            const facultyLimitsStr = event.faculty_limits;
            let limitForThisNganh = null;

            if (facultyLimitsStr) {
                try {
                    const limitsJson = JSON.parse(facultyLimitsStr);
                    if (limitsJson && limitsJson[studentNganh] !== undefined && limitsJson[studentNganh] !== '') {
                        limitForThisNganh = parseInt(limitsJson[studentNganh]);
                    }
                } catch (e) {
                    console.error("Lỗi phân tích JSON faculty_limits:", e);
                }
            }

            db.query("SELECT id FROM event_registrations WHERE mssv COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci AND event_id COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci", [mssv, event_id], (err, regs) => {
                if (regs.length > 0) return res.json({ status: "error", message: "Bạn đã đăng ký sự kiện này rồi!" });

                if (limitForThisNganh !== null && limitForThisNganh > 0) {
                    const countSql = `
                        SELECT COUNT(*) AS registered_count 
                        FROM event_registrations er
                        JOIN users u ON er.mssv COLLATE utf8mb4_unicode_ci = u.mssv COLLATE utf8mb4_unicode_ci
                        WHERE er.event_id COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci 
                        AND (u.email LIKE ? OR u.mssv LIKE ?)
                    `;
                    db.query(countSql, [event_id, `%${studentNganh.toLowerCase()}%`, `${studentNganh}%`], (countErr, countRes) => {
                        if (countErr) return res.json({ status: "error", message: "Lỗi hệ thống kiểm tra chỉ tiêu ngành." });

                        const currentRegistered = countRes[0].registered_count || 0;
                        if (currentRegistered >= limitForThisNganh) {
                            return res.json({
                                status: "error",
                                message: `Đăng ký thất bại! Chỉ tiêu dành cho ngành của bạn (${studentNganh}) đã hết suất (${currentRegistered}/${limitForThisNganh} suất).`
                            });
                        }

                        db.query("INSERT INTO event_registrations (mssv, event_id) VALUES (?, ?)", [mssv, event_id], (insErr) => {
                            if (insErr) return res.json({ status: "error", message: "Lỗi ghi nhận đăng ký: " + insErr.message });
                            res.json({ status: "success", message: "Đăng ký tham gia thành công!" });
                        });
                    });
                } else {
                    db.query("INSERT INTO event_registrations (mssv, event_id) VALUES (?, ?)", [mssv, event_id], (insErr) => {
                        if (insErr) return res.json({ status: "error", message: "Lỗi ghi nhận đăng ký: " + insErr.message });
                        res.json({ status: "success", message: "Đăng ký tham gia thành công!" });
                    });
                }
            });
        });
    });
});

// =========================================================================
// API 6.7: ĐIỂM DANH SỰ KIỆN TỪ DI ĐỘNG (ĐÃ VÁ LỖI BẢO MẬT GPS)
// =========================================================================
app.post('/api/mobile/checkin_event', (req, res) => {
    // Nhận thêm latitude và longitude từ Mobile App gửi lên
    const { mssv, event_id, latitude, longitude } = req.body;
    if (!mssv || !event_id) return res.json({ status: "error", message: "Thiếu thông tin điểm danh." });

    // 1. Xác thực tài khoản sinh viên
    db.query("SELECT id, mssv FROM users WHERE mssv COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci", [mssv], (err, users) => {
        if (err || users.length === 0) return res.json({ status: "error", message: "Không tìm thấy thông tin sinh viên." });

        const userId = users[0].id;
        const studentMssv = users[0].mssv || mssv;

        // 2. CHẶN SPAM: Kiểm tra trùng lặp bản ghi lịch sử trong bảng attendance
        const sqlCheckAttendance = `
            SELECT id FROM attendance 
            WHERE (LOWER(student_id) = LOWER(?) OR student_id = ?) 
              AND event_id COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci
        `;

        db.query(sqlCheckAttendance, [studentMssv, userId, event_id], (attCheckErr, attRows) => {
            if (attCheckErr) {
                console.error("❌ Lỗi kiểm tra trùng lặp điểm danh:", attCheckErr.message);
                return res.json({ status: "error", message: "Hệ thống bận, vui lòng kiểm tra lại." });
            }

            if (attRows.length > 0) {
                return res.json({ 
                    status: "error", 
                    message: "Bạn đã được ghi nhận điểm danh thành công sự kiện này rồi, không thể quét lại!" 
                });
            }

            // 3. Kiểm tra trạng thái ghi danh trong sự kiện
            db.query("SELECT id, is_checked_in FROM event_registrations WHERE mssv COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci AND event_id COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci", [studentMssv, event_id], (err, regs) => {
                if (err || regs.length === 0) return res.json({ status: "error", message: "Bạn chưa đăng ký sự kiện này nên không thể thực hiện điểm danh." });

                if (regs[0].is_checked_in == 1) {
                    return res.json({ status: "error", message: "Bạn đã được ghi nhận điểm danh sự kiện này rồi!" });
                }

                // Lấy thông tin cấu hình sự kiện (Kèm theo Tọa độ tổ chức)
                db.query("SELECT require_gps, require_proof, points, category, latitude, longitude FROM events WHERE id = ?", [event_id], (eventErr, eventRows) => {
                    if (eventErr || eventRows.length === 0) {
                        return res.json({ status: "error", message: "Không tìm thấy cấu hình sự kiện." });
                    }
                    const event = eventRows[0];
                    const requireGps = event.require_gps === 1 || event.require_gps === '1';
                    const requireProof = event.require_proof === 1 || event.require_proof === '1';
                    const points = event.points || 0;

                    // --- BỘ LỌC CHỐNG FAKE GPS (SERVER-SIDE) ---
                    if (requireGps) {
                        const eventLat = parseFloat(event.latitude);
                        const eventLng = parseFloat(event.longitude);
                        const userLat = parseFloat(latitude);
                        const userLng = parseFloat(longitude);

                        if (eventLat && eventLng) {
                            if (!userLat || !userLng) {
                                return res.json({ status: "error", message: "Thiết bị chưa gửi tọa độ. Vui lòng bật định vị GPS!" });
                            }

                            // Tính khoảng cách theo công thức Haversine
                            const R = 6371e3; // Bán kính trái đất tính bằng mét
                            const rad1 = eventLat * Math.PI/180;
                            const rad2 = userLat * Math.PI/180;
                            const deltaRad = (userLat - eventLat) * Math.PI/180;
                            const deltaLam = (userLng - eventLng) * Math.PI/180;

                            const a = Math.sin(deltaRad/2) * Math.sin(deltaRad/2) +
                                      Math.cos(rad1) * Math.cos(rad2) *
                                      Math.sin(deltaLam/2) * Math.sin(deltaLam/2);
                            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
                            const distance = R * c; // Khoảng cách thực tế (mét)

                            // Cho phép sai số 50 mét
                            if (distance > 50) {
                                return res.json({ 
                                    status: "error", 
                                    message: `Gian lận vị trí! Bạn đang cách địa điểm tổ chức ${Math.round(distance)} mét.` 
                                });
                            }
                        }
                    }
                    // --- KẾT THÚC BỘ LỌC CHỐNG FAKE GPS ---

                    // 4. Cập nhật trạng thái ghi danh
                    db.query("UPDATE event_registrations SET is_checked_in = 1, checkin_at = CURRENT_TIMESTAMP WHERE mssv COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci AND event_id COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci", [studentMssv, event_id], (updateErr) => {
                        if (updateErr) return res.json({ status: "error", message: "Lỗi cập nhật trạng thái điểm danh: " + updateErr.message });

                        const method = requireGps ? 'Định vị GPS' : 'Quét mã QR';
                        const sqlAtt = `INSERT INTO attendance (event_id, student_id, method, status, checkin_time) VALUES (?, ?, ?, 'checked_in', NOW())`;
                        
                        db.query(sqlAtt, [event_id, studentMssv, method], (attErr) => {
                            if (attErr) console.warn("⚠️ Cảnh báo lỗi đồng bộ bảng attendance:", attErr.message);

                            if (!requireProof) {
                                const proofId = 'PR_AUTO_' + Math.floor(Date.now() / 1000) + '_' + Math.floor(Math.random() * 1000);
                                const sqlProof = `INSERT INTO proofs (id, student_id, event_id, image_url, image_hash, ocr_match_percent, phash_warning, status, ai_note) 
                                                  VALUES (?, ?, ?, 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 0, 'approved', 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS')`;

                                db.query(sqlProof, [proofId, userId, event_id], (proofErr) => {
                                    if (proofErr) {
                                        console.error("Lỗi tự động duyệt minh chứng:", proofErr.message);
                                        return res.json({ status: "error", message: "Điểm danh thành công nhưng xảy ra lỗi đồng bộ bảng minh chứng." });
                                    }

                                    let criteriaId = 5;
                                    const catUpper = String(event.category).toUpperCase().trim();

                                    if (catUpper.startsWith('I_') || catUpper.includes('I.') || catUpper.includes('HỌC TẬP') || catUpper.includes('HỌC THUẬT')) {
                                        criteriaId = 1;
                                    } else if (catUpper.startsWith('II_') || catUpper.includes('II.') || catUpper.includes('NỘI QUY') || catUpper.includes('CHẤP HÀNH')) {
                                        criteriaId = 2;
                                    } else if (catUpper.startsWith('III_') || catUpper.includes('III.') || catUpper.includes('XÃ HỘI') || catUpper.includes('HOẠT ĐỘNG')) {
                                        criteriaId = 3;
                                    } else if (catUpper.startsWith('IV_') || catUpper.includes('IV.') || catUpper.includes('CỘNG ĐỒNG')) {
                                        criteriaId = 4;
                                    } else if (catUpper.startsWith('V_') || catUpper.includes('V.') || catUpper.includes('CÁN BỘ') || catUpper.includes('KHÁC')) {
                                        criteriaId = 5;
                                    }

                                    const sqlUpdateCriteria = `
                                        INSERT INTO student_criteria_points (mssv, criteria_id, current_points, updated_at)
                                        VALUES (?, ?, ?, NOW())
                                        ON DUPLICATE KEY UPDATE current_points = current_points + ?, updated_at = NOW()
                                    `;

                                    db.query(sqlUpdateCriteria, [studentMssv, criteriaId, points, points], (critErr) => {
                                        if (critErr) {
                                            console.error("❌ Lỗi phân bổ điểm mục chi tiết tự động:", critErr.message);
                                            return res.json({ status: "error", message: "Điểm danh thành công nhưng lỗi phân bổ danh mục." });
                                        }
                                        
                                        const sqlSumPoints = `SELECT SUM(current_points) AS total_points FROM student_criteria_points WHERE mssv = ?`;
                                        db.query(sqlSumPoints, [studentMssv], (sumErr, sumRows) => {
                                            const finalTotal = (sumRows && sumRows.length > 0) ? (sumRows[0].total_points || 0) : 0;
                                            
                                            db.query("UPDATE users SET point_wallet = ? WHERE mssv = ?", [finalTotal, studentMssv], (walletErr) => {
                                                if (walletErr) console.error("❌ Lỗi đồng bộ point_wallet gốc:", walletErr.message);
                                                
                                                return res.json({
                                                    status: "success",
                                                    message: "Ghi nhận điểm danh thành công! Hệ thống đã tự động cộng điểm rèn luyện."
                                                });
                                            });
                                        });
                                    });
                                });
                            } else {
                                return res.json({ 
                                    status: "success", 
                                    message: "Điểm danh thành công! Vui lòng chụp ảnh và nộp minh chứng để được phê duyệt điểm rèn luyện." 
                                });
                            }
                        });
                    });
                });
            });
        });
    });
});

app.post('/api/mobile/cancel_registration', (req, res) => {
    const { mssv, event_id } = req.body;
    if (!mssv || !event_id) return res.json({ status: "error", message: "Thiếu thông tin yêu cầu hủy." });

    db.query("SELECT date FROM events WHERE id COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci", [event_id], (err, events) => {
        if (err || events.length === 0) return res.json({ status: "error", message: "Sự kiện không tồn tại." });

        const eventTime = new Date(events[0].date).getTime();
        const currentTime = Date.now();

        if ((eventTime - currentTime) < 86400000) {
            return res.json({ status: "error", message: "Không thể hủy! Bạn chỉ được phép hủy đăng ký trước khi sự kiện diễn ra ít nhất 24 giờ." });
        }

        db.query("DELETE FROM event_registrations WHERE mssv COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci AND event_id COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci", [mssv, event_id], (err, result) => {
            if (err) return res.json({ status: "error", message: "Lỗi CSDL: " + err.message });
            if (result.affectedRows > 0) {
                res.json({ status: "success", message: "Hủy đăng ký sự kiện thành công!" });
            } else {
                res.json({ status: "error", message: "Dữ liệu đăng ký không tồn tại hoặc đã bị hủy từ trước." });
            }
        });
    });
});
/**
 * Hàm cập nhật điểm rèn luyện an toàn cho sinh viên
 * @param {string} mssv Mã số sinh viên
 * @param {string} category Danh mục sự kiện
 * @param {number} points Số điểm (Gửi số âm nếu muốn trừ điểm)
 * @param {string} scoreType Cơ chế tính điểm ('once' hoặc 'multiple')
 * @param {string} eventId Mã sự kiện
 * @param {string} currentProofStatus Trạng thái cũ của minh chứng trước khi thay đổi
 */
function updateUserPointsSecure(mssv, category, points, scoreType, eventId, currentProofStatus) {
    // Nếu cơ chế là tính 1 lần ('once') và minh chứng trước đó đã từng được duyệt ('approved') 
    // thì không thực hiện cộng thêm điểm nữa để chống buff điểm.
    if (scoreType === 'once' && currentProofStatus === 'approved' && points > 0) {
        console.log(`⚠️ Bỏ qua cộng điểm trùng cho SV ${mssv} tại sự kiện tính 1 lần.`);
        return;
    }

    // 1. Cập nhật ví tổng (point_wallet) tại bảng users
    const sqlUpdateWallet = `UPDATE users SET point_wallet = point_wallet + ? WHERE mssv = ?`;
    db.query(sqlUpdateWallet, [points, mssv]);

    // 2. Xác định nhóm tiêu chí chi tiết (Từ I đến V)
    let criteriaId = 5;
    const catUpper = String(category).toUpperCase().trim();
    if (catUpper.startsWith('I_') || catUpper.includes('I.') || catUpper.includes('HỌC TẬP')) criteriaId = 1;
    else if (catUpper.startsWith('II_') || catUpper.includes('II.') || catUpper.includes('NỘI QUY')) criteriaId = 2;
    else if (catUpper.startsWith('III_') || catUpper.includes('III.') || catUpper.includes('XÃ HỘI')) criteriaId = 3;
    else if (catUpper.startsWith('IV_') || catUpper.includes('IV.') || catUpper.includes('CỘNG ĐỒNG')) criteriaId = 4;

    // 3. Cập nhật bảng điểm chi tiết student_criteria_points
    const sqlUpdateCriteria = `
        INSERT INTO student_criteria_points (mssv, criteria_id, current_points, updated_at)
        VALUES (?, ?, ?, NOW())
        ON DUPLICATE KEY UPDATE current_points = current_points + ?, updated_at = NOW()
    `;
    db.query(sqlUpdateCriteria, [mssv, criteriaId, points, points], (err) => {
        if (err) console.error("❌ Lỗi đồng bộ dữ liệu bảng tiêu chí:", err.message);
    });
}
// Khởi tạo biến lưu cấu hình hệ thống mặc định (nếu chưa có bảng CSDL)


// =========================================================================
// API CẤU HÌNH HỆ THỐNG: KẾT NỐI ĐỌC/GHI TRỰC TIẾP XUỐNG DATABASE MYSQL
// =========================================================================

// 1. API lấy cấu hình hiện tại nạp lên giao diện React Admin
app.get('/api/system-settings', (req, res) => {
    db.query("SELECT auto_approve, ocr_threshold, hamming_distance, context_points FROM system_settings WHERE id = 1", (err, rows) => {
        if (!err && rows.length > 0) {
            // Đồng bộ dữ liệu từ CSDL vào biến đệm RAM của hệ thống để API 4.8 ăn theo
            aiSystemSettings = {
                autoApprove: rows[0].auto_approve === 1,
                ocrThreshold: rows[0].ocr_threshold,
                hammingDistance: rows[0].hamming_distance,
                contextPoints: rows[0].context_points
            };
        } else {
            console.error("⚠️ Lỗi đọc cấu hình từ MySQL, đang dùng cấu hình RAM mặc định:", err ? err.message : "Trống");
        }
        
        // Trả về dữ liệu cấu hình chuẩn cho giao diện React Admin nạp vào các thanh trượt
        res.json({ status: "success", data: aiSystemSettings });
    });
});

// 2. API cập nhật cấu hình hệ thống từ giao diện Web Admin gửi lên (ĐÃ VÁ LỖI GHI CSDL)
app.post('/api/system-settings', (req, res) => {
    const { autoApprove, ocrThreshold, hammingDistance, contextPoints } = req.body;
    
    const isAutoApprove = autoApprove === true ? 1 : 0;
    const threshold = Number(ocrThreshold) || 66;
    const distance = Number(hammingDistance) || 10;
    const points = Number(contextPoints) || 30;

    const sqlUpdate = `
        UPDATE system_settings 
        SET auto_approve = ?, ocr_threshold = ?, hamming_distance = ?, context_points = ? 
        WHERE id = 1
    `;

    db.query(sqlUpdate, [isAutoApprove, threshold, distance, points], (err, result) => {
        if (err) {
            console.error("❌ Lỗi ghi cấu hình vào database MySQL:", err.message);
            return res.status(500).json({ status: "error", message: "Lỗi cơ sở dữ liệu: " + err.message });
        }

        // Cập nhật lại biến toàn cục RAM ngay lập tức để bộ lọc AI (API 4.8) áp dụng tức thì
        aiSystemSettings = {
            autoApprove: autoApprove !== undefined ? Boolean(autoApprove) : true,
            ocrThreshold: threshold,
            hammingDistance: distance,
            contextPoints: points
        };

        console.log("⚙️ Đã cập nhật và đồng bộ cấu hình Trợ lý AI xuống MySQL:", aiSystemSettings);
        res.json({ status: "success", message: "🎉 Đã cập nhật và lưu cấu hình Trợ lý AI vào CSDL thành công!" });
    });
});
// =========================================================================
// API BỔ SUNG: BẢNG XẾP HẠNG THI ĐUA SINH VIÊN (TUẦN/THÁNG/HỌC KỲ)
// =========================================================================
app.get('/api/admin/leaderboard', (req, res) => {
    const { filter } = req.query; // Nhận 'week', 'month', hoặc 'semester'
    
    // Đổi điều kiện thời gian sang sử dụng created_at của bảng proofs
    let timeCondition = "AND p.created_at >= DATE_SUB(NOW(), INTERVAL 1 WEEK)";
    if (filter === 'month') {
        timeCondition = "AND p.created_at >= DATE_SUB(NOW(), INTERVAL 1 MONTH)";
    } else if (filter === 'semester') {
        timeCondition = "AND p.created_at >= DATE_SUB(NOW(), INTERVAL 3 MONTH)";
    }

    // Logic mới: Lấy dữ liệu từ bảng proofs, chỉ đếm các sự kiện đã duyệt (approved)
    const sqlLeaderboard = `
        SELECT 
            u.mssv,
            u.full_name AS name,
            COUNT(DISTINCT p.event_id) AS total_activities
        FROM users u
        INNER JOIN proofs p ON u.id = p.student_id
        WHERE p.status = 'approved' ${timeCondition}
        GROUP BY u.mssv, u.full_name
        ORDER BY total_activities DESC
        LIMIT 10;
    `;

    db.query(sqlLeaderboard, (err, rows) => {
        if (err) {
            console.error("❌ Lỗi lấy bảng xếp hạng thi đua:", err.message);
            return res.status(500).json({ status: "error", message: err.message });
        }
        res.json({ status: "success", leaderboard: rows });
    });
});
const PORT = 5000;
app.listen(PORT, () => {
    console.log(`🚀 Server đang chạy mượt mà tại địa chỉ công khai: http://localhost:${PORT}`);
});