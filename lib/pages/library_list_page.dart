import 'package:flutter/material.dart';
import 'package:suur/pages/librarypage.dart';
import 'package:suur/services/library_folder.dart';

class LibraryListPage extends StatelessWidget {
  final List<LibraryFolder> folders = const [
    LibraryFolder(
      icon: Icons.playlist_play,
      title: 'Playlists',
      subtitle: 'Your created playlists',
    ),
    LibraryFolder(
      icon: Icons.music_note,
      title: 'Locals',
      subtitle: 'Songs on this device',
    ),
    LibraryFolder(
      icon: Icons.download,
      title: 'Downloaded',
      subtitle: 'Saved for offline',
    ),
    LibraryFolder(
      icon: Icons.favorite,
      title: 'Favorites',
      subtitle: 'Liked songs',
    ),
  ];

  const LibraryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListView.separated(
        itemCount: folders.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final folder = folders[index];
          return ListTile(
            leading: Icon(folder.icon, size: 32),
            title: Text(folder.title),
            subtitle: Text(folder.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LibraryPage(libraryFolder: folder),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
