import React, { useEffect, useMemo, useState } from 'react';
import { Badge, Button, Card, Col, Row, Spinner } from 'react-bootstrap';
import { useNavigate, useParams } from 'react-router-dom';
import axios from 'axios';

// SỬA LOGIC: Phân chia mốc tháng học kỳ chuẩn xác theo năm học Đại học
const getAcademicTerm = (value) => {
  if (!value) {
    return { key: 'unknown', label: 'Chưa xác định' };
  }

  const date = new Date(value);
  // Nếu chuỗi truyền vào không thể parse thành Date hợp lệ
  if (Number.isNaN(date.getTime())) {
    return { key: 'unknown', label: 'Chưa xác định' };
  }

  const year = date.getFullYear();
  const month = date.getMonth() + 1;

  // Học kỳ 1: Thường từ tháng 9 đến tháng 12
  if (month >= 9 && month <= 12) {
    return { key: `${year}-${year + 1}-1`, label: `Học kỳ 1 (${year}-${year + 1})` };
  }

  // Học kỳ 2: Thường từ tháng 1 đến tháng 5 (Sửa lỗi bỏ sót tháng 4, tháng 5)
  if (month >= 1 && month <= 5) {
    return { key: `${year - 1}-${year}-2`, label: `Học kỳ 2 (${year - 1}-${year})` };
  }

  // Học kỳ hè: Thường từ tháng 6 đến tháng 8
  return { key: `${year}-${year + 1}-he`, label: `Học kỳ hè (${year}-${year + 1})` };
};

const StudentActivityHistory = () => {
  const { studentId } = useParams();
  const navigate = useNavigate();
  const [student, setStudent] = useState(null);
  const [activities, setActivities] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const [studentRes, activitiesRes] = await Promise.all([
          axios.get(`https://doan3-ooha.onrender.com/api/users/${studentId}`),
          axios.get(`https://doan3-ooha.onrender.com/api/users/${studentId}/activities`),
        ]);
        setStudent(studentRes.data || null);
        setActivities(Array.isArray(activitiesRes.data) ? activitiesRes.data : []);
      } catch (error) {
        console.error('Lỗi khi tải lịch sử hoạt động sinh viên:', error);
        setStudent(null);
        setActivities([]);
      } finally {
        setLoading(false);
      }
    };

    if (studentId) {
      fetchData();
    }
  }, [studentId]);

  const groupedActivities = useMemo(() => {
    const groups = {};
    activities.forEach((activity) => {
      // SỬA LOGIC: Ưu tiên dùng event_date gốc từ CSDL để định dạng học kỳ chính xác nhất, tránh lỗi chuỗi Tiếng Việt của checkin_time
      const dateForTerm = activity.event_date || activity.created_at;
      const term = getAcademicTerm(dateForTerm);
      
      if (!groups[term.key]) {
        groups[term.key] = {
          key: term.key,
          label: term.label,
          items: [],
        };
      }
      groups[term.key].items.push(activity);
    });

    return Object.values(groups).sort((a, b) => b.key.localeCompare(a.key));
  }, [activities]);

  return (
    <div className="d-flex flex-column gap-3">
      <div className="d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
          <div className="text-uppercase text-muted small fw-bold">Danh bạ sinh viên</div>
          <h4 className="fw-bold mb-1">Lịch sử tham gia hoạt động</h4>
          <p className="text-primary fw-semibold mb-0">
            {student ? `${student.full_name} (${student.mssv})` : 'Đang tải thông tin sinh viên...'}
          </p>
        </div>
        <Button variant="outline-secondary" className="rounded-3 fw-medium" onClick={() => navigate('/admin/users')}>
          <i className="bi bi-arrow-left me-2"></i>Quay về
        </Button>
      </div>

      {loading ? (
        <Card className="border-0 shadow-sm rounded-4">
          <Card.Body className="text-center py-5 text-muted">
            <Spinner animation="border" size="sm" className="me-2" variant="primary" />
            Đang liên kết dữ liệu lịch sử hoạt động...
          </Card.Body>
        </Card>
      ) : groupedActivities.length === 0 ? (
        <Card className="border-0 shadow-sm rounded-4">
          <Card.Body className="py-5 text-center text-muted fw-medium">
            <i className="bi bi-inbox fs-2 d-block mb-2 opacity-50"></i>
            Sinh viên chưa có hoạt động nào được phê duyệt trong hệ thống.
          </Card.Body>
        </Card>
      ) : (
        groupedActivities.map((group) => (
          <Card key={group.key} className="border-0 shadow-sm rounded-4 overflow-hidden">
            <Card.Header className="bg-light bg-opacity-50 border-0 py-3 px-4">
              <div className="d-flex justify-content-between align-items-center flex-wrap gap-2">
                <h6 className="fw-bold mb-0 text-dark"><i className="bi bi-bookmark-star-fill text-warning me-2"></i>{group.label}</h6>
                <Badge bg="primary" className="bg-opacity-10 text-primary px-3 py-2 rounded-pill fw-bold border border-primary border-opacity-25">
                  {group.items.length} hoạt động đã duyệt
                </Badge>
              </div>
            </Card.Header>
            <Card.Body className="p-4">
              <Row className="g-3">
                {group.items.map((activity, index) => (
                  <Col md={6} key={`${activity.event_id || activity.id || index}-${index}`}>
                    <div className="border rounded-4 p-3 h-100 bg-white shadow-none hover-shadow transition-all">
                      <div className="d-flex justify-content-between align-items-start gap-2 mb-2">
                        <div>
                          <div className="fw-bold text-dark fs-6">{activity.event_name || 'Hoạt động chưa có tên'}</div>
                          <div className="text-muted small mt-0.5"><i className="bi bi-tag-fill me-1"></i>{activity.category || 'Chưa phân loại'}</div>
                        </div>
                        <Badge bg="success" className="bg-opacity-10 text-success px-2 py-1.5 rounded border border-success border-opacity-25 fw-semibold">Đã duyệt</Badge>
                      </div>
                      <hr className="my-2 opacity-50" />
                      <div className="text-secondary small mb-2 fw-medium">
                        <i className="bi bi-calendar-event text-primary me-2"></i>
                        Ngày diễn ra: {activity.event_date ? new Date(activity.event_date).toLocaleDateString('vi-VN') : 'Chưa có thời gian sự kiện'}
                      </div>
                      <div className="text-secondary small mb-2 fw-medium">
                        <i className="bi bi-clock-history text-success me-2"></i>
                        Ghi nhận lúc: {activity.checkin_time || 'Chưa cập nhật'}
                      </div>
                      <div className="text-muted small bg-light p-2 rounded-3 mt-2 border border-light">
                        <i className="bi bi-info-circle me-1.5 text-secondary"></i>
                        {activity.event_description || 'Không có mô tả chi tiết từ ban tổ chức.'}
                      </div>
                    </div>
                  </Col>
                ))}
              </Row>
            </Card.Body>
          </Card>
        ))
      )}
    </div>
  );
};

export default StudentActivityHistory;
