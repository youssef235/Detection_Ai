import 'package:camera_detection/presentation/view/views/real_time_detection_view.dart';
import 'package:camera_detection/presentation/view/views/saved_images_view.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _screens = [
    const RealTimeDetectionScreen(),
    const SavedImagesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: "Detect",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: "Saved Images",
          ),
        ],
      ),
    );
  }
}
