import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';
import 'now_playing_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: Icon(
              context.read<ThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeProvider>().toggle(),
            tooltip: 'Toggle theme',
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildMiniPlayer(), _buildBottomNav()],
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Playlist';
      case 2:
        return 'Playing Now';
      default:
        return 'Home';
    }
  }

  Widget _buildBody() {
    final musicProvider = Provider.of<MusicProvider>(context);

    if (_selectedIndex == 0) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended for you',
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
              'My Playlist',
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
      return const Center(child: Text('Playing Now'));
    }
  }

  Widget _buildSongCard(Song song, MusicProvider provider) {
    return GestureDetector(
      onTap: () => provider.playSong(song),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
      trailing: IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.playlist_play),
          label: 'Playlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note),
          label: 'Playing Now',
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
            _drawerItem(context, Icons.person_outline, 'Profile'),
            _drawerItem(context, Icons.favorite_border, 'Liked Songs'),
            _drawerItem(context, Icons.language, 'Language'),
            _drawerItem(context, Icons.chat_bubble_outline, 'Contact us'),
            _drawerItem(context, Icons.help_outline, 'FAQs'),
            _drawerItem(context, Icons.settings_outlined, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      onTap: () {},
    );
  }
}
