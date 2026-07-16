import 'package:flutter/material.dart';
import 'dart:typed_data'; 
import 'package:dio/dio.dart'; 
import 'package:image_picker/image_picker.dart'; 
import '../widgets/shared_app_bar.dart'; 
import '../core/app_config.dart'; 
import 'notification_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'history_screen.dart';
import 'package:http_parser/http_parser.dart'; 
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
class EvidenceSubmitScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String? initialEventId;   
  final String? initialEventName; 
  final String? initialCategory;
  final double? latitude;  
  final double? longitude; 
  final bool requireProof;
  final bool requireFile;

  const EvidenceSubmitScreen({
    Key? key, 
    required this.userData,
    this.initialEventId,
    this.initialEventName,
    this.initialCategory,
    this.latitude,
    this.longitude,
    this.requireProof = true,
    this.requireFile = false,
  }) : super(key: key);
  
  @override
  State<EvidenceSubmitScreen> createState() => _EvidenceSubmitScreenState();
}

class _EvidenceSubmitScreenState extends State<EvidenceSubmitScreen> {
  String? _selectedCategory;
  List<String> _categories = []; 
  bool _isLoadingCategories = true;
  
  List<dynamic> _ongoingEvents = [];
  bool _isLoadingEvents = false;
  String? _selectedEventId;

  final TextEditingController _nameController = TextEditingController();
  XFile? _selectedImage;
  Uint8List? _imageBytes; 
  bool _isSubmitting = false;
  bool _hasSubmittedSuccessfully = false;

  bool _currentEventRequireProof = true; 
  bool _currentEventRequireFile = false;
  List<dynamic> _submittedProofsList = [];
  bool _isLoadingProofs = true;

  PlatformFile? _selectedFile;
  final TextEditingController _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    _currentEventRequireProof = widget.requireProof;
    _currentEventRequireFile = widget.requireFile;

