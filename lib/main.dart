import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suur/pages/home_page.dart';
import 'package:suur/provider/player_provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (context) => PlayerProvider(),
        child: HomePage(),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Suur',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
