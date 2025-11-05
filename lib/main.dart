// File: lib/main.dart

import 'package:flutter/material.dart';

import 'models/poi.dart';
import 'screens/map_screen.dart';
import 'screens/poi_detail_screen.dart';
import 'screens/poi_list_screen.dart';

void main() {
  runApp(const LokalExploreApp());
}

class LokalExploreApp extends StatelessWidget {
  const LokalExploreApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lokal Xplore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({Key? key}) : super(key: key);

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  String currentScreen = 'map';
  POI? selectedPOI;

  void handleNavigate(String screen, POI? poi) {
    setState(() {
      currentScreen = screen;
      if (poi != null) {
        selectedPOI = poi;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show appropriate screen based on currentScreen
    switch (currentScreen) {
      case 'map':
        return MapScreen(onNavigate: handleNavigate);
      case 'list':
        return POIListScreen(onNavigate: handleNavigate);
      case 'detail':
        if (selectedPOI != null) {
          return POIDetailScreen(poi: selectedPOI!, onNavigate: handleNavigate);
        }
        // Fallback to map if no POI selected
        return MapScreen(onNavigate: handleNavigate);
      default:
        return MapScreen(onNavigate: handleNavigate);
    }
  }
}
