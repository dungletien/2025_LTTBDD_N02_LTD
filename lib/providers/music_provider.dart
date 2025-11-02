import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/song.dart';

class MusicProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Song> _playlist = [];
  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  String _searchQuery = '';
  Song? _currentSong;
  int _currentIndex = 0;
  Set<String> _likedSongIds = {};

  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Getters
  List<Song> get playlist => _playlist;
  List<Song> get allSongs => _allSongs;
  List<Song> get filteredSongs => _searchQuery.isEmpty ? _allSongs : _filteredSongs;
  List<Song> get likedSongs => _allSongs.where((song) => _likedSongIds.contains(song.id)).toList();
  String get searchQuery => _searchQuery;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  bool isLiked(String songId) => _likedSongIds.contains(songId);

  MusicProvider() {
    _initAudioPlayer();
    _loadSampleSongs();
    _loadLikedSongs();
  }

  Future<void> _loadLikedSongs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedIdsJson = prefs.getString('liked_songs');
      if (likedIdsJson != null) {
        final List<dynamic> likedIdsList = json.decode(likedIdsJson);
        _likedSongIds = likedIdsList.map((id) => id.toString()).toSet();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading liked songs: $e');
      }
    }
  }

  Future<void> _saveLikedSongs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedIdsList = _likedSongIds.toList();
      await prefs.setString('liked_songs', json.encode(likedIdsList));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving liked songs: $e');
      }
    }
  }

  void _initAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      playNext();
    });
  }

  void _loadSampleSongs() {
    _allSongs = [
      Song(
        id: '1',
        title: 'Hãy Trao Cho Anh',
        artist: 'Sơn Tùng M-TP',
        album: 'M-TP',
        imagePath:
            'assets/images/hay_trao_cho_anh.jpg',
        audioPath: 'assets/audio/hay_trao_cho_anh.mp3',
        duration: Duration(minutes: 4, seconds: 24),
      ),
      Song(
        id: '2',
        title: 'Nơi Này Có Anh',
        artist: 'Sơn Tùng M-TP',
        album: 'M-TP',
        imagePath:
            'assets/images/noi_nay_co_anh.jpg',
        audioPath: 'assets/audio/noi_nay_co_anh.mp3',
        duration: Duration(minutes: 4, seconds: 15),
      ),
      Song(
        id: '3',
        title: 'Chạy Ngay ĐI',
        artist: 'Sơn Tùng M-TP',
        album: 'M-TP',
        imagePath:
            'assets/images/chay_ngay_di.jpg',
        audioPath: 'assets/audio/chay_ngay_di.mp3',
        duration: Duration(minutes: 3, seconds: 45),
      ),
    ];
    _playlist.addAll(_allSongs);
    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    _currentSong = song;
    _currentIndex = _playlist.indexOf(song);
    try {
      if (song.audioPath.startsWith('http')) {
        await _audioPlayer.play(UrlSource(song.audioPath));
      } else {
        // AssetSource expects the asset key relative to the asset bundle root
        final String assetKey = song.audioPath.startsWith('assets/')
            ? song.audioPath.substring('assets/'.length)
            : song.audioPath;
        await _audioPlayer.play(AssetSource(assetKey));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing song: $e');
      }
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    notifyListeners();
  }

  Future<void> playNext() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await playSong(_playlist[_currentIndex]);
    }
  }

  Future<void> playPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await playSong(_playlist[_currentIndex]);
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void addToPlaylist(Song song) {
    if (!_playlist.contains(song)) {
      _playlist.add(song);
      notifyListeners();
    }
  }

  void removeFromPlaylist(Song song) {
    _playlist.remove(song);
    notifyListeners();
  }

  void searchSongs(String query) {
    _searchQuery = query.toLowerCase().trim();
    if (_searchQuery.isEmpty) {
      _filteredSongs = [];
    } else {
      _filteredSongs = _allSongs
          .where((song) =>
              song.title.toLowerCase().contains(_searchQuery) ||
              song.artist.toLowerCase().contains(_searchQuery) ||
              song.album.toLowerCase().contains(_searchQuery))
          .toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredSongs = [];
    notifyListeners();
  }

  Future<void> toggleLike(Song song) async {
    if (_likedSongIds.contains(song.id)) {
      _likedSongIds.remove(song.id);
    } else {
      _likedSongIds.add(song.id);
    }
    await _saveLikedSongs();
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
