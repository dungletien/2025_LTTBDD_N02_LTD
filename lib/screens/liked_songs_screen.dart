import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../providers/language_provider.dart';
import '../models/song.dart';
import 'now_playing_screen.dart';

class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final likedSongs = musicProvider.likedSongs;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(lang.translate('liked_songs')),
      ),
      body: likedSongs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lang.translate('no_liked_songs'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: likedSongs.length,
              itemBuilder: (context, index) {
                final song = likedSongs[index];
                return _buildSongTile(context, song, musicProvider);
              },
            ),
    );
  }

  Widget _buildSongTile(BuildContext context, Song song, MusicProvider provider) {
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
}

