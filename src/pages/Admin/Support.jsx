import React from 'react';
import { Card, Row, Col, Accordion, Badge, Button } from 'react-bootstrap';

const Support = () => {
  return (
    <>
      {/* ================= HEADER TRANG ================= */}
      <div className="mb-4 d-flex align-items-center gap-3">
        <div 
          className="bg-primary bg-opacity-10 p-3 rounded-circle d-flex align-items-center justify-content-center shadow-sm" 
          style={{ width: '54px', height: '54px' }}
        >
          <i className="bi bi-life-preserver text-primary fs-3"></i>
        </div>
        <div>
          <h6 className="text-primary text-uppercase fw-bold mb-1" style={{ letterSpacing: '1px', fontSize: '0.75rem' }}>
            Trợ giúp & CSKH
          </h6>
          <h3 className="fw-bold mb-0 text-dark">Trung tâm Hỗ trợ Kỹ thuật</h3>
        </div>
      </div>

      <Row className="g-4">
        {/* ================= CỘT TRÁI: CÂU HỎI THƯỜNG GẶP (FAQ) ================= */}
        <Col md={7}>
          <Card className="border-0 shadow-sm h-100 rounded-4" style={{ overflow: 'hidden' }}>
            {/* Dải màu trang trí mỏng trên cùng của Card */}
            <div style={{ height: '5px', background: 'linear-gradient(90deg, #4f46e5, #0ea5e9)' }}></div>
            
            <Card.Body className="p-4 p-lg-5">
              <div className="d-flex align-items-center mb-4 pb-2 border-bottom">
                <i className="bi bi-patch-question-fill text-warning fs-3 me-3"></i>
                <h4 className="fw-bold mb-0 text-dark">Các câu hỏi thường gặp (FAQ)</h4>
              </div>
              
              <Accordion defaultActiveKey="0" className="custom-accordion">
                {/* Câu hỏi 1 */}
                <Accordion.Item eventKey="0" className="border-0 mb-3 rounded-4 shadow-sm bg-light">
                  <Accordion.Header className="fw-bold text-dark">
                    <i className="bi bi-shield-lock-fill text-primary me-2 fs-5"></i> 
                    Làm sao để cấp quyền Admin cho Bí thư chi đoàn?
                  </Accordion.Header>
                  <Accordion.Body className="text-muted small lh-lg bg-white border-top">
                    Truy cập vào menu <strong className="text-dark">Quản lý Người dùng</strong>, tìm kiếm tài khoản sinh viên cần cấp quyền, nhấn vào biểu tượng bánh răng (Cài đặt) và thay đổi vai trò (Role) từ <Badge bg="secondary" className="fw-normal">Student</Badge> sang <Badge bg="danger" className="fw-normal">Admin</Badge>.
                  </Accordion.Body>
                </Accordion.Item>
                
                {/* Câu hỏi 2 */}
                <Accordion.Item eventKey="1" className="border-0 mb-3 rounded-4 shadow-sm bg-light">
                  <Accordion.Header className="fw-bold text-dark">
                    <i className="bi bi-cpu-fill text-danger me-2 fs-5"></i> 
                    Hệ thống AI duyệt ảnh hoạt động như thế nào?
                  </Accordion.Header>
                  <Accordion.Body className="text-muted small lh-lg bg-white border-top">
                    Khi sinh viên nộp minh chứng, AI thực hiện 3 lớp bảo vệ: 
                    <br/><i className="bi bi-check-circle-fill text-success me-1"></i> 1. Tính mã băm <strong className="text-primary">pHash</strong> chống nộp trùng ảnh gian lận. 
                    <br/><i className="bi bi-check-circle-fill text-success me-1"></i> 2. Dùng <strong className="text-success">OCR Tesseract</strong> quét tìm thông tin MSSV/Tên sinh viên. 
                    <br/><i className="bi bi-check-circle-fill text-success me-1"></i> 3. Áp dụng thuật toán lọc bối cảnh <strong className="text-info">OpenCV</strong> để nhận diện thông minh ảnh chụp màn hình máy tính hoặc selfie hội trường không chứa văn bản tĩnh. Cán bộ có thể dùng công cụ <strong className="text-dark"><i className="bi bi-zoom-in"></i> Kính lúp</strong> để phóng to đối soát chi tiết.
                  </Accordion.Body>
                </Accordion.Item>
                
                {/* Câu hỏi 3 */}
                <Accordion.Item eventKey="2" className="border-0 mb-3 rounded-4 shadow-sm bg-light">
                  <Accordion.Header className="fw-bold text-dark">
                    <i className="bi bi-file-earmark-excel-fill text-success me-2 fs-5"></i> 
                    Làm sao để xuất danh sách điểm rèn luyện?
                  </Accordion.Header>
                  <Accordion.Body className="text-muted small lh-lg bg-white border-top">
                    Tại trang <strong className="text-dark">Quản lý Người dùng</strong>, sử dụng nút <Badge bg="success" className="px-2 py-1"><i className="bi bi-download me-1"></i>Xuất dữ liệu</Badge> ở góc trên bên phải để tải file Excel tổng hợp điểm của toàn bộ sinh viên khóa 2023.
                  </Accordion.Body>
                </Accordion.Item>
              </Accordion>
            </Card.Body>
          </Card>
        </Col>

        {/* ================= CỘT PHẢI: THÔNG TIN LIÊN HỆ KỸ THUẬT ================= */}
        <Col md={5}>
          <Card 
            className="border-0 shadow-lg h-100 text-white rounded-4 position-relative" 
            style={{ 
              background: 'linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%)', 
              overflow: 'hidden' 
            }}
          >
            {/* Các khối họa tiết chìm (Background Pattern) */}
            <div className="position-absolute opacity-10" style={{ top: '-10%', right: '-15%', transform: 'rotate(15deg)' }}>
              <i className="bi bi-hexagon-fill" style={{ fontSize: '15rem' }}></i>
            </div>
            <div className="position-absolute opacity-10" style={{ bottom: '-15%', left: '-10%', transform: 'rotate(-15deg)' }}>
              <i className="bi bi-circle-fill" style={{ fontSize: '12rem' }}></i>
            </div>

            <Card.Body className="p-4 p-lg-5 d-flex flex-column position-relative z-1">
              
              <div className="d-flex align-items-center mb-3 pb-3 border-bottom border-white border-opacity-10">
                <div className="bg-white bg-opacity-25 p-2 rounded-3 me-3 backdrop-blur shadow-sm">
                  <i className="bi bi-headset fs-3 text-white"></i>
                </div>
                <h4 className="fw-bold mb-0 text-white">Liên hệ Nhóm Phát triển</h4>
              </div>
              
              <p className="small text-white-50 mb-4 lh-lg" style={{ fontSize: '0.85rem' }}>
                Nếu gặp sự cố hệ thống nghiêm trọng (lỗi CSDL, hỏng API điểm danh, AI phân loại sai), vui lòng liên hệ trực tiếp với đội ngũ phát triển để được xử lý 24/7.
              </p>
              
              {/* Khối Email (Glassmorphism effect) */}
              <div className="bg-white bg-opacity-10 p-3 rounded-4 mb-3 backdrop-blur border border-white border-opacity-25 d-flex align-items-center shadow-sm hover-lift">
                <div className="bg-white rounded-circle d-flex align-items-center justify-content-center me-3" style={{ width: '45px', height: '45px' }}>
                  <i className="bi bi-envelope-at-fill fs-4 text-primary"></i>
                </div>
                <div>
                  <div className="text-white-50 small text-uppercase fw-bold" style={{ letterSpacing: '1px', fontSize: '0.65rem' }}>Email Hỗ Trợ</div>
                  <div className="fw-medium fs-6 text-white" style={{ wordBreak: 'break-all' }}>support.httt2023@sv.ctuet.edu.vn</div>
                </div>
              </div>

              {/* Khối Hotline (Glassmorphism effect) */}
              <div className="bg-white bg-opacity-10 p-3 rounded-4 mb-4 backdrop-blur border border-white border-opacity-25 d-flex align-items-center shadow-sm hover-lift">
                <div className="bg-white rounded-circle d-flex align-items-center justify-content-center me-3" style={{ width: '45px', height: '45px' }}>
                  <i className="bi bi-telephone-fill fs-4 text-success"></i>
                </div>
                <div>
                  <div className="text-white-50 small text-uppercase fw-bold" style={{ letterSpacing: '1px', fontSize: '0.65rem' }}>Hotline Kỹ Thuật</div>
                  <div className="fw-bold fs-4 text-warning">0901 234 567</div>
                </div>
              </div>

              <div className="mt-auto pt-3">
                <Button 
                  variant="light" 
                  size="lg" 
                  className="w-100 fw-bold text-primary shadow rounded-pill d-flex align-items-center justify-content-center gap-2 btn-hover-effect"
                >
                  <i className="bi bi-send-fill"></i> Gửi Yêu Cầu Hỗ Trợ (Ticket)
                </Button>
              </div>
            </Card.Body>
          </Card>
        </Col>
      </Row>

      {/* ================= TÙY CHỈNH CSS NỘI BỘ ================= */}
      <style type="text/css">
        {`
          /* Tùy chỉnh Accordion Bootstrap mềm mại hơn */
          .custom-accordion .accordion-item {
            border-radius: 1rem !important;
            overflow: hidden;
            transition: all 0.3s ease;
          }
          .custom-accordion .accordion-button {
            background-color: transparent;
            box-shadow: none !important;
            padding: 1.25rem 1.5rem;
          }
          .custom-accordion .accordion-button:not(.collapsed) {
            background-color: #eff6ff; /* Màu xanh nhạt khi mở */
            color: #0d235e;
          }
          .custom-accordion .accordion-button:focus {
            border-color: rgba(0,0,0,0.05);
          }
          
          /* Hiệu ứng kính mờ (Glassmorphism) */
          .backdrop-blur {
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
          }
          
          /* Hiệu ứng nổi nhẹ khi di chuột vào khối Liên hệ */
          .hover-lift {
            transition: transform 0.3s ease, box-shadow 0.3s ease;
          }
          .hover-lift:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2) !important;
            background-color: rgba(255,255,255,0.15) !important;
          }

          /* Nút bấm Gửi Ticket */
          .btn-hover-effect {
            transition: all 0.3s ease;
          }
          .btn-hover-effect:hover {
            background-color: #0d235e;
            color: white !important;
            transform: scale(1.02);
          }
        `}
      </style>
    </>
  );
};

export default Support;