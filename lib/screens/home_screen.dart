import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';
import 'now_playing_screen.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart' show LanguageProvider, AppLanguage;
import 'liked_songs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: Provider.of<LanguageProvider>(context, listen: false).translate('search_songs'),
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      Provider.of<MusicProvider>(context, listen: false).clearSearch();
                      setState(() {
                        _isSearching = false;
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  Provider.of<MusicProvider>(context, listen: false).searchSongs(value);
                },
              )
            : Text(_getTitle()),
        actions: _isSearching
            ? []
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              ],
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _searchController.clear();
                  Provider.of<MusicProvider>(context, listen: false).clearSearch();
                  setState(() {
                    _isSearching = false;
                  });
                },
              )
            : null,
      ),
      body: _buildBody(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildMiniPlayer(), _buildBottomNav()],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getTitle() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    switch (_selectedIndex) {
      case 0:
        return lang.translate('home');
      case 1:
        return lang.translate('playlist');
      case 2:
        return lang.translate('playing_now');
      default:
        return lang.translate('home');
    }
  }

  Widget _buildBody() {
    final musicProvider = Provider.of<MusicProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    if (_isSearching || musicProvider.searchQuery.isNotEmpty) {
      final songs = musicProvider.filteredSongs;
      if (songs.isEmpty && musicProvider.searchQuery.isNotEmpty) {
        return Center(
          child: Text(
            lang.translate('no_results'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return _buildListTile(song, musicProvider);
        },
      );
    }

    if (_selectedIndex == 0) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Provider.of<LanguageProvider>(context, listen: false).translate('recommended_for_you'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: musicProvider.allSongs.length,
                itemBuilder: (context, index) {
                  final song = musicProvider.allSongs[index];
                  return _buildSongCard(song, musicProvider);
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              Provider.of<LanguageProvider>(context, listen: false).translate('my_playlist'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: musicProvider.playlist.length,
              itemBuilder: (context, index) {
                final song = musicProvider.playlist[index];
                return _buildPlaylistCard(song, musicProvider);
              },
            ),
          ],
        ),
      );
    } else if (_selectedIndex == 1) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: musicProvider.playlist.length,
        itemBuilder: (context, index) {
          final song = musicProvider.playlist[index];
          return _buildListTile(song, musicProvider);
        },
      );
    } else {
      return Center(
        child: Text(
          Provider.of<LanguageProvider>(context, listen: false).translate('playing_now'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      );
    }
  }

  Widget _buildSongCard(Song song, MusicProvider provider) {
    final isLiked = provider.isLiked(song.id);
    return GestureDetector(
      onTap: () => provider.playSong(song),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: song.imagePath.startsWith('http')
                          ? NetworkImage(song.imagePath)
                          : AssetImage(song.imagePath) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => provider.toggleLike(song),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(Song song, MusicProvider provider) {
    return GestureDetector(
      onTap: () => provider.playSong(song),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  image: DecorationImage(
                    image: song.imagePath.startsWith('http')
                        ? NetworkImage(song.imagePath)
                        : AssetImage(song.imagePath) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                song.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(Song song, MusicProvider provider) {
    final isCurrentSong = provider.currentSong?.id == song.id;
    final isLiked = provider.isLiked(song.id);

    return ListTile(
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(
            image: song.imagePath.startsWith('http')
                ? NetworkImage(song.imagePath)
                : AssetImage(song.imagePath) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
          color: isCurrentSong
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        song.artist,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            onPressed: () => provider.toggleLike(song),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      onTap: () => provider.playSong(song),
    );
  }

  Widget _buildMiniPlayer() {
    final musicProvider = Provider.of<MusicProvider>(context);
    final currentSong = musicProvider.currentSong;

    if (currentSong == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NowPlayingScreen()),
        );
      },
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(4),
                image: DecorationImage(
                  image: currentSong.imagePath.startsWith('http')
                      ? NetworkImage(currentSong.imagePath)
                      : AssetImage(currentSong.imagePath) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentSong.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    currentSong.artist,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: musicProvider.playPrevious,
            ),
            IconButton(
              icon: Icon(
                musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: musicProvider.togglePlayPause,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: musicProvider.playNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final lang = Provider.of<LanguageProvider>(context);
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: lang.translate('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.playlist_play),
          label: lang.translate('playlist'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.music_note),
          label: lang.translate('playing_now'),
        ),
      ],
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      context.read<ThemeProvider>().isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    onPressed: () => context.read<ThemeProvider>().toggle(),
                    tooltip: 'Toggle theme',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _drawerItem(context, Icons.person_outline, 'profile', onTap: () {}),
            _drawerItem(
              context,
              Icons.favorite_border,
              'liked_songs',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LikedSongsScreen()),
                );
              },
            ),
            _drawerItem(context, Icons.language, 'language', onTap: () => _showLanguageDialog(context)),
            _drawerItem(context, Icons.chat_bubble_outline, 'contact_us', onTap: () {}),
            _drawerItem(context, Icons.help_outline, 'faqs', onTap: () {}),
            _drawerItem(context, Icons.settings_outlined, 'settings', onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String key, {required VoidCallback onTap}) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(
        lang.translate(key),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppLanguage>(
              title: Text(lang.translate('vietnamese')),
              value: AppLanguage.vietnamese,
              groupValue: lang.currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  lang.setLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<AppLanguage>(
              title: Text(lang.translate('english')),
              value: AppLanguage.english,
              groupValue: lang.currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  lang.setLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(lang.translate('cancel')),
          ),
        ],
      ),
    );
  }
}
