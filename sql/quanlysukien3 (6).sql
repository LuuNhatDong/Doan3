-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 16, 2026 at 10:35 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `quanlysukien3`
--

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `id` int(11) NOT NULL,
  `event_id` varchar(20) DEFAULT NULL,
  `student_id` varchar(20) DEFAULT NULL,
  `checkin_time` datetime DEFAULT NULL,
  `method` varchar(20) DEFAULT NULL,
  `status` enum('checked_in','absent','late') NOT NULL DEFAULT 'checked_in',
  `submitted_file` text DEFAULT NULL,
  `submitted_link` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`id`, `event_id`, `student_id`, `checkin_time`, `method`, `status`, `submitted_file`, `submitted_link`) VALUES
(49, 'EV-8540', '31', '2026-07-02 09:09:59', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(50, 'EV-9330', '31', '2026-07-02 14:56:33', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(51, 'EV-2862', 'HTTT2311033', '2026-07-03 23:50:05', 'Định vị GPS', 'checked_in', NULL, NULL),
(52, 'EV-8933', '54', '2026-07-03 23:55:58', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(53, 'EV-9685', '54', '2026-07-04 00:01:15', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(54, 'EV-2862', '54', '2026-07-04 07:28:59', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(55, 'EV-8042', 'HTTT2311033', '2026-07-04 19:05:01', 'Định vị GPS', 'checked_in', NULL, NULL),
(56, 'EV-3401', 'HTTT2311033', '2026-07-04 19:08:54', 'Định vị GPS', 'checked_in', NULL, NULL),
(57, 'EV-6737', '54', '2026-07-04 19:11:08', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(58, 'EV-4111', '54', '2026-07-04 19:16:44', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(59, 'EV-4111', '54', '2026-07-04 19:16:59', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(60, 'EV-3738', 'HTTT2311033', '2026-07-04 19:25:52', 'Định vị GPS', 'checked_in', NULL, NULL),
(61, 'EV-9455', '54', '2026-07-04 19:26:22', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(62, 'EV-4746', '54', '2026-07-04 19:26:54', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(63, 'EV-4746', '54', '2026-07-04 19:27:20', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(64, 'EV-9723', '54', '2026-07-04 23:36:33', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(65, 'EV-9723', '54', '2026-07-04 23:39:58', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(66, 'EV-9723', '54', '2026-07-04 23:40:27', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(67, 'EV-9723', '54', '2026-07-04 23:41:22', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(68, 'EV-9723', '54', '2026-07-04 23:42:18', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(69, 'EV-9723', '54', '2026-07-05 00:20:12', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(70, 'EV-9723', '54', '2026-07-05 00:25:58', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(71, 'EV-9723', '54', '2026-07-05 00:26:55', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(72, 'EV-9723', '54', '2026-07-05 00:29:52', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(73, 'EV-9723', '54', '2026-07-05 00:30:19', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(74, 'EV-9880', 'HTTT2311033', '2026-07-05 11:51:50', 'Định vị GPS', 'checked_in', NULL, NULL),
(75, 'EV-8563', '54', '2026-07-05 11:53:16', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(76, 'EV-9712', '54', '2026-07-05 12:05:15', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(77, 'EV-9712', '54', '2026-07-05 12:06:52', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(78, 'EV-9712', '54', '2026-07-05 12:08:05', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(79, 'EV-9712', '54', '2026-07-05 12:08:51', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(80, 'EV-9712', '54', '2026-07-05 12:10:28', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(81, 'EV-9712', '54', '2026-07-05 12:13:18', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(82, 'EV-2670', '54', '2026-07-05 12:19:19', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(83, 'EV-2670', '54', '2026-07-05 12:19:44', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(84, 'EV-2670', '54', '2026-07-05 12:19:59', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(85, 'EV-2670', '54', '2026-07-05 12:20:37', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(86, 'EV-2670', '54', '2026-07-05 12:35:02', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(87, 'EV-2670', '54', '2026-07-05 12:53:15', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(88, 'EV-2670', '54', '2026-07-05 12:54:58', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(89, 'EV-2670', '54', '2026-07-05 13:01:14', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(90, 'EV-9712', '54', '2026-07-05 19:30:39', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(91, 'EV-4266', 'HTTT2311033', '2026-07-05 20:31:24', 'Định vị GPS', 'checked_in', NULL, NULL),
(92, 'EV-2384', 'HTTT2311033', '2026-07-05 20:32:15', 'Định vị GPS', 'checked_in', NULL, NULL),
(93, 'EV-4266', 'HTTT2311052', '2026-07-05 20:33:46', 'Định vị GPS', 'checked_in', NULL, NULL),
(94, 'EV-4695', 'HTTT2311052', '2026-07-06 09:00:34', 'Định vị GPS', 'checked_in', NULL, NULL),
(95, 'EV-3827', 'HTTT2311052', '2026-07-06 09:10:10', 'Định vị GPS', 'checked_in', NULL, NULL),
(96, 'EV-3657', 'HTTT2311052', '2026-07-06 09:21:32', 'Định vị GPS', 'checked_in', NULL, NULL),
(97, 'EV-9200', 'HTTT2311052', '2026-07-06 09:33:12', 'Định vị GPS', 'checked_in', NULL, NULL),
(98, 'EV-9111', 'HTTT2311052', '2026-07-06 09:51:39', 'Định vị GPS', 'checked_in', NULL, NULL),
(99, 'EV-9043', 'HTTT2311052', '2026-07-06 10:02:00', 'Quét mã QR', 'checked_in', NULL, NULL),
(100, 'EV-6927', 'HTTT2311052', '2026-07-06 10:51:12', 'Định vị GPS', 'checked_in', NULL, NULL),
(101, 'EV-1789', 'HTTT2311052', '2026-07-06 10:53:24', 'Định vị GPS', 'checked_in', NULL, NULL),
(102, 'EV-1822', 'HTTT2311052', '2026-07-06 11:00:53', 'Định vị GPS', 'checked_in', NULL, NULL),
(103, 'EV-4436', 'HTTT2311052', '2026-07-06 11:12:36', 'Định vị GPS', 'checked_in', NULL, NULL),
(104, 'EV-3685', 'HTTT2311052', '2026-07-06 11:29:23', 'Định vị GPS', 'checked_in', NULL, NULL),
(105, 'EV-3067', 'HTTT2311052', '2026-07-06 11:34:39', 'Định vị GPS', 'checked_in', NULL, NULL),
(106, 'EV-7387', 'HTTT2311052', '2026-07-06 11:37:25', 'Định vị GPS', 'checked_in', NULL, NULL),
(107, 'EV-7085', 'HTTT2311052', '2026-07-06 11:47:42', 'Định vị GPS', 'checked_in', NULL, NULL),
(108, 'EV-7968', 'HTTT2311052', '2026-07-06 11:52:09', 'Định vị GPS', 'checked_in', NULL, NULL),
(109, 'EV-1115', 'HTTT2311052', '2026-07-06 12:04:07', 'Định vị GPS', 'checked_in', NULL, NULL),
(116, 'EV-3126', 'HTTT2311052', '2026-07-06 14:34:01', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(117, 'EV-2221', 'HTTT2311052', '2026-07-06 14:58:45', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(118, 'EV-8438', 'HTTT2311052', '2026-07-07 08:09:44', 'Định vị GPS', 'checked_in', NULL, NULL),
(119, 'EV-8613', 'HTTT2311052', '2026-07-07 08:18:38', 'Định vị GPS', 'checked_in', NULL, NULL),
(120, 'EV-2855', 'HTTT2311052', '2026-07-07 09:11:01', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(121, 'EV-3969', 'HTTT2311052', '2026-07-10 15:03:56', 'Định vị GPS', 'checked_in', NULL, NULL),
(122, 'EV-8044', 'HTTT2311052', '2026-07-10 15:05:35', 'Định vị GPS', 'checked_in', NULL, NULL),
(123, 'EV-3140', 'HTTT2311052', '2026-07-10 15:08:18', 'Định vị GPS', 'checked_in', NULL, NULL),
(124, 'EV-4264', 'HTTT2311052', '2026-07-10 15:17:07', 'Định vị GPS', 'checked_in', NULL, NULL),
(125, 'EV-3985', 'HTTT2311052', '2026-07-10 15:22:15', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(126, 'EV-2508', 'HTTT2311052', '2026-07-10 15:37:01', 'Định vị GPS', 'checked_in', NULL, NULL),
(127, 'EV-2370', 'HTTT2311052', '2026-07-10 15:39:18', 'Upload_Minh_Chung', 'checked_in', NULL, NULL),
(128, 'EV-7170', 'HTTT2311052', '2026-07-12 14:26:24', 'Nộp Bài / Minh Chứng', 'checked_in', '/uploads/1783841184554-476134600.pdf', NULL),
(129, 'EV-1933', 'HTTT2311052', '2026-07-12 14:31:23', 'Định vị GPS', 'checked_in', NULL, NULL),
(130, 'EV-1933', 'HTTT2311051', '2026-07-12 15:09:30', 'Định vị GPS', 'checked_in', NULL, NULL),
(131, 'EV-9808', 'HTTT2311052', '2026-07-13 21:52:48', 'Định vị GPS', 'checked_in', NULL, NULL),
(132, 'EV-9808', 'HTTT2311051', '2026-07-13 21:59:10', 'Định vị GPS', 'checked_in', NULL, NULL),
(133, 'EV-9808', 'HTTT2311021', '2026-07-13 22:00:41', 'Định vị GPS', 'checked_in', NULL, NULL),
(134, 'EV-9808', 'HTTT2311009', '2026-07-13 22:07:55', 'Định vị GPS', 'checked_in', NULL, NULL),
(135, 'EV-9808', 'HTTT2311011', '2026-07-13 22:09:25', 'Định vị GPS', 'checked_in', NULL, NULL),
(136, 'EV-9808', 'HTTT2311032', '2026-07-13 22:12:16', 'Định vị GPS', 'checked_in', NULL, NULL),
(137, 'EV-9808', 'HTTT2311024', '2026-07-13 22:21:30', 'Định vị GPS', 'checked_in', NULL, NULL),
(138, 'EV-8258', 'HTTT2311010', '2026-07-14 19:19:11', 'Nộp Bài / Minh Chứng', 'checked_in', NULL, NULL),
(139, 'EV-8258', 'HTTT2311011', '2026-07-14 19:17:58', 'Nộp Bài / Minh Chứng', 'checked_in', NULL, NULL),
(140, 'EV-8516', 'HTTT2311051', '2026-07-16 15:12:48', 'Định vị GPS', 'checked_in', NULL, NULL),
(141, 'EV-8516', 'HTTT2311052', '2026-07-16 15:17:10', 'Định vị GPS', 'checked_in', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `criteria`
--

CREATE TABLE `criteria` (
  `id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `max_points` int(11) NOT NULL,
  `icon_name` varchar(50) DEFAULT 'star',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `criteria`
--

INSERT INTO `criteria` (`id`, `title`, `max_points`, `icon_name`, `created_at`) VALUES
(1, 'Tham gia học tập', 20, 'menu_book', '2026-06-05 08:33:33'),
(2, 'Chấp hành nội quy', 25, 'volunteer_activism', '2026-06-05 08:33:33'),
(3, 'Hoạt động xã hội', 20, 'nature_people', '2026-06-05 08:33:33'),
(4, 'Quan hệ cộng đồng', 25, 'psychology_outlined', '2026-06-05 08:33:33'),
(5, 'Khác', 10, 'extension', '2026-06-05 08:33:33');

-- --------------------------------------------------------

--
-- Table structure for table `criteria_categories`
--

CREATE TABLE `criteria_categories` (
  `id` varchar(50) NOT NULL,
  `name` text NOT NULL,
  `max_points` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `criteria_categories`
--

INSERT INTO `criteria_categories` (`id`, `name`, `max_points`, `created_at`, `updated_at`) VALUES
('I', 'I. Đánh giá về ý thức tham gia học tập', 20, '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('II', 'II. Đánh giá về ý thức chấp hành hành chính, nội quy, quy chế', 25, '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('III', 'III. Đánh giá về ý thức tham gia các hoạt động chính trị, xã hội, văn hóa, văn nghệ, thể thao, phòng chống tệ nạn xã hội', 20, '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('IV', 'IV. Đánh giá về ý thức công dân trong quan hệ cộng đồng', 25, '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('V', 'V. Ý thức và kết quả tham gia công tác cán bộ lớp, đoàn thể hoặc thành tích đặc biệt', 10, '2026-06-28 01:19:02', '2026-06-28 01:19:02');

-- --------------------------------------------------------

--
-- Table structure for table `criteria_sub_categories`
--

CREATE TABLE `criteria_sub_categories` (
  `id` varchar(50) NOT NULL,
  `parent_id` varchar(50) NOT NULL,
  `name` text NOT NULL,
  `points` int(11) NOT NULL DEFAULT 0,
  `unit` varchar(50) DEFAULT 'lần',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `criteria_sub_categories`
--

INSERT INTO `criteria_sub_categories` (`id`, `parent_id`, `name`, `points`, `unit`, `created_at`, `updated_at`) VALUES
('I_1', 'I', 'Sinh viên có điểm trung bình học tập tích lũy với thang điểm 4', 5, 'học kỳ', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('I_2', 'I', 'Có giấy chứng nhận tham gia học các lớp chuyên đề kỹ năng học tập', 3, 'học kỳ', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('I_3', 'I', 'Tham gia Hội thảo hoặc Tọa đàm do Khoa hoặc Trường tổ chức', 3, 'lần', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('I_4', 'I', 'Tham gia các cuộc thi học thuật cấp Khoa hoặc Trường tổ chức', 7, 'lần', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('I_5', 'I', 'Các cuộc thi học thuật do các đơn vị bên ngoài trường tổ chức', 8, 'lần', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('II_1', 'II', 'Đăng ký học tập theo đúng quy định của Nhà trường', 5, 'học kỳ', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('II_2', 'II', 'Chấp hành nghiêm túc các văn bản chỉ đạo của Trường và cơ quan chức năng', 5, 'học kỳ', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('II_3', 'II', 'Thực hiện tốt việc đóng học phí và các khoản lệ phí đúng thời hạn', 5, 'học kỳ', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('III_1', 'III', 'Tham gia đầy đủ các buổi sinh hoạt chính trị đầu khóa, giữa khóa và cuối khóa', 10, 'đợt', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('III_2', 'III', 'Tham gia các hoạt động văn hóa, văn nghệ, thể thao cấp Khoa hoặc Trường', 5, 'lần', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('III_3', 'III', 'Tham gia các hoạt động ngày chủ nhật xanh, vệ sinh môi trường', 3, 'lần', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('IV_1', 'IV', 'Tham gia tích cực các hoạt động tình nguyện: Mùa hè xanh, Tiếp sức mùa thi', 10, 'đợt', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('IV_2', 'IV', 'Tham gia hiến máu nhân đạo hoặc các hoạt động hỗ trợ cộng đồng', 5, 'lần', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('IV_3', 'IV', 'Tuyên truyền, phổ biến pháp luật, phòng chống tệ nạn xã hội', 5, 'lần', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('V_1', 'V', 'Hoàn thành tốt nhiệm vụ Ban cán bộ Lớp, Chi đoàn, Ban chấp hành Đoàn - Hội', 5, 'học kỳ', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('V_2', 'V', 'Sinh viên đạt giải thưởng NCKH hoặc các cuộc thi học thuật lớn', 7, 'lần', '2026-06-28 01:19:02', '2026-06-28 01:19:02'),
('V_3', 'V', 'Đạt danh hiệu Sinh viên 5 tốt, Đoàn viên tiêu biểu xuất sắc các cấp', 6, 'lần', '2026-06-28 01:19:02', '2026-06-28 01:19:02');

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `id` varchar(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `date` datetime NOT NULL,
  `end_date` datetime DEFAULT NULL,
  `description` text DEFAULT NULL,
  `category` varchar(100) NOT NULL DEFAULT '',
  `poster_url` varchar(500) DEFAULT NULL,
  `attached_file` text DEFAULT NULL,
  `status` enum('Sắp diễn ra','Đang diễn ra','Đã kết thúc','Ngừng hoạt động') DEFAULT 'Sắp diễn ra',
  `require_gps` tinyint(1) DEFAULT 0,
  `require_proof` tinyint(1) DEFAULT 1,
  `faculty_limits` text DEFAULT NULL,
  `points` int(11) NOT NULL DEFAULT 0,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `required_fields` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `location_preset_id` int(11) DEFAULT NULL,
  `allowed_radius` int(11) NOT NULL DEFAULT 50 COMMENT 'Bán kính hợp lệ (mét)',
  `max_participants` int(11) DEFAULT 0,
  `score_type` varchar(50) DEFAULT 'once',
  `sample_proof_url` varchar(255) DEFAULT NULL,
  `require_file` tinyint(1) DEFAULT 0,
  `require_class_committee` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`id`, `name`, `date`, `end_date`, `description`, `category`, `poster_url`, `attached_file`, `status`, `require_gps`, `require_proof`, `faculty_limits`, `points`, `latitude`, `longitude`, `required_fields`, `created_at`, `location_preset_id`, `allowed_radius`, `max_participants`, `score_type`, `sample_proof_url`, `require_file`, `require_class_committee`) VALUES
('EV-1044', 'tét21', '2026-07-06 12:28:00', '2026-07-07 12:28:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 2, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 05:28:41', 9, 50, 20, 'once', '', 0, 0),
('EV-1115', 'tét17', '2026-07-06 12:02:00', '2026-07-07 12:02:00', '', 'IV_2', '', '', 'Đã kết thúc', 1, 1, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 05:02:55', 9, 50, 20, 'once', '', 0, 0),
('EV-1453', 'con mẹ nó chứđaèadssadd', '2026-06-29 08:46:00', '2026-06-30 08:46:00', 'dấdsadasdasd', 'I_1', '', '', 'Đã kết thúc', 0, 0, NULL, 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-01 01:46:59', NULL, 50, 10, 'once', NULL, 0, 0),
('EV-1505', 'adcxasd', '2026-07-01 15:11:00', '2026-07-07 15:11:00', '', 'I_2', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 10, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-01 08:11:40', NULL, 50, 10, 'once', NULL, 0, 0),
('EV-1593', 'trsatyud', '2026-06-14 00:19:00', '2026-06-23 22:03:00', '', 'III_1', '', '', 'Đã kết thúc', 0, 1, NULL, 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\"]', '2026-06-09 15:03:48', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-1718', 'teest111', '2026-06-15 09:32:00', '2026-06-30 20:33:00', 'dấdasd', 'I_2', '', '', 'Đã kết thúc', 0, 1, NULL, 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-06-09 13:33:28', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-1789', 'tét8', '2026-07-06 10:52:00', '2026-07-07 10:52:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 03:52:42', 9, 50, 20, 'once', '', 0, 0),
('EV-1822', 'tét9', '2026-07-06 10:59:00', '2026-07-07 10:59:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 03:59:44', 9, 50, 20, 'once', '', 0, 0),
('EV-1933', 'kiki', '2026-07-12 15:04:00', '2026-07-16 14:27:00', 'adasdadad', 'II_2', '/uploads/1783841362853-98995319.jpg', '[\"/uploads/1783841382883-628987772.pdf\"]', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 3, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-12 07:29:22', 9, 50, 0, 'once', '', 0, 0),
('EV-2221', 'ĐOÀN KHOA CÔNG NGHỆ THÔNG TIN', '2026-07-06 14:58:00', '2026-07-07 14:58:00', '', 'IV_2', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 2, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 07:58:08', NULL, 50, 0, 'once', '/uploads/1783325376886-790936658.png', 0, 0),
('EV-2370', '123', '2026-07-09 15:38:00', '2026-07-18 15:38:00', '', 'II_1', '', '', 'Đang diễn ra', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-10 08:38:25', NULL, 50, 0, 'once', '', 0, 0),
('EV-2384', 'th11', '2026-07-05 20:32:00', '2026-07-06 20:30:00', '', 'III_1', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, 10.82200000, 106.62570000, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-05 13:30:35', 7, 50, 0, 'once', '', 0, 0),
('EV-2508', 'lo', '2026-07-09 15:35:00', '2026-07-12 15:35:00', '', 'I_2', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 0, 10.04733600, 105.76733600, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-10 08:36:05', 10, 50, 0, 'once', '', 0, 0),
('EV-2549', 'tét22', '2026-07-06 13:47:00', '2026-07-07 13:47:00', '', 'IV_3', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 06:47:59', NULL, 50, 20, 'once', '', 0, 0),
('EV-2587', 'hoithao', '2026-07-03 20:10:00', '2026-07-04 19:59:00', '', 'III_1', '/uploads/1783083678848-542686904.jpg', '', 'Ngừng hoạt động', 0, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-03 13:01:18', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-2670', 'chungchiielts', '2026-07-05 12:18:00', '2026-07-06 12:16:00', '', 'I_2', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-05 05:16:47', NULL, 50, 0, 'multiple', '/uploads/1783228607727-101881991.jpg', 0, 0),
('EV-2855', '2', '2026-07-07 09:10:00', '2026-07-08 09:10:00', '', 'III_1', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-07 02:10:33', NULL, 50, 0, 'once', '', 0, 0),
('EV-2862', 'truonghop1', '2026-07-03 23:48:00', '2026-07-04 23:42:00', '', 'III_1', '/uploads/1783096950951-852691233.jpg', '', 'Ngừng hoạt động', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.82200000, 106.62570000, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-03 16:42:30', 7, 50, 0, 'once', NULL, 0, 0),
('EV-3067', 'tét12', '2026-07-06 11:33:00', '2026-07-07 11:34:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 04:34:04', 9, 50, 20, 'once', '', 0, 0),
('EV-3126', 'HIẾN MÁU TÌNH NGUYỆN', '2026-07-06 14:33:00', '2026-07-07 14:33:00', '', 'IV_2', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 8, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 07:33:22', NULL, 50, 0, 'once', '', 0, 0),
('EV-3140', 'sdaad', '2026-07-09 15:07:00', '2026-07-12 15:07:00', '', 'I_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 0, 10.82200000, 106.62570000, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-10 08:07:44', 7, 50, 0, 'once', '', 0, 0),
('EV-3150', 'ahahaa', '2026-07-02 08:33:00', '2026-07-04 08:33:00', '', 'II_2', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-02 01:33:56', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-3401', 'test1', '2026-07-04 18:58:00', '2026-07-05 18:54:00', '', 'III_1', '', '', 'Ngừng hoạt động', 1, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, 16.16670000, 107.83330000, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-04 11:55:07', 8, 50, 0, 'once', NULL, 0, 0),
('EV-3574', 'te222w', '2026-06-29 20:37:00', '2026-06-24 20:37:00', '', '', '', '', 'Đã kết thúc', 0, 1, NULL, 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-06-09 13:37:15', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-3657', 'tét3', '2026-07-06 09:20:00', '2026-07-07 09:20:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 2, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 02:20:51', 9, 50, 0, 'once', '', 0, 0),
('EV-3685', 'tét11', '2026-07-06 11:28:00', '2026-07-07 11:28:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 04:28:30', 9, 50, 20, 'once', '', 0, 0),
('EV-3738', 'truonghop1', '2026-07-04 19:25:00', '2026-07-05 19:21:00', '', 'III_1', '', '', 'Ngừng hoạt động', 1, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, 16.16670000, 107.83330000, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-04 12:21:44', 8, 50, 0, 'once', NULL, 0, 0),
('EV-3820', 'weqwee', '2026-07-03 20:14:00', '2026-07-04 20:03:00', '', 'III_2', '', '', 'Ngừng hoạt động', 1, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.82200000, 106.62570000, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-03 13:04:03', 7, 50, 0, 'once', NULL, 0, 0),
('EV-3825', '1', '2026-07-03 20:14:00', '2026-07-04 20:08:00', '', 'III_2', '', '', 'Ngừng hoạt động', 0, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-03 13:08:20', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-3827', 'tét2', '2026-07-06 09:08:00', '2026-07-07 09:09:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 0, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 02:09:12', 9, 50, 0, 'once', '', 0, 0),
('EV-3969', 'skt1', '2026-07-09 15:01:00', '2026-07-11 15:01:00', '', 'II_1', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 2, 10.04733600, 105.76733600, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-10 08:02:02', 10, 50, 0, 'once', '', 0, 0),
('EV-3985', 'SAD', '2026-07-09 15:21:00', '2026-07-12 15:21:00', '', 'I_2', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-10 08:21:46', NULL, 50, 0, 'once', '', 0, 0),
('EV-4111', 'th4', '2026-07-04 19:15:00', '2026-07-05 19:13:00', '', 'I_4', '', '', 'Ngừng hoạt động', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 2, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-04 12:13:20', NULL, 50, 0, 'multiple', NULL, 0, 0),
('EV-4264', 'sấ1', '2026-07-09 15:15:00', '2026-07-11 15:15:00', '', 'II_2', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 0, 10.04733600, 105.76733600, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-10 08:15:32', 10, 50, 0, 'once', '', 0, 0),
('EV-4266', 'th1', '2026-07-05 20:33:00', '2026-07-06 20:29:00', '', 'I_4', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, 16.16670000, 107.83330000, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-05 13:29:56', 8, 50, 0, 'once', '', 0, 0),
('EV-4436', 'tét10', '2026-07-06 11:11:00', '2026-07-07 11:11:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 3, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 04:12:01', 9, 50, 20, 'once', '', 0, 0),
('EV-4695', 'tét1', '2026-07-06 08:58:00', '2026-07-07 08:58:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 01:58:54', 9, 50, 0, 'once', '', 0, 0),
('EV-4705', 'con mẹ nó chứ ad', '2026-06-29 11:38:00', '2026-06-30 11:43:00', '', 'I_2', '', '', 'Đã kết thúc', 0, 0, NULL, 2, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-06-28 04:38:31', NULL, 50, 10, 'once', NULL, 0, 0),
('EV-4746', 'truonghop4', '2026-07-04 19:26:00', '2026-07-05 19:23:00', '', 'I_5', '', '', 'Ngừng hoạt động', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-04 12:23:12', NULL, 50, 0, 'multiple', NULL, 0, 0),
('EV-5121', 'tesw12', '2026-06-09 12:49:00', '2026-06-12 20:49:00', 'dsadasdsad', '', '', '', 'Đã kết thúc', 0, 1, NULL, 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-06-09 13:49:55', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-5776', 'Hiến máu tình nguyện', '2026-07-06 13:54:00', '2026-07-07 13:54:00', '', 'III_2', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 8, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 06:54:20', NULL, 50, 100, 'once', '', 0, 0),
('EV-6161', 'adgada111', '2026-07-01 12:03:00', '2026-07-10 12:03:00', '', 'III_2', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"10\",\"CNTT\":\"20\",\"HTTT\":\"20\",\"KHMT\":\"37\",\"KTPM\":\"13\",\"TTNT\":\"\"}', 22, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-01 05:03:43', NULL, 50, 100, 'once', NULL, 0, 0),
('EV-6442', 'l2', '2026-07-16 19:14:00', '2026-07-17 19:14:00', '', 'II_2', '', '', 'Sắp diễn ra', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 2, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-14 12:14:15', NULL, 50, 0, 'once', '', 0, 0),
('EV-6737', 'th2', '2026-07-04 18:59:00', '2026-07-05 18:56:00', '', 'IV_1', '', '', 'Ngừng hoạt động', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-04 11:57:10', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-6927', 'tét7', '2026-07-06 10:49:00', '2026-07-07 10:49:00', '', 'V_1', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 03:49:56', 9, 50, 20, 'once', '', 0, 0),
('EV-6962', 'tét18', '2026-07-06 12:06:00', '2026-07-07 12:06:00', '', 'IV_3', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 05:06:44', NULL, 50, 20, 'once', '', 0, 0),
('EV-7012', 'chungchi', '2026-07-05 20:35:00', '2026-07-06 20:35:00', '', 'I_2', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-05 13:35:19', NULL, 50, 0, 'once', '/uploads/1783258519235-287192239.webp', 0, 0),
('EV-7085', 'tét14', '2026-07-06 11:46:00', '2026-07-07 11:47:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 6, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 04:47:05', 9, 50, 20, 'once', '', 0, 0),
('EV-7170', 'Câu chuyện thời hoa lửa', '2026-07-09 15:42:00', '2026-07-20 15:42:00', '@All  Căn cứ CV 525 ngày 09/7 của Thành Đoàn Cần Thơ và Số lượng phân bổ mới chỉ tiêu Đề án 20 \"Câu chuyện thời hoa lửa\" Số lượng bài còn lại là 800 bài hoàn thành đến trước 27/7.\r\nKính gửi quý Thầy/Cô, Anh/Chị Bí thư các Đoàn khoa số liệu phân bổ mới để hoàn thành số lượng đề ra.\r\nTheo số liệu hoàn thành chỉ tiêu trước đó, ĐK KT-QLCN hoàn thành 100% số lượng, các đơn vị còn lại chưa đảm bảo số lượng. Nên số lượng sẽ được phân bổ như sau:\r\n- ĐK KHXH 120 sản phẩm\r\n- ĐK KT-QLCN 100 sản phẩm\r\n- ĐK KTCK 160 sản phẩm\r\n- ĐK Đ-ĐT 120 sản phẩm\r\n- ĐK CNTT 110 sản phẩm\r\n- ĐK SH-TP 150 sản phẩm\r\n- ĐK KTXD 120 sản phẩm\r\nCác đơn vị căn cứ số lượng kính mong các đơn vị hỗ trợ thực hiện đảm bảo chỉ tiêu Đoàn bộ TP phân bổ trước ngày 20/7 để bộ phận kỹ thuật up bài lên hệ thống.\r\nTrân trọng cảm ơn!', 'II_1', '', '[\"/uploads/1783673034520-843380046.docx\"]', 'Đang diễn ra', 0, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-10 08:43:54', NULL, 50, 110, 'once', '', 1, 0),
('EV-7387', 'tét13', '2026-07-06 11:36:00', '2026-07-07 11:36:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 04:36:38', 9, 50, 20, 'once', '', 0, 0),
('EV-7454', 'huhuh', '2026-06-14 23:30:00', '2026-06-30 23:30:00', 'dấdasddấdasdad', 'I_2', '', '', 'Đã kết thúc', 0, 1, NULL, 30, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-06-09 16:31:06', NULL, 50, 100, 'once', NULL, 0, 0),
('EV-7659', 'huhuh', '2026-07-03 20:05:00', '2026-07-04 20:01:00', '', 'III_1', '/uploads/1783083711799-95370351.jpg', '', 'Ngừng hoạt động', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-03 13:01:51', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-7816', 'alibaba', '2026-06-03 16:51:00', '2026-06-12 15:50:00', 'đâbjsdhkjnalsndál;d', 'Học thuật', '/uploads/1781018919776-Shi Hao ç³æ à¸ªà¸·à¸­à¹à¸®à¹à¸² Huang è à¸®à¸§à¸ _ Perfect World å®ç¾ä¸ç à¹à¸¥à¸à¸­à¸±à¸à¸ªà¸¡à¸à¸¹à¸£à¸à¹à¹à¸à¸.jpg', '/uploads/1781019672492-indexhtml.php', 'Đã kết thúc', 1, 1, NULL, 0, 10.02108100, 99.99999999, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-06-09 08:50:48', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-7968', 'tét16', '2026-07-06 11:51:00', '2026-07-07 11:51:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 04:51:34', 9, 50, 20, 'once', '', 0, 0),
('EV-8042', 'truonghop1', '2026-07-04 18:58:00', '2026-07-05 18:52:00', '', 'III_1', '', '', 'Ngừng hoạt động', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 16.16670000, 107.83330000, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-04 11:53:06', 8, 50, 0, 'once', NULL, 0, 0),
('EV-8044', 'skt2', '2026-07-09 15:04:00', '2026-07-11 15:04:00', '', 'III_2', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 2, 16.16670000, 107.83330000, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-10 08:04:53', 8, 50, 0, 'once', '', 0, 0),
('EV-8254', 'tét19', '2026-07-06 12:14:00', '2026-07-07 12:14:00', '', 'IV_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 05:14:47', 9, 50, 20, 'once', '', 0, 0),
('EV-8258', 'l1', '2026-07-14 19:09:00', '2026-07-16 19:09:00', '', 'I_2', '', '', 'Đang diễn ra', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 3, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-14 12:09:54', NULL, 50, 0, 'multiple', '', 0, 0),
('EV-8393', 'test', '2026-06-09 19:45:00', '2026-06-13 15:45:00', 'https://meet.google.com/xyz  adadasdasdacaca', '', '/uploads/1780994720848-Shi Hao ç³æ à¸ªà¸·à¸­à¹à¸®à¹à¸² Huang è à¸®à¸§à¸ _ Perfect World å®ç¾ä¸ç à¹à¸¥à¸à¸­à¸±à¸à¸ªà¸¡à¸à¸¹à¸£à¸à¹à¹à¸à¸.jpg', '', 'Đã kết thúc', 0, 1, NULL, 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-06-09 08:45:20', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-8438', 'hihi', '2026-07-07 08:09:00', '2026-07-08 08:09:00', '', 'IV_1', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-07 01:09:16', 9, 50, 0, 'once', '', 0, 0),
('EV-8516', 'Chương trình sinh hoạt', '2026-07-16 15:12:00', '2026-07-19 14:22:00', '@All dạ em xin phép triển khai Công văn số 481 của BTV Đoàn Trường về việc điều động lực lượng tham dự Chương trình sinh hoạt chuyên đề “Sinh viên CTUT với văn hóa giao thông năm 2026”\r\n1. Thời gian: 07g30, ngày 18 tháng 7 năm 2026 (thứ Bảy).\r\n2. Địa điểm: Hội trường A, Trường Đại học Kỹ thuật - Công nghệ Cần Thơ.\r\n3. Trang phục: Áo Đoàn, áo Hội, áo Trường.\r\n4. Thành phần tham dự:\r\n- Mỗi chi đoàn cử 03 đồng chí (gồm Bí thư, Phó Bí thư, 01 UV BCH).\r\n- Mỗi chi hội cử 02 đồng chí (gồm Chi hội trưởng, Chi hội phó).\r\n- Mỗi Câu lạc bộ, Đội, Nhóm cử 01 đồng chí trong Ban Điều hành và  Ban Chủ nhiệm của đơn vị.\r\nCác trường hợp thay thế phải có sự đồng ý của Bí thư Đoàn khoa, Liên Chi hội trưởng, nhưng phải đảm bảo số lượng theo phân bổ.\r\nĐường dẫn danh sách đăng ký tham dự Chương trình:  https://docs.google.com/spreadsheets/d/1cRC6QzpCCB5njYnU0OQ-7MPSIiiX9I4S8gSbyRhK8NM/edit?usp=sharing\r\nMọi chi tiết liên hệ: đồng chí Trần Đức Mạnh - Phó Chánh Thường trực Văn phòng Đoàn Trường, số điện thoại: 0818 504 704.\r\nKính nhờ quý Thầy/Cô, Anh/Chị BTĐK triển khai về đơn vị để sinh viên đăng ký tham dự chương trình ạ. Em xin cảm ơn!', 'III_1', '', '', 'Đang diễn ra', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"3\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"97\"}', 5, 10.04733600, 105.76733600, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-16 07:22:44', 10, 50, 100, 'once', '', 0, 1),
('EV-8540', 'adadadad', '2026-07-01 09:32:00', '2026-07-08 09:32:00', 'adasdasdad', 'V_1', '', '', 'Đã kết thúc', 0, 0, '{\"ANMT\":\"20\",\"CNTT\":\"30\",\"HTTT\":\"50\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 12, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-01 02:32:40', NULL, 50, 100, 'once', NULL, 0, 0),
('EV-8563', 'truonghop2', '2026-07-05 12:04:00', '2026-07-06 11:49:00', '', 'III_1', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-05 04:49:44', NULL, 50, 0, 'once', '', 0, 0),
('EV-8613', '1', '2026-07-07 08:17:00', '2026-07-08 08:17:00', '', 'I_2', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-07 01:18:02', 9, 50, 0, 'once', '', 0, 0),
('EV-8770', 'trsatyud', '2026-07-03 20:05:00', '2026-07-04 20:02:00', '', 'III_2', '/uploads/1783083764239-484644047.jpg', '', 'Ngừng hoạt động', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 0, 10.82200000, 106.62570000, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-03 13:02:44', 7, 50, 0, 'once', NULL, 0, 0),
('EV-8933', 'truonghop2', '2026-07-03 23:50:00', '2026-07-04 23:44:00', '', 'III_2', '', '', 'Ngừng hoạt động', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-03 16:44:33', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-9043', 'tét6', '2026-07-06 10:00:00', '2026-07-07 10:00:00', '', 'V_3', '', '', 'Đã kết thúc', 0, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 03:00:53', NULL, 50, 20, 'once', '', 0, 0),
('EV-9050', 'testtgday', '2026-06-10 00:16:00', '2026-06-12 21:17:00', 'ádasdsad', '', '', '', 'Đã kết thúc', 0, 1, NULL, 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-06-09 14:17:44', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-9111', 'tét5', '2026-07-06 09:46:00', '2026-07-07 09:46:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 1, '{\"ANMT\":\"\",\"CNTT\":\"0\",\"HTTT\":\"1\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 02:46:24', 9, 50, 1, 'once', '', 0, 0),
('EV-9200', 'tét4', '2026-07-06 08:30:00', '2026-07-07 09:31:00', '', 'V_2', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 5, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 02:32:03', 9, 50, 0, 'once', '', 0, 0),
('EV-9330', 'koko', '2026-07-02 14:47:00', '2026-07-06 14:47:00', '', 'I_2', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 2, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-02 07:47:45', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-9340', 'ko', '2026-06-09 20:05:00', '2026-06-23 23:13:00', '', 'Học thuật', '/uploads/1780654645063-Shi Hao ç³æ à¸ªà¸·à¸­à¹à¸®à¹à¸² Huang è à¸®à¸§à¸ _ Perfect World å®ç¾ä¸ç à¹à¸¥à¸à¸­à¸±à¸à¸ªà¸¡à¸à¸¹à¸£à¸à¹à¹à¸à¸.jpg', '', 'Đã kết thúc', 0, 1, NULL, 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-06-04 16:13:32', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-9455', 'truonghop2', '2026-07-04 19:25:00', '2026-07-05 19:22:00', '', 'I_4', '', '', 'Ngừng hoạt động', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-04 12:22:19', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-9522', 'test2', '2026-06-16 00:03:00', '2026-06-23 22:01:00', 'sdadadadsad', '', '', '', 'Đã kết thúc', 0, 1, NULL, 0, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-06-09 15:01:59', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-9672', 'tét20', '2026-07-06 12:25:00', '2026-07-07 12:25:00', '', 'V_3', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"10\",\"HTTT\":\"10\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, 10.02106400, 105.73338900, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-06 05:25:13', 9, 50, 20, 'once', '', 0, 0),
('EV-9685', 'truonghop21', '2026-07-04 00:00:00', '2026-07-04 23:57:00', '', 'III_2', '', '', 'Ngừng hoạt động', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-03 16:57:34', NULL, 50, 0, 'once', NULL, 0, 0),
('EV-9712', 'truonghop4', '2026-07-05 12:02:00', '2026-07-06 11:59:00', '', 'I_4', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-05 04:59:51', NULL, 50, 0, 'multiple', '/uploads/1783227591550-947659259.png', 0, 0),
('EV-9723', 'tìm hiểu pháp luật 2026', '2026-07-04 23:35:00', '2026-07-06 23:32:00', '', 'I_4', '', '', 'Đã kết thúc', 0, 1, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, NULL, NULL, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-04 16:33:09', NULL, 50, 0, 'multiple', '/uploads/1783182942503-619096678.png', 0, 0),
('EV-9808', '1231', '2026-07-13 22:40:00', '2026-07-17 21:48:00', '', 'I_2', '', '', 'Đang diễn ra', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 3, 10.02101100, 105.73335000, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-13 14:48:52', 11, 50, 0, 'once', '', 0, 0),
('EV-9880', 'truonghop1', '2026-07-05 11:51:00', '2026-07-06 11:48:00', '', 'III_1', '', '', 'Đã kết thúc', 1, 0, '{\"ANMT\":\"\",\"CNTT\":\"\",\"HTTT\":\"\",\"KHMT\":\"\",\"KTPM\":\"\",\"TTNT\":\"\"}', 1, 16.16670000, 107.83330000, '[\"mssv\",\"name\",\"phone\",\"chi_doan\",\"checkin_time\",\"method\"]', '2026-07-05 04:48:29', 8, 50, 0, 'once', '', 0, 0),
('EVT-26001', 'Đại hội Chi đoàn Hệ thống Thông tin Khóa 2023', '2026-05-15 14:00:00', '2026-05-15 17:30:00', '', '', '/uploads/poster_daihoi.jpg', '/uploads/kehoach_daihoi.pdf', 'Đã kết thúc', 1, 1, NULL, 0, 10.04530000, 99.99999999, '[\"mssv\", \"full_name\"]', '2026-05-01 01:00:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26002', 'Sinh hoạt Chuyên đề Web Fullstack: PHP & ReactJS', '2026-05-20 08:00:00', '2026-05-20 11:30:00', 'https://meet.google.com/abc', 'Học thuật', '', '', 'Đã kết thúc', 0, 1, NULL, 0, NULL, NULL, '[\"mssv\"]', '2026-05-05 02:15:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26003', 'Hội thảo Ứng dụng AI & Machine Learning', '2026-06-04 07:30:00', '2026-06-04 11:30:00', '', 'Học thuật', '/uploads/poster_ai.jpg', '', 'Đã kết thúc', 1, 1, NULL, 0, 10.04530000, 99.99999999, '[\"mssv\", \"full_name\", \"faculty\"]', '2026-05-25 03:00:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26004', 'Chiến dịch Mùa Hè Xanh 2026', '2026-06-12 06:00:00', '2026-07-15 17:00:00', 'https://muahexanh.sv.ctuet.edu.vn', 'Tham gia học tập', '/uploads/poster_mhx.png', '/uploads/dk_mhx.docx', 'Đã kết thúc', 1, 1, NULL, 10, 10.04086600, 105.76257700, '[\"mssv\",\"phone\",\"chi_doan\"]', '2026-06-01 07:30:00', 6, 50, 0, 'once', NULL, 0, 0),
('EVT-26005', 'Giải bóng đá Sinh viên Công nghệ', '2026-06-09 00:00:00', '2026-06-20 18:00:00', '', '', '', '', 'Đã kết thúc', 1, 1, NULL, 0, 10.04600000, 99.99999999, '[\"mssv\",\"full_name\"]', '2026-06-02 01:20:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26006', 'Tiếp sức Mùa thi THPT Quốc gia 2026', '2026-06-12 06:00:00', '2026-06-28 17:00:00', '', 'I_2', '/uploads/tsmt_2026.jpg', '', 'Đã kết thúc', 1, 1, NULL, 0, 10.04086600, 105.76257700, '[\"mssv\",\"phone\"]', '2026-06-03 02:00:00', 6, 50, 100, 'once', NULL, 0, 0),
('EVT-26007', 'Ngày hội Sinh viên 5 Tốt cấp Trường', '2026-06-15 08:00:00', '2026-06-30 11:30:00', '', 'Tham gia học tập', '/uploads/sv5t.png', '', 'Đã kết thúc', 0, 1, NULL, 2, NULL, NULL, '[\"mssv\"]', '2026-04-25 08:00:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26008', 'Seminar: Xây dựng Recommendation System', '2026-06-13 14:00:00', '2026-06-15 16:30:00', 'https://zoom.us/j/123456789', 'Quan hệ cộng đồng', '/uploads/nlp_seminar.jpg', '/uploads/slide_nlp.pdf', 'Đã kết thúc', 0, 1, NULL, 5, NULL, NULL, '[\"mssv\",\"full_name\",\"phone\"]', '2026-06-01 03:10:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26009', 'lolo', '2026-06-27 14:00:00', '2026-06-04 17:00:00', '', 'Tình nguyện', '/uploads/1780654351135-Shi Hao ç³æ à¸ªà¸·à¸­à¹à¸®à¹à¸² Huang è à¸®à¸§à¸ _ Perfect World å®ç¾ä¸ç à¹à¸¥à¸à¸­à¸±à¸à¸ªà¸¡à¸à¸¹à¸£à¸à¹à¹à¸à¸.jpg', '', 'Đã kết thúc', 1, 1, NULL, 0, 10.04530000, 99.99999999, '[\"mssv\"]', '2026-05-28 01:00:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26010', 'Cuộc thi Thiết kế UI/UX Ứng dụng Quản lý', '2026-06-15 08:00:00', '2026-07-05 17:00:00', 'https://uiux.ctuet.edu.vn', 'Quan hệ cộng đồng', '/uploads/uiux_contest.png', '/uploads/thele_uiux.pdf', 'Đã kết thúc', 0, 1, NULL, 5, NULL, NULL, '[\"mssv\",\"full_name\",\"email\"]', '2026-06-02 07:00:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26011', 'Workshop Kỹ năng viết CV ngành IT', '2026-05-25 18:30:00', '2026-05-25 21:00:00', '', '', '', '', 'Đã kết thúc', 1, 1, NULL, 0, 10.04530000, 99.99999999, '[\"mssv\"]', '2026-05-15 01:00:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26012', 'Giao lưu văn nghệ Chào mừng năm học mới', '2026-06-13 06:30:00', '2026-08-15 22:00:00', '', 'Hoạt động xã hội', '/uploads/van_nghe.jpg', '', 'Đang diễn ra', 0, 1, NULL, 5, NULL, NULL, '[\"mssv\",\"chi_doan\"]', '2026-06-01 00:30:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26013', 'Sinh hoạt Chi đoàn chủ điểm tháng 6', '2026-06-04 19:00:00', '2026-06-04 21:00:00', 'https://meet.google.com/xyz', '', '/uploads/1780654382384-Shi Hao ç³æ à¸ªà¸·à¸­à¹à¸®à¹à¸² Huang è à¸®à¸§à¸ _ Perfect World å®ç¾ä¸ç à¹à¸¥à¸à¸­à¸±à¸à¸ªà¸¡à¸à¸¹à¸£à¸à¹à¹à¸à¸.jpg', '', 'Đã kết thúc', 0, 1, NULL, 0, NULL, NULL, '[\"mssv\",\"full_name\"]', '2026-06-01 02:00:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26014', 'Tọa đàm Định hướng nghề nghiệp Data Science', '2026-06-13 08:00:00', '2026-06-18 11:30:00', '', 'Hoạt động xã hội', '/uploads/datascience.png', '', 'Đã kết thúc', 1, 1, NULL, 20, 10.04086600, 105.76257700, '[\"mssv\",\"full_name\",\"chi_doan\",\"checkin_time\"]', '2026-06-03 08:45:00', 6, 50, 0, 'once', NULL, 0, 0),
('EVT-26015', 'Chuyên đề An toàn thông tin mạng', '2026-05-05 14:00:00', '2026-05-05 16:30:00', '', 'Học thuật', '', '', 'Đã kết thúc', 1, 1, NULL, 0, 10.04530000, 99.99999999, '[\"mssv\"]', '2026-04-20 03:00:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26016', 'Hiến máu tình nguyện đợt 2 - Năm 2026', '2026-06-09 07:00:00', '2026-06-12 11:30:00', '', 'Tình nguyện', '/uploads/hien_mau.jpg', '/uploads/phieu_dangky.pdf', 'Đã kết thúc', 1, 1, NULL, 0, 10.04530000, 99.99999999, '[\"mssv\",\"full_name\",\"phone\"]', '2026-06-02 01:00:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26017', 'Tham quan doanh nghiệp phần mềm', '2026-06-13 07:30:00', '2026-06-22 17:00:00', '', 'Học thuật', '', '', 'Đã kết thúc', 0, 1, NULL, 0, NULL, NULL, '[\"mssv\",\"phone\",\"chi_doan\"]', '2026-06-04 02:00:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26018', 'Lớp tập huấn Kỹ năng cán bộ Đoàn - Hội', '2026-05-28 08:00:00', '2026-05-29 17:00:00', '', '', '/uploads/tap_huan.png', '', 'Đã kết thúc', 1, 1, NULL, 0, 10.04530000, 99.99999999, '[\"mssv\", \"chi_doan\"]', '2026-05-10 07:00:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26019', 'Ngày hội Sinh viên Đổi mới sáng tạo', '2026-06-04 08:00:00', '2026-06-04 17:00:00', '', '', '/uploads/startup.jpg', '', 'Đã kết thúc', 1, 1, NULL, 0, 10.04530000, 99.99999999, '[\"mssv\", \"full_name\"]', '2026-05-20 03:30:00', NULL, 50, 0, 'once', NULL, 0, 0),
('EVT-26020', 'Cuộc thi Tiếng Anh chuyên ngành CNTT', '2026-06-15 08:00:00', '2026-06-30 11:30:00', '', 'II_1', '', '', 'Đã kết thúc', 0, 1, NULL, 0, NULL, NULL, '[\"mssv\",\"full_name\",\"checkin_time\",\"method\"]', '2026-06-03 09:00:00', NULL, 50, 0, 'once', NULL, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `event_registrations`
--

CREATE TABLE `event_registrations` (
  `id` int(11) NOT NULL,
  `mssv` varchar(20) NOT NULL,
  `event_id` varchar(50) DEFAULT NULL,
  `is_checked_in` tinyint(1) DEFAULT 0,
  `checkin_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `event_registrations`
--

INSERT INTO `event_registrations` (`id`, `mssv`, `event_id`, `is_checked_in`, `checkin_at`, `created_at`) VALUES
(71, 'HTTT2311052', 'EVT-26020', 1, '2026-06-28 15:02:35', '2026-06-16 12:37:48'),
(72, 'HTTT2311052', 'EVT-26010', 1, '2026-07-01 17:04:31', '2026-06-16 12:51:37'),
(73, 'HTTT2311052', 'EV-4705', 1, '2026-07-01 08:50:46', '2026-06-28 04:39:16'),
(74, 'HTTT2311052', 'EV-1453', 0, NULL, '2026-07-01 01:47:57'),
(75, 'HTTT2311052', 'EV-8540', 1, '2026-07-02 09:09:59', '2026-07-01 02:50:45'),
(76, 'HTTT2311052', 'EV-6161', 0, NULL, '2026-07-01 10:08:49'),
(77, 'HTTT2311052', 'EV-1505', 0, NULL, '2026-07-02 00:43:20'),
(78, 'HTTT2311052', 'EV-3150', 0, NULL, '2026-07-02 01:34:08'),
(79, 'HTTT2311052', 'EV-9330', 1, '2026-07-02 14:56:33', '2026-07-02 07:49:46'),
(80, 'HTTT2311033', 'EV-7659', 0, NULL, '2026-07-03 13:03:08'),
(81, 'HTTT2311033', 'EV-8770', 0, NULL, '2026-07-03 13:03:12'),
(82, 'HTTT2311033', 'EV-2587', 0, NULL, '2026-07-03 13:05:47'),
(83, 'HTTT2311033', 'EV-3825', 0, NULL, '2026-07-03 13:08:59'),
(84, 'HTTT2311033', 'EV-3820', 0, NULL, '2026-07-03 13:09:01'),
(85, 'HTTT2311033', 'EV-2862', 1, '2026-07-04 07:28:59', '2026-07-03 16:42:44'),
(86, 'HTTT2311033', 'EV-8933', 1, '2026-07-03 23:55:58', '2026-07-03 16:44:46'),
(87, 'HTTT2311033', 'EV-9685', 1, '2026-07-04 00:01:15', '2026-07-03 16:58:28'),
(88, 'HTTT2311033', 'EV-8042', 1, '2026-07-04 19:05:01', '2026-07-04 11:54:14'),
(89, 'HTTT2311033', 'EV-3401', 1, '2026-07-04 19:08:54', '2026-07-04 11:55:25'),
(90, 'HTTT2311033', 'EV-6737', 1, '2026-07-04 19:11:08', '2026-07-04 11:57:19'),
(91, 'HTTT2311033', 'EV-4111', 1, '2026-07-04 19:16:59', '2026-07-04 12:13:30'),
(92, 'HTTT2311033', 'EV-3738', 1, '2026-07-04 19:25:52', '2026-07-04 12:23:22'),
(93, 'HTTT2311033', 'EV-9455', 1, '2026-07-04 19:26:22', '2026-07-04 12:23:25'),
(94, 'HTTT2311033', 'EV-4746', 1, '2026-07-04 19:27:20', '2026-07-04 12:23:27'),
(95, 'HTTT2311033', 'EV-9723', 1, '2026-07-05 00:30:19', '2026-07-04 16:33:16'),
(96, 'HTTT2311033', 'EV-9880', 1, '2026-07-05 11:51:50', '2026-07-05 04:48:52'),
(97, 'HTTT2311033', 'EV-8563', 1, '2026-07-05 11:53:16', '2026-07-05 04:50:02'),
(98, 'HTTT2311033', 'EV-9712', 1, '2026-07-05 19:30:39', '2026-07-05 05:00:47'),
(99, 'HTTT2311033', 'EV-2670', 1, '2026-07-05 13:01:14', '2026-07-05 05:16:59'),
(100, 'HTTT2311033', 'EV-4266', 1, '2026-07-05 20:31:24', '2026-07-05 13:30:43'),
(101, 'HTTT2311033', 'EV-2384', 1, '2026-07-05 20:32:15', '2026-07-05 13:30:45'),
(102, 'HTTT2311052', 'EV-4266', 1, '2026-07-05 20:33:46', '2026-07-05 13:33:15'),
(103, 'HTTT2311052', 'EV-7012', 0, NULL, '2026-07-05 13:35:30'),
(104, 'HTTT2311052', 'EV-4695', 1, '2026-07-06 09:00:34', '2026-07-06 02:00:01'),
(105, 'HTTT2311052', 'EV-3827', 1, '2026-07-06 09:10:10', '2026-07-06 02:09:32'),
(106, 'HTTT2311052', 'EV-3657', 1, '2026-07-06 09:21:32', '2026-07-06 02:21:00'),
(107, 'HTTT2311052', 'EV-9200', 1, '2026-07-06 09:33:12', '2026-07-06 02:32:13'),
(108, 'HTTT2311052', 'EV-9111', 1, '2026-07-06 09:51:39', '2026-07-06 02:46:36'),
(109, 'HTTT2311052', 'EV-9043', 1, '2026-07-06 10:02:00', '2026-07-06 03:01:06'),
(110, 'HTTT2311052', 'EV-6927', 1, '2026-07-06 10:51:12', '2026-07-06 03:50:12'),
(111, 'HTTT2311052', 'EV-1789', 1, '2026-07-06 10:53:24', '2026-07-06 03:52:57'),
(112, 'HTTT2311052', 'EV-1822', 1, '2026-07-06 11:00:53', '2026-07-06 04:00:09'),
(113, 'HTTT2311052', 'EV-4436', 1, '2026-07-06 11:12:36', '2026-07-06 04:12:14'),
(114, 'HTTT2311052', 'EV-3685', 1, '2026-07-06 11:29:23', '2026-07-06 04:28:44'),
(115, 'HTTT2311052', 'EV-3067', 1, '2026-07-06 11:34:39', '2026-07-06 04:34:14'),
(116, 'HTTT2311052', 'EV-7387', 1, '2026-07-06 11:37:25', '2026-07-06 04:36:48'),
(117, 'HTTT2311052', 'EV-7085', 1, '2026-07-06 11:47:42', '2026-07-06 04:47:13'),
(118, 'HTTT2311052', 'EV-7968', 1, '2026-07-06 11:52:09', '2026-07-06 04:51:39'),
(119, 'HTTT2311052', 'EV-1115', 1, '2026-07-06 12:04:19', '2026-07-06 05:03:03'),
(120, 'HTTT2311052', 'EV-6962', 1, '2026-07-06 12:08:05', '2026-07-06 05:07:05'),
(121, 'HTTT2311052', 'EV-8254', 1, '2026-07-06 12:15:11', '2026-07-06 05:14:51'),
(126, 'HTTT2311052', 'EV-3126', 1, '2026-07-06 14:57:03', '2026-07-06 07:33:31'),
(127, 'HTTT2311052', 'EV-2221', 1, '2026-07-06 15:15:36', '2026-07-06 07:58:16'),
(128, 'HTTT2311052', 'EV-8438', 1, '2026-07-07 08:09:44', '2026-07-07 01:09:20'),
(129, 'HTTT2311052', 'EV-8613', 1, '2026-07-07 08:18:38', '2026-07-07 01:18:09'),
(130, 'HTTT2311052', 'EV-2855', 1, '2026-07-07 09:11:01', '2026-07-07 02:10:40'),
(131, 'HTTT2311052', 'EV-3969', 1, '2026-07-10 15:03:56', '2026-07-10 08:03:29'),
(132, 'HTTT2311052', 'EV-8044', 1, '2026-07-10 15:05:35', '2026-07-10 08:05:05'),
(133, 'HTTT2311052', 'EV-3140', 1, '2026-07-10 15:08:18', '2026-07-10 08:07:50'),
(134, 'HTTT2311052', 'EV-4264', 1, '2026-07-10 15:17:07', '2026-07-10 08:15:38'),
(135, 'HTTT2311052', 'EV-3985', 1, '2026-07-10 15:22:15', '2026-07-10 08:21:51'),
(136, 'HTTT2311052', 'EV-2508', 1, '2026-07-10 15:37:01', '2026-07-10 08:36:15'),
(137, 'HTTT2311052', 'EV-2370', 1, '2026-07-10 15:39:18', '2026-07-10 08:38:35'),
(138, 'HTTT2311052', 'EV-7170', 1, '2026-07-12 14:26:24', '2026-07-10 08:45:24'),
(139, 'HTTT2311052', 'EV-1933', 1, '2026-07-12 14:31:23', '2026-07-12 07:30:02'),
(141, 'HTTT2311051', 'EV-1933', 1, '2026-07-12 15:09:30', '2026-07-12 08:08:58'),
(145, 'HTTT2311052', 'EV-9808', 1, '2026-07-13 21:52:48', '2026-07-13 14:52:48'),
(146, 'HTTT2311051', 'EV-9808', 1, '2026-07-13 21:59:10', '2026-07-13 14:59:10'),
(147, 'HTTT2311021', 'EV-9808', 1, '2026-07-13 22:00:41', '2026-07-13 15:00:40'),
(148, 'HTTT2311009', 'EV-9808', 1, '2026-07-13 22:07:55', '2026-07-13 15:07:55'),
(149, 'HTTT2311011', 'EV-9808', 1, '2026-07-13 22:09:25', '2026-07-13 15:09:25'),
(150, 'HTTT2311032', 'EV-9808', 1, '2026-07-13 22:12:16', '2026-07-13 15:12:16'),
(151, 'HTTT2311024', 'EV-9808', 1, '2026-07-13 22:21:30', '2026-07-13 15:21:30'),
(152, 'HTTT2311010', 'EV-8258', 1, '2026-07-14 19:19:11', '2026-07-14 12:10:17'),
(153, 'HTTT2311011', 'EV-8258', 1, '2026-07-14 19:17:58', '2026-07-14 12:14:22'),
(156, 'HTTT2311051', 'EV-8516', 1, '2026-07-16 15:12:48', '2026-07-16 08:08:34'),
(157, 'HTTT2311052', 'EV-8516', 1, '2026-07-16 15:17:10', '2026-07-16 08:16:31'),
(158, 'HTTT2311011', 'EV-8516', 0, NULL, '2026-07-16 08:29:22');

-- --------------------------------------------------------

--
-- Table structure for table `faculties`
--

CREATE TABLE `faculties` (
  `id` int(11) NOT NULL,
  `faculty_code` varchar(20) NOT NULL,
  `faculty_name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `faculties`
--

INSERT INTO `faculties` (`id`, `faculty_code`, `faculty_name`, `created_at`) VALUES
(1, 'HTTT', 'Hệ thống Thông tin (HTTT)', '2026-07-01 03:52:06'),
(2, 'KTPM', 'Kỹ thuật Phần mềm (KTPM)', '2026-07-01 03:52:06'),
(3, 'KHMT', 'Khoa học Máy tính (KHMT)', '2026-07-01 03:52:06'),
(5, 'TTNT', 'Trí tuệ Nhân tạo (TTNT)', '2026-07-01 04:06:53'),
(6, 'ANMT', 'An toàn Thông tin (ANMT)', '2026-07-01 04:06:53'),
(7, 'CNTT', 'Công nghệ Thông tin (CNTT)', '2026-07-01 04:06:53');

-- --------------------------------------------------------

--
-- Table structure for table `location_presets`
--

CREATE TABLE `location_presets` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `location_presets`
--

INSERT INTO `location_presets` (`id`, `name`, `latitude`, `longitude`, `created_at`) VALUES
(7, 'nha', 10.82200000, 106.62570000, '2026-07-03 13:02:43'),
(8, 'Vị trí mới', 16.16670000, 107.83330000, '2026-07-04 11:53:04'),
(9, 'nhà1', 10.02106400, 105.73338900, '2026-07-06 01:59:38'),
(10, 'phòng máy 4', 10.04733600, 105.76733600, '2026-07-10 08:01:46'),
(11, 'nhà', 10.02101100, 105.73335000, '2026-07-13 14:51:55');

-- --------------------------------------------------------

--
-- Table structure for table `proofs`
--

CREATE TABLE `proofs` (
  `id` varchar(50) NOT NULL,
  `student_id` int(11) NOT NULL,
  `event_id` varchar(20) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `image_hash` varchar(64) DEFAULT NULL,
  `ocr_match_percent` float DEFAULT 0,
  `ai_note` text DEFAULT NULL,
  `phash_warning` tinyint(1) DEFAULT 0,
  `status` varchar(20) DEFAULT 'pending',
  `admin_comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `ocr_text` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `proofs`
--

INSERT INTO `proofs` (`id`, `student_id`, `event_id`, `image_url`, `image_hash`, `ocr_match_percent`, `ai_note`, `phash_warning`, `status`, `admin_comment`, `created_at`, `ocr_text`) VALUES
('PR_1782900590', 31, 'EV-8540', '/uploads/1782958198734-284992874.png', 'afb93673d10d79b6c046cf4e9439b24cc07389e992c1d207387265bb6da9c78c', 0, NULL, 1, 'approved', '', '2026-07-02 02:09:59', NULL),
('PR_1782978876_476', 31, 'EV-9330', '/uploads/1782978992567-196889888.png', 'afb81ab1c10f6cf6d046cf4a9531b3ccc056cd63e6c9e60d3e30258d69ecdb90', 0, NULL, 1, 'pending', NULL, '2026-07-02 07:56:33', NULL),
('PR_1783097758_176', 54, 'EV-8933', '/uploads/1783097753319-894514544.png', 'ca64cb591d59362666fb68ab5da552a372cb659524963c4631db231a2e56cc5b', 0, NULL, 1, 'approved', '', '2026-07-03 16:55:58', NULL),
('PR_1783098075_762', 54, 'EV-9685', '/uploads/1783098074948-567288886.png', 'd5451e2a6a3868fc60fc68f06bd03fc23f802ecbe83ce83efc3c9d0b97039543', 0, NULL, 0, 'approved', '', '2026-07-03 17:01:15', NULL),
('PR_1783124939_657', 54, 'EV-2862', '/uploads/1783124933206-586401372.png', 'b5594baa4bae4aae4aa66a266aa648a37bb0499349b1f4b243f66e666266b647', 0, NULL, 0, 'rejected', '', '2026-07-04 00:28:59', NULL),
('PR_1783167068_276', 54, 'EV-6737', '/uploads/1783167061626-547189464.jpg', 'eaa0957b859f6b80957868a790db3d21d8764699950ecc1c91e37e262f1b72f1', 0, NULL, 0, 'approved', '', '2026-07-04 12:11:08', NULL),
('PR_1783167404_643', 54, 'EV-4111', '/uploads/1783167403855-420944170.jpg', 'caa185bd3e4c6cf7915515730ec67d5ff550378924ad322bc8a3328c81bbd239', 0, NULL, 0, 'approved', '', '2026-07-04 12:16:44', NULL),
('PR_1783167419_619', 54, 'EV-4111', '/uploads/1783167419484-999227904.png', 'fd347e8d7c16b85b929557b00d24e9a9e696424952e13c76c80f12fc355fb813', 0, NULL, 0, 'approved', '', '2026-07-04 12:16:59', NULL),
('PR_1783167982_891', 54, 'EV-9455', '/uploads/1783167982478-327883009.png', 'af0390cc707ccb3be0b0c86598e467b39a5b338c64843733cccd9b36c36b4cbd', 0, NULL, 0, 'approved', '', '2026-07-04 12:26:22', NULL),
('PR_1783168014_925', 54, 'EV-4746', '/uploads/1783168014010-365281117.jpg', 'ae43c08f916a2f7443ac38830fd890fcf093e52b4e731bd42dee761bd26ce125', 0, NULL, 0, 'approved', '', '2026-07-04 12:26:54', NULL),
('PR_1783168040_0', 54, 'EV-4746', '/uploads/1783168040352-477316474.jpg', '84079e1f63c770f1c13847ef8797d6ef4a39aadf0a33b24d4925283f95174421', 0, NULL, 0, 'approved', '', '2026-07-04 12:27:20', NULL),
('PR_1783182993_543', 54, 'EV-9723', '/uploads/1783182985766-917381877.png', 'd822807ff79da389f7d8a354f7208977c0237cef8817771808a203f677088df6', 0, NULL, 0, 'approved', '', '2026-07-04 16:36:33', NULL),
('PR_1783183198_703', 54, 'EV-9723', '/uploads/1783183197966-532954921.png', 'd822807ff7dda389f7d8a374f7208877c0215caf8817771808a227f677088df6', 0, NULL, 0, 'approved', '', '2026-07-04 16:39:58', NULL),
('PR_1783183227_975', 54, 'EV-9723', '/uploads/1783183226364-343963431.png', 'd822807ff7dda389f7d8a374f7208877c0215caf8817771808a227f677088df6', 0, NULL, 0, 'rejected', '', '2026-07-04 16:40:27', NULL),
('PR_1783183282_215', 54, 'EV-9723', '/uploads/1783183281690-800309351.png', 'ead5c06e85ea8fe0c0ff60be40bf4e8407c0e280a544be043d7f787561f773c6', 0, NULL, 0, 'rejected', '', '2026-07-04 16:41:22', NULL),
('PR_1783183338_138', 54, 'EV-9723', '/uploads/1783183338090-138674360.png', 'd822807ff7dda389f7d8a374f7208877c0215caf8817771808a227f677088df6', 0, NULL, 0, 'rejected', '', '2026-07-04 16:42:18', NULL),
('PR_1783185612_357', 54, 'EV-9723', '/uploads/1783185612284-824974635.png', 'd822807ff7dda389f7d8a374f7208877c0215caf8817771808a227f677088df6', 0, NULL, 0, 'rejected', '', '2026-07-04 17:20:12', NULL),
('PR_1783185958_173', 54, 'EV-9723', '/uploads/1783185957033-673813608.png', 'd822807ff7dda389f7d8a374f7208877c0215caf8817771808a227f677088df6', 0, NULL, 1, 'rejected', '', '2026-07-04 17:25:58', NULL),
('PR_1783186015_601', 54, 'EV-9723', '/uploads/1783186014498-273452493.png', 'd822807ff7dda389f7d8a374f7208877c0215caf8817771808a227f677088df6', 0, NULL, 1, 'rejected', '', '2026-07-04 17:26:55', NULL),
('PR_1783186192_896', 54, 'EV-9723', '/uploads/1783186192227-675786310.png', 'd822807ff7dda389b7d8a374f7208877c0215caf8817775808a227f677088df6', 0, NULL, 1, 'rejected', '', '2026-07-04 17:29:52', NULL),
('PR_1783186219_615', 54, 'EV-9723', '/uploads/1783186218463-797069969.png', '89767c8923d8722368cc0df27c2785d87e27a3dc5c8ca23705eed8832777dd88', 0, NULL, 0, 'rejected', '', '2026-07-04 17:30:19', NULL),
('PR_1783227196_865', 54, 'EV-8563', '/uploads/1783227191026-141030448.png', 'c7a58e0e381b31b3c72cc46c69f3381b963dc5e5c646c796c39398f3902ce78c', 0, NULL, 0, 'approved', '', '2026-07-05 04:53:16', NULL),
('PR_1783227915_632', 54, 'EV-9712', '/uploads/1783227915467-53441717.png', 'e49b318e9b24ce719f249b2664db649bbb8c6c9966db33863666cc719b249b20', 0, NULL, 0, 'approved', '', '2026-07-05 05:05:15', NULL),
('PR_1783228012_758', 54, 'EV-9712', '/uploads/1783228011465-223206828.png', '89767c8923d8722368cc0df27c2785d87e27a3dc5c8ca23705eed8832777dd88', 0, NULL, 0, 'approved', '', '2026-07-05 05:06:52', NULL),
('PR_1783228085_823', 54, 'EV-9712', '/uploads/1783228084439-314159950.png', '9e97a014ede9b836fda8773affc47f5705c113b3428d325ca87689e9301a45c0', 0, NULL, 0, 'approved', '', '2026-07-05 05:08:05', NULL),
('PR_1783228131_994', 54, 'EV-9712', '/uploads/1783228130386-70406266.png', '9e97a014ede9b836fda8773affc47f5705c113b3428d325ca87689e9301a45c0', 0, NULL, 1, 'approved', '', '2026-07-05 05:08:51', NULL),
('PR_1783228228_565', 54, 'EV-9712', '/uploads/1783228228142-556127952.png', '89767c8923d8722368cc0df27c2785d87e27a3dc5c8ca23705eed8832777dd88', 0, NULL, 1, 'approved', '', '2026-07-05 05:10:28', NULL),
('PR_1783228398_263', 54, 'EV-9712', '/uploads/1783228398424-311242499.png', 'd822807ff7dda389b7d8a374f7208877c0215caf8817775808a227f677088df6', 0, NULL, 1, 'approved', '', '2026-07-05 05:13:18', NULL),
('PR_1783228759_30', 54, 'EV-2670', '/uploads/1783228758666-970716671.png', '8abf0eb72f4f85eb855a854f0f9f1e9f8e9504b583e3a52cd303356865a2340c', 0, NULL, 0, 'approved', '', '2026-07-05 05:19:19', NULL),
('PR_1783228784_875', 54, 'EV-2670', '/uploads/1783228783514-92617501.webp', 'cebe1afe2f4f85a5b55dcd5f58b65acac0b5ee8ce161a504f032716960a0f021', 0, NULL, 0, 'rejected', '', '2026-07-05 05:19:44', NULL),
('PR_1783228799_985', 54, 'EV-2670', '/uploads/1783228798838-882993112.webp', 'cebe1afe2f4f85a5b55dcd5f58b65acac0b5ee8ce161a504f032716960a0f021', 0, NULL, 1, 'rejected', '', '2026-07-05 05:19:59', NULL),
('PR_1783228837_450', 54, 'EV-2670', '/uploads/1783228837086-470452714.webp', 'af7e35ee748166010b7a487e1a7e01e835a1f6052ad183c997efdb7f8835c811', 0, NULL, 0, 'rejected', '', '2026-07-05 05:20:37', NULL),
('PR_1783229702_19', 54, 'EV-2670', '/uploads/1783229700139-76304750.jpeg', '87fba7e3f004f00107778b5dda78daaadca56835f85132c025d437e334c36d83', 0, NULL, 0, 'rejected', '', '2026-07-05 05:35:02', NULL),
('PR_1783230795_134', 54, 'EV-2670', '/uploads/1783230795015-839764328.jpeg', '87fba7e3f004f00107778b5dda78daaadca56835f85132c025d437e334c36d83', 0, NULL, 1, 'rejected', '', '2026-07-05 05:53:15', NULL),
('PR_1783230898_926', 54, 'EV-2670', '/uploads/1783230896268-106926314.png', 'b74549bb49bb48a24aaa48a249b268a3499349bbc893b193a3f7b6e4b666b667', 0, 'Thiếu thông tin: MSSV, Tên, Tên Sự Kiện | Cảnh báo: Không giống mẫu hoạt động', 0, 'rejected', '', '2026-07-05 05:54:58', 'file edit insert view... mssv... application programming interface...'),
('PR_1783231274_310', 54, 'EV-2670', '/uploads/1783231273354-647210443.png', 'b35612e8ed1f45946916d2e93a6a10f42d890f32e5856c7392d4f972964dbe53', 0, 'Thiếu thông tin: MSSV, Tên, Tên Sự Kiện | Cảnh báo: Không giống mẫu hoạt động', 0, 'rejected', '', '2026-07-05 06:01:14', '€ cg (0 © localhost:5196\n\nqe ff © th»\net ® lich hoc, lich thi the... ‘6 drive ctia t6i - goo... \"google antigravity 4& php-myadmin.net /.. if0_41322676 (goldc... €) qha1905/goldcinema client id for web a...\n\n® get started | gitgua. >» (© all bookmarks\n\nthu vién viét sdchméi banchay vanhoc —kinh té\n\nthigunhi — gidm gia\n\ntinh hoa van hoc\ntrong tam tay\n\nkham pha kho tang tri thifc vit vai uu dai [an dén 40% cho cac tac\npham kinh dién va hién dai vitalénké.\n\nkhadm pha ngay xem khuyén mai\n\ndanh muc n6i bat\n\n'),
('PR_1783254639_289', 54, 'EV-9712', '/uploads/1783254633650-490489952.png', 'd822807ff7dda389f7d8a374f7208877c0215caf8817771808a227f677088df6', 0, 'Thiếu thông tin: MSSV, Tên, Tên Sự Kiện | Cảnh báo: Không giống mẫu hoạt động | Cảnh báo trùng lặp ảnh/nội dung', 1, 'rejected', '', '2026-07-05 12:30:39', 'trang chu thele kehoach qa\n\n» can tho\n\nuy -\n5) hoi dong pho! hop q uat thanh pho can tho\ncuo en\n; 2 8/10 wg\n“tim hieu e thi sinh: nguyen lam quang at bau cu\n\nha\n\ndai bieu quoc hoi reign 7025984 dong nhan dan”\n\nnm ~_\ntren dia £ se ben gen es can tho\n!\n|\n\nthdi gian: tu 00< way 22/12/2025\n\n'),
('PR_1783314485_77', 31, 'EV-6962', '/uploads/1783314485747-747385148.png', 'FACK_HASH', 85, 'Hợp lệ', 0, 'approved', NULL, '2026-07-06 05:08:05', 'TEST'),
('PR_1783320550_847', 31, 'EV-2549', '/uploads/1783320545445-195550178.png', 'N/A', 0, 'Lỗi kết nối máy chủ AI - Chuyển Cán bộ duyệt thủ công', 0, 'approved', '', '2026-07-06 06:49:10', ''),
('PR_1783320919_651', 31, 'EV-5776', '/uploads/1783322720922-49963897.jpg', '85fa6a1f6a952e056e953a416ac43e806b5495286bdb95bbc17995aec07a91fa', 33, 'Thiếu thông tin: MSSV, Tên', 0, 'approved', '', '2026-07-06 07:25:21', 'hiến máu cứu người\nmột nghĩa cử cao đẹp\n\n1. giấy chứng nhận này được trao cho người hiến máu sau\nmỗi lần hiền máu tình nguyện.\n\n2. có giá tị để được truyền máu miễn phí bằng số lượng\nmau đã hién, khi bản thân người hiến máu có nhu cầu sử dụng\nmáu tại tắt cả các cơ sở y tế công lập trên toàn quốc.\n\n3. người hiến máu cần xuất trình giấy chứng nhận này dé\nlàm cơ sở cho các cơ sở y tế thực hiện việc truyền máu miễn phi.\n\n4. cơ sở y tế có trách nhiệm ký, đóng dấu, xác nhận số\nlượng máu đã truyền miễn phí cho người hiển máu vào giấy\nchứng nhận.\n\nchung nhận của cơ sở y tế\nđã truyen mau\n\nngày........tháng,...... năm.\nsố lượng:\n\ncộng hoa xã hội chủ nghĩa việt nam\nđộc lập - tự do - hạnh phúc\n\ngiấy chứng nhận\nhiến mâu tình nguyện\n\nbcd vận động biến mau tỉnh nguyện tinh/tp.... cẩn thơ\n„chứng nhận:\n\nông/bà: nguyen dlúnh, định, uth\n\nsinh ngày: độ s08... jad005.\n\nđã biến máu tình nguyện .\ntại cơ sở tiếp nhận máubệnh viện hh-tm tp.can thơ\n\nân ái của. ônglbà.\npep\n\n'),
('PR_1783323241_825', 31, 'EV-3126', '/uploads/1783324621928-731125875.jpg', 'd0257f002fd43fa42b521f7c6f5a0ef26b5a07762b6e93f239d890f434a4906c', 100, 'Hợp lệ: Trùng khớp Danh tính & Sự kiện', 0, 'approved', '', '2026-07-06 07:57:03', 'HIẾN MAU CỬU NGƯỜI\nMỘT NGHĨA CỬ CAO ĐẸP\n\n1. Giấy chứng nhận này được trao cho người hiển máu sins\n\nlân hiễn máu tinh nguyện.\n\n2. Có gia trị dé được truyền máu miễn phi bằng sd lượng\nmau đã hiến. khi bản thân người hiển máu có nhu cầu sử dụng\nmẫu tại tắt cả các cơ sở y tế công lập trên toàn quốc.\n\n3. Người hiến máu cân xuất tian Giây chứng nhận nay để\n\nm cơ sở cho các cơ sở y tế thục n uyễn máu miễn phi\n\n4. Cơ sở y tế có trách nhé: g dấu, xác nhận số\n\nmau vào giấy\nchứng nhận.\n\n—ễeễềễễ————\n\nCHUNG NHAN CUA CƠ SỞ Y TẾ\nĐÃ TRUYEN MAU\n\nCONG HOA XÃ HỘI CHU NGHĨA VIET NAM\nĐộc lập - Tự do - Hạnh phúc\n\nGIẤY CHỨNG NHẬN\nHIẾN MÁU TINH NGUYEN\nBOD và : stp Cần Thị\n\n_ ‘aes an:\nÔng/Ba.... He tết du. cnh nn\nSinh ngày:. ch. atts\n\nSố CCCD:..Cf9465(051À5 |\nĐịa chi:..Aa. #0 gác . Tinh\n\ncần, Gandy\n\nĐã hiển ma\nTai cơ Sở tiêp\nSô lượng: +\nNgười bệ\n\noi Ban capa\n\n'),
('PR_1783324725_330', 31, 'EV-2221', '/uploads/1783325733838-290606093.png', 'e7fa331c3b86ccdab805ccfbc165992684f8492784393a076d1c1be23f134eda', 100, 'Hợp lệ: Trùng khớp Danh tính & Sự kiện', 0, 'approved', NULL, '2026-07-06 08:15:36', 'Ï WN\nBAN CHAP HANH DOAN THANH NIÊN CỘNG SAN HỒ CHÍ MINH\n\'TRƯỜNG ĐẠI HỌC KỸ THUẬT - CÔNG NGHỆ CAN THƠ\n\nTẶNG\n\ný x\nK GIAY KHEN\n\n&\n\nK DOAN KHOA CÔNG NGHỆ THONG TIN\n\n& Dé có thành tích xuất sắc trong công tác Đoàn và phong trào thank niên,\nK năm học 2025 - 2026\n\n&\n\nCin Ces ngụ Tag 6 năm 200k\n1 AP HANH DOAN TRƯỜNG -/_\nNà ‘THU —\n\nSihighll~QDIDTN.DHKTCN\n\nŨ\n9000) loo a9]\n90009) CER\n\n'),
('PR_1783390261_386', 31, 'EV-2855', '/uploads/1783390257650-645071206.png', 'afb936f1c14ee936d046cf589431f2ccc076896b864172073a1c25f96de9db0d', 0, 'Hệ thống xử lý', 0, 'rejected', 'ko thích ', '2026-07-07 02:11:01', ''),
('PR_1783671735_945', 31, 'EV-3985', '/uploads/1783671731026-231813512.png', 'ebedd6db854a7cb4c027cb4a9412b927d01331b9c1e1c9669d44379778b1c2dc', 0, 'Hệ thống xử lý', 0, 'pending', NULL, '2026-07-10 08:22:15', ''),
('PR_1783672758_971', 31, 'EV-2370', '/uploads/1783672757786-712846619.png', 'ebedd6db854a7cb4c027cb4a9412b927d01331b9c1e1c9669d44379778b1c2dc', 0, 'Hệ thống xử lý | Cảnh báo trùng lặp ảnh/nội dung', 1, 'pending', NULL, '2026-07-10 08:39:18', ''),
('PR_1783840505_657', 31, 'EV-7170', 'Không có ảnh', 'N/A', 100, 'Sinh viên đã nộp bài (File/Link). Không có ảnh minh chứng.', 0, 'approved', NULL, '2026-07-12 07:26:24', NULL),
('PR_1784031060_237', 35, 'EV-8258', '/uploads/1784031054764-86174735.png', 'efb11e73c54ce9b6d0420f4e9431f24cc05e0de1c6c9c29d3a3ccd3b2d29cb95', 0, 'Hệ thống xử lý', 0, 'approved', '', '2026-07-14 12:11:00', NULL),
('PR_1784031071_86', 35, 'EV-8258', '/uploads/1784031070699-377862846.png', 'efb11e73c54ce9b6d0420f4e9431f24cc05e0de1c6c9c29d3a3ccd3b2d29cb95', 0, 'Hệ thống xử lý | Cảnh báo trùng lặp ảnh', 1, 'approved', '', '2026-07-14 12:11:11', NULL),
('PR_1784031078_556', 35, 'EV-8258', '/uploads/1784031077786-897243568.png', 'efb11e73c54ce9b6d0420f4e9431f24cc05e0de1c6c9c29d3a3ccd3b2d29cb95', 0, 'Hệ thống xử lý | Cảnh báo trùng lặp ảnh', 1, 'approved', '', '2026-07-14 12:11:18', NULL),
('PR_1784031272_261', 60, 'EV-8258', '/uploads/1784031271637-270306251.png', 'efb11e73c54ce9b6d0420f4e9431f24cc05e0de1c6c9c29d3a3ccd3b2d29cb95', 0, 'Hệ thống xử lý | Cảnh báo trùng lặp ảnh', 1, 'pending', NULL, '2026-07-14 12:14:32', NULL),
('PR_1784031462_651', 60, 'EV-8258', '/uploads/1784031461060-772512289.jpg', 'afffb70a1af2ec0a350c83ba5ae2b45f6c08b30213e2ced9055ff9064bf0b641', 40, 'Hệ thống xử lý', 0, 'pending', NULL, '2026-07-14 12:17:42', NULL),
('PR_1784031478_857', 60, 'EV-8258', '/uploads/1784031477286-296481390.jpg', '8fff94283f1dccaa7888b74d6480eb8913ff99bb6880b7675e00cf93f5003862', 40, 'Hệ thống xử lý', 0, 'pending', NULL, '2026-07-14 12:17:58', NULL),
('PR_1784031533_691', 35, 'EV-8258', '/uploads/1784031532076-861840642.jpg', 'afffb70a1af2ec0a350c83ba5ae2b45f6c08b30213e2ced9055ff9064bf0b641', 40, 'Hệ thống xử lý | Cảnh báo trùng lặp ảnh', 1, 'pending', NULL, '2026-07-14 12:18:53', NULL),
('PR_1784031551_923', 35, 'EV-8258', '/uploads/1784031550566-704355340.jpg', '8fff94283f1dccaa7888b74d6480eb8913ff99bb6880b7675e00cf93f5003862', 40, 'Hệ thống xử lý | Cảnh báo trùng lặp ảnh', 1, 'pending', NULL, '2026-07-14 12:19:11', NULL),
('PR_AUTO_1783303234_983', 31, 'EV-4695', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 02:00:34', NULL),
('PR_AUTO_1783303810_308', 31, 'EV-3827', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 02:10:10', NULL),
('PR_AUTO_1783304492_558', 31, 'EV-3657', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 02:21:32', NULL),
('PR_AUTO_1783305192_132', 31, 'EV-9200', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 02:33:12', NULL),
('PR_AUTO_1783306299_979', 31, 'EV-9111', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 02:51:39', NULL),
('PR_AUTO_1783306920_916', 31, 'EV-9043', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 03:02:00', NULL),
('PR_AUTO_1783309872_622', 31, 'EV-6927', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 03:51:12', NULL),
('PR_AUTO_1783310004_239', 31, 'EV-1789', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 03:53:24', NULL),
('PR_AUTO_1783310453_542', 31, 'EV-1822', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 04:00:53', NULL),
('PR_AUTO_1783311156_3', 31, 'EV-4436', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 04:12:36', NULL),
('PR_AUTO_1783312645_445', 31, 'EV-7387', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 04:37:25', NULL),
('PR_AUTO_1783313262_941', 31, 'EV-7085', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 04:47:42', NULL),
('PR_AUTO_1783313529_774', 31, 'EV-7968', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 04:52:09', NULL),
('PR_AUTO_1783314247_377', 31, 'EV-1115', '/uploads/1783314259956-841318879.png', 'FACK_HASH', 85, 'Hợp lệ', 0, 'approved', NULL, '2026-07-06 05:04:19', 'TEST'),
('PR_AUTO_1783314911_69', 31, 'EV-8254', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 05:15:11', NULL),
('PR_AUTO_1783315672_733', 31, 'EV-9672', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 05:27:52', NULL),
('PR_AUTO_1783315748_555', 31, 'EV-1044', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-06 05:29:08', NULL),
('PR_AUTO_1783386584_119', 31, 'EV-8438', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-07 01:09:44', NULL),
('PR_AUTO_1783387118_33', 31, 'EV-8613', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-07 01:18:38', NULL),
('PR_AUTO_1783670636_19', 31, 'EV-3969', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-10 08:03:56', NULL),
('PR_AUTO_1783670735_282', 31, 'EV-8044', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-10 08:05:35', NULL),
('PR_AUTO_1783670898_267', 31, 'EV-3140', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-10 08:08:18', NULL),
('PR_AUTO_1783671427_438', 31, 'EV-4264', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-10 08:17:07', NULL),
('PR_AUTO_1783672621_900', 31, 'EV-2508', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-10 08:37:01', NULL),
('PR_AUTO_1783841483_99', 31, 'EV-1933', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-12 07:31:23', NULL),
('PR_AUTO_1783843770_358', 50, 'EV-1933', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-12 08:09:30', NULL),
('PR_AUTO_1783954368_275', 31, 'EV-9808', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-13 14:52:48', NULL),
('PR_AUTO_1783954750_443', 50, 'EV-9808', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-13 14:59:10', NULL),
('PR_AUTO_1783954841_739', 63, 'EV-9808', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-13 15:00:41', NULL),
('PR_AUTO_1783955275_417', 70, 'EV-9808', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-13 15:07:55', NULL),
('PR_AUTO_1783955365_649', 60, 'EV-9808', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-13 15:09:25', NULL),
('PR_AUTO_1783955536_866', 42, 'EV-9808', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-13 15:12:16', NULL),
('PR_AUTO_1783956090_963', 47, 'EV-9808', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-13 15:21:30', NULL),
('PR_AUTO_1784189568_995', 50, 'EV-8516', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-16 08:12:48', NULL),
('PR_AUTO_1784189830_540', 31, 'EV-8516', 'Check-in trực tiếp (Không cần minh chứng)', 'N/A', 100, 'Hệ thống tự động duyệt trực tiếp qua check-in QR/GPS', 0, 'approved', NULL, '2026-07-16 08:17:10', NULL);

--
-- Triggers `proofs`
--
DELIMITER $$
CREATE TRIGGER `trg_proof_approved_insert` AFTER INSERT ON `proofs` FOR EACH ROW BEGIN
    DECLARE v_mssv VARCHAR(20);
    DECLARE v_points INT;
    DECLARE v_category VARCHAR(100);
    DECLARE v_criteria_id INT;
    DECLARE v_max_points INT;

    IF NEW.status = 'approved' THEN
        SELECT mssv INTO v_mssv FROM users WHERE id = NEW.student_id LIMIT 1;
        SELECT points, category INTO v_points, v_category FROM events WHERE id = NEW.event_id LIMIT 1;
        SELECT id, max_points INTO v_criteria_id, v_max_points FROM criteria WHERE title = v_category LIMIT 1;
        
        IF v_criteria_id IS NOT NULL THEN
            IF EXISTS (SELECT 1 FROM student_criteria_points WHERE mssv = v_mssv AND criteria_id = v_criteria_id) THEN
                UPDATE student_criteria_points 
                SET current_points = LEAST(current_points + v_points, v_max_points)
                WHERE mssv = v_mssv AND criteria_id = v_criteria_id;
            ELSE
                INSERT INTO student_criteria_points (mssv, criteria_id, current_points) 
                VALUES (v_mssv, v_criteria_id, LEAST(v_points, v_max_points));
            END IF;
            
            UPDATE users SET point_wallet = point_wallet + v_points WHERE id = NEW.student_id;
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_proof_approved_update` AFTER UPDATE ON `proofs` FOR EACH ROW BEGIN
    DECLARE v_mssv VARCHAR(20);
    DECLARE v_points INT;
    DECLARE v_criteria_id INT;
    DECLARE v_max_points INT;
    DECLARE v_current_points INT DEFAULT NULL;
    DECLARE v_actual_diff INT DEFAULT 0;

    -- TH1: DUYỆT MINH CHỨNG
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        SELECT u.mssv, e.points, c.id, c.max_points 
        INTO v_mssv, v_points, v_criteria_id, v_max_points
        FROM events e
        JOIN criteria c ON c.title = e.category
        JOIN users u ON u.id = NEW.student_id
        WHERE e.id = NEW.event_id LIMIT 1;
        
        IF v_criteria_id IS NOT NULL THEN
            SELECT current_points INTO v_current_points 
            FROM student_criteria_points WHERE mssv = v_mssv AND criteria_id = v_criteria_id LIMIT 1;
            
            IF v_current_points IS NOT NULL THEN
                -- Tính số điểm thực tế được phép cộng (không vượt max)
                SET v_actual_diff = LEAST(v_current_points + v_points, v_max_points) - v_current_points;
                IF v_actual_diff > 0 THEN
                    UPDATE student_criteria_points SET current_points = current_points + v_actual_diff WHERE mssv = v_mssv AND criteria_id = v_criteria_id;
                    UPDATE users SET point_wallet = point_wallet + v_actual_diff WHERE id = NEW.student_id;
                END IF;
            ELSE
                SET v_actual_diff = LEAST(v_points, v_max_points);
                INSERT INTO student_criteria_points (mssv, criteria_id, current_points) VALUES (v_mssv, v_criteria_id, v_actual_diff);
                UPDATE users SET point_wallet = point_wallet + v_actual_diff WHERE id = NEW.student_id;
            END IF;
        END IF;
    END IF;
    
    -- TH2: HỦY DUYỆT MINH CHỨNG
    IF OLD.status = 'approved' AND NEW.status != 'approved' THEN
        SELECT u.mssv, e.points, c.id 
        INTO v_mssv, v_points, v_criteria_id
        FROM events e
        JOIN criteria c ON c.title = e.category
        JOIN users u ON u.id = NEW.student_id
        WHERE e.id = NEW.event_id LIMIT 1;
        
        IF v_criteria_id IS NOT NULL THEN
            SELECT current_points INTO v_current_points 
            FROM student_criteria_points WHERE mssv = v_mssv AND criteria_id = v_criteria_id LIMIT 1;
            
            IF v_current_points IS NOT NULL THEN
                -- Tính số điểm thực tế cần trừ
                SET v_actual_diff = v_current_points - GREATEST(v_current_points - v_points, 0);
                IF v_actual_diff > 0 THEN
                    UPDATE student_criteria_points SET current_points = current_points - v_actual_diff WHERE mssv = v_mssv AND criteria_id = v_criteria_id;
                    UPDATE users SET point_wallet = point_wallet - v_actual_diff WHERE id = NEW.student_id;
                END IF;
            END IF;
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `student_criteria_points`
--

CREATE TABLE `student_criteria_points` (
  `id` int(11) NOT NULL,
  `mssv` varchar(20) NOT NULL,
  `criteria_id` int(11) NOT NULL,
  `current_points` int(11) DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_criteria_points`
--

INSERT INTO `student_criteria_points` (`id`, `mssv`, `criteria_id`, `current_points`, `updated_at`) VALUES
(12, 'HTTT2311052', 5, 3, '2026-07-06 05:29:08'),
(14, 'HTTT2311052', 4, 20, '2026-07-07 01:09:44'),
(19, 'HTTT2311052', 1, 8, '2026-07-13 14:52:48'),
(20, 'HTTT2311052', 2, 5, '2026-07-12 07:31:23'),
(21, 'HTTT2311052', 3, 7, '2026-07-16 08:17:10'),
(33, 'HTTT2311051', 2, 3, '2026-07-12 08:09:30'),
(34, 'HTTT2311033', 1, 7, '2026-07-13 14:25:40'),
(37, 'HTTT2311033', 3, 1, '2026-07-13 14:25:36'),
(43, 'HTTT2311051', 1, 3, '2026-07-13 14:59:10'),
(44, 'HTTT2311021', 1, 3, '2026-07-13 15:00:41'),
(45, 'HTTT2311009', 1, 3, '2026-07-13 15:07:55'),
(46, 'HTTT2311011', 1, 3, '2026-07-13 15:09:25'),
(47, 'HTTT2311032', 1, 3, '2026-07-13 15:12:16'),
(48, 'HTTT2311024', 1, 3, '2026-07-13 15:21:30'),
(49, 'HTTT2311010', 1, 9, '2026-07-14 12:12:55'),
(52, 'HTTT2311051', 3, 5, '2026-07-16 08:12:48');

-- --------------------------------------------------------

--
-- Table structure for table `system_settings`
--

CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL,
  `auto_approve` tinyint(1) DEFAULT 1 COMMENT '1: Bật AI tự duyệt, 0: Tắt AI',
  `ocr_threshold` int(11) DEFAULT 66 COMMENT 'Ngưỡng khớp chữ tối thiểu (%)',
  `hamming_distance` int(11) DEFAULT 10 COMMENT 'Khoảng cách Hamming chống trùng ảnh',
  `context_points` int(11) DEFAULT 30 COMMENT 'Ngưỡng lọc ảnh bối cảnh',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `system_settings`
--

INSERT INTO `system_settings` (`id`, `auto_approve`, `ocr_threshold`, `hamming_distance`, `context_points`, `updated_at`) VALUES
(1, 1, 66, 8, 60, '2026-07-07 01:02:18');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `mssv` varchar(20) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `avatar` varchar(500) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` enum('classCommittee','student','teacher','admin') DEFAULT 'student',
  `is_locked` tinyint(1) NOT NULL DEFAULT 0,
  `faculty` varchar(100) DEFAULT NULL,
  `point_wallet` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `phone` varchar(20) DEFAULT NULL,
  `chi_doan` varchar(100) DEFAULT NULL,
  `cohort` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `mssv`, `full_name`, `email`, `avatar`, `password`, `role`, `is_locked`, `faculty`, `point_wallet`, `created_at`, `phone`, `chi_doan`, `cohort`) VALUES
(3, 'HTTT2311017', 'Lưu Nhật Đông', 'lndonghttt2311017@student.ctuet.edu.vn\n', '/uploads/1782221215140-666932524.png', '123456', 'admin', 0, 'Hệ thống Thông tin', 120, '2025-10-15 01:10:00', '0923456789', 'HTTT Khóa 2023', NULL),
(31, 'HTTT2311052', 'Nguyễn Minh Anh Tuấn', 'nmatuanhttt2311052@student.ctuet.edu.vn', 'uploads/avatars/21578cef8b79596cca2975af69d0c745.jpg', '$2b$10$VtrGELplYTptVs2Mu7E9cuk3d4YUSd4EyZeZ34y4qpMbc/P7rq7ce', 'admin', 0, 'Hệ thống Thông tin', 43, '2026-06-09 17:13:52', '01010101', 'HTTT2311', NULL),
(32, 'HTTT2311043', 'Nguyễn Anh Kiệt', 'nakiethttt2311043@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(33, 'HTTT2311014', 'Bùi Thành Long', 'btlonghttt2311014@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(34, 'HTTT2311053', 'Trần Thị Ngọc Mỹ', 'tranthingocmy92nd@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(35, 'HTTT2311010', 'Hồ Minh Thiện', 'thienvcf@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 9, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(36, 'HTTT2311042', 'Huỳnh Nguyên Toàn', 'hntoanhttt2311042@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(37, 'HTTT2311004', 'Nguyễn Đức Lương', 'ndluonghttt2311004@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(38, 'HTTT2311019', 'Quách Thành Danh', 'mrthanhdanh2005@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(39, 'HTTT2311054', 'Đỗ Quốc Đạt', 'doquocdatmxst@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(40, 'HTTT2311047', 'Đinh Thị Thu Cúc', 'dttcuchttt2311047@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(41, 'HTTT2311007', 'Ngô Thị Anh Thư', 'ngothianhthu2005ck@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(42, 'HTTT2311032', 'Liễu Hiếu Nhi', 'lhnhihttt2311032@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 3, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(43, 'HTTT2311013', 'Nguyễn Trần An Khang', 'ntakhanghttt2311013@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(44, 'HTTT2311038', 'Trần Thanh Hương', 'tranthanhhuong07102005@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(45, 'HTTT2311055', 'Nguyễn Trung Hậu', 'nthauhttt2311055@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(46, 'HTTT2311026', 'Đỗ Nguyễn Minh Thư', 'donguyenminhthutt2021@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(47, 'HTTT2311024', 'Nguyễn Vũ Khang', 'nvkhanghttt2311024@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 3, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(48, 'HTTT2311022', 'Nguyễn Thị Thùy Trang', 'ntttranghttt2311022@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(49, 'HTTT2311016', 'Doan Thanh Long', 'doanthanhl399@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(50, 'HTTT2311051', 'Trần Quỳnh Mai', 'trankhanh300781@gmail.com', NULL, '123456', 'classCommittee', 0, 'Hệ thống Thông tin', 11, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(51, 'HTTT2311046', 'Trần Thiên Phú', 'ttphuhttt2311046@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(52, 'HTTT2311008', 'Lê Hồ Quang Thông', 'lhqthonghttt2311008@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(53, 'HTTT2311018', 'Phan Đặng Đức Nguyên', 'ducnguyen612005@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(54, 'HTTT2311033', 'Nguyễn Lâm Quang Hà', 'nlqhahttt2311033@student.ctuet.edu.vn', 'https://lh3.googleusercontent.com/a/ACg8ocLEsnrqnM9eCKREh59ygiiuRtGM7Ge9WDI9MIGKCTnv5q5knA=s96-c', '123456', 'student', 0, 'Hệ thống Thông tin', 8, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(55, 'HTTT2311049', 'Nguyễn Ngọc Nhi', 'nnnhihttt2311049@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(56, 'HTTT2311036', 'Nguyễn Hữu Hào', 'nhhaohttt2311036@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(57, 'HTTT2311048', 'Nguyễn Thị Cẩm Tiên', 'tiennguyenthicam1905@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(58, 'HTTT2311029', 'Võ Quốc Vinh', 'vqvinhhttt2311029@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(59, 'HTTT2311057', 'Phạm Thúy Huỳnh', 'phamthuyhuynh0101.st@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(60, 'HTTT2311011', 'Phan Trần Minh Khuê', 'minhkhuephantran65@gmail.com', NULL, '123456', 'classCommittee', 0, 'Hệ thống Thông tin', 3, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(61, 'HTTT2311020', 'NGUYỄN ĐẬU TUỆ KHƯƠNG', 'nguyendautuekhuongln@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(62, 'HTTT2311037', 'Nguyễn Trần Duy Khang', 'ntdkhanghttt2311037@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(63, 'HTTT2311021', 'Huỳnh Nguyễn Xuân Thi', 'xuanthi2020cm@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 3, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(64, 'HTTT2311058', 'Huỳnh Thị Bảo Hân', 'htbhanhttt2311058@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(65, 'HTTT2311045', 'Trần Quốc Hùng', 'tqhunghttt2311045@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(66, 'HTTT2311060', 'Võ Hoàng Nhã', 'vhnhahttt2311060@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(67, 'HTTT2311066', 'Hoàng Thị Ngọc Mai', 'htnmaihttt2311066@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(68, 'HTTT2311056', 'PHẠM VĂN TẤN PHƯỚC', 'pvtp.clx@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(69, 'HTTT2311039', 'Nguyễn Đắc Nhân', 'ndnhanhttt2311039@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(70, 'HTTT2311009', 'Huỳnh Gia Tuấn', 'huynhgiatuan7105@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 3, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(71, 'HTTT2311023', 'Bùi Hữu Lộc', 'huulocbui48@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(72, 'HTTT2311015', 'Hồ Trần Phương Anh', 'htpanhhttt2311015@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(73, 'HTTT2311061', 'Nguyễn Ngọc Tường Vy', 'nntvyhttt2311061@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(74, 'HTTT2311030', 'Phan Thiện Nhân', 'phanthiennhan3007@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(75, 'HTTT2311062', 'Lý Minh Lộc', 'minhloc20052005@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(76, 'HTTT2311064', 'Trần Ngọc Ẩn', 'tnanhttt2311064@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(77, 'HTTT2311040', 'Phạm Hoàng Thiện', 'phthienhttt2311040@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(78, 'HTTT2311006', 'Bùi Diệp Ngọc Hân', 'bdnhanhttt2311006@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(79, 'HTTT2311012', 'Trần Thị Huyền Trân', 'tthtranhttt2311012@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(80, 'HTTT2311025', 'Trần Toàn Phát', 'ttphathttt2311025@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(81, 'HTTT2311063', 'Kha Minh Khang', 'kmkhanghttt2311063@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(82, 'HTTT2311041', 'Đặng Khánh Hoà', 'dkhoahttt2311041@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(83, 'HTTT2311069', 'Lê Nhật Trường', 'lntruonghttt2311069@student.ctuet.edu.vn', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(84, 'HTTT2311065', 'Nguyễn Vũ Hà', 'nguyenduuha@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(85, 'HTTT2311067', 'Phạm Thị Khánh Vy', 'phamthikhanhvy120125@gmail.com', NULL, '123456', 'student', 0, 'Hệ thống Thông tin', 0, '2026-06-23 13:20:28', NULL, 'HTTT Khóa 2023', NULL),
(92, 'NGUYENTUAN452016', 'Anh Tuấn Nguyễn Minh', 'nguyentuan452016@gmail.com', 'https://lh3.googleusercontent.com/a/ACg8ocKZi5z73GZXa_Nc64WKSQ1SVDuBK6m4dU4G747tAb8TYhUUNb0=s96-c', '$2b$10$7PDQby8SC5oSF/ybsHbdXODcS7hHdD8Sc4QdSB6gCT9cLkKIzgazS', 'classCommittee', 0, 'Chưa cập nhật', 0, '2026-06-26 01:23:26', NULL, 'Chưa xếp lớp', NULL),
(93, 'VUIVUICHOI1', 'Chi bi Ghoul Velles', 'vuivuichoi1@gmail.com', '/uploads/1783390582227-482998459.png', '$2b$10$7PDQby8SC5oSF/ybsHbdXODcS7hHdD8Sc4QdSB6gCT9cLkKIzgazS', 'student', 0, 'Chưa cập nhật', 0, '2026-06-26 01:31:58', '', 'Chưa xếp lớp', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `student_id` (`student_id`);

--
-- Indexes for table `criteria`
--
ALTER TABLE `criteria`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `criteria_categories`
--
ALTER TABLE `criteria_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `criteria_sub_categories`
--
ALTER TABLE `criteria_sub_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `parent_id` (`parent_id`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `event_registrations`
--
ALTER TABLE `event_registrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `faculties`
--
ALTER TABLE `faculties`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `faculty_code` (`faculty_code`);

--
-- Indexes for table `location_presets`
--
ALTER TABLE `location_presets`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `proofs`
--
ALTER TABLE `proofs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `student_criteria_points`
--
ALTER TABLE `student_criteria_points`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `mssv_criteria_unique` (`mssv`,`criteria_id`),
  ADD KEY `criteria_id` (`criteria_id`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `mssv` (`mssv`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=142;

--
-- AUTO_INCREMENT for table `criteria`
--
ALTER TABLE `criteria`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `event_registrations`
--
ALTER TABLE `event_registrations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=159;

--
-- AUTO_INCREMENT for table `faculties`
--
ALTER TABLE `faculties`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `location_presets`
--
ALTER TABLE `location_presets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `student_criteria_points`
--
ALTER TABLE `student_criteria_points`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT for table `system_settings`
--
ALTER TABLE `system_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `criteria_sub_categories`
--
ALTER TABLE `criteria_sub_categories`
  ADD CONSTRAINT `criteria_sub_categories_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `criteria_categories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `student_criteria_points`
--
ALTER TABLE `student_criteria_points`
  ADD CONSTRAINT `student_criteria_points_ibfk_1` FOREIGN KEY (`criteria_id`) REFERENCES `criteria` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
