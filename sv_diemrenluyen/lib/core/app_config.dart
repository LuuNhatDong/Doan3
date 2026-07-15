import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

// ĐÃ CHUYỂN SANG HOSTING
final String backendBaseUrl = 'https://doan3-ooha.onrender.com';

final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: kIsWeb ? '601742724925-2rhfv5aj9pcaac8up8bm8os292dl5mo6.apps.googleusercontent.com' : null,
  serverClientId: '601742724925-2rhfv5aj9pcaac8up8bm8os292dl5mo6.apps.googleusercontent.com',
  scopes: ['email', 'profile'],
);

String getUserAvatarUrl(Map<String, dynamic> userData) {
  if (userData.isEmpty) return 'https://ui-avatars.com/api/?name=User&background=random&color=fff&format=png';

  String fullName = userData['name'] ?? userData['full_name'] ?? 'User';
  String tempAvatar = userData['picture'] ?? userData['avatar'] ?? '';

  if (tempAvatar.isNotEmpty) {
    if (tempAvatar.contains('uploads/avatars/')) {
      return '$backendBaseUrl/$tempAvatar';
    }
    if (tempAvatar.startsWith('http')) {
      return tempAvatar;
    }
  }
  return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&background=random&color=fff&format=png';
}