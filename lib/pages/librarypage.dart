import 'package:flutter/material.dart';
import 'package:suur/services/library_folder.dart';

class LibraryPage extends StatefulWidget {
  final LibraryFolder libraryFolder;

  const LibraryPage({super.key, required this.libraryFolder});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.libraryFolder.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(widget.libraryFolder.subtitle),
      ),
    );
  }
}
