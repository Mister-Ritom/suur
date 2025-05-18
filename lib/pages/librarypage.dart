import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:suur/provider/player_provider.dart';
import 'package:suur/services/library_folder.dart';

class LibraryPage extends StatefulWidget {
  final LibraryFolder libraryFolder;

  const LibraryPage({super.key, required this.libraryFolder});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  Future<List<Map<String, dynamic>>> _fetchLibraryData() async {
    if (widget.libraryFolder.title != 'Downloaded') return [];

    final downloadDir = await getDownloadsDirectory();
    if (downloadDir == null) return [];

    final songPath = '${downloadDir.path}/Suur';
    final directory = Directory(songPath);
    final List<Map<String, dynamic>> songs = [];

    if (!(await directory.exists())) return [];

    final List<FileSystemEntity> folders = directory.listSync();

    for (var folder in folders) {
      if (folder is Directory) {
        File? songFile;
        Map<String, dynamic>? manifestMap;

        final List<FileSystemEntity> subFiles = folder.listSync();

        for (var subFile in subFiles) {
          final fileName = subFile.uri.pathSegments.last;

          if (subFile is File) {
            if (fileName.endsWith('.mp3')) {
              songFile = subFile;
            } else if (fileName == 'manifest.json') {
              manifestMap = await getManifestMap(subFile);
            }
          }
        }

        if (songFile != null && manifestMap != null) {
          songs.add({'file': songFile, ...manifestMap});
        }
      }
    }

    return songs;
  }

  Future<Map<String, dynamic>> getManifestMap(File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonMap = jsonDecode(jsonString);
      return jsonMap;
    } catch (e) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlayerProvider(),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.libraryFolder.title)),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchLibraryData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No songs found.'));
            }

            final songs = snapshot.data!;
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                final title = song['title'] ?? 'Unknown';
                final artist = song['artist'] ?? 'Unknown';
                final imageUrl = song['image'];
                return ListTile(
                  leading:
                      imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(imageUrl)
                          : const Icon(Icons.music_note),
                  title: Text(title),
                  subtitle: Text(artist),
                  onTap: () {
                    //Show a snackbar with the song title
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Playing: $title'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    final player = Provider.of<PlayerProvider>(
                      context,
                      listen: false,
                    );
                    final audioPlayer = player.audioPlayer;
                    if (player.isPlaying) {
                      player.pause();
                    }
                    audioPlayer.setSource(DeviceFileSource(song['file'].path));
                    player.play();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
