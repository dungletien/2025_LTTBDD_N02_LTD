import 'package:flutter/material.dart';

enum AppLanguage { english, vietnamese }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.vietnamese;

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get locale => _currentLanguage == AppLanguage.vietnamese
      ? const Locale('vi', 'VN')
      : const Locale('en', 'US');

  void setLanguage(AppLanguage language) {
    _currentLanguage = language;
    notifyListeners();
  }

  String translate(String key) {
    if (_currentLanguage == AppLanguage.vietnamese) {
      return _vietnameseTranslations[key] ?? key;
    } else {
      return _englishTranslations[key] ?? key;
    }
  }

  static const Map<String, String> _vietnameseTranslations = {
    'home': 'Trang chủ',
    'playlist': 'Danh sách phát',
    'playing_now': 'Đang phát',
    'recommended_for_you': 'Đề xuất cho bạn',
    'my_playlist': 'Danh sách của tôi',
    'search': 'Tìm kiếm',
    'search_songs': 'Tìm kiếm bài hát...',
    'no_results': 'Không tìm thấy kết quả',
    'profile': 'Hồ sơ',
    'liked_songs': 'Bài hát đã thích',
    'language': 'Ngôn ngữ',
    'contact_us': 'Liên hệ',
    'faqs': 'Câu hỏi thường gặp',
    'settings': 'Cài đặt',
    'vietnamese': 'Tiếng Việt',
    'english': 'English',
    'select_language': 'Chọn ngôn ngữ',
    'cancel': 'Hủy',
    'no_song_playing': 'Không có bài hát đang phát',
    'no_liked_songs': 'Bạn chưa thích bài hát nào',
    'name': 'Tên',
    'email': 'Email',
    'total_songs': 'Tổng bài hát',
  };

  static const Map<String, String> _englishTranslations = {
    'home': 'Home',
    'playlist': 'Playlist',
    'playing_now': 'Playing Now',
    'recommended_for_you': 'Recommended for you',
    'my_playlist': 'My Playlist',
    'search': 'Search',
    'search_songs': 'Search songs...',
    'no_results': 'No results found',
    'profile': 'Profile',
    'liked_songs': 'Liked Songs',
    'language': 'Language',
    'contact_us': 'Contact us',
    'faqs': 'FAQs',
    'settings': 'Settings',
    'vietnamese': 'Tiếng Việt',
    'english': 'English',
    'select_language': 'Select Language',
    'cancel': 'Cancel',
    'no_song_playing': 'No song playing',
    'no_liked_songs': 'No liked songs yet',
    'name': 'Name',
    'email': 'Email',
    'total_songs': 'Total Songs',
  };
}

