import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suur/pages/download_page.dart';
import 'package:suur/pages/library_list_page.dart';
import 'package:suur/provider/player_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageController = PageController();
  int _selectedPageIndex = 0;
  bool _isRailHovered = false;

  bool get _isDesktop {
    final width = MediaQuery.of(context).size.width;
    return width >= 800; // Customize threshold based on your design
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);
    final pages = [
      Center(child: Text("Page 1")),
      LibraryListPage(),
      DownloadPage(),
    ];

    return Scaffold(
      body: Row(
        children: [
          if (_isDesktop)
            MouseRegion(
              onEnter: (_) => setState(() => _isRailHovered = true),
              onExit: (_) => setState(() => _isRailHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isRailHovered ? 200 : 72,
                child: NavigationRail(
                  extended: _isRailHovered,
                  selectedIndex: _selectedPageIndex,
                  onDestinationSelected: _onItemTapped,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.explore),
                      label: Text("Discover"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.library_books),
                      label: Text("Library"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.download),
                      label: Text("Download"),
                    ),
                  ],
                ),
              ),
            ),
          if (_isDesktop)
            const VerticalDivider(thickness: 1, color: Colors.grey),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          !_isDesktop
              ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BottomNavigationBar(
                    currentIndex: _selectedPageIndex,
                    onTap: _onItemTapped,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.explore),
                        label: "Discover",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.library_books),
                        label: "Library",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.download),
                        label: "Download",
                      ),
                    ],
                  ),
                ),
              )
              : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child:
            player.isPlaying
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
