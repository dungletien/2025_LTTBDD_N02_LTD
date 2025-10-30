import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';

class MusicProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Song> _playlist = [];
  List<Song> _allSongs = [];
  Song? _currentSong;
  int _currentIndex = 0;

  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Getters
  List<Song> get playlist => _playlist;
  List<Song> get allSongs => _allSongs;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  MusicProvider() {
    _initAudioPlayer();
    _loadSampleSongs();
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
        title: 'Believer',
        artist: 'Imagine Dragons',
        album: 'Evolve',
        imagePath:
            'https://via.placeholder.com/300x300/FF5722/FFFFFF?text=Believer',
        audioPath: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
        duration: Duration(minutes: 3, seconds: 24),
      ),
      Song(
        id: '2',
        title: 'Moment Apart',
        artist: 'ODESZA',
        album: 'A Moment Apart',
        imagePath:
            'https://via.placeholder.com/300x300/2196F3/FFFFFF?text=Moment+Apart',
        audioPath: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
        duration: Duration(minutes: 4, seconds: 15),
      ),
      Song(
        id: '3',
        title: 'Shortcake',
        artist: 'Artist Name',
        album: 'Album Name',
        imagePath:
            'https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=Shortcake',
        audioPath: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
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
        await _audioPlayer.play(AssetSource(song.audioPath));
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
