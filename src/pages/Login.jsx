import React, { useState } from 'react';
import { Row, Col, Card, Form, Button, InputGroup, Alert, Spinner } from 'react-bootstrap';
import { GoogleLogin } from '@react-oauth/google';
import InfoCarousel from './InfoCarousel';
import { isStudentLoginValue, normalizeStudentLogin } from '../utils/loginUtils';

const Login = ({ onLoginSuccess }) => {
  // States cho luồng Đăng nhập
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  // Hiển thị thông báo thành công/lỗi thay cho alert()
  const [message, setMessage] = useState({ type: '', text: '' }); 

  const clearMessage = () => { if (message.text) setMessage({ type: '', text: '' }); };

  // =================================================================
  // 1. XỬ LÝ ĐĂNG NHẬP TRUYỀN THỐNG
  // =================================================================
  const handleNormalLogin = async (e) => {
    e.preventDefault();
    if (!username || !password) {
      setMessage({ type: 'warning', text: 'Vui lòng nhập đầy đủ tài khoản và mật khẩu!' });
      return;
    }
    if (!isStudentLoginValue(username)) {
      setMessage({ type: 'warning', text: 'Vui lòng nhập MSSV (VD: httt2311017) hoặc email hợp lệ!' });
      return;
    }
    
    setIsLoading(true);
    setMessage({ type: '', text: '' });

    try {
      const response = await fetch('https://doan3-ooha.onrender.com/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username: normalizeStudentLogin(username), password })
      });
      const data = await response.json();
      
      if (response.ok && data.token) {
        const role = data.user?.role?.toLowerCase();
        const allowedRoles = ['admin', 'teacher', 'classcommittee'];
        
        if (role === 'student') {
          setMessage({ type: 'danger', text: 'Tài khoản sinh viên không được phép đăng nhập vào Web Quản trị. Vui lòng dùng ứng dụng di động.' });
        } else if (data.user && allowedRoles.includes(role)) {
          localStorage.setItem('token', data.token);
          localStorage.setItem('user', JSON.stringify(data.user));
          onLoginSuccess(data.user);
        } else {
          setMessage({ type: 'danger', text: 'Từ chối truy cập: Tài khoản không có quyền quản trị.' });
        }
      } else {
        setMessage({ type: 'danger', text: data.message || data.error || 'Sai thông tin đăng nhập' });
      }
    } catch (err) {
      setMessage({ type: 'danger', text: 'Lỗi kết nối máy chủ! Vui lòng kiểm tra lại đường truyền.' });
      console.error("Login Error:", err);
    } finally {
      setIsLoading(false);
    }
  };

  // =================================================================
  // 2. XỬ LÝ ĐĂNG NHẬP GOOGLE
  // =================================================================
  const handleGoogleSuccess = (credentialResponse) => {
    const credential = credentialResponse?.credential || '';
    if (!credential) {
      setMessage({ type: 'warning', text: 'Đăng nhập Google chưa trả về thông tin xác thực.' });
      return;
    }

    const parseEmailFromCredential = (credentialValue) => {
      try {
        const payload = JSON.parse(atob(credentialValue.split('.')[1]));
        return payload.email || '';
      } catch {
        return '';
      }
    };

    const email = parseEmailFromCredential(credential);
    if (!isStudentLoginValue(email)) {
      setMessage({ type: 'warning', text: 'Vui lòng dùng tài khoản Google có email hợp lệ.' });
      return;
    }

    fetch('https://doan3-ooha.onrender.com/api/auth/google', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ credential })
    })
    .then(res => res.json())
    .then(data => {
      if (data.token) {
        const role = data.user?.role?.toLowerCase();
        const allowedRoles = ['admin', 'teacher', 'classcommittee'];
        if (role === 'student') {
          setMessage({ type: 'danger', text: 'Tài khoản sinh viên không được phép đăng nhập Web Quản trị.' });
        } else if (data.user && allowedRoles.includes(role)) {
          localStorage.setItem('token', data.token);
          localStorage.setItem('user', JSON.stringify(data.user));
          onLoginSuccess(data.user);
        } else {
          setMessage({ type: 'danger', text: 'Tài khoản Google này không có quyền quản trị.' });
        }
      } else {
        setMessage({ type: 'danger', text: 'Đăng nhập thất bại: ' + data.error });
      }
    })
    .catch(err => {
      setMessage({ type: 'danger', text: 'Lỗi kết nối máy chủ Google auth. Vui lòng dùng đăng nhập thường.' });
      console.error("Google Login Error:", err);
    });
  };

  return (
    <Row className="vh-100 m-0 overflow-hidden bg-light">
      {/* Component Carousel thông tin bên trái giữ nguyên */}
      <InfoCarousel /> 

      <Col lg={7} xs={12} className="d-flex flex-column justify-content-center align-items-center position-relative auth-bg-pattern">
        
        {/* Lớp thẻ Form (Glassmorphism Card) */}
        <Card className="border-0 shadow-lg rounded-4 glass-card fade-in-up" style={{ width: '100%', maxWidth: '440px', zIndex: 1 }}>
          <Card.Body className="p-4 p-md-5">
            
            {/* Hiển thị thông báo (Inline Alert) */}
            {message.text && (
              <Alert variant={message.type} className="small py-2 mb-4 fw-medium border-0 shadow-sm d-flex align-items-center fade-in">
                <i className={`bi ${message.type === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill'} me-2 fs-6`}></i>
                {message.text}
              </Alert>
            )}

            <div className="fade-in">
              <h3 className="fw-bold mb-1 text-dark" style={{ letterSpacing: '-0.5px' }}>Đăng nhập Quản trị</h3>
              <p className="text-muted small mb-4">Nhập tài khoản Cán bộ Đoàn / Admin để tiếp tục</p>

              <Form onSubmit={handleNormalLogin}>
                <Form.Group className="mb-3">
                  <Form.Label className="fw-bold small text-secondary">Tài khoản hoặc Email</Form.Label>
                  <InputGroup className="shadow-sm rounded-3 overflow-hidden">
                    <InputGroup.Text className="bg-white text-primary border-end-0 px-3">
                      <i className="bi bi-person-badge"></i>
                    </InputGroup.Text>
                    <Form.Control 
                      type="text" 
                      placeholder="VD: httt2311017@student..." 
                      className="border-start-0 bg-white py-2 custom-input"
                      value={username}
                      onChange={(e) => { setUsername(e.target.value); clearMessage(); }}
                      required
                    />
                  </InputGroup>
                </Form.Group>

                <Form.Group className="mb-4">
                  <Form.Label className="fw-bold small text-secondary">Mật khẩu</Form.Label>
                  <InputGroup className="shadow-sm rounded-3 overflow-hidden">
                    <InputGroup.Text className="bg-white text-primary border-end-0 px-3">
                      <i className="bi bi-shield-lock"></i>
                    </InputGroup.Text>
                    <Form.Control 
                      type={showPassword ? "text" : "password"} 
                      placeholder="••••••••" 
                      className="border-start-0 border-end-0 bg-white py-2 custom-input"
                      value={password}
                      onChange={(e) => { setPassword(e.target.value); clearMessage(); }}
                      required
                    />
                    <InputGroup.Text 
                      className="bg-white text-muted border-start-0 cursor-pointer px-3 hover-text-primary"
                      onClick={() => setShowPassword(!showPassword)}
                    >
                      <i className={showPassword ? "bi bi-eye-slash" : "bi bi-eye"}></i>
                    </InputGroup.Text>
                  </InputGroup>
                </Form.Group>

                <Button 
                  type="submit" 
                  disabled={isLoading}
                  className="w-100 fw-bold py-2.5 mb-4 shadow-sm btn-login-glow" 
                >
                  {isLoading ? <Spinner animation="border" size="sm" /> : 'Đăng nhập hệ thống'}
                </Button>
              </Form>

              <div className="position-relative d-flex align-items-center justify-content-center mb-4">
                <div className="border-bottom w-100 position-absolute" style={{ zIndex: 1 }}></div>
                <span className="px-3 text-muted small fw-bold bg-white position-relative" style={{ zIndex: 2 }}>HOẶC</span>
              </div>

              <div className="d-flex justify-content-center google-btn-wrapper shadow-sm rounded-3">
                <GoogleLogin
                  onSuccess={handleGoogleSuccess}
                  onError={() => setMessage({ type: 'danger', text: 'Dịch vụ Google Login đang gián đoạn.' })}
                  useOneTap={false}
                  theme="outline"
                  size="large"
                  text="signin_with"
                  shape="rectangular"
                />
              </div>
            </div>
          </Card.Body>
        </Card>

        {/* CHÂN TRANG */}
        <div className="position-absolute bottom-0 w-100 p-4 d-flex flex-column flex-md-row justify-content-between align-items-center text-muted gap-2" style={{ fontSize: '0.75rem', zIndex: 0 }}>
          <span className="fw-medium">© 2026 CTUT Hệ thống Điểm rèn luyện.</span>
          <div className="d-flex gap-4 fw-bold">
            <a href="#privacy" className="text-muted text-decoration-none hover-text-dark transition-all">Quyền riêng tư</a>
            <a href="#terms" className="text-muted text-decoration-none hover-text-dark transition-all">Điều khoản sử dụng</a>
          </div>
        </div>
      </Col>

      {/* ================= STYLES NỘI BỘ ================= */}
      <style type="text/css">
        {`
          .auth-bg-pattern {
            background-color: #f8fafc;
            background-image: radial-gradient(#e2e8f0 1px, transparent 1px);
            background-size: 20px 20px;
          }
          .glass-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.5);
          }
          .custom-input {
            border: 1px solid #e2e8f0;
            transition: all 0.2s ease;
          }
          .custom-input:focus {
            box-shadow: none;
            border-color: #3b82f6;
          }
          .cursor-pointer { cursor: pointer; }
          .transition-all { transition: all 0.2s ease; }
          .hover-text-primary:hover { color: #2563eb !important; }
          .hover-text-dark:hover { color: #0f172a !important; }

          .btn-login-glow {
            background: linear-gradient(90deg, #1e3a8a, #3b82f6);
            border: none;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
          }
          .btn-login-glow:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(37, 99, 235, 0.4) !important;
          }

          .google-btn-wrapper iframe { margin: 0 auto !important; }

          .fade-in { animation: fadeIn 0.3s ease-out forwards; }
          .fade-in-up { animation: fadeInUp 0.5s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
          
          @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
          }
          @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
          }
        `}
      </style>
    </Row>
  );
};

export default Login;
