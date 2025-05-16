import 'dart:convert';
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
  final _linkController = TextEditingController();
  final _yt = YoutubeExplode();

  bool _showDetails = false;
  bool _isDownloading = false;

  int _selectedIndex = 0;
  List<AudioOnlyStreamInfo> _audioStreams = [];

  String? _title, _description, _thumbnail, _videoUrl;

  Future<void> _submitLink() async {
    final link = _linkController.text.trim();
    if (link.isEmpty) return _showMessage('Please enter a valid link');

    setState(() => _showDetails = true);
    try {
      final video = await _yt.videos.get(link);
      final manifest = await _yt.videos.streams.getManifest(video.id);

      setState(() {
        _title = video.title;
        _description = video.description;
        _thumbnail = video.thumbnails.mediumResUrl;
        _videoUrl = video.url;
        _audioStreams = manifest.audioOnly.toList();
      });
    } catch (_) {
      _showMessage('Invalid video link');
      setState(() {
        _showDetails = false;
        _audioStreams.clear();
        _title = _description = _thumbnail = _videoUrl = null;
      });
    }
  }

  Future<void> _startDownload() async {
    if (_selectedIndex < 0 || _selectedIndex >= _audioStreams.length) {
      return _showMessage('Please select a valid audio stream');
    }

    setState(() => _isDownloading = true);
    try {
      final stream = _yt.videos.streams.get(_audioStreams[_selectedIndex]);
      final dir = await getDownloadsDirectory();
      if (dir == null) return _showMessage('Download directory not found');

      final filename = _title ?? 'video';
      final filePath = '${dir.path}/$filename';
      final file = File(
        '$filePath/music_${_audioStreams[_selectedIndex].bitrate.kiloBitsPerSecond}kbps.${_audioStreams[_selectedIndex].container}',
      );

      if (await file.exists()) await file.delete();
      await file.create(recursive: true);
      final sink = file.openWrite();
      await stream.pipe(sink);
      await sink.flush();
      await sink.close();

      await _writeMetadata(filePath);
      _showMessage('Downloaded to $filePath');
      _resetState();
    } catch (_) {
      _showMessage('Download failed');
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _writeMetadata(String dir) async {
    final file = File('$dir/manifest.txt');
    if (await file.exists()) await file.delete();
    await file.create(recursive: true);

    final metadata = {
      'videoTitle': _title,
      'videoDescription': _description,
      'videoUrl': _videoUrl,
      'title':
          _title?.split(' - ').length == 2
              ? _title!.split(' - ')[1].trim()
              : _title,
      'artist':
          _title?.split(' - ').length == 2
              ? _title!.split(' - ')[0].trim()
              : 'Unknown Artist',
      'image': _thumbnail,
    };

    await file.writeAsString(JsonEncoder.withIndent('  ').convert(metadata));
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _resetState() {
    setState(() {
      _linkController.clear();
      _audioStreams.clear();
      _title = _description = _thumbnail = _videoUrl = null;
      _selectedIndex = 0;
      _showDetails = false;
      _isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Downloader')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Enter music link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              !_showDetails
                  ? ElevatedButton(
                    onPressed: _submitLink,
                    child: const Text('Submit'),
                  )
                  : _audioStreams.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDownloadDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_thumbnail != null) Image.network(_thumbnail!, fit: BoxFit.cover),
        const SizedBox(height: 16),
        if (_title != null)
          Text(_title!, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_description != null)
          Text(
            _description!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        const SizedBox(height: 16),
        Text('Audio Streams:', style: Theme.of(context).textTheme.titleMedium),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _audioStreams.length,
          itemBuilder: (context, index) {
            final stream = _audioStreams[index];
            return ListTile(
              title: Text(stream.bitrate.toString()),
              subtitle: Text(stream.container.toString()),
              trailing: Text('${stream.size} MB'),
              selected: _selectedIndex == index,
              selectedTileColor: Colors.blue[100],
              onTap: () => setState(() => _selectedIndex = index),
            );
          },
        ),
        const SizedBox(height: 16),
        _isDownloading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
              onPressed: _startDownload,
              child: const Text('Download'),
            ),
      ],
    );
  }
}