    if (widget.initialEventName != null) {
      _nameController.text = widget.initialEventName!;
    }
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }

    _fetchCategories();
    
    _fetchSubmittedProofs().then((_) {
      if (widget.initialEventId == null) {
        _fetchOngoingEvents();
      }
    });
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Chưa cập nhật';
    try {
      DateTime dt = DateTime.parse(isoString).toLocal();
      String hour = dt.hour.toString().padLeft(2, '0');
      String minute = dt.minute.toString().padLeft(2, '0');
      String second = dt.second.toString().padLeft(2, '0');
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      return '$hour:$minute:$second $day/$month/${dt.year}';
    } catch (e) {
      return isoString;
    }
  }

  Future<void> _fetchSubmittedProofs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedUserData = prefs.getString('user_data');
      String mssv = '';
      
      if (savedUserData != null) {
        final Map<String, dynamic> localData = jsonDecode(savedUserData);
        mssv = localData['mssv']?.toString() ?? '';
      }

      if (!mounted) return;

      if (mssv.isEmpty) {
        setState(() => _isLoadingProofs = false);
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await Dio().get('$backendBaseUrl/api/mobile/history?mssv=$mssv&_t=$timestamp');
      
      if (!mounted) return;

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic> allHistory = response.data['data'] ?? [];
        setState(() {
          _submittedProofsList = allHistory;
          _isLoadingProofs = false;
        });
      } else {
        setState(() => _isLoadingProofs = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingProofs = false);
    }
  }

  Future<void> _fetchOngoingEvents() async {
    if (!mounted) return;
    setState(() => _isLoadingEvents = true);
    try {
      final mssv = widget.userData['mssv'] ?? '';
      final response = await Dio().get('$backendBaseUrl/api/mobile/events?mssv=$mssv');
      
      if (!mounted) return;
      
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic> events = response.data['events'] ?? [];
        
        final filtered = events.where((e) {
            bool isRegistered = e['is_registered'] == 1 || e['is_registered'] == '1';
            bool isEnded = e['status'] == 'Đã kết thúc' || e['status'] == 'Ngừng hoạt động';
            bool requireProof = e['require_proof'] == 1 || e['require_proof'] == '1' || e['require_proof'] == true;
            bool isCheckedIn = e['is_checked_in'] == 1 || e['is_checked_in'] == '1' || e['is_checked_in'] == true;

            bool passCheckInRule = !requireProof || isCheckedIn;

            final existingHistory = _submittedProofsList.firstWhere(
              (h) => h['event_id'].toString() == e['id'].toString(), 
              orElse: () => null,
            );

            bool passDuplicateRule = true;
            if (existingHistory != null) {
              final String proofStatus = (existingHistory['proof_status'] ?? '').toString().trim().toLowerCase();
              bool isCountByTurn = (e['score_type'] ?? 'once').toString().trim().toLowerCase() == 'multiple';

              if (!isCountByTurn) {
                if (proofStatus == 'approved' || proofStatus == 'pending') {
                  passDuplicateRule = false;
                }
              }
            }

            return isRegistered && !isEnded && passCheckInRule && passDuplicateRule;
          }).toList();

        final Map<String, dynamic> uniqueById = {};
        for (var ev in filtered) {
          final idStr = ev['id']?.toString() ?? '';
          if (idStr.isEmpty) continue;
          if (!uniqueById.containsKey(idStr)) uniqueById[idStr] = ev;
        }

        setState(() {
          _ongoingEvents = uniqueById.values.toList();
          _isLoadingEvents = false;
        });
      } else {
        setState(() => _isLoadingEvents = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingEvents = false);
    }
  }

  Future<void> _fetchCategories() async {
    try { 
      Response response = await Dio().get('$backendBaseUrl/api/criteria');
      
      if (!mounted) return; 
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData['status'] == 'success') {
          final List<dynamic> mainCategories = responseData['data'] ?? [];
          
          setState(() {
            _categories = mainCategories.map((item) => item['name'].toString()).toList();
            _isLoadingCategories = false;
          });
        } else {
          setState(() => _isLoadingCategories = false);
        }
      } else {
        setState(() => _isLoadingCategories = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF0D235E)),
                title: const Text('Chụp ảnh mới'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF0D235E)),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source, imageQuality: 80);
      
      if (!mounted) return; 
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() { _selectedImage = image; _imageBytes = bytes; });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở máy ảnh/thư viện!'), backgroundColor: Colors.red));
    }
  }

  // --- LOGIC MỚI: CHỌN FILE ĐÍNH KÈM TÀI LIỆU ---
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'zip', 'rar', 'ppt', 'pptx', 'xls', 'xlsx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi chọn file!'), backgroundColor: Colors.red));
    }
  }

  Future<void> _submitEvidence() async {
    final finalEventId = widget.initialEventId ?? _selectedEventId;

    if (_nameController.text.isEmpty || _selectedCategory == null || finalEventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Vui lòng chọn sự kiện hợp lệ!'), backgroundColor: Colors.red)
      );
      return;
    }

    if (_currentEventRequireProof && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Sự kiện yêu cầu bắt buộc phải chụp hoặc chọn ảnh minh chứng!'), backgroundColor: Colors.red)
      );
      return;
    }

    // Xác thực logic bắt buộc nộp bài làm File / Link
    if (_currentEventRequireFile && _selectedFile == null && _linkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Sự kiện yêu cầu bắt buộc nộp File tài liệu hoặc nhập Link bài làm!'), backgroundColor: Colors.red)
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedUserData = prefs.getString('user_data');
      String realMssv = 'Chưa rõ MSSV';
      int realStudentId = 1;
      String realFullName = ''; 

      if (savedUserData != null) {
        final Map<String, dynamic> localData = jsonDecode(savedUserData);
        realMssv = localData['mssv']?.toString() ?? 'Chưa rõ MSSV';
        realStudentId = int.tryParse(localData['id']?.toString() ?? '1') ?? 1;
        realFullName = localData['full_name']?.toString() ?? ''; 
      }

Map<String, dynamic> mapData = {
        'student_id': realStudentId,  
        'mssv': realMssv,             
        'student_name': realFullName, 
        'event_id': finalEventId, 
        'event_name': _nameController.text,
        'category': _selectedCategory,
        'latitude': widget.latitude ?? 0.0,
        'longitude': widget.longitude ?? 0.0,
      };

      // 1. ĐÍNH KÈM LINK BÀI LÀM VÀO BODY REQUEST
      if (_linkController.text.trim().isNotEmpty) {
        mapData['submit_link'] = _linkController.text.trim();
      }

      FormData formData = FormData.fromMap(mapData);

      // 2. ĐÍNH KÈM ẢNH MINH CHỨNG (Nếu có)
      if (_selectedImage != null) {
        String fileName = _selectedImage!.name;
        if (!fileName.contains('.')) {
          fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        }

        formData.files.add(MapEntry(
          'proof_image',
          MultipartFile.fromBytes(
            _imageBytes ?? await _selectedImage!.readAsBytes(), 
            filename: fileName,
            contentType: MediaType('image', 'jpeg'), 
          ),
        ));
      }

      // 3. ĐÍNH KÈM FILE TÀI LIỆU NỘP BÀI (Hỗ trợ cả Web và Mobile)
      if (_selectedFile != null) {
        if (_selectedFile!.bytes != null) {
          // Xử lý dành riêng cho nền tảng Web (Chrome, Edge...)
          formData.files.add(MapEntry(
            'submit_file',
            MultipartFile.fromBytes(
              _selectedFile!.bytes!.toList(), 
              filename: _selectedFile!.name
            ),
          ));
        } else if (_selectedFile!.path != null) {
          // Xử lý dành cho thiết bị di động (Android, iOS)
          formData.files.add(MapEntry(
            'submit_file',
            await MultipartFile.fromFile(
              _selectedFile!.path!, 
              filename: _selectedFile!.name
            ),
          ));
        }
      }
      
      // GỌI API UPLOAD LÊN SERVER
      Response response = await Dio().post('$backendBaseUrl/api/proofs/upload_ai', data: formData);
      
      if (!mounted) return;
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success') {
          await NotificationHelper.saveNotificationRecord(
            '✅ Điểm danh / Nộp bài thành công', 
            'Bạn đã hoàn thành nộp minh chứng và bài làm cho sự kiện: ${_nameController.text}',
            eventId: finalEventId,
          );
          if (!mounted) return;
          setState(() => _hasSubmittedSuccessfully = true);
          _showResultDialog(data['auto_status'] ?? 'pending', data['phash_warning']?.toString() == '1' ? 'Phát hiện trùng lặp' : 'Hợp lệ');
          _fetchSubmittedProofs();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ Lỗi: ${data['message']}'), backgroundColor: Colors.orange));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ Lỗi kết nối: ${response.statusCode}'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      if (e is DioException && e.response != null && e.response?.data != null) {
        final errorMessage = e.response?.data['error'] ?? e.response?.data['message'] ?? 'Lỗi không xác định từ máy chủ';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ $errorMessage'), backgroundColor: Colors.orange));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Lỗi kết nối tới máy chủ!'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
  
  void _showDetailDialogFromSubmit(Map<String, dynamic> item) {
    final String proofStatus = (item['proof_status'] ?? '').toString().trim().toLowerCase();
    final bool isApproved = proofStatus == 'approved';
    final bool isRejected = proofStatus == 'rejected';
    final bool isPending = proofStatus == 'pending' || (proofStatus.isEmpty && item['checkin_time'] != null);

    String statusText = 'KHÔNG YÊU CẦU MINH CHỨNG';
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey.shade100;
    if (isApproved) {
      statusText = 'ĐÃ DUYỆT MINH CHỨNG';
      statusColor = const Color(0xFF2ECA7F);
      statusBgColor = const Color(0xFF2ECA7F).withOpacity(0.1);
    } else if (isRejected) {
      statusText = 'BỊ TỪ CHỐI';
      statusColor = Colors.red;
      statusBgColor = Colors.red.withOpacity(0.1);
    } else if (isPending) {
      statusText = 'ĐANG CHỜ DUYỆT';
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.withOpacity(0.1);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  color: const Color(0xFF0D235E),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.15,
                          child: const Center(
                            child: Text('CTUT', style: TextStyle(color: Colors.white, fontSize: 70, fontWeight: FontWeight.w900, letterSpacing: 5)),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10, left: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.black26, radius: 16,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFE8EFFF), borderRadius: BorderRadius.circular(4)),
                              child: Text(item['category']?.toString() ?? 'Tham gia học tập', style: const TextStyle(color: Color(0xFF0D235E), fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(4)),
                            child: Text(statusText.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const Spacer(),
                          Text('+${item['points'] ?? 0} ĐRL', style: const TextStyle(color: Color(0xFF2ECA7F), fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFFFF7EB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFFE3B8))),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 18),
                            const SizedBox(width: 8),
                            Text('Điểm rèn luyện/hoạt động: ${item['points'] ?? 0}', style: const TextStyle(color: Color(0xFFB36B00), fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(item['name'] ?? 'Tên sự kiện', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.play_circle_outline, size: 18, color: Color(0xFF0D235E)),
                                const SizedBox(width: 8),
                                Text('Bắt đầu: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                Expanded(child: Text(_formatDateTime(item['event_date'] ?? item['date']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.stop_circle_outlined, size: 18, color: Color(0xFF0D235E)),
                                const SizedBox(width: 8),
                                Text('Kết thúc: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                Expanded(child: Text(_formatDateTime(item['event_end_date'] ?? item['end_date']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF0D235E)),
                                const SizedBox(width: 8),
                                Text('Hình thức: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                Expanded(child: Text(item['method'] ?? 'Quét mã QR hệ thống', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Nội dung chi tiết', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D235E))),
                      const SizedBox(height: 6),
                      Text(
                        (item['event_description'] != null && item['event_description'].toString().isNotEmpty)
                            ? item['event_description'].toString()
                            : (item['description'] != null && item['description'].toString().isNotEmpty)
                                ? item['description'].toString()
                                : 'Không có mô tả chi tiết cho hoạt động này.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                      ),

                      if (isRejected && item['admin_comment'] != null && item['admin_comment'].toString().trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('Lý do từ chối của Cán bộ:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            item['admin_comment'].toString(),
                            style: const TextStyle(fontSize: 13, color: Colors.red, height: 1.4, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      const Text('Tài liệu đính kèm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D235E))),
                      const SizedBox(height: 8),
                      () {
                        List<String> attachedFiles = [];
                        try {
                          final rawAttached = item['attached_file'] ?? item['event_attached_file'];
                          if (rawAttached != null && rawAttached.toString().isNotEmpty) {
                            final decoded = jsonDecode(rawAttached.toString());
                            if (decoded is List) attachedFiles = decoded.map((f) => f.toString()).toList();
                          }
                        } catch (e) {
                          if (item['attached_file'] != null) attachedFiles.add(item['attached_file'].toString());
                        }

                        if (attachedFiles.isEmpty) {
                          return Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Text('Không có tài liệu đính kèm.', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic)));
                        }

                        return Column(
                          children: attachedFiles.map((filePath) {
                            final fileName = filePath.split('/').last;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                              child: Row(
                                children: [
                                  Icon(fileName.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.description, color: fileName.endsWith('.pdf') ? Colors.red : Colors.blue, size: 28),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  IconButton(
  icon: const Icon(Icons.download, color: Color(0xFF0D235E), size: 20),
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints(),
  onPressed: () async {
    String cleanFileUrl = filePath.startsWith('/') ? filePath.substring(1) : filePath;
    String cleanBaseUrl = backendBaseUrl.endsWith('/') ? backendBaseUrl.substring(0, backendBaseUrl.length - 1) : backendBaseUrl;
    final String fullUrl = filePath.startsWith("http") ? filePath : '$cleanBaseUrl/$cleanFileUrl';
    final Uri url = Uri.parse(fullUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Không thể tải tệp!'), backgroundColor: Colors.red)
        );
      }
    }
  },
),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }(),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isApproved ? Colors.grey.shade300 : const Color(0xFF0D235E),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: isApproved
                    ? const Padding(padding: EdgeInsets.all(14), child: Center(child: Text('Đã được phê duyệt hoàn tất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))))
                    : Builder(
                        builder: (context) {
                          bool isExpired = false;
                          final now = DateTime.now();
                          final endData = item['event_end_date'] ?? item['end_date'];
                          if (endData != null) {
                            final endTime = DateTime.tryParse(endData.toString());
                            if (endTime != null && now.isAfter(endTime)) isExpired = true;
                          }

                          if (isExpired) {
                            return Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock_clock, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text('SỰ KIỆN HẾT HẠN', style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            );
                          }

                          return InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _selectedEventId = item['event_id']?.toString();
                                _nameController.text = item['name']?.toString() ?? '';
                                _selectedCategory = item['category']?.toString();
                                
                                _currentEventRequireProof = item['require_proof'] == 1 || 
                                                            item['require_proof'] == '1' || 
                                                            item['require_proof'] == true;
                                
                                _currentEventRequireFile = item['require_file'] == 1 || 
                                                           item['require_file'] == '1' || 
                                                           item['require_file'] == true;

                                _selectedImage = null;
                                _imageBytes = null;
                                _selectedFile = null;
                                _linkController.clear();

                                if (_selectedEventId != null) {
                                  final newEvent = {
                                    'id': _selectedEventId.toString(),
                                    'name': _nameController.text,
                                    'category': _selectedCategory,
                                    'require_proof': _currentEventRequireProof,
                                    'require_file': _currentEventRequireFile,
                                  };

                                  _ongoingEvents.add(newEvent);

                                  final Map<String, dynamic> uniq = {};
                                  for (var ev in _ongoingEvents) {
                                    final idStr = ev['id']?.toString() ?? '';
                                    if (idStr.isEmpty) continue;
                                    if (!uniq.containsKey(idStr)) uniq[idStr] = ev;
                                  }
                                  _ongoingEvents = uniq.values.toList();
                                }
                              });
                            },
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(isRejected ? Icons.replay_rounded : Icons.edit_document, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(isRejected ? 'MINH CHỨNG BỊ TỪ CHỐI - BẤM ĐỂ NỘP LẠI' : 'CHỜ XÁC NHẬN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDialog(String status, String aiMessage) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (ctx) => AlertDialog(
        title: const Text('Kết quả Nộp Bài/Minh Chứng', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status == 'approved' ? '✅ Hệ thống đã duyệt tự động!' : '⏳ Đã nộp thành công. Đang chờ Xác nhận.'),
            const SizedBox(height: 12),
            Text('Phân tích từ hệ thống:', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            Text(aiMessage, style: TextStyle(
              color: aiMessage.contains('trùng lặp') || aiMessage.contains('⚠️') ? Colors.red : Colors.green, 
              fontWeight: FontWeight.bold
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Đóng dialog
              // Luôn quay về màn hình trước nếu được mở từ QR scan hoặc từ màn hình khác
              if (widget.initialEventId != null) {
                // Đến từ QR scan screen -> luôn pop về
                Navigator.pop(context, true);
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context, true); 
              } else {
                setState(() {
                  _nameController.clear();
                  _selectedCategory = null;
                  _selectedEventId = null;
                  _selectedImage = null;
                  _imageBytes = null;
                  _selectedFile = null;
                  _linkController.clear();
                  _hasSubmittedSuccessfully = false;
                });
                _fetchOngoingEvents(); 
              }
            }, 
            child: const Text('Đóng', style: TextStyle(color: Color(0xFF0D235E), fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String avatarUrl = getUserAvatarUrl(widget.userData);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: buildSharedAppBar('Nộp Minh Chứng', avatarUrl),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20), 
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nộp Minh Chứng Mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D235E))),
                  const SizedBox(height: 20),
                  
                  const Text('TÊN HOẠT ĐỘNG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  
                  if (widget.initialEventId != null)
                    TextField(
                      controller: _nameController, 
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                      )
                    )
                  else
                    _isLoadingEvents 
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D235E)))
                      : _ongoingEvents.isEmpty
                        ? const Text('Bạn chưa tham gia sự kiện nào cần nộp minh chứng.', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic))
                        : DropdownButtonFormField<String>(
                            value: _ongoingEvents.any((e) => e['id'].toString() == _selectedEventId)
                                ? _selectedEventId
                                : null,
                            hint: const Text('Chọn sự kiện bạn đã tham gia'),
                            isExpanded: true,
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                            items: _ongoingEvents.map((e) => DropdownMenuItem<String>(
                              value: e['id'].toString(), 
                              child: Text(e['name'], maxLines: 1, overflow: TextOverflow.ellipsis)
                            )).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedEventId = val;
                                final ev = _ongoingEvents.firstWhere((e) => e['id'].toString() == val);
                                _nameController.text = ev['name'];
                                _selectedCategory = ev['category'];
                                
                                _currentEventRequireFile = ev['require_file'] == 1 || 
                                                           ev['require_file'] == '1' || 
                                                           ev['require_file'] == true;

                                _currentEventRequireProof = ev['require_proof'] == 1 || 
                                                            ev['require_proof'] == '1' || 
                                                            ev['require_proof'] == true;

                                _selectedImage = null;
                                _imageBytes = null;
                                _selectedFile = null;
                                _linkController.clear();
                              });
                            },
                          ),
                  const SizedBox(height: 16),
                  
                  const Text('DANH MỤC TIÊU CHÍ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),

                  if (widget.initialCategory != null || _selectedEventId != null)
                    TextField(
                      controller: TextEditingController(text: _selectedCategory ?? ''),
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                      )
                    )
                  else
                    _isLoadingCategories 
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D235E)))
                      : DropdownButtonFormField<String>(
                          value: _categories.contains(_selectedCategory) ? _selectedCategory : null,
                          hint: const Text('Chọn nhóm danh mục tiêu chí'),
                          isExpanded: true,
                          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                          items: _categories.map((String catName) => DropdownMenuItem<String>(
                            value: catName, 
                            child: Text(catName, maxLines: 1, overflow: TextOverflow.ellipsis)
                          )).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCategory = val;
                            });
                          },
                        ),
                  const SizedBox(height: 16),
                  
                  // =================== BLOCK: CHỤP ẢNH MINH CHỨNG ===================
                  GestureDetector(
                    onTap: _showImageSourceActionSheet, 
                    child: Container(
                      width: double.infinity, height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FB), 
                        borderRadius: BorderRadius.circular(12), 
                        border: Border.all(color: const Color(0xFFD6E0FF)), 
                        image: _imageBytes != null 
                          ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover) 
                          : null
                      ),
                      child: _imageBytes == null 
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Icon(
                                Icons.camera_alt, 
                                size: 40, 
                                color: _currentEventRequireProof ? const Color(0xFF0D235E) : Colors.grey
                              ), 
                              const SizedBox(height: 8), 
                              Text(
                                _currentEventRequireProof 
                                  ? 'Nhấn để chụp hoặc tải ảnh lên (*)' 
                                  : 'Sự kiện quét mã QR - Tải ảnh lên ', 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  color: _currentEventRequireProof ? const Color(0xFF0D235E) : Colors.green
                                )
                              )
                            ]
                          )
                        : const Stack(
                            children: [
                              Positioned(bottom: 8, right: 8, child: CircleAvatar(backgroundColor: Colors.black54, radius: 16, child: Icon(Icons.edit, color: Colors.white, size: 20))),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // =================== BLOCK: NỘP BÀI LÀM / FILE (MỚI THÊM) ===================

                  if (true) ...[
                    Row(
                      children: [
                        const Text('NỘP BÀI LÀM / TÀI LIỆU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                        if (_currentEventRequireFile)
                          const Text(' (* Bắt buộc)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    InkWell(
                      onTap: _pickFile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: _selectedFile != null ? Colors.blue.shade50 : Colors.grey.shade100,
                          border: Border.all(color: _selectedFile != null ? Colors.blue : Colors.grey.shade300, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.attach_file, color: _selectedFile != null ? Colors.blue : Colors.grey.shade700),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedFile != null ? _selectedFile!.name : 'Bấm để đính kèm File (PDF, DOCX, ZIP...)',
                                style: TextStyle(
                                  color: _selectedFile != null ? Colors.blue.shade800 : Colors.grey.shade700,
                                  fontWeight: _selectedFile != null ? FontWeight.bold : FontWeight.normal
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_selectedFile != null)
                              InkWell(
                                onTap: () {
                                  setState(() => _selectedFile = null);
                                },
                                child: const Icon(Icons.cancel, color: Colors.red, size: 20),
                              )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _linkController,
                      decoration: InputDecoration(
                        hintText: 'Hoặc dán Link bài làm (Google Drive, Github...)',
                        hintStyle: const TextStyle(fontSize: 14),
                        prefixIcon: const Icon(Icons.link),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // =================== KẾT THÚC KHỐI FILE/LINK ===================

                  SizedBox(
                    width: double.infinity, height: 45,
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _hasSubmittedSuccessfully) ? null : _submitEvidence, 
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D235E)), 
                      child: _isSubmitting 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Text('Gửi Minh Chứng Lên CSDL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hoạt động tham gia gần đây', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D235E)),
                ),
                if (_submittedProofsList.length > 5)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryScreen(userData: widget.userData),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Text('Xem thêm', style: TextStyle(color: Color(0xFF0D235E), fontWeight: FontWeight.bold)),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF0D235E)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            _isLoadingProofs
                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                : _submittedProofsList.isEmpty
                    ? const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: Text('Bạn chưa nộp minh chứng cho sự kiện nào.', style: TextStyle(color: Colors.grey))),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _submittedProofsList.length > 5 ? 5 : _submittedProofsList.length,
                        itemBuilder: (context, index) {
                          final item = _submittedProofsList[index];
                          
                          String statusLabel = 'Đang chờ';
                          Color labelColor = Colors.orange;
                          IconData leadingIcon = Icons.pending;
                          
                          final String currentStatus = (item['proof_status'] ?? '').toString().trim().toLowerCase();

                          if (currentStatus == 'approved') {
                            statusLabel = 'Đã duyệt';
                            labelColor = const Color(0xFF2ECA7F);
                            leadingIcon = Icons.check_circle;
                          } else if (currentStatus == 'rejected') {
                            statusLabel = 'Bị từ chối';
                            labelColor = Colors.red;
                            leadingIcon = Icons.cancel;
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showDetailDialogFromSubmit(item),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: labelColor.withOpacity(0.2),
                                  child: Icon(leadingIcon, color: labelColor),
                                ),
                                title: Text(
                                  item['name'] ?? 'Tên sự kiện', 
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text('Thời gian check-in: ${_formatDateTime(item['checkin_time'])}', style: const TextStyle(fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Trạng thái minh chứng: $statusLabel', 
                                      style: TextStyle(fontSize: 12, color: labelColor, fontWeight: FontWeight.bold)
                                    ),
                                  ],
                                ),
                                trailing: SizedBox(
                                  width: 85, 
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end, 
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '+${item['points'] ?? 0} Đ', 
                                          style: const TextStyle(color: Color(0xFF0D235E), fontWeight: FontWeight.bold, fontSize: 16),
                                          textAlign: TextAlign.end,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}