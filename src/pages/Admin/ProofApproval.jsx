import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Row, Col, Card, Button, Badge, Form, Modal, ProgressBar, Toast, ToastContainer } from 'react-bootstrap';

const ProofApproval = () => {
  const [proofs, setProofs] = useState([]);
  const [selectedProof, setSelectedProof] = useState(null);
  const [loading, setLoading] = useState(true);

  const [filterQuery, setFilterQuery] = useState('');
  const [adminComment, setAdminComment] = useState('');
  const [showZoomModal, setShowZoomModal] = useState(false);

  // State cho thông báo (Thay thế alert)
  const [toast, setToast] = useState({ show: false, message: '', type: 'success' });

  const fetchProofs = async () => {
    try {
      const userStr = localStorage.getItem('user');
      const user = userStr ? JSON.parse(userStr) : null;
      const userId = user?.id ? `&userId=${user.id}` : '';
      const res = await axios.get(`https://doan3-ooha.onrender.com/api/proofs?status=pending${userId}`);
      
      let fetchedProofs = res.data || [];

      // =========================================================================
      // BỘ LỌC BẢO MẬT: GIỚI HẠN QUYỀN CÁN BỘ LỚP (CÙNG NGÀNH, CÙNG KHÓA)
      // Dựa trên 6 ký tự đầu của MSSV (VD: HTTT23)
      // =========================================================================
      if (user && user.role === 'classCommittee' && user.mssv) {
        const committeePrefix = String(user.mssv).substring(0, 6).toUpperCase();
        fetchedProofs = fetchedProofs.filter(p => {
          const studentPrefix = String(p.mssv || '').substring(0, 6).toUpperCase();
          return studentPrefix === committeePrefix;
        });
      }

      setProofs(fetchedProofs);
      setSelectedProof(fetchedProofs.length > 0 ? fetchedProofs[0] : null);
      setAdminComment(''); 
    } catch (error) {
      console.error('Lỗi khi tải danh sách minh chứng:', error);
      showToast('Lỗi khi tải danh sách minh chứng từ máy chủ!', 'danger');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProofs();
  }, []);

  const showToast = (message, type = 'success') => {
    setToast({ show: true, message, type });
    setTimeout(() => setToast({ show: false, message: '', type: 'success' }), 3000);
  };

  const handleUpdateStatus = async (proofId, newStatus) => {
    try {
      await axios.patch(`https://doan3-ooha.onrender.com/api/proofs/${proofId}/status`, { 
        status: newStatus,
        admin_comment: adminComment 
      });
      
      const updatedProofs = proofs.filter(p => p.id !== proofId);
      setProofs(updatedProofs);
      
      setSelectedProof(updatedProofs.length > 0 ? updatedProofs[0] : null);
      setAdminComment(''); 
      
      showToast(`Đã ${newStatus === 'approved' ? 'CHẤP THUẬN' : 'TỪ CHỐI'} hồ sơ thành công!`, newStatus === 'approved' ? 'success' : 'danger');
    } catch (error) {
      console.error('Lỗi cập nhật trạng thái:', error);
      showToast('Có lỗi xảy ra khi thao tác với cơ sở dữ liệu!', 'danger');
    }
  };

  const pendingCount = proofs.length;
  const flaggedCount = proofs.filter((proof) => proof.phash_warning === 1).length;
  const lowOcrCount = proofs.filter((proof) => proof.ocr_match_percent < 50 && proof.phash_warning === 0).length;
  const activeCase = selectedProof?.id || '';

  const handleSelectProof = (proof) => {
    setSelectedProof(proof);
    setAdminComment(''); 
  };

  const filteredProofs = proofs.filter(p => {
    if (!filterQuery) return true;
    const query = filterQuery.toLowerCase();
    const mssvMatch = (p.mssv || '').toLowerCase().includes(query);
    const chiDoanMatch = (p.chi_doan || '').toLowerCase().includes(query);
    return mssvMatch || chiDoanMatch;
  });

  const uniqueChiDoan = [...new Set(proofs.map(p => p.chi_doan).filter(Boolean))];

  return (
    <div className="proof-approval-container">
      {/* HEADER & FILTER */}
      <div className="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
        <div>
          <h6 className="text-muted text-uppercase fw-bold mb-1" style={{ letterSpacing: '1px', fontSize: '0.75rem' }}>Kiểm duyệt tự động</h6>
          <h3 className="fw-bold mb-0 text-dark">Thẩm định Minh chứng</h3>
        </div>
        <div className="d-flex align-items-center bg-white p-1 rounded-3 border shadow-sm">
          <div className="px-3 text-muted"><i className="bi bi-funnel-fill"></i></div>
          <Form.Select 
            className="border-0 shadow-none bg-transparent" 
            style={{ width: '220px', cursor: 'pointer' }}
            value={filterQuery}
            onChange={(e) => setFilterQuery(e.target.value)}
          >
            <option value="">Tất cả ngành/lớp</option>
            {uniqueChiDoan.map((cd, index) => (
              <option key={index} value={cd}>Lớp: {cd}</option>
            ))}
          </Form.Select>
        </div>
      </div>

      {/* THẺ THỐNG KÊ KPI */}
      <Row className="mb-4 g-3">
        <Col md={4}>
          <Card className="border-0 shadow-sm h-100 rounded-4 overflow-hidden" style={{ background: 'linear-gradient(135deg, #f8fafc, #e2e8f0)' }}>
            <Card.Body className="d-flex align-items-center p-4">
              <div className="bg-primary bg-opacity-10 p-3 rounded-circle me-3"><i className="bi bi-inbox-fill text-primary fs-3"></i></div>
              <div>
                <p className="text-muted fw-bold mb-0 small text-uppercase">Chờ phê duyệt</p>
                <h3 className="fw-bold mb-0 text-dark">{loading ? <span className="spinner-border spinner-border-sm"></span> : pendingCount} <span className="fs-6 fw-normal text-muted">hồ sơ</span></h3>
              </div>
            </Card.Body>
          </Card>
        </Col>
        <Col md={4}>
          <Card className="border-0 shadow-sm h-100 rounded-4 overflow-hidden bg-danger bg-opacity-10 border border-danger border-opacity-25">
            <Card.Body className="d-flex align-items-center p-4">
              <div className="bg-danger text-white p-3 rounded-circle me-3 shadow-sm"><i className="bi bi-fingerprint fs-3"></i></div>
              <div>
                <p className="text-danger fw-bold mb-0 small text-uppercase">Cảnh báo trùng lặp</p>
                <h3 className="fw-bold mb-0 text-danger">{loading ? '...' : flaggedCount} <span className="fs-6 fw-normal">nghi vấn</span></h3>
              </div>
            </Card.Body>
          </Card>
        </Col>
        <Col md={4}>
          <Card className="border-0 shadow-sm h-100 rounded-4 overflow-hidden" style={{ background: 'linear-gradient(135deg, #fffbeb, #fef3c7)' }}>
            <Card.Body className="d-flex align-items-center p-4">
              <div className="bg-warning bg-opacity-25 p-3 rounded-circle me-3 text-warning"><i className="bi bi-eye-slash-fill fs-3" style={{ color: '#d97706' }}></i></div>
              <div>
                <p className="fw-bold mb-0 small text-uppercase" style={{ color: '#b45309' }}>Ảnh mờ / Màn hình</p>
                <h3 className="fw-bold mb-0" style={{ color: '#92400e' }}>{loading ? '...' : lowOcrCount} <span className="fs-6 fw-normal">hồ sơ</span></h3>
              </div>
            </Card.Body>
          </Card>
        </Col>
      </Row>

      <Row className="g-4">
        {/* ================= CỘT TRÁI: HÀNG CHỜ (SCROLL ĐỘC LẬP) ================= */}
        <Col lg={7} xl={8}>
          <div className="d-flex justify-content-between align-items-end mb-3">
            <h5 className="fw-bold mb-0 text-dark">Danh sách hàng chờ</h5>
            <Badge bg="secondary" className="px-2 py-1 bg-opacity-10 text-dark border fw-medium">{filteredProofs.length} kết quả</Badge>
          </div>

          <div className="proof-list-scroll pe-2" style={{ maxHeight: 'calc(100vh - 280px)', overflowY: 'auto' }}>
            {loading ? (
              <div className="text-center text-muted py-5 my-5">
                <div className="spinner-border text-primary mb-3"></div>
                <div>Đang tải danh sách minh chứng...</div>
              </div>
            ) : filteredProofs.length === 0 ? (
              <div className="text-center py-5 my-5 bg-white rounded-4 border border-dashed">
                <i className="bi bi-check2-circle text-success" style={{ fontSize: '4rem' }}></i>
                <h5 className="fw-bold mt-3 text-dark">Tuyệt vời!</h5>
                <p className="text-muted">Không còn hồ sơ nào đang chờ duyệt trong danh sách này.</p>
              </div>
            ) : filteredProofs.map((proof) => {
              const isSelected = activeCase === proof.id;
              const isFlagged = proof.phash_warning === 1;
              const isLowOcr = proof.ocr_match_percent < 50;

              return (
                <Card 
                  key={proof.id} 
                  className={`border-0 mb-3 rounded-4 overflow-hidden proof-card-hover transition-all ${isSelected ? 'shadow ring-2 ring-primary ring-offset-2' : 'shadow-sm border'}`}
                  style={{ cursor: 'pointer', outline: isSelected ? '2px solid #3b82f6' : 'none' }}
                  onClick={() => handleSelectProof(proof)}
                >
                  <Card.Body className="p-0 d-flex flex-column flex-sm-row">
                    
                    {/* Ảnh Thumbnail */}
                    <div 
                      className="proof-thumbnail-wrapper position-relative bg-light"
                      style={{ width: '100%', minWidth: '160px', maxWidth: '180px', minHeight: '160px' }}
                      onClick={(e) => { e.stopPropagation(); setSelectedProof(proof); setShowZoomModal(true); }}
                    >
                      {proof.image_url ? (
                        <div 
                          className="w-100 h-100"
                          style={{
                            backgroundImage: `url(https://doan3-ooha.onrender.com${proof.image_url})`,
                            backgroundSize: 'cover',
                            backgroundPosition: 'center',
                          }}
                        ></div>
                      ) : (
                        <div className="w-100 h-100 d-flex align-items-center justify-content-center text-muted small">Mất ảnh</div>
                      )}
                      
                      <div className="proof-thumbnail-overlay position-absolute top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center">
                        <div className="bg-dark bg-opacity-75 text-white rounded-circle d-flex align-items-center justify-content-center shadow" style={{ width: '40px', height: '40px' }}>
                          <i className="bi bi-zoom-in fs-5"></i>
                        </div>
                      </div>
                    </div>

                    {/* Nội dung List */}
                    <div className="p-3 d-flex flex-column flex-grow-1">
                      <div className="d-flex justify-content-between align-items-start mb-2">
                        <Badge bg="light" text="dark" className="border fw-semibold px-2 py-1">#{proof.id}</Badge>
                        
                        {isFlagged ? (
                          <Badge bg="danger" className="bg-opacity-10 text-danger border border-danger px-2 py-1"><i className="bi bi-exclamation-octagon-fill me-1"></i> TRÙNG LẶP</Badge>
                        ) : isLowOcr ? (
                          <Badge bg="warning" className="bg-opacity-10 text-warning border border-warning px-2 py-1"><i className="bi bi-eye-slash-fill me-1"></i> ẢNH MỜ</Badge>
                        ) : null}
                      </div>

                      <h5 className="fw-bold mb-1 text-dark fs-6">
                        {proof.student_name} <span className="text-primary opacity-75">({proof.mssv})</span>
                      </h5>
                      <p className="text-muted small mb-3 text-truncate" style={{ maxWidth: '350px' }}>
                        <i className="bi bi-geo-alt me-1"></i>{proof.event_name || 'Sự kiện chưa rõ'}
                      </p>
                      
                      <div className="mt-auto d-flex align-items-center gap-3 bg-light p-2 rounded-3">
                        <div className="flex-grow-1">
                          <div className="d-flex justify-content-between mb-1">
                            <span className="small text-muted fw-semibold" style={{ fontSize: '0.7rem' }}>ĐỘ CHÍNH XÁC AI (OCR)</span>
                            <span className={`small fw-bold ${proof.ocr_match_percent >= 66 ? 'text-success' : 'text-danger'}`}>{proof.ocr_match_percent}%</span>
                          </div>
                          <ProgressBar 
                            variant={proof.ocr_match_percent >= 66 ? 'success' : proof.ocr_match_percent >= 40 ? 'warning' : 'danger'} 
                            now={proof.ocr_match_percent} 
                            style={{ height: '6px' }} 
                          />
                        </div>
                        <div className="text-end" style={{ maxWidth: '40%' }}>
                          <span className="small text-muted fw-semibold d-block" style={{ fontSize: '0.7rem' }}>KẾT LUẬN TỪ AI</span>
                          <span className="small fw-medium text-truncate d-inline-block w-100 text-dark" title={proof.ai_note}>{proof.ai_note || 'Chưa phân tích'}</span>
                        </div>
                      </div>
                    </div>
                  </Card.Body>
                </Card>
              );
            })}
          </div>
        </Col>

        {/* ================= CỘT PHẢI: BẢNG ĐIỀU KHIỂN & RA QUYẾT ĐỊNH (STICKY) ================= */}
        <Col lg={5} xl={4}>
          <div className="position-sticky" style={{ top: '20px' }}>
            <Card className="border-0 shadow-lg rounded-4 overflow-hidden">
              <div className="bg-dark text-white p-4" style={{ background: 'linear-gradient(135deg, #1e293b, #0f172a)' }}>
                <div className="d-flex align-items-center mb-1">
                  <i className="bi bi-robot fs-4 text-info me-2"></i>
                  <h5 className="fw-bold mb-0">Trợ lý Phân tích AI</h5>
                </div>
                <p className="text-white-50 small mb-0 mt-2">Hỗ trợ Cán bộ ra quyết định phê duyệt.</p>
              </div>

              <Card.Body className="p-4 bg-white">
                {!selectedProof ? (
                  <div className="text-center text-muted py-5">
                    <i className="bi bi-hand-index-thumb fs-1 mb-2 d-block opacity-50"></i>
                    Vui lòng chọn một minh chứng bên trái để xem chi tiết.
                  </div>
                ) : (
                  <>
                    <div className="mb-4">
                      <h6 className="fw-bold text-dark text-uppercase small mb-3">Kết quả quét dữ liệu</h6>
                      
                      <div className="d-flex flex-column gap-2">
                        <div className="d-flex justify-content-between align-items-center p-2 rounded bg-light border">
                          <span className="small text-muted"><i className="bi bi-person-bounding-box me-2"></i>Đối tượng nộp:</span>
                          <span className="small fw-bold text-dark">{selectedProof.student_name}</span>
                        </div>
                        <div className="d-flex justify-content-between align-items-center p-2 rounded bg-light border">
                          <span className="small text-muted"><i className="bi bi-fingerprint me-2"></i>Mã hàm băm (pHash):</span>
                          <span className="small fw-bold text-primary font-monospace">{selectedProof.image_hash?.substring(0, 10)}...</span>
                        </div>
                        
                        <div className={`mt-2 p-3 rounded-3 border ${selectedProof.phash_warning === 1 ? 'bg-danger bg-opacity-10 border-danger' : selectedProof.ocr_match_percent >= 66 ? 'bg-success bg-opacity-10 border-success' : 'bg-warning bg-opacity-10 border-warning'}`}>
                          <div className="fw-bold small mb-1 d-flex align-items-center gap-1">
                            {selectedProof.phash_warning === 1 ? <><i className="bi bi-shield-x text-danger"></i> <span className="text-danger">PHÁT HIỆN GIAN LẬN</span></>
                             : selectedProof.ocr_match_percent >= 66 ? <><i className="bi bi-shield-check text-success"></i> <span className="text-success">HỢP LỆ / KHỚP ẢNH MẪU</span></>
                             : <><i className="bi bi-shield-exclamation text-warning"></i> <span className="text-warning">CẦN XEM XÉT THỦ CÔNG</span></>}
                          </div>
                          <p className="mb-0 small fw-medium text-dark">{selectedProof.ai_note}</p>
                        </div>
                      </div>
                    </div>

                    <hr className="text-muted opacity-25" />

                    <div className="mt-3">
                      <h6 className="fw-bold text-dark text-uppercase small mb-3">Quyết định của Cán bộ</h6>
                      <Form.Group className="mb-3">
                        <Form.Control 
                          as="textarea" 
                          rows={3} 
                          value={adminComment}
                          onChange={(e) => setAdminComment(e.target.value)}
                          placeholder="Nhập ghi chú phản hồi cho sinh viên (Bắt buộc nếu Từ chối)..." 
                          className="shadow-sm border-secondary border-opacity-25 rounded-3 bg-light" 
                        />
                      </Form.Group>
                      
                      <div className="d-flex gap-2 mt-4">
                        <Button 
                          variant="danger" 
                          className="w-50 fw-bold shadow-sm d-flex justify-content-center align-items-center gap-2 py-2"
                          onClick={() => handleUpdateStatus(selectedProof.id, 'rejected')}
                        >
                          <i className="bi bi-x-lg"></i> Từ chối
                        </Button>
                        <Button 
                          variant="success" 
                          className="w-50 fw-bold shadow-sm d-flex justify-content-center align-items-center gap-2 py-2"
                          onClick={() => handleUpdateStatus(selectedProof.id, 'approved')}
                          style={{ backgroundColor: '#10b981', borderColor: '#10b981' }}
                        >
                          <i className="bi bi-check-all fs-5"></i> Duyệt
                        </Button>
                      </div>
                    </div>
                  </>
                )}
              </Card.Body>
            </Card>
          </div>
        </Col>
      </Row>

      {/* ================= MODAL PHÓNG TO ẢNH (LIGHTBOX ZOOM) ================= */}
      <Modal 
        show={showZoomModal} 
        onHide={() => {
          setShowZoomModal(false);
          const img = document.getElementById('movable-zoom-img');
          if (img) { img.style.transform = 'scale(1)'; }
        }} 
        centered 
        size="lg"
        dialogClassName="modal-zoom-custom bg-transparent"
      >
        <Modal.Header closeButton className="border-0 bg-dark text-white py-3">
          <Modal.Title className="fs-6 fw-bold">
            <i className="bi bi-search text-primary me-2"></i>
            Đối soát minh chứng: {selectedProof?.student_name}
          </Modal.Title>
        </Modal.Header>
        
        <Modal.Body className="p-0 text-center bg-dark position-relative" style={{ minHeight: '60vh', overflow: 'hidden' }}>
          
          <div className="position-absolute top-0 start-50 translate-middle-x mt-3 d-flex gap-1 p-1 rounded-pill shadow-lg" style={{ backgroundColor: 'rgba(255, 255, 255, 0.15)', backdropFilter: 'blur(10px)', zIndex: 10 }}>
            <Button variant="link" className="text-white p-2 rounded-circle hover-bg-white" onClick={() => {
                const img = document.getElementById('movable-zoom-img');
                if (img) {
                  let currentScale = parseFloat(img.style.transform.match(/scale\(([^)]+)\)/)?.[1] || 1);
                  if (currentScale < 3) img.style.transform = `scale(${currentScale + 0.3})`;
                }
              }}><i className="bi bi-zoom-in fs-5"></i></Button>
            <Button variant="link" className="text-white p-2 rounded-circle hover-bg-white" onClick={() => {
                const img = document.getElementById('movable-zoom-img');
                if (img) {
                  let currentScale = parseFloat(img.style.transform.match(/scale\(([^)]+)\)/)?.[1] || 1);
                  if (currentScale > 1) img.style.transform = `scale(${currentScale - 0.3})`;
                }
              }}><i className="bi bi-zoom-out fs-5"></i></Button>
            <Button variant="link" className="text-warning p-2 rounded-circle hover-bg-white" onClick={() => {
                const img = document.getElementById('movable-zoom-img');
                if (img) img.style.transform = 'scale(1)';
              }}><i className="bi bi-arrow-counterclockwise fs-5"></i></Button>
          </div>

          <div className="w-100 h-100 d-flex align-items-center justify-content-center p-4" style={{ height: '70vh', overflow: 'auto' }}>
            {selectedProof?.image_url ? (
              <img 
                id="movable-zoom-img"
                src={`https://doan3-ooha.onrender.com${selectedProof.image_url}`} 
                alt="Minh chứng" 
                className="img-fluid rounded shadow"
                style={{ 
                  maxHeight: '65vh', 
                  objectFit: 'contain', 
                  transform: 'scale(1)', 
                  transition: 'transform 0.25s cubic-bezier(0.2, 0.8, 0.2, 1)' 
                }} 
              />
            ) : (
              <div className="text-white-50">Không có ảnh minh chứng</div>
            )}
          </div>
        </Modal.Body>
      </Modal>

      {/* TOAST NOTIFICATION CONTAINER */}
      <ToastContainer position="top-end" className="p-3" style={{ zIndex: 9999, position: 'fixed' }}>
        <Toast show={toast.show} bg={toast.type} onClose={() => setToast({ ...toast, show: false })} autohide delay={3000}>
          <Toast.Body className="text-white fw-bold d-flex align-items-center">
            <i className={`bi ${toast.type === 'success' ? 'bi-check-circle' : 'bi-exclamation-triangle'} fs-5 me-2`}></i>
            {toast.message}
          </Toast.Body>
        </Toast>
      </ToastContainer>

      {/* CUSTOM STYLES */}
      <style>{`
        /* Scrollbar tàng hình cho danh sách mượt mà */
        .proof-list-scroll::-webkit-scrollbar { width: 6px; }
        .proof-list-scroll::-webkit-scrollbar-track { background: transparent; }
        .proof-list-scroll::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
        .proof-list-scroll::-webkit-scrollbar-thumb:hover { background: #94a3b8; }

        /* Animation Hover Card */
        .transition-all { transition: all 0.25s ease; }
        .proof-card-hover:hover { transform: translateY(-3px); box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1) !important; }
        
        /* Hiệu ứng kính lúp trên ảnh thu nhỏ */
        .proof-thumbnail-overlay { opacity: 0; transition: opacity 0.2s ease; background-color: rgba(0,0,0,0.1); cursor: zoom-in; }
        .proof-thumbnail-wrapper:hover .proof-thumbnail-overlay { opacity: 1; }

        /* Nút Hover trong Modal Zoom */
        .hover-bg-white:hover { background-color: rgba(255,255,255,0.2) !important; }
      `}</style>
    </div>
  );
};

export default ProofApproval;
