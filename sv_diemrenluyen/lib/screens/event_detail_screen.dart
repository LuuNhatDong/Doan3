import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../core/app_config.dart';
import 'notification_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'qr_scan_screen.dart'; 
import 'evidence_submit_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final bool isRegistered;
  final String? mssv;
  final VoidCallback onStateChanged;

  const EventDetailScreen({
    Key? key,
    required this.event,
    required this.isRegistered,
    required this.mssv,
    required this.onStateChanged,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final Dio _dio = Dio();
  late bool _isRegistered;
  bool _isOngoing = false;
  bool _isCheckedIn = false; 

  @override
  void initState() {
    super.initState();
    _isRegistered = widget.isRegistered;
    
    // Chuẩn hóa kiểm tra score_type
    final String scoreType = (widget.event['score_type'] ?? 'once').toString().trim().toLowerCase();
    bool isMultiple = scoreType == 'multiple';
    
    if (isMultiple) {
      _isCheckedIn = widget.event['is_checked_in'] == 1 || widget.event['is_checked_in'] == '1' || widget.event['is_checked_in'] == true;
    } else {
      _isCheckedIn = widget.event['is_checked_in'] == 1 || 
                     widget.event['is_checked_in'] == '1' || 
                     widget.event['is_checked_in'] == true || 
                     widget.event['proof_status'] != null;
    }

    _checkEventStatus();
  }

  bool _isFacultyLimitReached() {
    if (widget.event['faculty_limits'] == null || widget.event['faculty_limits'].toString().isEmpty) {
      return false; 
    }

    try {
      final String mssv = (widget.mssv ?? '').toString().toUpperCase().trim();
      String studentNganh = mssv.replaceAll(RegExp(r'[0-9]'), '');
      if (studentNganh.isEmpty) studentNganh = 'KHAC';

      final Map<String, dynamic> limits = jsonDecode(widget.event['faculty_limits'].toString());
      if (limits[studentNganh] == null || limits[studentNganh].toString().isEmpty) return false; 
      
      final int limitForMyNganh = int.tryParse(limits[studentNganh].toString()) ?? 0;
      if (limitForMyNganh <= 0) return false;

      Map<String, dynamic> registeredCounts = {};
      if (widget.event['faculty_registered_counts'] != null && widget.event['faculty_registered_counts'].toString().isNotEmpty) {
        try {
          Map<String, dynamic> rawCounts = jsonDecode(widget.event['faculty_registered_counts'].toString());
          registeredCounts = rawCounts.map((key, value) => MapEntry(key.toUpperCase(), value));
        } catch (_) {}
      }

      final int currentFacultyCount = int.tryParse(registeredCounts[studentNganh]?.toString() ?? '0') ?? 0;
      return currentFacultyCount >= limitForMyNganh;
    } catch (e) {
      return false;
    }
  }

  void _checkEventStatus() {
    _isOngoing = widget.event['status'] == 'Đang diễn ra';
    if (!_isOngoing && widget.event['date'] != null) {
      try {
        DateTime startTime = DateTime.parse(widget.event['date']);
        DateTime now = DateTime.now();
        DateTime endTime = widget.event['end_date'] != null
            ? DateTime.parse(widget.event['end_date'])
            : startTime.add(const Duration(hours: 4));

        if (now.isAfter(startTime) && now.isBefore(endTime)) {
          _isOngoing = true;
        }
      } catch (e) {
        debugPrint("Lỗi kiểm tra trạng thái: $e");
      }
    }
  }

  Future<void> _handleRegister() async {
    if (widget.mssv == null) return;
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final response = await _dio.post('$backendBaseUrl/api/mobile/register_event', data: {
        'event_id': widget.event['id'].toString(),
        'mssv': widget.mssv
      });
      if (!mounted) return;
      Navigator.pop(context);
      
      if (response.data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🎉 ${response.data['message']}'), backgroundColor: Colors.green));
        setState(() => _isRegistered = true);
        widget.onStateChanged();

        if (widget.event['date'] != null) {
          try {
            DateTime startTime = DateTime.parse(widget.event['date']);
            int baseId = int.tryParse(widget.event['id'].toString()) ?? 0;
            DateTime morningReminder = DateTime(startTime.year, startTime.month, startTime.day, 6, 0);
            if (morningReminder.isAfter(DateTime.now())) {
              NotificationHelper.scheduleEventNotification(
                id: baseId * 10 + 1,
                title: '📅 Hôm nay có sự kiện!',
                body: 'Sự kiện "${widget.event['name']}" sẽ diễn ra hôm nay lúc ${startTime.hour}:${startTime.minute}.',
                scheduledTime: morningReminder,
              );
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty || isoString == 'Đang cập nhật') return 'Đang cập nhật';
    try {
      DateTime dt = DateTime.parse(isoString).toLocal();
      String hour = dt.hour.toString().padLeft(2, '0');
      String minute = dt.minute.toString().padLeft(2, '0');
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      return '$hour:$minute $day/$month/${dt.year}';
    } catch (e) {
      return isoString;
    }
  }

  // KHỐI HÀM XÂY DỰNG NÚT BẤM ĐIỀU HƯỚNG BÊN DƯỚI
  Widget _buildBottomButton() {
    bool isFacultyFull = _isFacultyLimitReached();
    bool pastRegisterDeadline = false;

    if (widget.event['date'] != null) {
      try {
        DateTime startTime = DateTime.parse(widget.event['date']);
        if (DateTime.now().isAfter(startTime.add(const Duration(minutes: 30)))) {
          pastRegisterDeadline = true;
        }
      } catch (_) {}
    }

    if (_isOngoing) {
      if (_isRegistered) {
        return ElevatedButton(
onPressed: _isCheckedIn ? null : () async {
            bool? isSuccess = false;
            
            // 1. Lấy trạng thái của cả 3 công tắc
            final bool reqGps = widget.event['require_gps'] == 1 || widget.event['require_gps'] == '1' || widget.event['require_gps'] == true;
            final bool reqProof = widget.event['require_proof'] == 1 || widget.event['require_proof'] == '1' || widget.event['require_proof'] == true;
            final bool reqFile = widget.event['require_file'] == 1 || widget.event['require_file'] == '1' || widget.event['require_file'] == true;

            // 2. Gộp chung: Có cần nộp Minh chứng hoặc File hay không?
            final bool needsSubmission = reqProof || reqFile;

            if (reqGps && needsSubmission) {
              final qrResult = await Navigator.push(context, MaterialPageRoute(
                builder: (context) => QRScanScreen(
                  userData: {'mssv': widget.mssv}, 
                  expectedEventId: widget.event['id'].toString(), 
                  expectedEventName: widget.event['name'] ?? 'Chưa có tên', 
                  expectedCategory: widget.event['category'],
                )
              ));
              if (qrResult == true) {
                isSuccess = true;
              }
            } else if (!reqGps && needsSubmission) {
              // Chuyển thẳng tới trang nộp bài nếu không yêu cầu GPS
              final proofResult = await Navigator.push(context, MaterialPageRoute(
                builder: (context) => EvidenceSubmitScreen(
                  userData: {'mssv': widget.mssv},
                  initialEventId: widget.event['id'].toString(),
                  initialEventName: widget.event['name'],
                  initialCategory: widget.event['category'],
                  requireProof: reqProof,
                  requireFile: reqFile, // <-- Truyền trạng thái nộp file sang
                )
              ));
              isSuccess = proofResult;
            } else {
              // Sự kiện chỉ quét QR/GPS đơn thuần (Không nộp ảnh, Không nộp file)
              final qrResult = await Navigator.push(context, MaterialPageRoute(
                builder: (context) => QRScanScreen(
                  userData: {'mssv': widget.mssv}, 
                  expectedEventId: widget.event['id'].toString(), 
                  expectedEventName: widget.event['name'] ?? 'Chưa có tên', 
                  expectedCategory: widget.event['category'],
                )
              ));
              isSuccess = qrResult;
            }

            if (isSuccess == true && mounted) {
              widget.onStateChanged(); 
              Navigator.pop(context);  
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isCheckedIn ? Colors.green : Colors.redAccent,
            disabledBackgroundColor: _isCheckedIn ? Colors.green : Colors.grey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            _isCheckedIn ? '✅ Đã điểm danh' : 'Điểm danh ngay',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      } else if (!pastRegisterDeadline && !isFacultyFull) {
        return ElevatedButton(
          onPressed: _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D235E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Đăng ký muộn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        );
      } else {
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            disabledBackgroundColor: Colors.grey.shade400,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Đã đóng đăng ký', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        );
      }
    } else {
      // TRƯỜNG HỢP: SẮP DIỄN RA
      return ElevatedButton(
        onPressed: (_isRegistered || isFacultyFull) ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFacultyFull ? Colors.grey : const Color(0xFF0D235E),
          disabledBackgroundColor: _isRegistered ? Colors.green : Colors.grey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          _isRegistered 
              ? '✅ Đã đăng ký tham gia' 
              : (isFacultyFull ? 'Ngành của bạn đã hết suất' : 'Đăng ký tham gia ngay'), 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
        ),
      );
    }
  }

  // KHỐI HÀM XÂY DỰNG CARD THỐNG KÊ NGÀNH
  Widget _buildStatsCard(int maxParticipants, int currentParticipants) {
    Map<String, dynamic> limitsObj = {};
    if (widget.event['faculty_limits'] != null && widget.event['faculty_limits'].toString().isNotEmpty) {
      try { limitsObj = jsonDecode(widget.event['faculty_limits'].toString()); } catch (_) {}
    }

    Map<String, dynamic> registeredCounts = {};
    if (widget.event['faculty_registered_counts'] != null && widget.event['faculty_registered_counts'].toString().isNotEmpty) {
      try {
        String rawStr = widget.event['faculty_registered_counts'].toString().trim();
        if (rawStr != "{}" && rawStr != "null" && rawStr.startsWith('{')) {
          Map<String, dynamic> rawCounts = jsonDecode(rawStr);
          registeredCounts = rawCounts.map((key, value) => MapEntry(key.toUpperCase(), value));
        }
      } catch (e) {
        debugPrint("Lỗi parse faculty_registered_counts: $e");
      }
    }

    List<Widget> facultyLines = [];
    limitsObj.forEach((nganhCode, limitVal) {
      if (limitVal != null && limitVal.toString().trim().isNotEmpty) {
        final int limit = int.tryParse(limitVal.toString()) ?? 0;
        if (limit > 0) {
          final String upperNganh = nganhCode.toString().toUpperCase().replaceAll(RegExp(r'[0-9]'), '');
          final int currentReg = int.tryParse(registeredCounts[upperNganh]?.toString() ?? '0') ?? 0;
          
          facultyLines.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right_alt_rounded, size: 18, color: Colors.purple),
                  const SizedBox(width: 6),
                  Text(
                    'Ngành $upperNganh: Đã đăng ký $currentReg / Chỉ tiêu $limit suất',
                    style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        }
      }
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.blue.shade900, size: 18),
              const SizedBox(width: 6),
              Text('THÔNG SỐ CHỈ TIÊU ĐĂNG KÝ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue.shade900, letterSpacing: 0.3)),
            ],
          ),
          const Divider(height: 16, thickness: 0.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Icon(Icons.brightness_1, size: 8, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  maxParticipants > 0 ? 'Tổng sự kiện: Đã có $currentParticipants / $maxParticipants SV đăng ký' : 'Tổng sự kiện: Không giới hạn số lượng',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ],
          ),
          if (facultyLines.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...facultyLines,
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String points = (widget.event['points'] != null && widget.event['points'].toString() != '0') ? widget.event['points'].toString() : '0';
    final String category = widget.event['category'] ?? 'SỰ KIỆN';
    final String name = widget.event['name'] ?? 'Chưa có tên';
    final String dateStart = widget.event['date'] ?? 'Đang cập nhật';
    final String dateEnd = widget.event['end_date'] ?? 'Đang cập nhật';
    
    String rawDescription = widget.event['description'] ?? widget.event['event_description'] ?? '';
    final String description = (rawDescription.trim().isNotEmpty) ? rawDescription.trim() : 'Không có nội dung mô tả chi tiết cho hoạt động này.';
    final dynamic rawFile = widget.event['attached_file'] ?? widget.event['event_attached_file'];
    final String? fileAttachment = widget.event['attached_file'] ?? widget.event['event_attached_file'];

    final int maxParticipants = int.tryParse(widget.event['max_participants']?.toString() ?? '0') ?? 0;
    final int currentParticipants = int.tryParse(widget.event['current_participants']?.toString() ?? '0') ?? 0;

    Widget buildPoster() {
      final String? posterPath = widget.event['poster_url']?.toString();
      if (posterPath == null || posterPath.isEmpty) {
        return Image.asset('assets/img/ctut-placeholder.jpg', fit: BoxFit.cover);
      }
      final cleanPath = posterPath.startsWith("/") ? posterPath.substring(1) : posterPath;
      final fullUrl = '$backendBaseUrl/$cleanPath';

      return Image.network(
        Uri.encodeFull(fullUrl), 
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset('assets/img/ctut-placeholder.jpg', fit: BoxFit.cover),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF0D235E),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(tag: 'poster_${widget.event['id']}', child: buildPoster()),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(6)),
                        child: Text(category.toUpperCase(), style: const TextStyle(color: Color(0xFF0D235E), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isOngoing ? Colors.redAccent.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isOngoing ? 'ĐANG DIỄN RA' : 'SẮP DIỄN RA',
                          style: TextStyle(color: _isOngoing ? Colors.redAccent : Colors.blue.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Text('+$points ĐRL', style: const TextStyle(color: Color(0xFF2ECA7F), fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50, 
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars, color: Colors.orange, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Điểm rèn luyện/hoạt động: $points điểm',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3)),
                  const Divider(height: 32, thickness: 1, color: Color(0xFFECEFF1)),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.play_circle_outline, color: Color(0xFF0D235E), size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Bắt đầu: ${_formatDateTime(dateStart)}', style: const TextStyle(fontSize: 14, color: Colors.black87))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.stop_circle_outlined, color: Colors.orange, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Kết thúc: ${_formatDateTime(dateEnd)}', style: const TextStyle(fontSize: 14, color: Colors.black87))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.event['require_gps'] == 1 || widget.event['require_gps'] == '1' ? 'Yêu cầu điểm danh Định vị GPS' : 'Hình thức Online / Quét mã QR',
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              widget.event['score_type'] == 'multiple' ? Icons.replay_circle_filled_rounded : Icons.looks_one_rounded, 
                              color: widget.event['score_type'] == 'multiple' ? Colors.green : Colors.blue, 
                              size: 20
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.event['score_type'] == 'multiple' 
                                    ? 'Cơ chế: Tính theo Lượt (Cho phép cộng dồn)' 
                                    : 'Cơ chế: Tính theo Lần (Nhận điểm 1 lần duy nhất)',
                                style: TextStyle(
                                  fontSize: 14, 
                                  color: widget.event['score_type'] == 'multiple' ? Colors.green.shade700 : Colors.black87,
                                  fontWeight: widget.event['score_type'] == 'multiple' ? FontWeight.bold : FontWeight.normal
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildStatsCard(maxParticipants, currentParticipants),
                  
                  const SizedBox(height: 16),
                  const Text('Nội dung chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D235E))),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.6), textAlign: TextAlign.justify),
                  const SizedBox(height: 24),

                  const Text('Tài liệu đính kèm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D235E))),
                  const SizedBox(height: 10),
                  
                  Builder(
                    builder: (context) {
                      if (fileAttachment == null || fileAttachment.trim().isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Không có tài liệu đính kèm cho sự kiện này.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        );
                      }

                      List<String> fileList = [];
                      try {
                        if (fileAttachment.startsWith('[')) {
                          final List<dynamic> decoded = jsonDecode(fileAttachment);
                          fileList = decoded.map((e) => e.toString()).toList();
                        } else {
                          fileList = fileAttachment.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                        }
                      } catch (_) {
                        fileList = [fileAttachment];
                      }

                      return Column(
                        children: fileList.map((fileUrl) {
                          final String currentFileName = fileUrl.split('/').last; 
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0), 
                            child: Card(
                              elevation: 0,
                              color: const Color(0xFFF5F5F5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade300)),
                              child: ListTile(
                                leading: Icon(
                                  currentFileName.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.description, 
                                  color: currentFileName.endsWith('.pdf') ? Colors.redAccent : Colors.blue, 
                                  size: 32
                                ),
                                title: Text(currentFileName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: const Text('Bấm để xem/tải về', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.download_for_offline, color: Color(0xFF0D235E)),
                                  onPressed: () async {
                                    String cleanFileUrl = fileUrl.startsWith('/') ? fileUrl.substring(1) : fileUrl;
                                    String cleanBaseUrl = backendBaseUrl.endsWith('/') ? backendBaseUrl.substring(0, backendBaseUrl.length - 1) : backendBaseUrl;
                                    final String fullUrl = fileUrl.startsWith("http") ? fileUrl : '$cleanBaseUrl/$cleanFileUrl';
                                    final Uri url = Uri.parse(fullUrl);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Không thể mở đường dẫn tệp!'), backgroundColor: Colors.red));
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: _buildBottomButton(), // ĐÃ CHUYỂN VÀO HÀM _buildBottomButton ĐỂ TRÁNH LỖI DẤU NGOẶC
        ),
      ),
    );
  }
}