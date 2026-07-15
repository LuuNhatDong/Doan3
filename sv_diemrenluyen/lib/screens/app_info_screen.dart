import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Thông tin hệ thống', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // --- KHỐI LOGO VÀ PHIÊN BẢN ---
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF0D235E),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0D235E).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                ]
              ),
              child: const Center(child: Icon(Icons.school, color: Colors.white, size: 45)),
            ),
            const SizedBox(height: 16),
            const Text('CTUT E-Point', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0D235E), letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECA7F).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2ECA7F).withOpacity(0.5))
              ),
              child: const Text('Phiên bản v1.0.2', style: TextStyle(color: Color(0xFF2ECA7F), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 32),

            // --- KHỐI TÊN ĐỀ TÀI ---
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.article_outlined, color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('TÊN ĐỀ TÀI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'HỆ THỐNG QUẢN LÝ SỰ KIỆN VÀ TỰ ĐỘNG HÓA DUYỆT MINH CHỨNG ĐIỂM RÈN LUYỆN CHO SINH VIÊN',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.5, color: Color(0xFF0D235E)),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- KHỐI GIÁO VIÊN & SINH VIÊN ---
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Giáo viên hướng dẫn
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.person_outline, color: Colors.blue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('GIÁO VIÊN HƯỚNG DẪN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.only(left: 44.0),
                      child: Text('ThS. Nguyễn Thúy Anh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                    
                    const Divider(height: 30, thickness: 1, color: Color(0xFFF4F6FB)),

                    // Nhóm sinh viên
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: const Color(0xFF2ECA7F).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.group_outlined, color: Color(0xFF2ECA7F), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('NHÓM SINH VIÊN THỰC HIỆN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTeamMember('Nguyễn Minh Anh Tuấn', 'Trưởng nhóm', false),
                    _buildTeamMember('Lưu Nhật Đông', 'Thành viên', false),
                    _buildTeamMember('Nguyễn Lâm Quang Hà', 'Thành viên', false),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(String name, String role, bool isLeader) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isLeader ? const Color(0xFF0D235E).withOpacity(0.1) : const Color(0xFFF4F6FB),
            child: Icon(
              isLeader ? Icons.star : Icons.person, 
              color: isLeader ? const Color(0xFF0D235E) : Colors.grey.shade600, 
              size: 20
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
              const SizedBox(height: 2),
              Text(role, style: TextStyle(fontSize: 13, color: isLeader ? const Color(0xFF0D235E) : Colors.grey.shade600, fontWeight: isLeader ? FontWeight.w600 : FontWeight.normal)),
            ],
          ),
        ],
      ),
    );
  }
}