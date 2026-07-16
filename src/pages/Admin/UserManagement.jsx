import React, { useState, useEffect, useRef } from 'react';
import { Row, Col, Card, Table, Button, Badge, Pagination, Modal, Form, Spinner, Toast, ToastContainer } from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import * as XLSX from 'xlsx';

const UserManagement = ({ searchQuery }) => {
  // 1. State cho Danh bạ sinh viên
  const [students, setStudents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedStudent, setSelectedStudent] = useState(null);
  const [detailModalVisible, setDetailModalVisible] = useState(false);
  const [actionLoading, setActionLoading] = useState(false);
  const [studentActivities, setStudentActivities] = useState([]);
  const [activitiesLoading, setActivitiesLoading] = useState(false);

  // 2. State cho Thống kê, Phân trang & Lọc
  const [currentUser, setCurrentUser] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [filterFaculty, setFilterFaculty] = useState('all');
  const [filterCohort, setFilterCohort] = useState('all');
  
  // 3. State cho Thông báo Toast
  const [toast, setToast] = useState({ show: false, message: '', type: 'success' });
  
  const navigate = useNavigate();
  const fileInputRef = useRef(null);

  // =========================================================
  // HÀM BỔ TRỢ & API
  // =========================================================
  const showToast = (message, type = 'success') => {
    setToast({ show: true, message, type });
    setTimeout(() => setToast(prev => ({ ...prev, show: false })), 3000);
  };

  const getAvatarUrl = (avatar, fullName) => {
    if (!avatar) return `https://ui-avatars.com/api/?name=${encodeURIComponent(fullName)}&background=random`;
    if (avatar.startsWith('http')) return avatar;
    if (avatar.startsWith('/')) return `https://doan3-ooha.onrender.com${avatar}`;
    return `https://doan3-ooha.onrender.com/${avatar}`;
  };

  const getModalAvatarUrl = (avatar, fullName) => {
    if (!avatar) return `https://ui-avatars.com/api/?name=${encodeURIComponent(fullName)}&background=c7d2fe&color=3730a3&size=100&rounded=false&bold=true`;
    if (avatar.startsWith('http')) return avatar;
    if (avatar.startsWith('/')) return `https://doan3-ooha.onrender.com${avatar}`;
    return `https://doan3-ooha.onrender.com/${avatar}`;
  };

  const getCohortFromMssv = (mssv) => {
    if (!mssv) return '';
    const match = String(mssv).toUpperCase().match(/^[A-Z]{4}(\d{2})\d{5}$/);
    return match ? `20${match[1]}` : '';
  };

  const handleAvatarChange = async (event) => {
    const file = event.target.files[0];
    if (!file || !selectedStudent) return;

    const formData = new FormData();
    formData.append('id', selectedStudent.id);
    formData.append('avatar', file);

    try {
      const response = await axios.put('https://doan3-ooha.onrender.com/api/profile', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      if (response.data.user) {
        const newAvatar = response.data.user.avatar;
        updateStudentInState(selectedStudent.id, { avatar: newAvatar });
        setSelectedStudent(prev => ({ ...prev, avatar: newAvatar }));
        if (fileInputRef.current) fileInputRef.current.value = '';
        showToast('Cập nhật ảnh đại diện thành công!', 'success');
      }
    } catch (error) {
      console.error('Lỗi cập nhật ảnh đại diện:', error);
      showToast('Không thể cập nhật ảnh đại diện lúc này.', 'danger');
    }
  };

  const handleExportExcel = () => {
    if (filteredStudents.length === 0) {
      showToast("Không có dữ liệu sinh viên để xuất!", "warning");
      return;
    }

    const exportData = filteredStudents.map((s, index) => ({
      'STT': index + 1,
      'MSSV': s.mssv,
      'Họ và tên': s.full_name,
      'Email': s.email || '',
      'Số điện thoại': s.phone || s.sdt || '',
      'Ngành': s.faculty || '',
      'Chi đoàn': s.chi_doan || '',
      'Vai trò': s.role === 'admin' ? 'Quản trị viên' : s.role === 'classCommittee' ? 'Cán bộ lớp' : 'Sinh viên',
      'Trạng thái': s.is_locked === 1 || s.status === 'locked' ? 'Đã khóa' : 'Hoạt động',
      'Điểm rèn luyện': s.point_wallet || 0
    }));

    const worksheet = XLSX.utils.json_to_sheet(exportData);
    worksheet['!cols'] = [{ wch: 5 }, { wch: 15 }, { wch: 25 }, { wch: 30 }, { wch: 15 }, { wch: 25 }, { wch: 15 }, { wch: 15 }, { wch: 15 }, { wch: 15 }];
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, "DanhSachSinhVien");
    XLSX.writeFile(workbook, `DanhSachSinhVien_${new Date().getTime()}.xlsx`);
    showToast("Xuất file Excel thành công!", "success");
  };

  // BAN ĐẦU LOAD DỮ LIỆU CÓ THÊM LOGIC KIỂM TRA PHÂN QUYỀN CÁN BỘ LỚP
  useEffect(() => {
    const fetchData = async () => {
      try {
        const storedUser = window.localStorage.getItem('user');
        let activeUser = null;
        if (storedUser) {
          try { 
            activeUser = JSON.parse(storedUser);
            setCurrentUser(activeUser); 
          } catch (parseErr) { 
            console.warn('Lỗi phân tích thông tin user đăng nhập', parseErr); 
          }
        }

        const usersRes = await axios.get('https://doan3-ooha.onrender.com/api/users');
        let fetchedData = usersRes.data;

        // BỘ LỌC GIỚI HẠN QUYỀN: Nếu đăng nhập là cán bộ lớp, chỉ giữ lại SV cùng Ngành và cùng Khóa
        if (activeUser && activeUser.role === 'classCommittee') {
          const committeeCohort = getCohortFromMssv(activeUser.mssv);
          fetchedData = fetchedData.filter(student => 
            student.faculty === activeUser.faculty && 
            getCohortFromMssv(student.mssv) === committeeCohort
          );
        }

        setStudents(fetchedData);
      } catch (error) {
        console.error("Lỗi khi tải dữ liệu:", error);
        showToast("Lỗi kết nối đến máy chủ!", "danger");
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  const getStatusBadge = (points) => {
    const pt = points || 0;
    if (pt >= 80) return <Badge bg="success" className="bg-opacity-10 text-success border border-success px-2 py-1">TỐT</Badge>;
    if (pt >= 50) return <Badge bg="info" className="bg-opacity-10 text-info border border-info px-2 py-1">KHÁ</Badge>;
    return <Badge bg="danger" className="bg-opacity-10 text-danger border border-danger px-2 py-1">CẢNH BÁO</Badge>;
  };

  const faculties = Array.from(new Set(students.map((s) => s.faculty || 'Chưa cập nhật'))).filter(Boolean);
  const cohorts = Array.from(new Set(students.map((s) => getCohortFromMssv(s.mssv)).filter(Boolean)));

  const filteredStudents = students.filter((student) => {
    const facultyName = student.faculty || 'Chưa cập nhật';
    const cohortName = getCohortFromMssv(student.mssv) || 'Chưa cập nhật';
    const facultyMatches = filterFaculty === 'all' || facultyName === filterFaculty;
    const cohortMatches = filterCohort === 'all' || cohortName === filterCohort;

    let searchMatches = true;
    if (searchQuery) {
      const query = searchQuery.toLowerCase().replace(/\s+/g, '');
      const name = (student.full_name || '').toLowerCase().replace(/\s+/g, '');
      const mssv = (student.mssv || '').toLowerCase();
      searchMatches = name.includes(query) || mssv.includes(query);
    }
    return facultyMatches && cohortMatches && searchMatches;
  });

  const totalStudents = students.length;
  const lockedCount = students.filter((s) => s.is_locked === 1 || s.status === 'locked').length;
  const classCommitteeCount = students.filter((s) => s.role === 'classCommittee').length;
  const activeCount = totalStudents - lockedCount;

  const totalPages = Math.max(1, Math.ceil(filteredStudents.length / pageSize));
  const paginatedStudents = filteredStudents.slice((currentPage - 1) * pageSize, currentPage * pageSize);
  const pageStart = filteredStudents.length > 0 ? (currentPage - 1) * pageSize + 1 : 0;
  const pageEnd = Math.min(currentPage * pageSize, filteredStudents.length);

  useEffect(() => { if (currentPage > totalPages) setCurrentPage(totalPages); }, [currentPage, totalPages]);
  useEffect(() => { setCurrentPage(1); }, [filterFaculty, filterCohort, searchQuery]);

  const fetchStudentDetails = async (studentId, fallbackStudent = null) => {
    try {
      const response = await axios.get(`https://doan3-ooha.onrender.com/api/users/${studentId}`);
      setSelectedStudent({ ...(fallbackStudent || {}), ...(response.data || {}) });
    } catch (error) { console.error('Lỗi lấy chi tiết SV từ CSDL:', error); }
  };

  const fetchStudentActivities = async (studentId) => {
    setActivitiesLoading(true);
    try {
      const response = await axios.get(`https://doan3-ooha.onrender.com/api/users/${studentId}/activities`);
      setStudentActivities(response.data || []);
    } catch (error) { setStudentActivities([]); } 
    finally { setActivitiesLoading(false); }
  };

  const openStudentDetails = (student) => {
    setSelectedStudent(student);
    setDetailModalVisible(true);
    fetchStudentDetails(student.id, student);
    fetchStudentActivities(student.id);
  };

  const closeStudentDetails = () => {
    setDetailModalVisible(false);
    setSelectedStudent(null);
    setStudentActivities([]);
  };

  const updateStudentInState = (id, updates) => {
    setStudents((prev) => prev.map((s) => (s.id === id ? { ...s, ...updates } : s)));
  };

  const handleToggleLock = async (student) => {
    const locked = student.is_locked === 1 || student.status === 'locked';
    const action = locked ? 'unlock' : 'lock';
    setActionLoading(true);
    try {
      const response = await axios.patch(`https://doan3-ooha.onrender.com/api/users/${student.id}`, { action });
      if (response.data.success) {
        const updatedFields = {
          is_locked: response.data.is_locked ?? (action === 'lock' ? 1 : 0),
          status: response.data.status ?? (action === 'lock' ? 'locked' : 'active')
        };
        updateStudentInState(student.id, updatedFields);
        if (selectedStudent?.id === student.id) setSelectedStudent(prev => ({ ...prev, ...updatedFields }));
        showToast(`Đã ${action === 'lock' ? 'khóa' : 'mở khóa'} tài khoản thành công!`, 'success');
      }
    } catch (error) { showToast('Lỗi khi thay đổi trạng thái khóa!', 'danger'); } 
    finally { setActionLoading(false); }
  };

  const handleChangeRole = async (student, targetRole) => {
    setActionLoading(true);
    try {
      const response = await axios.patch(`https://doan3-ooha.onrender.com/api/users/${student.id}`, {
        action: 'grant_permission', targetRole, currentUserRole: currentUser?.role, currentUserId: currentUser?.id
      });
      if (response.data.success) {
        updateStudentInState(student.id, { role: response.data.role });
        if (selectedStudent?.id === student.id) setSelectedStudent(prev => ({ ...prev, role: response.data.role }));
        showToast('Đã thay đổi quyền tài khoản thành công!', 'success');
      }
    } catch (error) { showToast('Bạn không có quyền thực hiện hành động này!', 'danger'); } 
    finally { setActionLoading(false); }
  };

  const canGrantClassCommittee = currentUser?.role === 'admin' || currentUser?.role === 'superadmin';
  const canRevokeClassCommittee = currentUser && ['admin', 'superadmin', 'classCommittee', 'teacher'].includes(currentUser.role);
  const isSelectedSelf = selectedStudent?.id === currentUser?.id;

  return (
    <>
      {/* ================= HEADER & XUẤT DỮ LIỆU ================= */}
      <div className="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
        <div className="d-flex align-items-center gap-3">
          <div className="bg-primary bg-opacity-10 p-3 rounded-circle d-flex align-items-center justify-content-center shadow-sm" style={{ width: '54px', height: '54px' }}>
            <i className="bi bi-people-fill text-primary fs-3"></i>
          </div>
          <div>
            <h6 className="text-primary text-uppercase fw-bold mb-1" style={{ letterSpacing: '1px', fontSize: '0.75rem' }}>Danh bạ & Phân quyền</h6>
            <h3 className="fw-bold mb-0 text-dark">
              {currentUser?.role === 'classCommittee' ? 'Quản lý Lớp học / Chi đoàn' : 'Quản lý Sinh viên'}
            </h3>
          </div>
        </div>
        <Button 
          className="btn-hover-lift fw-bold px-4 py-2 shadow-sm d-flex align-items-center gap-2" 
          style={{ background: 'linear-gradient(90deg, #10b981, #059669)', border: 'none', borderRadius: '10px' }}
          onClick={handleExportExcel}
        >
          <i className="bi bi-file-earmark-excel-fill fs-5"></i> Xuất Excel
        </Button>
      </div>

      {/* ================= THỐNG KÊ KPI ================= */}
      <Row className="g-3 mb-4">
        <Col md={3} sm={6} xs={12}>
          <Card className="border-0 shadow-sm h-100 rounded-4 overflow-hidden" style={{ background: 'linear-gradient(135deg, #eff6ff, #dbeafe)' }}>
            <Card.Body className="p-4 d-flex align-items-center">
              <div className="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-3 shadow-sm" style={{ width: '48px', height: '48px' }}><i className="bi bi-person-lines-fill fs-4"></i></div>
              <div>
                <div className="text-uppercase text-primary fw-bold small mb-1">Thành viên lớp</div>
                <div className="h3 mb-0 fw-bold text-dark">{totalStudents}</div>
              </div>
            </Card.Body>
          </Card>
        </Col>
        <Col md={3} sm={6} xs={12}>
          <Card className="border-0 shadow-sm h-100 rounded-4 overflow-hidden" style={{ background: 'linear-gradient(135deg, #f0fdf4, #dcfce7)' }}>
            <Card.Body className="p-4 d-flex align-items-center">
              <div className="bg-success text-white rounded-circle d-flex align-items-center justify-content-center me-3 shadow-sm" style={{ width: '48px', height: '48px' }}><i className="bi bi-person-check-fill fs-4"></i></div>
              <div>
                <div className="text-uppercase text-success fw-bold small mb-1">Đang hoạt động</div>
                <div className="h3 mb-0 fw-bold text-dark">{activeCount}</div>
              </div>
            </Card.Body>
          </Card>
        </Col>
        <Col md={3} sm={6} xs={12}>
          <Card className="border-0 shadow-sm h-100 rounded-4 overflow-hidden" style={{ background: 'linear-gradient(135deg, #fef2f2, #fee2e2)' }}>
            <Card.Body className="p-4 d-flex align-items-center">
              <div className="bg-danger text-white rounded-circle d-flex align-items-center justify-content-center me-3 shadow-sm" style={{ width: '48px', height: '48px' }}><i className="bi bi-person-x-fill fs-4"></i></div>
              <div>
                <div className="text-uppercase text-danger fw-bold small mb-1">Bị khóa</div>
                <div className="h3 mb-0 fw-bold text-dark">{lockedCount}</div>
              </div>
            </Card.Body>
          </Card>
        </Col>
        <Col md={3} sm={6} xs={12}>
          <Card className="border-0 shadow-sm h-100 rounded-4 overflow-hidden" style={{ background: 'linear-gradient(135deg, #fffbeb, #fef3c7)' }}>
            <Card.Body className="p-4 d-flex align-items-center">
              <div className="bg-warning text-white rounded-circle d-flex align-items-center justify-content-center me-3 shadow-sm" style={{ width: '48px', height: '48px' }}><i className="bi bi-person-badge-fill fs-4"></i></div>
              <div>
                <div className="text-uppercase text-warning fw-bold small mb-1" style={{ color: '#d97706' }}>Ban cán sự</div>
                <div className="h3 mb-0 fw-bold text-dark">{classCommitteeCount}</div>
              </div>
            </Card.Body>
          </Card>
        </Col>
      </Row>

      {/* ================= BẢNG DANH BẠ ================= */}
      <Card className="border-0 shadow-lg rounded-4 overflow-hidden bg-white mb-4">
        <div style={{ height: '4px', background: 'linear-gradient(90deg, #4f46e5, #0ea5e9, #10b981)' }}></div>
        <Card.Body className="p-0">
          <div className="p-3 border-bottom d-flex justify-content-between align-items-center flex-wrap gap-3 bg-light bg-opacity-50">
            <h6 className="fw-bold mb-0 text-dark text-uppercase"><i className="bi bi-list-ul me-2 text-primary"></i>Danh sách Chi tiết</h6>
            <div className="d-flex gap-2 flex-wrap align-items-center">
              <Form.Select size="sm" value={filterFaculty} onChange={(e) => setFilterFaculty(e.target.value)} className="shadow-none border-secondary border-opacity-25 rounded-3 fw-medium text-dark" disabled={currentUser?.role === 'classCommittee'}>
                <option value="all">Tất cả ngành</option>
                {faculties.map((f) => <option key={f} value={f}>{f}</option>)}
              </Form.Select>
              <Form.Select size="sm" value={filterCohort} onChange={(e) => setFilterCohort(e.target.value)} className="shadow-none border-secondary border-opacity-25 rounded-3 fw-medium text-dark" disabled={currentUser?.role === 'classCommittee'}>
                <option value="all">Tất cả khóa</option>
                {cohorts.map((c) => <option key={c} value={c}>{c}</option>)}
              </Form.Select>
            </div>
          </div>

          <Table responsive hover className="align-middle mb-0 custom-hover-table">
            <thead style={{ backgroundColor: '#f8fafc' }}>
              <tr>
                <th className="py-3 px-4 text-uppercase text-muted fw-bold fs-7">Họ và Tên</th>
                <th className="py-3 text-uppercase text-muted fw-bold fs-7">MSSV</th>
                <th className="py-3 text-uppercase text-muted fw-bold fs-7">Lớp / Ngành</th>
                <th className="py-3 text-uppercase text-muted fw-bold fs-7">Trạng thái</th>
                <th className="py-3 text-uppercase text-muted fw-bold fs-7">Ví ĐRL</th>
                <th className="py-3 text-uppercase text-muted fw-bold fs-7 text-center">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan="6" className="text-center py-5 text-muted"><Spinner animation="border" size="sm" className="me-2" />Đang tải dữ liệu...</td></tr>
              ) : paginatedStudents.length === 0 ? (
                <tr><td colSpan="6" className="text-center py-5 text-muted">Không tìm thấy sinh viên nào khớp dữ liệu lọc.</td></tr>
              ) : (
                paginatedStudents.map((student) => {
                  const isLocked = student.is_locked === 1 || student.status === 'locked';
                  const isClassCommittee = student.role === 'classCommittee';
                  
                  return (
                    <tr key={student.id} className={isLocked ? 'bg-danger bg-opacity-10' : isClassCommittee ? 'bg-warning bg-opacity-10' : ''}>
                      <td className="px-4 py-3 border-bottom-0">
                        <div className="d-flex align-items-center">
                          <img src={getAvatarUrl(student.avatar, student.full_name)} className="rounded-circle me-3 shadow-sm border border-white border-2" width="42" height="42" alt="avatar" style={{ objectFit: 'cover' }} />
                          <div>
                            <div className="fw-bold text-dark">{student.full_name}</div>
                            <small className="text-muted">{student.email || 'Chưa cập nhật email'}</small>
                          </div>
                        </div>
                      </td>
                      <td className="fw-bold text-secondary border-bottom-0">{student.mssv}</td>
                      <td className="border-bottom-0">
                        <div className="fw-semibold text-dark">{student.chi_doan || 'Chưa xếp lớp'}</div>
                        <small className="text-muted">{student.faculty || 'Chưa cập nhật ngành'}</small>
                      </td>
                      <td className="border-bottom-0">{getStatusBadge(student.point_wallet)}</td>
                      <td className="border-bottom-0">
                        <div className="d-flex align-items-center">
                          <span className={`fw-bold fs-6 ${student.point_wallet > 0 ? "text-primary" : "text-muted"}`}>{student.point_wallet || 0}</span>
                          <i className="bi bi-star-fill text-warning ms-1" style={{ fontSize: '0.7rem' }}></i>
                        </div>
                      </td>
                      <td className="text-center border-bottom-0">
                        <Button variant="light" size="sm" className="text-primary border shadow-sm btn-icon-hover" title="Xem & Quản lý" onClick={() => openStudentDetails(student)}>
                          <i className="bi bi-gear-fill"></i>
                        </Button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </Table>

          {/* Phân trang */}
          <div className="p-3 bg-light border-top d-flex flex-column flex-sm-row justify-content-between align-items-center gap-3">
            <small className="text-muted fw-medium">
              Đang xem <strong className="text-dark">{pageStart} - {pageEnd}</strong> / <strong>{filteredStudents.length}</strong> kết quả
            </small>
            <div className="d-flex align-items-center gap-3 flex-wrap">
              <Form.Select size="sm" style={{ width: '70px' }} value={pageSize} onChange={(e) => { setPageSize(Number(e.target.value)); setCurrentPage(1); }} className="shadow-none rounded-3 border-secondary border-opacity-25">
                <option value={5}>5</option><option value={10}>10</option><option value={20}>20</option>
              </Form.Select>
              <Pagination size="sm" className="mb-0 custom-pagination">
                <Pagination.Prev disabled={currentPage === 1} onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))} />
                {Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
                  <Pagination.Item key={page} active={currentPage === page} onClick={() => setCurrentPage(page)}>{page}</Pagination.Item>
                ))}
                <Pagination.Next disabled={currentPage === totalPages} onClick={() => setCurrentPage((prev) => Math.min(prev + 1, totalPages))} />
              </Pagination>
            </div>
          </div>
        </Card.Body>
      </Card>

      {/* ================= MODAL CHI TIẾT SINH VIÊN (HIỂN THỊ ĐỦ ĐIỂM + LỊCH SỬ) ================= */}
      <Modal show={detailModalVisible} onHide={closeStudentDetails} size="xl" centered backdrop="static" contentClassName="border-0 rounded-4 shadow-lg overflow-hidden">
        <Modal.Header className="text-white border-0 py-3 px-4" style={{ background: 'linear-gradient(135deg, #1e293b, #0f172a)' }}>
          <div className="d-flex align-items-center flex-grow-1">
            <Button variant="link" className="text-white p-0 me-3 opacity-75 hover-opacity-100" onClick={closeStudentDetails}>
              <i className="bi bi-arrow-left fs-4"></i>
            </Button>
            <Modal.Title className="fw-bold fs-5 m-0 d-flex align-items-center gap-2">
              <i className="bi bi-person-vcard text-info"></i> Hồ sơ chi tiết thành viên
            </Modal.Title>
          </div>
          <div className="d-flex gap-2">
            {selectedStudent && currentUser?.role !== 'classCommittee' && (
              <>
                <Button
                  variant={selectedStudent.is_locked === 1 || selectedStudent.status === 'locked' ? 'success' : 'danger'}
                  onClick={() => handleToggleLock(selectedStudent)}
                  disabled={actionLoading}
                  className="fw-bold px-3 shadow-sm border-0 d-flex align-items-center gap-2"
                >
                  {actionLoading ? <Spinner animation="border" size="sm" /> : (selectedStudent.is_locked === 1 || selectedStudent.status === 'locked' ? <><i className="bi bi-unlock-fill"></i> Mở khóa</> : <><i className="bi bi-lock-fill"></i> Khóa tài khoản</>)}
                </Button>
                {selectedStudent.role === 'student' && canGrantClassCommittee && !isSelectedSelf && (
                  <Button variant="warning" onClick={() => handleChangeRole(selectedStudent, 'classCommittee')} disabled={actionLoading} className="fw-bold px-3 shadow-sm border-0 d-flex align-items-center gap-2 text-dark">
                    <i className="bi bi-star-fill"></i> Cấp quyền Cán bộ lớp
                  </Button>
                )}
              </>
            )}
          </div>
        </Modal.Header>

        <Modal.Body className="bg-light p-4">
          {selectedStudent ? (
            <div className="mx-auto" style={{ maxWidth: '1000px' }}>
              
              {/* Banner Cá nhân */}
              <Card className="border-0 shadow-sm mb-4 rounded-4 overflow-hidden">
                <Card.Body className="p-4 d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-4 bg-white">
                  <div className="d-flex align-items-center gap-4">
                    <div className="position-relative d-inline-block">
                      <img src={getModalAvatarUrl(selectedStudent.avatar, selectedStudent.full_name)} alt="avatar" className="rounded-4 shadow-sm border border-2 border-white" style={{ width: '90px', height: '90px', objectFit: 'cover' }} />
                      {currentUser?.role !== 'classCommittee' && (
                        <div className="position-absolute bottom-0 end-0 bg-primary rounded-circle d-flex align-items-center justify-content-center shadow" style={{ width: '32px', height: '32px', cursor: 'pointer', transform: 'translate(25%, 25%)', border: '3px solid white' }} onClick={() => fileInputRef.current?.click()}>
                          <i className="bi bi-camera-fill text-white" style={{ fontSize: '14px' }}></i>
                        </div>
                      )}
                      <input type="file" ref={fileInputRef} className="d-none" accept="image/*" onChange={handleAvatarChange} />
                    </div>
                    <div>
                      <h4 className="fw-bold mb-2 text-dark">{selectedStudent.full_name}</h4>
                      <div className="d-flex gap-2 flex-wrap">
                        <Badge bg="primary" className="bg-opacity-10 text-primary border border-primary border-opacity-25 fw-medium px-2 py-1"><i className="bi bi-person-badge me-1"></i>{selectedStudent.mssv}</Badge>
                        <Badge bg="dark" className="bg-opacity-10 text-dark border border-dark border-opacity-25 fw-medium px-2 py-1"><i className="bi bi-shield-check me-1"></i>Quyền: {selectedStudent.role === 'classCommittee' ? 'Cán bộ lớp' : selectedStudent.role === 'admin' ? 'Quản trị viên' : 'Sinh viên'}</Badge>
                      </div>
                    </div>
                  </div>

                  {/* GIỮ NGUYÊN HIỂN THỊ ĐIỂM RÈN LUYỆN ĐÃ ĐƯỢC LOAD TỪ ĐATABASE */}
                  <div className="d-flex align-items-center gap-4 border-start ps-md-4 pt-3 pt-md-0 border-top border-md-top-0">
                    <div>
                      <div className="text-muted fw-bold small mb-1 text-uppercase" style={{ fontSize: '0.7rem', letterSpacing: '0.5px' }}>Ví Điểm Rèn Luyện</div>
                      <div className="fw-bold text-primary fs-3 d-flex align-items-center gap-1">
                        {selectedStudent.point_wallet || 0} <i className="bi bi-star-fill text-warning fs-5"></i>
                      </div>
                    </div>
                    <div className="border-start ps-4 h-100 d-flex flex-column justify-content-center">
                      <div className="text-muted fw-bold small mb-2 text-uppercase" style={{ fontSize: '0.7rem', letterSpacing: '0.5px' }}>Trạng thái</div>
                      {selectedStudent.is_locked === 1 || selectedStudent.status === 'locked' ? (
                        <Badge bg="danger" className="px-3 py-2 rounded-pill fw-medium shadow-sm"><i className="bi bi-lock-fill me-1"></i>Đã Khóa</Badge>
                      ) : (
                        <Badge bg="success" className="px-3 py-2 rounded-pill fw-medium shadow-sm"><i className="bi bi-check-circle-fill me-1"></i>Hoạt động</Badge>
                      )}
                    </div>
                  </div>
                </Card.Body>
              </Card>

              {/* Thông tin Chi tiết */}
              <Row className="g-4 mb-4">
                <Col md={6}>
                  <Card className="border-0 shadow-sm h-100 rounded-4">
                    <Card.Body className="p-4">
                      <div className="d-flex align-items-center mb-3 pb-3 border-bottom">
                        <div className="bg-primary bg-opacity-10 p-2 rounded-3 me-3 text-primary"><i className="bi bi-person-lines-fill fs-5"></i></div>
                        <h6 className="fw-bold mb-0 text-dark">Thông tin Cá nhân</h6>
                      </div>
                      <Row className="g-4">
                        <Col xs={6}>
                          <div className="text-muted small fw-semibold mb-1 text-uppercase fs-7">Họ và tên</div>
                          <div className="fw-bold text-dark">{selectedStudent.full_name || '-'}</div>
                        </Col>
                        <Col xs={6}>
                          <div className="text-muted small fw-semibold mb-1 text-uppercase fs-7">Mã số sinh viên</div>
                          <div className="fw-bold text-primary">{selectedStudent.mssv || '-'}</div>
                        </Col>
                        <Col xs={12}>
                          <div className="text-muted small fw-semibold mb-1 text-uppercase fs-7">Email Liên hệ</div>
                          <div className="fw-medium text-dark">{selectedStudent.email || '-'}</div>
                        </Col>
                        <Col xs={12}>
                          <div className="text-muted small fw-semibold mb-1 text-uppercase fs-7">Số điện thoại</div>
                          <div className="fw-medium text-dark">{selectedStudent.phone || selectedStudent.sdt || '-'}</div>
                        </Col>
                      </Row>
                    </Card.Body>
                  </Card>
                </Col>

                <Col md={6}>
                  <Card className="border-0 shadow-sm h-100 rounded-4">
                    <Card.Body className="p-4">
                      <div className="d-flex align-items-center mb-3 pb-3 border-bottom">
                        <div className="bg-success bg-opacity-10 p-2 rounded-3 me-3 text-success"><i className="bi bi-mortarboard-fill fs-5"></i></div>
                        <h6 className="fw-bold mb-0 text-dark">Hồ sơ Học tập</h6>
                      </div>
                      <Row className="g-4">
                        <Col xs={12}>
                          <div className="text-muted small fw-semibold mb-1 text-uppercase fs-7">Ngành học</div>
                          <div className="fw-bold text-dark">{selectedStudent.faculty || '-'}</div>
                        </Col>
                        <Col xs={6}>
                          <div className="text-muted small fw-semibold mb-1 text-uppercase fs-7">Chi đoàn / Lớp</div>
                          <div className="fw-medium text-dark">{selectedStudent.chi_doan || '-'}</div>
                        </Col>
                        <Col xs={6}>
                          <div className="text-muted small fw-semibold mb-1 text-uppercase fs-7">Khóa học</div>
                          <div className="fw-medium text-dark">K{getCohortFromMssv(selectedStudent.mssv).slice(-2)}</div>
                        </Col>
                        <Col xs={12}>
                          <div className="text-muted small fw-semibold mb-1 text-uppercase fs-7">Ngày tham gia hệ thống</div>
                          <div className="fw-medium text-secondary">{selectedStudent.created_at ? new Date(selectedStudent.created_at).toLocaleDateString('vi-VN') : 'Đang cập nhật...'}</div>
                        </Col>
                      </Row>
                    </Card.Body>
                  </Card>
                </Col>
              </Row>

              {/* LỊCH SỬ HOẠT ĐỘNG HOÀN THIỆN ĐÃ ĐƯỢC ĐỒNG BỘ FIX LỖI DATABASE */}
              <Card className="border-0 shadow-sm rounded-4">
                <Card.Header className="bg-white border-bottom p-4 d-flex justify-content-between align-items-center rounded-top-4">
                  <div className="d-flex align-items-center">
                    <div className="bg-warning bg-opacity-10 p-2 rounded-3 me-3 text-warning"><i className="bi bi-clock-history fs-5"></i></div>
                    <h6 className="fw-bold mb-0 text-dark">Hoạt động tham gia gần đây</h6>
                  </div>
                  <Button variant="light" size="sm" className="text-primary fw-bold border shadow-sm btn-hover-lift" onClick={() => navigate(`/admin/users/${selectedStudent.id}/activities`)}>
                    Xem tất cả <i className="bi bi-arrow-right ms-1"></i>
                  </Button>
                </Card.Header>
                <Card.Body className="p-0">
                  {activitiesLoading ? (
                    <div className="text-center py-5 text-muted"><Spinner animation="border" className="me-2" />Đang liên kết dữ liệu hoạt động...</div>
                  ) : studentActivities.length === 0 ? (
                    <div className="text-center py-5">
                      <div className="bg-light rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style={{ width: '80px', height: '80px' }}><i className="bi bi-inbox fs-1 text-muted opacity-50"></i></div>
                      <h6 className="fw-bold text-dark">Chưa có dữ liệu lịch sử</h6>
                      <p className="text-muted small mb-0">Sinh viên chưa ghi nhận hoạt động nào trên hệ thống.</p>
                    </div>
                  ) : (
                    <div className="list-group list-group-flush">
                      {studentActivities.slice(0, 4).map((activity, idx) => (
                        <div key={idx} className="list-group-item p-4 d-flex justify-content-between align-items-center bg-transparent border-bottom">
                          <div className="d-flex align-items-center gap-3">
                            <div className="bg-light p-2 rounded text-secondary border"><i className="bi bi-calendar-event"></i></div>
                            <div>
                              <div className="fw-bold text-dark mb-1">{activity.event_name}</div>
                              <div className="text-muted small d-flex align-items-center gap-2">
                                <span><i className="bi bi-clock me-1"></i>{activity.checkin_time}</span>
                                <span className="opacity-50">|</span>
                                <span className="text-primary"><i className="bi bi-tag-fill me-1"></i>{activity.method}</span>
                              </div>
                            </div>
                          </div>
                          <Badge bg="success" className="bg-opacity-10 text-success border border-success px-3 py-2 rounded-pill fw-medium">Ghi nhận</Badge>
                        </div>
                      ))}
                    </div>
                  )}
                </Card.Body>
              </Card>
            </div>
          ) : (
            <div className="text-center py-5 text-muted"><Spinner animation="border" className="me-2" /> Đang tải cấu trúc dữ liệu hồ sơ...</div>
          )}
        </Modal.Body>
      </Modal>

      {/* ================= TOAST THÔNG BÁO ================= */}
      <ToastContainer position="top-end" className="p-4" style={{ zIndex: 9999, position: 'fixed' }}>
        <Toast show={toast.show} bg={toast.type} onClose={() => setToast({ ...toast, show: false })} autohide delay={3000} className="shadow-lg border-0 rounded-3">
          <Toast.Body className="text-white fw-bold d-flex align-items-center p-3">
            <i className={`bi ${toast.type === 'success' ? 'bi-check-circle-fill' : toast.type === 'warning' ? 'bi-exclamation-triangle-fill' : 'bi-x-octagon-fill'} fs-4 me-3`}></i>
            {toast.message}
          </Toast.Body>
        </Toast>
      </ToastContainer>

      {/* ================= CSS CẤU HÌNH GIAO DIỆN ================= */}
      <style>{`
        .fs-7 { font-size: 0.8rem; }
        .btn-hover-lift { transition: transform 0.2s, box-shadow 0.2s; color: white; }
        .btn-hover-lift:hover { transform: translateY(-2px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1) !important; color: white; }
        .custom-hover-table tbody tr { transition: background-color 0.2s ease; }
        .custom-hover-table tbody tr:hover { background-color: #f8fafc !important; }
        .btn-icon-hover { width: 34px; height: 34px; display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; transition: all 0.2s ease; }
        .btn-icon-hover:hover { background-color: #e2e8f0 !important; transform: translateY(-1px); }
        .custom-pagination .page-item .page-link { color: #475569; border: none; margin: 0 2px; border-radius: 6px; font-weight: 500; }
        .custom-pagination .page-item.active .page-link { background-color: #0ea5e9; color: white; box-shadow: 0 4px 6px -1px rgba(14, 165, 233, 0.2); }
      `}</style>
    </>
  );
};

export default UserManagement;