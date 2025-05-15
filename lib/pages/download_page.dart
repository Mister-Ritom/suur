import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final TextEditingController _linkController = TextEditingController();
  bool _showDownloadDetails = false;
  int selectedIndex = 0;
  List<AudioOnlyStreamInfo> _audioStreams = [];
  String? _videoTitle;
  String? _videoDescription;
  String? _videoThumbnail;

  void _submitLink() async {
    final String link = _linkController.text.trim();
    if (link.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a valid link')));
      return;
    }

    final yt = YoutubeExplode();
    final videoInfo = await yt.videos.get(link);
    if (!videoInfo.hasWatchPage) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid video link')));
      return;
    }
    setState(() {
      _videoTitle = videoInfo.title;
      _videoDescription = videoInfo.description;
      _videoThumbnail = videoInfo.thumbnails.mediumResUrl;
    });
    final manifest = await yt.videos.streams.getManifest(videoInfo.id);
    final audioStream = manifest.audioOnly;
    setState(() {
      _audioStreams = audioStream.toList();
      _showDownloadDetails = true;
    });
  }

  void _startDownload() async {
    if (selectedIndex < 0 || selectedIndex >= _audioStreams.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid audio stream')),
      );
      return;
    }
    final selectedStream = _audioStreams[selectedIndex];
    final yt = YoutubeExplode();
    final stream = yt.videos.streams.get(selectedStream);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${selectedStream.bitrate}...')),
    );
    final downloadDirectory = await getDownloadsDirectory();
    if (downloadDirectory == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not find download directory')),
        );
      }
      return;
    }
    final filePath =
        '${downloadDirectory.path}/${_videoTitle ?? 'video'}-${selectedStream.audioCodec}.mp3';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    await file.create(recursive: true);
    final fileStream = file.openWrite();
    await stream.pipe(fileStream);
    await fileStream.flush();
    await fileStream.close();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Downloaded to $filePath')));
    if (mounted) {
      setState(() {
        _showDownloadDetails = false;
        _linkController.clear();
        _audioStreams.clear();
        _videoTitle = null;
        _videoDescription = null;
        _videoThumbnail = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Music Downloader')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Enter music link',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              if (!_showDownloadDetails)
                ElevatedButton(onPressed: _submitLink, child: Text('Submit')),
              if (_showDownloadDetails) ...[
                Image.network(
                  _videoThumbnail ?? '',
                  height: 200,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 16),
                Text(
                  _videoTitle ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8),
                Text(
                  _videoDescription ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 16),
                Text(
                  'Audio Streams:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _audioStreams.length,
                  itemBuilder: (context, index) {
                    final stream = _audioStreams[index];
                    return ListTile(
                      title: Text(stream.bitrate.toString()),
                      subtitle: Text(stream.container.toString()),
                      trailing: Text('${stream.size} MB'),
                      selected: selectedIndex == index,
                      selectedTileColor: Colors.blue[100],
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _startDownload,
                  child: Text('Download'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
