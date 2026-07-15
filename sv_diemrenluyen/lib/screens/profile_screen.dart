import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/shared_app_bar.dart'; 
import '../core/app_config.dart';
import 'history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'app_info_screen.dart';
class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData; 
  final VoidCallback onLogoutAction;
  
  const ProfileScreen({Key? key, required this.userData, required this.onLogoutAction}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = 'Đang tải...';
  String _mssv = 'Đang tải...';
  String _chiDoan = 'Đang tải...';
  String _faculty = 'Đang tải...';
  String _phone = 'Đang tải...';
  String _role = 'Đang tải...';
  String _avatarUrl = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDataAndFetch();
  }

  void _initializeDataAndFetch() {
    String email = widget.userData['email'] ?? '';
    _fullName = widget.userData['name'] ?? widget.userData['full_name'] ?? 'Đang tải...';
    _avatarUrl = getUserAvatarUrl(widget.userData);

    if (email.isNotEmpty) {
      _fetchProfileFromDB(email);
    } else {
      setState(() {
        _mssv = 'Không tìm thấy Email';
        _chiDoan = _faculty = _phone = _role = 'Không có thông tin';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProfileFromDB(String email) async {
    try {
      final response = await Dio().get('$backendBaseUrl/api/mobile/profile?email=$email');
      
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final data = response.data['data'];
        setState(() {
          _fullName = data['full_name'] ?? _fullName;
          _mssv = data['mssv'] ?? 'Chưa cập nhật';
          _chiDoan = data['chi_doan'] ?? 'Chưa cập nhật';
          _faculty = data['faculty'] ?? 'Chưa cập nhật';
          _phone = data['phone'] ?? 'Chưa cập nhật';
          _role = data['role'] == 'student' ? 'Sinh viên' : (data['role'] ?? 'Chưa cập nhật');
          
          if (data['avatar'] != null && data['avatar'].toString().isNotEmpty) {
            String rawAvatar = data['avatar'];
            _avatarUrl = rawAvatar.startsWith('http') ? rawAvatar : '$backendBaseUrl/$rawAvatar?t=${DateTime.now().millisecondsSinceEpoch}';
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _mssv = _chiDoan = _faculty = _phone = _role = 'Chưa có trong CSDL';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _mssv = _chiDoan = _faculty = _phone = _role = 'Lỗi mạng';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang tải ảnh lên...')));
      try {
        String email = widget.userData['email'] ?? '';
        FormData formData = FormData.fromMap({
          'email': email,
          'avatar_image': MultipartFile.fromBytes(await image.readAsBytes(), filename: image.name),
        });

        var response = await Dio().post('$backendBaseUrl/api/mobile/update_avatar', data: formData);
        
        if (response.data['status'] == 'success') {
          String newAvatarPath = response.data['new_avatar_path'];

          setState(() {
            _avatarUrl = '$backendBaseUrl/$newAvatarPath?t=${DateTime.now().millisecondsSinceEpoch}';
          });

          widget.userData['avatar'] = newAvatarPath;

          final prefs = await SharedPreferences.getInstance();
          final String? savedUserData = prefs.getString('user_data');
          if (savedUserData != null) {
            Map<String, dynamic> localData = jsonDecode(savedUserData);
            localData['avatar'] = newAvatarPath;
            await prefs.setString('user_data', jsonEncode(localData));
          }

          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật ảnh thành công!'), backgroundColor: Colors.green));
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi tải ảnh lên!'), backgroundColor: Colors.red));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối máy chủ!'), backgroundColor: Colors.red));
      }
    }
  }

  void _showEditPhoneDialog() {
    TextEditingController phoneController = TextEditingController(text: _phone == 'Chưa cập nhật' || _phone == 'Chưa có trong CSDL' ? '' : _phone);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật số điện thoại', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Nhập số điện thoại mới',
            filled: true, fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updatePhoneInDB(phoneController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D235E), foregroundColor: Colors.white),
            child: const Text('Lưu lại'),
          )
        ],
      ),
    );
  }

  Future<void> _updatePhoneInDB(String newPhone) async {
    if (newPhone.isEmpty) return;
    try {
      String email = widget.userData['email'] ?? '';
      var response = await Dio().post(
        '$backendBaseUrl/api/mobile/update_phone',
        data: FormData.fromMap({'email': email, 'phone': newPhone}),
      );
      if (response.data['status'] == 'success') {
        setState(() { _phone = newPhone; });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật SĐT thành công!'), backgroundColor: Colors.green));
      }
    } catch (e) {}
  }

  void _showEditNameDialog() {
    TextEditingController nameController = TextEditingController(
        text: _fullName == 'Đang tải...' ? '' : _fullName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật họ tên', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Nhập họ tên mới',
            filled: true, fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên!'), backgroundColor: Colors.orange));
                return;
              }
              Navigator.pop(context);
              _updateNameInDB(nameController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D235E), foregroundColor: Colors.white),
            child: const Text('Lưu lại'),
          )
        ],
      ),
    );
  }

  Future<void> _updateNameInDB(String newName) async {
    try {
      String email = widget.userData['email'] ?? '';
      var response = await Dio().post(
        '$backendBaseUrl/api/mobile/update_name',
        data: FormData.fromMap({'email': email, 'full_name': newName}),
      );
      
      if (response.data['status'] == 'success') {
        setState(() { _fullName = newName; });
        
        final prefs = await SharedPreferences.getInstance();
        final String? savedUserData = prefs.getString('user_data');
        if (savedUserData != null) {
          Map<String, dynamic> localData = jsonDecode(savedUserData);
          localData['full_name'] = newName;
          localData['name'] = newName; 
          await prefs.setString('user_data', jsonEncode(localData));
        }

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật tên thành công!'), backgroundColor: Colors.green));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi cập nhật tên!'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối mạng!'), backgroundColor: Colors.red));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: buildSharedAppBar('Tài khoản của tôi', _avatarUrl),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickAndUploadAvatar,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(radius: 50, backgroundImage: NetworkImage(_avatarUrl)),
                            Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFF2ECA7F), shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.white, size: 16))
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D235E))),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showEditNameDialog,
                            child: const Icon(Icons.edit_square, color: Color(0xFF2ECA7F), size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Sinh viên ĐH Kỹ thuật - Công nghệ Cần Thơ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      _buildProfileTile(Icons.badge_outlined, 'Mã số sinh viên', _mssv),
                      _buildProfileTile(Icons.class_outlined, 'Lớp sinh hoạt', _chiDoan),
                      _buildProfileTile(Icons.school_outlined, 'Ngành học', _faculty),
                      _buildProfileTile(Icons.apartment_outlined, 'Chi đoàn khoa', 'Công nghệ thông tin'),
                      _buildProfileTile(Icons.person, 'Vai trò', _role),
                      _buildProfileTile(
                        Icons.phone, 'Số điện thoại', _phone, 
                        isLast: true,
                        trailingAction: GestureDetector(
                          onTap: _showEditPhoneDialog,
                          child: const Icon(Icons.edit_square, color: Color(0xFF2ECA7F), size: 20),
                        )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      _buildActionTile(Icons.history, 'Lịch sử tham gia hoạt động', () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen(userData: widget.userData)));
                      }),
                      _buildActionTile(
  Icons.info_outline_rounded, 
  'Thông tin phiên bản v1.0.2', 
  () {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const AppInfoScreen())
    );
  }, 
  showChevron: true, 
  isLast: true
),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: OutlinedButton.icon(
                    onPressed: widget.onLogoutAction,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Đăng xuất tài khoản', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red, width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.red.withOpacity(0.05)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileTile(IconData icon, String label, String value, {bool isLast = false, Widget? trailingAction}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D235E), size: 20), 
          const SizedBox(width: 16), 
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)), 
          const Spacer(), 
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
          if (trailingAction != null) ...[
            const SizedBox(width: 10),
            trailingAction,
          ]
        ]
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap, {bool showChevron = true, bool isLast = false}) {
    return ListTile(
      onTap: onTap, 
      dense: true, 
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2), 
      shape: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100)), 
      leading: Icon(icon, color: const Color(0xFF0D235E), size: 20), 
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)), 
      trailing: showChevron ? const Icon(Icons.chevron_right, size: 18, color: Colors.grey) : null
    );
  }
}