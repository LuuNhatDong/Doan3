import React, { useState, useEffect } from 'react';
import { Row, Col, Card, Button, Table, Badge, Spinner, Form } from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';
import * as XLSX from 'xlsx';

const Dashboard = () => {
  const navigate = useNavigate();

  // --- STATES LƯU DỮ LIỆU TỪ DATABASE ---
  const [stats, setStats] = useState({ activeEvents: 0, totalAttendees: 0, attendanceTrend: '' });
  const [events, setEvents] = useState([]);
  const [allPendingProofs, setAllPendingProofs] = useState([]); 
  const [allActivities, setAllActivities] = useState([]);
  const [loading, setLoading] = useState(true);

  // --- STATES CHO BẢNG XẾP HẠNG THI ĐUA ---
  const [leaderboard, setLeaderboard] = useState([]);
  const [leaderboardFilter, setLeaderboardFilter] = useState('week');
  const [leaderboardLoading, setLeaderboardLoading] = useState(false);

  // --- STATES CHO BỘ LỌC VÀ MODALS (HỒ SƠ THỦ CÔNG) ---
  const [selectedEventFilter, setSelectedEventFilter] = useState('');

  // --- GỌI API TỪ CƠ SỞ DỮ LIỆU ---
  const loadData = (showLoading = true) => {
    if (showLoading) setLoading(true);
    const fetchJson = async (url) => {
      const res = await fetch(url);
      if (!res.ok) throw new Error('Request failed');
      return await res.json();
    };

    Promise.all([
      fetchJson('https://doan3-ooha.onrender.com/api/dashboard/stats').catch(() => ({ activeEvents: 0, totalAttendees: 0, attendanceTrend: '' })),
      fetchJson('https://doan3-ooha.onrender.com/api/dashboard/activities').catch(() => []),
      fetchJson('https://doan3-ooha.onrender.com/api/dashboard/pending-proofs').catch(() => []),
      fetchJson('https://doan3-ooha.onrender.com/api/events').catch(() => [])
    ])
    .then(([statsData, activitiesData, proofsData, eventsData]) => {
      setStats(statsData || { activeEvents: 0, totalAttendees: 0, attendanceTrend: '' });
      setAllActivities(Array.isArray(activitiesData) ? activitiesData : []);
      setAllPendingProofs(Array.isArray(proofsData) ? proofsData : []);
      setEvents(Array.isArray(eventsData) ? eventsData : []);
      if (showLoading) setLoading(false);
    })
    .catch(error => {
      console.error("Lỗi khi lấy dữ liệu tổng quan:", error);
      if (showLoading) setLoading(false);
    });
  };

  // --- GỌI API BẢNG XẾP HẠNG ---
  const fetchLeaderboard = async (filterType) => {
    setLeaderboardLoading(true);
    try {
      const res = await fetch(`https://doan3-ooha.onrender.com/api/admin/leaderboard?filter=${filterType}`);
      if (res.ok) {
        const data = await res.json();
        if (data.status === 'success') {
          setLeaderboard(data.leaderboard || []);
        }
      }
    } catch (err) {
      console.error("Lỗi fetch dữ liệu thi đua:", err);
    } finally {
      setLeaderboardLoading(false);
    }
  };

  useEffect(() => {
    loadData(true);
    const interval = setInterval(() => loadData(false), 15000); // Auto refresh 15s
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    fetchLeaderboard(leaderboardFilter);
  }, [leaderboardFilter]);

  // --- XỬ LÝ DỮ LIỆU HỒ SƠ CHỜ DUYỆT ---
  const pendingProofs = Array.isArray(allPendingProofs) ? allPendingProofs : [];
  const flaggedProofs = pendingProofs.filter(proof => proof?.phash_warning === 1);
  const safeProofsCount = pendingProofs.length - flaggedProofs.length;
  const displayProofs = selectedEventFilter 
    ? flaggedProofs.filter(proof => proof?.event_name === selectedEventFilter)
    : flaggedProofs;

  const handleAutoApproveSafe = () => {
    if (safeProofsCount === 0) return;
    if (window.confirm(`Hệ thống sẽ phê duyệt tự động ${safeProofsCount} minh chứng an toàn. Bạn đồng ý chứ?`)) {
      setAllPendingProofs(flaggedProofs); 
      alert(`Đã phê duyệt xong ${safeProofsCount} hồ sơ hợp lệ!`);
    }
  };

  const getInitials = (name) => name ? (name.split(' ')[0][0] + (name.split(' ').pop()?.[0] || '')).toUpperCase() : 'SV';
  const getAvatarColor = (name) => ['#4e73df', '#1cc88a', '#36b9cc', '#f6c23e', '#e74a3b'][(name?.charCodeAt(0) || 0) % 5];

// ================= TÍNH NĂNG XUẤT EXCEL =================
  const handleExportExcel = () => {
    const statsData = [
      ['BÁO CÁO THI ĐUA VÀ TỔNG QUAN HỆ THỐNG'],
      ['Thời gian xuất:', new Date().toLocaleString('vi-VN')],
      [''],
      ['1. THỐNG KÊ HOẠT ĐỘNG', ''],
      ['Sự kiện đang diễn ra:', stats.activeEvents],
      ['Tổng lượt điểm danh:', stats.totalAttendees],
      [''],
      ['2. BẢNG XẾP HẠNG THI ĐUA SINH VIÊN', `Bộ lọc: ${leaderboardFilter === 'week' ? 'Trong Tuần' : leaderboardFilter === 'month' ? 'Trong Tháng' : 'Học Kỳ'}`],
    ];

    const wsStats = XLSX.utils.aoa_to_sheet(statsData);
    wsStats['!cols'] = [{ wch: 40 }, { wch: 25 }]; 

    // Đã xóa cột TỔNG ĐIỂM
    const headers = ['HẠNG', 'MSSV', 'HỌ VÀ TÊN', 'SỐ HOẠT ĐỘNG'];
    const rows = leaderboard.map((p, index) => [
      index + 1, 
      p.mssv, 
      p.name || 'Sinh viên', 
      p.total_activities
    ]);

    const wsDetails = XLSX.utils.aoa_to_sheet([headers, ...rows]);
    wsDetails['!cols'] = [{ wch: 10 }, { wch: 15 }, { wch: 35 }, { wch: 20 }]; // Đã giảm số cột config

    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, wsStats, "Tổng quan Thống kê");
    XLSX.utils.book_append_sheet(wb, wsDetails, "Bảng Xếp Hạng");

    XLSX.writeFile(wb, `Bao_Cao_Thi_Dua_${new Date().getTime()}.xlsx`);
  };

  // --- TIỆN ÍCH RENDER HUY CHƯƠNG CHO TOP 3 ---
  const renderRankBadge = (index) => {
    if (index === 0) return <div className="medal-badge gold-medal shadow-sm"><i className="bi bi-trophy-fill me-1"></i> TOP 1</div>;
    if (index === 1) return <div className="medal-badge silver-medal shadow-sm">TOP 2</div>;
    if (index === 2) return <div className="medal-badge bronze-medal shadow-sm">TOP 3</div>;
    return <div className="medal-badge normal-rank text-muted">#{index + 1}</div>;
  };

  return (
    <div className="p-4 dashboard-container" style={{ backgroundColor: '#f4f7fe', minHeight: '100vh' }}>
      
      {/* HEADER SECTION */}
      <div className="d-flex justify-content-between align-items-end mb-4 pb-2 border-bottom border-light">
        <div>
          <h2 className="fw-extrabold text-dark mb-1 d-flex align-items-center gap-2" style={{ letterSpacing: '-0.5px' }}>
            <span className="bg-primary bg-gradient text-white rounded p-2 d-flex align-items-center justify-content-center shadow-sm" style={{width: '40px', height: '40px'}}><i className="bi bi-grid-1x2-fill fs-5"></i></span>
            Tổng quan Hệ thống
          </h2>
          <p className="text-muted mb-0 fw-medium ms-5 ps-2">Báo cáo số liệu và Bảng xếp hạng thi đua thời gian thực.</p>
        </div>
        <div>
          <Button 
            variant="white" 
            className="shadow-sm border-0 fw-bold px-4 py-2 text-primary d-flex align-items-center gap-2 hover-elevate bg-white"
            style={{ borderRadius: '12px', fontSize: '0.9rem' }}
            onClick={handleExportExcel}
          >
            <i className="bi bi-file-earmark-excel-fill fs-5 text-success"></i> Xuất Báo Cáo
          </Button>
        </div>
      </div>

      {/* ================= THẺ THỐNG KÊ (KPI CARDS) ================= */}
      <Row className="mb-4 g-4">
        <Col md={4}>
          <Card className="border-0 shadow-sm kpi-card overflow-hidden" style={{ borderRadius: '16px', background: 'linear-gradient(135deg, #ffffff 0%, #f8faff 100%)' }}>
            <div className="card-accent bg-primary"></div>
            <Card.Body className="d-flex justify-content-between align-items-center p-4">
              <div>
                <p className="text-primary fw-bold text-uppercase mb-1 small" style={{ letterSpacing: '1px', fontSize: '0.75rem' }}>Sự kiện đang mở</p>
                <h2 className="fw-black text-dark mb-0 display-6">{loading ? <Spinner animation="grow" size="sm" variant="primary" /> : stats.activeEvents}</h2>
              </div>
              <div className="icon-box bg-primary bg-opacity-10 text-primary">
                <i className="bi bi-calendar2-event-fill fs-3"></i>
              </div>
            </Card.Body>
          </Card>
        </Col>

        <Col md={4}>
          <Card className="border-0 shadow-sm kpi-card overflow-hidden" style={{ borderRadius: '16px', background: 'linear-gradient(135deg, #ffffff 0%, #f6fdf9 100%)' }}>
            <div className="card-accent bg-success"></div>
            <Card.Body className="d-flex justify-content-between align-items-center p-4">
              <div>
                <p className="text-success fw-bold text-uppercase mb-1 small" style={{ letterSpacing: '1px', fontSize: '0.75rem' }}>Lượt Điểm Danh</p>
                <h2 className="fw-black text-dark mb-0 display-6">{loading ? <Spinner animation="grow" size="sm" variant="success" /> : (stats.totalAttendees?.toLocaleString() || 0)}</h2>
              </div>
              <div className="icon-box bg-success bg-opacity-10 text-success">
                <i className="bi bi-people-fill fs-3"></i>
              </div>
            </Card.Body>
          </Card>
        </Col>

        <Col md={4}>
          <Card className="border-0 shadow-sm kpi-card overflow-hidden" style={{ borderRadius: '16px', background: 'linear-gradient(135deg, #ffffff 0%, #fffaf5 100%)' }}>
            <div className="card-accent bg-warning"></div>
            <Card.Body className="d-flex justify-content-between align-items-center p-4">
              <div>
                <p className="text-warning fw-bold text-uppercase mb-1 small" style={{ letterSpacing: '1px', fontSize: '0.75rem' }}>Minh Chứng Chờ Duyệt</p>
                <h2 className="fw-black text-dark mb-0 display-6">{loading ? <Spinner animation="grow" size="sm" variant="warning" /> : allPendingProofs.length}</h2>
              </div>
              <div className="icon-box bg-warning bg-opacity-10 text-warning">
                <i className="bi bi-shield-exclamation fs-3"></i>
              </div>
            </Card.Body>
          </Card>
        </Col>
      </Row>

      {/* ================= BẢNG XẾP HẠNG & HOẠT ĐỘNG GẦN ĐÂY ================= */}
      <Row className="mb-4 g-4">
        
        {/* KHÔNG GIAN BẢNG XẾP HẠNG THI ĐUA */}
        <Col lg={8}>
          <Card className="border-0 shadow-sm h-100" style={{ borderRadius: '16px' }}>
            <Card.Header className="bg-white border-0 p-4 pb-0 d-flex justify-content-between align-items-center">
              <div>
                <h5 className="m-0 fw-extrabold text-dark d-flex align-items-center gap-2">
                  <i className="bi bi-trophy-fill text-warning"></i>
                  Bảng Xếp Hạng Thi Đua
                </h5>
                <small className="text-muted fw-medium">Top sinh viên tích cực tham gia hoạt động nhất</small>
              </div>
              
              {/* BỘ LỌC THỜI GIAN */}
              <div className="custom-select-wrapper shadow-sm" style={{ background: '#f8fafc', borderRadius: '10px', padding: '4px 12px' }}>
                <Form.Select 
                  size="sm" 
                  className="border-0 fw-bold text-primary bg-transparent shadow-none cursor-pointer pe-4" 
                  value={leaderboardFilter} 
                  onChange={(e) => setLeaderboardFilter(e.target.value)}
                >
                  <option value="week">Trong Tuần</option>
                  <option value="month">Trong Tháng</option>
                  <option value="semester">Học Kỳ (3 Tháng)</option>
                </Form.Select>
              </div>
            </Card.Header>

<Card.Body className="p-0 mt-3" style={{ overflowY: 'auto', maxHeight: '315px' }}>
              <Table hover className="align-middle mb-0 custom-leaderboard-table border-top border-light">
                <thead style={{ backgroundColor: '#f8fafc', color: '#64748b', fontSize: '0.75rem', letterSpacing: '0.5px' }} className="fw-bold text-uppercase position-sticky top-0 shadow-sm">
                  <tr>
                    <th className="py-3 px-4 border-0 text-center" style={{ width: '90px' }}>Hạng</th>
                    <th className="py-3 border-0">Thông tin Sinh viên</th>
                    <th className="py-3 border-0 text-center">Số Hoạt Động</th>
                    {/* Đã xóa cột Tổng điểm ở đây */}
                  </tr>
                </thead>
                <tbody className="border-0">
                  {leaderboardLoading ? (
                    <tr>
                      <td colSpan="3" className="text-center py-5">
                        <Spinner animation="grow" variant="warning" size="sm" className="me-2"/>
                        <span className="fw-bold text-muted">Đang cập nhật xếp hạng...</span>
                      </td>
                    </tr>
                  ) : leaderboard.length === 0 ? (
                    <tr>
                      <td colSpan="3" className="text-center py-5 text-muted fw-medium">
                        Chưa có sinh viên nào có hoạt động được duyệt trong thời gian này.
                      </td>
                    </tr>
                  ) : (
                    leaderboard.slice(0, 6).map((student, index) => {
                      const isTop3 = index < 3;
                      const shortName = student.name ? student.name.split(' ').pop()[0] : 'S';
                      return (
                        <tr key={student.mssv} className={`leaderboard-row ${isTop3 ? 'bg-light bg-opacity-25' : ''}`}>
                          <td className="px-4 py-3 text-center">
                            {renderRankBadge(index)}
                          </td>
                          <td className="py-3">
                            <div className="d-flex align-items-center gap-3">
                              <div className={`avatar-circle fw-bold shadow-sm ${isTop3 ? 'bg-primary text-white' : 'bg-secondary bg-opacity-10 text-secondary'}`}>
                                {shortName}
                              </div>
                              <div>
                                <div className={`fw-bold mb-0 ${isTop3 ? 'text-dark fs-6' : 'text-secondary'}`}>
                                  {student.name || 'Sinh viên'}
                                </div>
                                <div className="text-muted style-code small bg-white border d-inline-block px-2 py-0.5 rounded mt-1">
                                  {student.mssv}
                                </div>
                              </div>
                            </div>
                          </td>
                          <td className="py-3 text-center">
                            <Badge bg="info" className="bg-opacity-10 text-info px-3 py-2 rounded-pill fw-bold border border-info border-opacity-25">
                              {student.total_activities} sự kiện
                            </Badge>
                          </td>
                          {/* Đã xóa thẻ <td> hiển thị ĐRL ở đây */}
                        </tr>
                      );
                    })
                  )}
                </tbody>
              </Table>
            </Card.Body>
          </Card>
        </Col>

        {/* LỊCH SỬ HOẠT ĐỘNG BÊN PHẢI */}
        <Col lg={4}>
          <Card className="border-0 shadow-sm h-100" style={{ borderRadius: '16px' }}>
            <Card.Header className="bg-white border-0 p-4 pb-0 d-flex justify-content-between align-items-center">
              <h5 className="m-0 fw-bold text-dark">Lịch sử Hoạt động</h5>
              <Button variant="link" className="text-decoration-none text-primary fw-bold p-0 small" onClick={() => navigate('/admin/events')}>Xem tất cả</Button>
            </Card.Header>
            <Card.Body className="px-4 py-3" style={{ maxHeight: '315px', overflowY: 'auto' }}>
              {allActivities.length === 0 && !loading ? (
                <div className="text-muted text-center py-5 small fw-medium">Chưa có hoạt động tạo hoặc cập nhật sự kiện gần đây.</div>
              ) : (
                <div className="activity-timeline mt-2">
                  {allActivities.map((activity, idx) => (
                    <div 
                      key={activity.id || idx} 
                      className="timeline-item d-flex align-items-start mb-3 cursor-pointer"
                      onClick={() => navigate(`/admin/events?id=${activity.id}`)} 
                    >
                      <div className="timeline-icon bg-light text-primary rounded-circle d-flex align-items-center justify-content-center shadow-sm" style={{ width: '40px', height: '40px', zIndex: 2 }}>
                        <i className="bi bi-check2-circle fs-5"></i>
                      </div>
                      <div className="timeline-content ms-3 pb-3 border-bottom border-light w-100 hover-bg-light p-2 rounded transition-all">
                        <div className="d-flex justify-content-between align-items-center mb-1">
                          <p className="mb-0 text-dark fw-bold text-truncate" style={{ fontSize: '0.85rem', maxWidth: '160px' }}>{activity.message}</p>
                          <Badge bg={activity.status === 'Đang diễn ra' ? 'success' : 'warning'} className={`px-2 py-1 ${activity.status === 'Đang diễn ra' ? 'text-white' : 'text-dark'}`} style={{ fontSize: '0.65rem' }}>
                            {activity.status}
                          </Badge>
                        </div>
                        <small className="text-muted d-block mb-1 fw-medium" style={{ fontSize: '0.75rem' }}>{activity.subMessage}</small>
                        <span className="text-secondary fw-bold" style={{ fontSize: '0.65rem' }}><i className="bi bi-clock-history me-1"></i>{activity.time}</span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </Card.Body>
          </Card>
        </Col>
      </Row>

      {/* ================= BẢNG HỒ SƠ CẦN KIỂM TRA THỦ CÔNG (ĐÃ ĐƯỢC KHÔI PHỤC) ================= */}
      <Card className="border-0 shadow-sm" style={{ borderRadius: '16px', overflow: 'hidden' }}>
        <Card.Header className="bg-white py-3 px-4 border-0 d-flex flex-wrap justify-content-between align-items-center gap-3">
          <div className="d-flex align-items-center flex-wrap gap-3">
            <h5 className="m-0 fw-extrabold text-dark">
              Hồ sơ cần kiểm tra thủ công
            </h5>
            <div className="custom-select-wrapper shadow-sm ms-2" style={{ background: '#f8fafc', borderRadius: '10px', padding: '4px 12px' }}>
              <Form.Select 
                size="sm" 
                className="border-0 fw-medium bg-transparent shadow-none" 
                style={{ width: '220px', fontSize: '0.85rem' }}
                value={selectedEventFilter} 
                onChange={(e) => setSelectedEventFilter(e.target.value)}
              >
                <option value="">Tất cả sự kiện hệ thống</option>
                {events.map((evt, idx) => (<option key={evt.id || idx} value={evt.name}>{evt.name}</option>))}
              </Form.Select>
            </div>
          </div>
          <div>

          </div>
        </Card.Header>
        
        <Table responsive hover className="align-middle mb-0 custom-dashboard-table">
          <thead style={{ backgroundColor: '#f8fafc', color: '#64748b', fontSize: '0.75rem', letterSpacing: '0.5px' }} className="fw-bold text-uppercase border-bottom">
            <tr>
              <th className="py-3 px-4 border-0">Sinh viên nộp</th>
              <th className="py-3 border-0">Tên sự kiện / Chiến dịch</th>
              <th className="py-3 border-0">Thời gian</th>
              <th className="py-3 border-0">Trạng thái AI</th>
              <th className="py-3 text-center border-0">Hành động</th>
            </tr>
          </thead>
          <tbody style={{ fontSize: '0.85rem' }} className="border-0">
            {loading ? (
              <tr><td colSpan="5" className="text-center py-5 text-muted"><Spinner animation="border" variant="primary" size="sm" className="me-2"/>Đang liên kết dữ liệu hệ thống...</td></tr>
            ) : displayProofs.length === 0 ? (
              <tr>
                <td colSpan="5" className="text-center py-5 text-muted fw-medium">
                  <div className="opacity-75 mb-2"><i className="bi bi-patch-check-fill text-success" style={{fontSize: '2rem'}}></i></div>
                  Tuyệt vời! Không phát hiện hồ sơ nào có dấu hiệu trùng lặp gian lận.
                </td>
              </tr>
            ) : (
              displayProofs.map((proof) => {
                const avatarBg = getAvatarColor(proof.full_name);
                return (
                  <tr key={proof.id} style={{ transition: 'all 0.2s' }}>
                    <td className="px-4 py-3">
                      <div className="d-flex align-items-center">
                        <div 
                          className="avatar-circle text-white fw-bold me-3 shadow-sm" 
                          style={{ backgroundColor: avatarBg }}
                        >
                          {getInitials(proof.full_name)}
                        </div>
                        <div>
                          <span className="fw-bold text-dark d-block mb-0" style={{fontSize: '0.9rem'}}>{proof.full_name}</span>
                          <small className="text-muted style-code mt-1 d-inline-block">{proof.id}</small>
                        </div>
                      </div>
                    </td>
                    <td className="py-3 fw-medium text-secondary">{proof.event_name}</td>
                    <td className="text-muted py-3 fw-medium">
                      <i className="bi bi-clock me-1"></i>
                      {new Date(proof.created_at).toLocaleString('vi-VN')}
                    </td>
                    <td className="py-3">
                      <Badge 
                        bg="none" 
                        className="text-danger border border-danger border-opacity-50 px-2 py-1.5 d-inline-flex align-items-center gap-1" 
                        style={{ fontSize: '0.7rem', backgroundColor: '#fff5f5', borderRadius: '6px' }}
                      >
                        <span className="spinner-grow spinner-grow-sm text-danger" role="status" style={{ width: '6px', height: '6px' }}></span>
                        CẢNH BÁO: {proof.ai_note?.toUpperCase() || 'PHASH TRÙNG LẶP'}
                      </Badge>
                    </td>
                    <td className="py-3 text-center">
                      <Button 
                        variant="primary" 
                        size="sm"
                        className="px-3 py-1.5 border-0 shadow-sm fw-bold hover-elevate" 
                        style={{ fontSize: '0.75rem', borderRadius: '8px', backgroundColor: '#4f46e5' }}
                        onClick={() => navigate('/admin/evidence')}
                      >
                        Đối soát thủ công
                      </Button>
                    </td>
                  </tr>
                )
              })
            )}
          </tbody>
        </Table>
      </Card>

      {/* ================= CSS NÂNG CAO ================= */}
      <style>{`
        /* Tổng quan */
        .fw-black { font-weight: 900; }
        .fw-extrabold { font-weight: 800; }
        .hover-elevate { transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); }
        .hover-elevate:hover { transform: translateY(-3px); box-shadow: 0 10px 20px rgba(0,0,0,0.08) !important; }
        
        /* KPI Cards */
        .kpi-card { position: relative; transition: all 0.3s ease; }
        .kpi-card:hover { transform: translateY(-5px); box-shadow: 0 15px 30px rgba(0,0,0,0.05) !important; }
        .card-accent { position: absolute; left: 0; top: 0; bottom: 0; width: 5px; }
        .icon-box { width: 60px; height: 60px; border-radius: 16px; display: flex; align-items: center; justify-content: center; }

        /* Custom Select Wrapper */
        .custom-select-wrapper { background: #fff; border-radius: 8px; padding: 4px 12px; border: 1px solid #e2e8f0; }

        /* Timeline Activities */
        .activity-timeline { position: relative; }
        .activity-timeline::before { content: ''; position: absolute; left: 20px; top: 0; bottom: 0; width: 2px; background: #e2e8f0; z-index: 1; }
        .hover-bg-light:hover { background-color: #f8fafc; padding-left: 15px !important; }

        /* Leaderboard & Data Tables */
        .custom-leaderboard-table th, .custom-dashboard-table th { font-weight: 700; border-bottom: 2px solid #e2e8f0 !important; }
        .leaderboard-row, .custom-dashboard-table tbody tr { transition: all 0.2s ease; cursor: default; }
        .leaderboard-row:hover { background-color: #f1f5f9 !important; transform: translateX(2px); }
        .custom-dashboard-table tbody tr:hover { background-color: #f8fafc !important; }
        
        .avatar-circle { width: 38px; height: 38px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1rem; }
        .style-code { font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace; letter-spacing: 0.5px; }

        /* Medals */
        .medal-badge { padding: 6px 12px; border-radius: 8px; font-weight: 900; display: inline-block; font-size: 0.85rem; letter-spacing: 1px; }
        .gold-medal { background: linear-gradient(135deg, #ffd700 0%, #f7b733 100%); color: #fff; box-shadow: 0 4px 10px rgba(247, 183, 51, 0.4) !important; border: 1px solid #e5c100; }
        .silver-medal { background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #475569; box-shadow: 0 4px 10px rgba(203, 213, 225, 0.4) !important; border: 1px solid #cbd5e1; }
        .bronze-medal { background: linear-gradient(135deg, #fbc2eb 0%, #a18cd1 100%); color: #fff; box-shadow: 0 4px 10px rgba(161, 140, 209, 0.4) !important; border: 1px solid #d4a5d4; }
        .normal-rank { background: #f1f5f9; padding: 6px 16px; font-size: 0.9rem; }
        .text-gradient-gold { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
      `}</style>
    </div>
  );
};

export default Dashboard;
