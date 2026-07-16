import React, { useState, useEffect } from 'react';
import { Card, Table, Button, Modal, Form, Badge, Spinner } from 'react-bootstrap';

const CategoryManagement = () => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);

  // --- TRẠNG THÁI MODAL (DÙNG CHUNG CHO THÊM & SỬA) ---
  const [showModal, setShowModal] = useState(false);
  const [modalMode, setModalMode] = useState('add_main'); // add_main, add_sub, edit_main, edit_sub
  
  const [currentMainId, setCurrentMainId] = useState('');
  const [currentSubId, setCurrentSubId] = useState('');
  
  const [formId, setFormId] = useState('');
  const [formName, setFormName] = useState('');
  const [formPoints, setFormPoints] = useState(0);
  const [formUnit, setFormUnit] = useState('lần');

  // ==========================================
  // 1. API: LẤY DỮ LIỆU TỪ SERVER
  // ==========================================
  const fetchCriteria = async () => {
    setLoading(true);
    try {
      const res = await fetch('https://doan3-ooha.onrender.com/api/criteria');
      const json = await res.json();
      if (json.status === 'success') {
        setCategories(json.data);
      }
    } catch (error) {
      console.error("Lỗi tải danh mục:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCriteria();
  }, []);

  // ==========================================
  // 2. CÁC HÀM MỞ MODAL ĐIỀU HƯỚNG TƯƠNG TÁC
  // ==========================================
  const openAddMainModal = () => {
    setModalMode('add_main');
    setFormId(''); setFormName(''); setFormPoints(0); setFormUnit('học kỳ');
    setShowModal(true);
  };

  const openAddSubModal = (mainId) => {
    setModalMode('add_sub');
    setCurrentMainId(mainId);
    setFormId(''); setFormName(''); setFormPoints(0); setFormUnit('lần');
    setShowModal(true);
  };

  const openEditMainModal = (mainCat) => {
    setModalMode('edit_main');
    setCurrentMainId(mainCat.id);
    setFormId(mainCat.id);
    setFormName(mainCat.name);
    setFormPoints(mainCat.maxPoints);
    setShowModal(true);
  };

  const openEditSubModal = (mainId, subCat) => {
    setModalMode('edit_sub');
    setCurrentMainId(mainId);
    setCurrentSubId(subCat.id);
    setFormId(subCat.id);
    setFormName(subCat.name);
    setFormPoints(subCat.points);
    setFormUnit(subCat.unit);
    setShowModal(true);
  };

  // ==========================================
  // 3. API: LƯU (THÊM/SỬA) DỮ LIỆU
  // ==========================================
  const handleSave = async () => {
    if (!formName) {
      alert("Vui lòng nhập Nội dung danh mục/tiêu chí!");
      return;
    }

    const isSub = modalMode.includes('sub');
    const isEdit = modalMode.includes('edit');
    const endpoint = isSub ? 'https://doan3-ooha.onrender.com/api/criteria/sub' : 'https://doan3-ooha.onrender.com/api/criteria/main';

    const payload = isSub ? {
      id: isEdit ? currentSubId : "", 
      parentId: currentMainId,
      name: formName,
      points: Number(formPoints),
      unit: formUnit,
      isEdit: isEdit
    } : {
      id: isEdit ? currentMainId : formId, 
      name: formName,
      maxPoints: Number(formPoints),
      isEdit: isEdit
    };

    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      
      if (data.status === 'success') {
        setShowModal(false);
        fetchCriteria(); // Refresh dữ liệu
      } else {
        alert("Lỗi: " + data.message);
      }
    } catch (e) {
      alert("Không kết nối được tới máy chủ!");
    }
  };

  // ==========================================
  // 4. API: XÓA DỮ LIỆU
  // ==========================================
  const handleDelete = async (type, id) => {
    if (window.confirm(`⚠️ Cảnh báo: Bạn có chắc muốn xóa mục [ ${id} ] này không? Thao tác này sẽ xóa toàn bộ các tiêu chí phụ thuộc!`)) {
      try {
        const res = await fetch(`https://doan3-ooha.onrender.com/api/criteria/${type}/${id}`, { method: 'DELETE' });
        const data = await res.json();
        if (data.status === 'success') {
          fetchCriteria();
        } else {
          alert("Lỗi: " + data.message);
        }
      } catch (e) {
        alert("Lỗi khi kết nối đến máy chủ.");
      }
    }
  };

  return (
    <>
      {/* ================= HEADER TRANG ================= */}
      <div className="mb-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div className="d-flex align-items-center gap-3">
          <div 
            className="bg-primary bg-opacity-10 p-3 rounded-circle d-flex align-items-center justify-content-center shadow-sm" 
            style={{ width: '54px', height: '54px' }}
          >
            <i className="bi bi-diagram-3-fill text-primary fs-3"></i>
          </div>
          <div>
            <h6 className="text-primary text-uppercase fw-bold mb-1" style={{ letterSpacing: '1px', fontSize: '0.75rem' }}>
              Cấu hình Tiêu chí
            </h6>
            <h3 className="fw-bold mb-0 text-dark">Quản lý Danh mục & Khung điểm</h3>
          </div>
        </div>
        
        <Button 
          className="btn-hover-lift fw-bold px-4 py-2 shadow-sm" 
          style={{ background: 'linear-gradient(90deg, #0f172a, #3730a3)', border: 'none', borderRadius: '10px' }}
          onClick={openAddMainModal}
        >
          <i className="bi bi-plus-circle-fill me-2"></i> Thêm Mục Lớn Mới
        </Button>
      </div>

      {/* ================= BẢNG DANH MỤC (TABLE) ================= */}
      <Card className="border-0 shadow-lg rounded-4 overflow-hidden bg-white">
        {/* Dải gradient trang trí mép trên Card */}
        <div style={{ height: '4px', background: 'linear-gradient(90deg, #4f46e5, #0ea5e9, #10b981)' }}></div>
        
        <Card.Body className="p-0">
          {loading ? (
            <div className="text-center py-5">
              <Spinner animation="border" className="text-primary mb-3" />
              <div className="text-muted fw-medium">Đang đồng bộ dữ liệu từ Cơ sở dữ liệu...</div>
            </div>
          ) : (
            <Table responsive className="align-middle mb-0 custom-category-table">
              <thead style={{ backgroundColor: '#f8fafc' }}>
                <tr>
                  <th style={{ width: '55%' }} className="text-muted text-uppercase fw-bold py-3 ps-4 fs-7">Nội dung đánh giá / Danh mục</th>
                  <th style={{ width: '20%' }} className="text-center text-muted text-uppercase fw-bold py-3 fs-7">Quy định điểm</th>
                  <th style={{ width: '25%' }} className="text-end text-muted text-uppercase fw-bold py-3 pe-4 fs-7">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {categories.length === 0 ? (
                  <tr>
                    <td colSpan="3" className="text-center py-5 text-muted">
                      <i className="bi bi-inbox fs-1 d-block mb-2 text-light"></i>
                      Chưa có danh mục nào. Hãy tạo mới!
                    </td>
                  </tr>
                ) : (
                  categories.map((mainCat) => (
                    <React.Fragment key={mainCat.id}>
                      {/* --- DÒNG DANH MỤC CHÍNH --- */}
                      <tr className="main-category-row">
                        <td className="py-3 ps-4">
                          <div className="d-flex align-items-center">
                            <div className="icon-box bg-warning bg-opacity-10 text-warning rounded-3 me-3 d-flex justify-content-center align-items-center" style={{ width: '36px', height: '36px' }}>
                              <i className="bi bi-folder-fill fs-5"></i>
                            </div>
                            <span className="fw-bold text-dark fs-6">{mainCat.name}</span>
                          </div>
                        </td>
                        <td className="text-center py-3">
                          <Badge pill bg="dark" className="px-3 py-2 fw-medium fs-7 shadow-sm border border-secondary border-opacity-25">
                            Trần điểm: {mainCat.maxPoints} đ
                          </Badge>
                        </td>
                        <td className="text-end py-3 pe-4">
                          <Button variant="light" size="sm" className="btn-icon-hover text-success me-1 shadow-sm border" title="Thêm tiêu chí con" onClick={() => openAddSubModal(mainCat.id)}>
                            <i className="bi bi-plus-lg"></i>
                          </Button>
                          <Button variant="light" size="sm" className="btn-icon-hover text-primary me-1 shadow-sm border" title="Sửa danh mục lớn" onClick={() => openEditMainModal(mainCat)}>
                            <i className="bi bi-pencil-square"></i>
                          </Button>
                          <Button variant="light" size="sm" className="btn-icon-hover text-danger shadow-sm border" title="Xóa danh mục lớn" onClick={() => handleDelete('main', mainCat.id)}>
                            <i className="bi bi-trash3"></i>
                          </Button>
                        </td>
                      </tr>

                      {/* --- CÁC DÒNG TIÊU CHÍ CON --- */}
                      {mainCat.subCategories?.map((sub, index) => {
                        const isLast = index === mainCat.subCategories.length - 1;
                        return (
                          <tr key={sub.id} className={`sub-category-row ${isLast ? 'border-bottom-thick' : ''}`}>
                            <td className="py-2 ps-4">
                              <div className="d-flex align-items-center ms-4 ps-2">
                                <i className="bi bi-arrow-return-right text-secondary opacity-50 fs-5 me-3"></i>
                                <span className="text-secondary fw-medium" style={{ fontSize: '0.95rem' }}>{sub.name}</span>
                              </div>
                            </td>
                            <td className="text-center py-2">
                              <span className="text-success fw-bold bg-success bg-opacity-10 px-2 py-1 rounded-2" style={{ fontSize: '0.85rem' }}>
                                + {sub.points} đ / {sub.unit}
                              </span>
                            </td>
                            <td className="text-end py-2 pe-4">
                              <div className="action-buttons-sub opacity-50 transition-opacity">
                                <Button variant="link" size="sm" className="text-primary p-1 me-1 text-decoration-none fw-semibold" onClick={() => openEditSubModal(mainCat.id, sub)}>
                                  <i className="bi bi-pencil-fill me-1"></i>Sửa
                                </Button>
                                <Button variant="link" size="sm" className="text-danger p-1 text-decoration-none fw-semibold" onClick={() => handleDelete('sub', sub.id)}>
                                  <i className="bi bi-x-circle-fill me-1"></i>Xóa
                                </Button>
                              </div>
                            </td>
                          </tr>
                        );
                      })}
                    </React.Fragment>
                  ))
                )}
              </tbody>
            </Table>
          )}
        </Card.Body>
      </Card>

      {/* ================= MODAL THÊM / SỬA (DÙNG CHUNG) ================= */}
      <Modal show={showModal} onHide={() => setShowModal(false)} centered backdrop="static" contentClassName="border-0 rounded-4 shadow-lg overflow-hidden">
        {/* Modal Header với Gradient */}
        <Modal.Header className="text-white border-0 py-3" style={{ background: 'linear-gradient(135deg, #1e3a8a, #4338ca)' }}>
          <div className="d-flex align-items-center w-100">
            <div className="bg-white bg-opacity-25 p-2 rounded-circle me-3 d-flex justify-content-center align-items-center" style={{ width: '40px', height: '40px' }}>
              <i className={`bi ${modalMode.includes('add') ? 'bi-plus-circle' : 'bi-pencil-square'} fs-4`}></i>
            </div>
            <Modal.Title className="fw-bold fs-5 m-0">
              {modalMode === 'add_main' && 'Khởi tạo Danh mục lớn'}
              {modalMode === 'add_sub' && `Thêm tiêu chí con [${currentMainId}]`}
              {modalMode === 'edit_main' && `Sửa Danh mục chính [${currentMainId}]`}
              {modalMode === 'edit_sub' && `Sửa Tiêu chí [${currentSubId}]`}
            </Modal.Title>
            <button type="button" className="btn-close btn-close-white ms-auto shadow-none" onClick={() => setShowModal(false)}></button>
          </div>
        </Modal.Header>

        <Modal.Body className="bg-light p-4">
          <Form>
            {/* Chỉ hiện input ID khi THÊM Danh mục lớn (main) */}
            {!modalMode.includes('edit') && modalMode === 'add_main' && (
              <Form.Group className="mb-4">
                <Form.Label className="fw-bold text-dark small text-uppercase mb-1">Mã định danh duy nhất (ID)</Form.Label>
                <Form.Control 
                  type="text" 
                  placeholder="Ví dụ: I, II, III, IV..."
                  value={formId} 
                  onChange={(e) => setFormId(e.target.value.toUpperCase())}
                  className="shadow-sm border-0 py-2 fw-bold text-primary bg-white"
                />
                <Form.Text className="text-muted" style={{ fontSize: '0.75rem' }}>* ID viết hoa, không được trùng lặp.</Form.Text>
              </Form.Group>
            )}

            <Form.Group className="mb-4">
              <Form.Label className="fw-bold text-dark small text-uppercase mb-1">
                Nội dung / Tên hiển thị
              </Form.Label>
              <Form.Control 
                as="textarea" 
                rows={3} 
                placeholder="Nhập nội dung tiêu chí đánh giá..."
                value={formName} 
                onChange={(e) => setFormName(e.target.value)}
                className="shadow-sm border-0 py-2 bg-white"
              />
            </Form.Group>

            <div className="row g-3">
              <Col md={modalMode.includes('sub') ? 6 : 12}>
                <Form.Group>
                  <Form.Label className="fw-bold text-dark small text-uppercase mb-1">
                    {modalMode.includes('main') ? 'Điểm tối đa (Trần)' : 'Điểm cộng quy định'}
                  </Form.Label>
                  <div className="input-group shadow-sm">
                    <Form.Control 
                      type="number" 
                      min="0"
                      value={formPoints} 
                      onChange={(e) => setFormPoints(e.target.value)}
                      className="border-0 bg-white fw-bold text-center"
                    />
                    <span className="input-group-text bg-white border-0 text-muted fw-bold">Điểm</span>
                  </div>
                </Form.Group>
              </Col>
              
              {modalMode.includes('sub') && (
                <Col md={6}>
                  <Form.Group>
                    <Form.Label className="fw-bold text-dark small text-uppercase mb-1">Đơn vị tính</Form.Label>
                    <Form.Select 
                      value={formUnit} 
                      onChange={(e) => setFormUnit(e.target.value)}
                      className="shadow-sm border-0 py-2 bg-white fw-medium text-dark"
                    >
                      <option value="lần">/ lần</option>
                      <option value="học kỳ">/ học kỳ</option>
                      <option value="đợt">/ đợt</option>
                      <option value="năm học">/ năm học</option>
                    </Form.Select>
                  </Form.Group>
                </Col>
              )}
            </div>
          </Form>
        </Modal.Body>
        
        <Modal.Footer className="bg-white border-top-0 pt-0 p-4">
          <Button variant="light" onClick={() => setShowModal(false)} className="fw-bold text-secondary border px-4 rounded-3 shadow-sm">
            Hủy bỏ
          </Button>
          <Button 
            className="fw-bold text-white px-4 rounded-3 shadow border-0" 
            style={{ background: 'linear-gradient(90deg, #2563eb, #4f46e5)' }}
            onClick={handleSave}
          >
            <i className="bi bi-check-circle-fill me-2"></i> Xác nhận Lưu
          </Button>
        </Modal.Footer>
      </Modal>

      {/* ================= TÙY CHỈNH CSS (NỘI BỘ) ================= */}
      <style type="text/css">
        {`
          /* Nút bấm nổi khối (Hover Lift) */
          .btn-hover-lift {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
          }
          .btn-hover-lift:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(15, 23, 42, 0.3) !important;
          }

          /* Nút hành động Icon */
          .btn-icon-hover {
            width: 34px; height: 34px;
            display: inline-flex; align-items: center; justify-content: center;
            border-radius: 8px;
            transition: all 0.2s ease;
          }
          .btn-icon-hover:hover {
            background-color: #f1f5f9 !important;
            transform: translateY(-1px);
          }

          /* Bảng danh mục */
          .custom-category-table th {
            letter-spacing: 0.5px;
            border-bottom: 2px solid #e2e8f0;
          }
          .custom-category-table td {
            vertical-align: middle;
            border-color: #f1f5f9;
          }

          /* Dòng Danh mục lớn */
          .main-category-row {
            background-color: #f8fafc;
            border-bottom: 1px solid #e2e8f0;
          }
          .main-category-row:hover {
            background-color: #f1f5f9;
          }

          /* Dòng Tiêu chí con */
          .sub-category-row {
            transition: background-color 0.2s ease;
          }
          .sub-category-row:hover {
            background-color: #fcfdfd;
          }
          .sub-category-row:hover .action-buttons-sub {
            opacity: 1 !important; /* Hiện nút xóa/sửa khi hover */
          }
          .transition-opacity {
            transition: opacity 0.2s ease;
          }
          
          /* Đường kẻ ngăn cách nhóm */
          .border-bottom-thick {
            border-bottom: 3px solid #e2e8f0 !important;
          }

          /* Reset Form Focus */
          .form-control:focus, .form-select:focus {
            box-shadow: 0 0 0 0.25rem rgba(79, 70, 229, 0.1) !important;
          }
        `}
      </style>
    </>
  );
};

export default CategoryManagement;