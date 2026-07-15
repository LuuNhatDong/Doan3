import React, { useState } from 'react';
import { Col, Carousel } from 'react-bootstrap';

const InfoCarousel = () => {
  const posterData = [
    {
      title: "Cổng thông tin\nĐiểm Rèn Luyện",
      description: "Bảng điều khiển thống nhất giúp bạn theo dõi, quản lý và xác thực điểm rèn luyện của sinh viên. Tối ưu, bảo mật và minh bạch tuyệt đối.",
      icon: "bi-bar-chart-fill",
    },
    {
      title: "Cập nhật nhanh chóng,\nMinh bạch dữ liệu",
      description: "Hệ thống lưu trữ dữ liệu thời gian thực, giúp cán bộ dễ dàng theo dõi tiến độ tham gia các hoạt động ngoại khóa.",
      icon: "bi-shield-check",
    },
    {
      title: "Đơn giản hóa quy trình\nHành chính",
      description: "Thay thế hoàn toàn giấy tờ truyền thống. Mọi thao tác nộp minh chứng, chấm điểm và xét duyệt đều được thực hiện trực tuyến.",
      icon: "bi-lightning-fill",
    },
    {
      title: "Hệ thống Báo cáo\nThông minh",
      description: "Tự động tổng hợp dữ liệu, trích xuất báo cáo thống kê chi tiết cho từng cá nhân, chi đoàn và tập thể Khoa.",
      icon: "bi-graph-up-arrow",
    }
  ];

  const [activeIndex, setActiveIndex] = useState(0);

  return (
    <Col lg={5} className="d-none d-lg-flex flex-column p-5 text-white h-100 position-relative info-carousel-bg">
      
      {/* Các khối họa tiết trôi nổi trang trí nền */}
      <div className="floating-shape shape-1"></div>
      <div className="floating-shape shape-2"></div>

      {/* HEADER CĂN GIỮA */}
      <div className="d-flex flex-column align-items-center text-center mb-5 w-100 z-index-1">
        <div className="d-flex align-items-center mb-1">
          <div className="bg-white bg-opacity-25 p-2 rounded-3 me-3 backdrop-blur shadow-sm">
            <i className="bi bi-mortarboard-fill fs-4 text-white"></i>
          </div>
          <h4 className="fw-bold mb-0 text-uppercase" style={{ letterSpacing: '1px' }}>CTUT E-Point</h4>
        </div>
        <small className="text-white-50 mt-2 fw-semibold" style={{ fontSize: '0.75rem', letterSpacing: '2px' }}>TRƯỜNG ĐẠI HỌC KỸ THUẬT - CÔNG NGHỆ CẦN THƠ</small>
      </div>

      {/* CAROUSEL CHÍNH */}
      <Carousel 
        controls={false} 
        indicators={false} 
        interval={4000} 
        fade 
        activeIndex={activeIndex}
        onSelect={(idx) => setActiveIndex(idx)}
        className="flex-grow-1 d-flex flex-column z-index-1"
      >
        {posterData.map((item, index) => (
          <Carousel.Item key={index} className="flex-column text-center h-100 w-100">
            <h1 className="fw-bold mb-4" style={{ fontSize: '2.4rem', lineHeight: '1.4', whiteSpace: 'pre-line', textShadow: '0 4px 10px rgba(0,0,0,0.3)' }}>
              {item.title}
            </h1>
            
            <p className="text-white opacity-75 mb-5 text-center mx-auto fw-medium" style={{ fontSize: '1.05rem', lineHeight: '1.6', maxWidth: '85%' }}>
              {item.description}
            </p>
            
            <div className="w-100 d-flex justify-content-center mt-auto mb-5">
              <div className="bg-white bg-opacity-10 rounded-4 d-flex flex-column justify-content-center align-items-center p-4 shadow backdrop-blur border border-white border-opacity-25 hover-lift-icon" style={{ width: '75%', minHeight: '180px' }}>
                <div className="bg-white rounded-circle p-3 mb-4 shadow-lg d-flex align-items-center justify-content-center" style={{ width: '70px', height: '70px' }}>
                  <i className={`bi ${item.icon}`} style={{ fontSize: '2rem', color: '#0f172a' }}></i>
                </div>
                <div className="d-flex gap-2">
                  <div className={`rounded-pill ${index % 2 === 0 ? 'bg-white' : 'bg-white bg-opacity-25'}`} style={{ width: '12px', height: '4px' }}></div>
                  <div className={`rounded-pill ${index % 2 !== 0 ? 'bg-white' : 'bg-white bg-opacity-25'}`} style={{ width: '12px', height: '4px' }}></div>
                </div>
              </div>
            </div>
          </Carousel.Item>
        ))}
      </Carousel>

      {/* CHÂN TRANG ĐIỀU HƯỚNG */}
      <div className="d-flex justify-content-center gap-2 mt-auto pb-4 w-100 z-index-1">
        {[...Array(posterData.length)].map((_, i) => (
          <div
            key={i}
            className={`rounded-pill transition-all ${i === activeIndex ? 'bg-white shadow' : 'bg-white bg-opacity-25'}`}
            style={{ width: i === activeIndex ? '24px' : '8px', height: '6px', cursor: 'pointer' }}
            onClick={() => setActiveIndex(i)}
          />
        ))}
      </div>

      <style type="text/css">
        {`
          .info-carousel-bg {
            background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%);
            overflow: hidden;
          }
          .z-index-1 { z-index: 1; }
          .backdrop-blur { backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); }
          .transition-all { transition: all 0.3s ease-in-out; }
          .hover-lift-icon { transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); }
          .hover-lift-icon:hover { transform: translateY(-10px); }
          
          /* Họa tiết trôi nổi */
          .floating-shape {
            position: absolute;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 50%;
            filter: blur(60px);
            z-index: 0;
            animation: float 10s infinite ease-in-out alternate;
          }
          .shape-1 { width: 400px; height: 400px; top: -100px; left: -100px; animation-delay: 0s; }
          .shape-2 { width: 300px; height: 300px; bottom: 50px; right: -50px; background: rgba(56, 189, 248, 0.1); animation-delay: -5s; }
          
          @keyframes float {
            0% { transform: translateY(0) scale(1); }
            100% { transform: translateY(30px) scale(1.1); }
          }
        `}
      </style>
    </Col>
  );
};

export default InfoCarousel;