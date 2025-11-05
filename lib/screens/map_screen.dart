// File: lib/screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../data/mock_pois.dart';
import '../models/poi.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/category_selector.dart';

class MapScreen extends StatefulWidget {
  final Function(String, POI?) onNavigate;

  const MapScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Category? selectedCategory;
  int activeNavIndex = 0;
  Set<Marker> markers = {};

  String searchQuery = ''; // ← NEW
  TextEditingController searchController = TextEditingController(); // ← NEW

  // Default location (KL City Centre)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(3.1570, 101.7118), // KLCC coordinates
    zoom: 13.5,
  );

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  // Filter POIs based on category AND search
  List<POI> get filteredPOIs {
    var pois = mockPOIs;

    // Filter by category
    if (selectedCategory != null) {
      pois = pois.where((poi) => poi.category == selectedCategory).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      pois = pois.where((poi) {
        return poi.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            poi.address.toLowerCase().contains(searchQuery.toLowerCase()) ||
            poi.category.displayName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
      }).toList();
    }

    return pois;
  }

  // Create markers for POIs
  void _createMarkers() {
    final newMarkers = <Marker>{};

    for (var poi in filteredPOIs) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(poi.id),
          position: LatLng(poi.lat, poi.lng),
          infoWindow: InfoWindow(
            title: poi.name,
            snippet: '${poi.rating} ⭐ • ${poi.distance}',
            onTap: () => widget.onNavigate('detail', poi),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(poi.category),
          ),
        ),
      );
    }

    setState(() {
      markers = newMarkers;
    });
  }

  // Get marker color based on category
  double _getMarkerColor(Category category) {
    switch (category) {
      case Category.food:
        return BitmapDescriptor.hueRed;
      case Category.attractions:
        return BitmapDescriptor.hueBlue;
      case Category.shopping:
        return BitmapDescriptor.hueViolet;
      case Category.petrolStations:
        return BitmapDescriptor.hueGreen;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCategoryChanged(Category? category) {
    setState(() {
      selectedCategory = category;
    });
    _createMarkers();
  }

  // ADD THESE TWO METHODS HERE (SEPARATE, NOT INSIDE OTHER METHOD)
  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _createMarkers();
  }

  void _clearSearch() {
    setState(() {
      searchQuery = '';
      searchController.clear();
    });
    _createMarkers();
    FocusScope.of(context).unfocus();
  }

  // THEN _onNearMePressed (WITHOUT nested methods inside)
  void _onNearMePressed() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(_initialPosition),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Symbols.location_searching, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Finding places near you...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          Container(
            color: Colors.grey[200],
            child: Stack(
              children: [
                // Grid pattern
                CustomPaint(size: Size.infinite, painter: GridPainter()),
                // Center message
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Map View',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${filteredPOIs.length} places nearby',
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                // Mock POI markers
                ...filteredPOIs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final poi = entry.value;
                  final positions = [
                    Offset(0.3, 0.25),
                    Offset(0.6, 0.35),
                    Offset(0.25, 0.5),
                    Offset(0.7, 0.45),
                    Offset(0.4, 0.65),
                    Offset(0.8, 0.3),
                    Offset(0.65, 0.7),
                    Offset(0.5, 0.55),
                  ];
                  final position = positions[index % positions.length];

                  return Positioned(
                    left: MediaQuery.of(context).size.width * position.dx,
                    top: MediaQuery.of(context).size.height * position.dy,
                    child: GestureDetector(
                      onTap: () => widget.onNavigate('detail', poi),
                      child: Icon(
                        Symbols.explore,
                        size: 40,
                        color: Colors.red[600],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // Top Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Header
          SafeArea(
            child: Column(
              children: [
                // App Title & Counter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue[600]!,
                                  Colors.purple[600]!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Symbols.location_on,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lokal Xplore',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Discover nearby places',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[600]!, Colors.purple[600]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Symbols.star_shine,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${filteredPOIs.length} places',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController, // ← ADD CONTROLLER
                      onChanged: _onSearchChanged, // ← ADD CALLBACK
                      decoration: InputDecoration(
                        hintText: 'Search restaurants, attractions...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(
                          Symbols.search,
                          color: Colors.blue[600],
                        ),
                        suffixIcon:
                            searchQuery
                                .isNotEmpty // ← SHOW X BUTTON WHEN TYPING
                            ? IconButton(
                                icon: Icon(
                                  Symbols.close,
                                  color: Colors.grey[600],
                                ),
                                onPressed: _clearSearch,
                              )
                            : Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue[600]!,
                                      Colors.purple[600]!,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Symbols.tune,
                                  color: Colors.white,
                                  size: 20,
                                  fill: 1.0,
                                ),
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const SizedBox(height: 12),

                // Active Filters Indicator (NEW!)
                if (searchQuery.isNotEmpty || selectedCategory != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Symbols.filter_alt,
                            size: 16,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getActiveFilterText(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategory = null;
                                searchQuery = '';
                                searchController.clear();
                              });
                              _createMarkers();
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Symbols.close,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Category Selector (existing)
                CategorySelector(
                  selectedCategory: selectedCategory,
                  onCategoryChange: _onCategoryChanged,
                ),

                // Category Selector
                CategorySelector(
                  selectedCategory: selectedCategory,
                  onCategoryChange: _onCategoryChanged,
                ),
              ],
            ),
          ),

          // Trending Places Cards (Horizontal scroll)
          Positioned(
            top: MediaQuery.of(context).padding.top + 220,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredPOIs.take(3).length,
                itemBuilder: (context, index) {
                  final poi = filteredPOIs[index];
                  return _buildTrendingCard(poi);
                },
              ),
            ),
          ),

          // No Results Message
          if (filteredPOIs.isEmpty)
            Positioned.fill(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No places found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        searchQuery.isNotEmpty
                            ? 'Try different keywords'
                            : 'No places in this category',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedCategory = null;
                            searchQuery = '';
                            searchController.clear();
                          });
                          _createMarkers();
                          FocusScope.of(context).unfocus();
                        },
                        icon: const Icon(Symbols.refresh),
                        label: const Text('Clear All Filters'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating Action Buttons
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                // Near Me Button
                FloatingActionButton(
                  onPressed: _onNearMePressed,
                  backgroundColor: Colors.blue[600],
                  child: const Icon(Symbols.my_location, color: Colors.white),
                ),
                const SizedBox(height: 12),
                // List View Button
                FloatingActionButton.extended(
                  onPressed: () => widget.onNavigate('list', null),
                  backgroundColor: Colors.white,
                  icon: Icon(Symbols.list, color: Colors.blue[600]),
                  label: Text(
                    'View List',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNav(
        activeIndex: activeNavIndex,
        onTabChange: (index) {
          setState(() {
            activeNavIndex = index;
          });
          // TODO: Handle tab changes (Favorites, Profile)
          if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Favorites coming soon!')),
            );
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile coming soon!')),
            );
          }
        },
      ),
    );
  }

  String _getActiveFilterText() {
    List<String> filters = [];

    if (selectedCategory != null) {
      filters.add(selectedCategory!.displayName);
    }

    if (searchQuery.isNotEmpty) {
      filters.add('"$searchQuery"');
    }

    if (filters.isEmpty) return 'Active filters';

    return 'Filtered by: ${filters.join(' • ')}';
  }

  Widget _buildTrendingCard(POI poi) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => widget.onNavigate('detail', poi),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      poi.image,
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 90,
                          color: Colors.grey[300],
                          child: Icon(
                            _getCategoryIcon(poi.category),
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  if (poi.rating >= 4.5)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Trending',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Info
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Symbols.star,
                              color: Colors.amber[600],
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${poi.rating}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          poi.distance,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.food:
        return Symbols.restaurant;
      case Category.attractions:
        return Symbols.attractions;
      case Category.shopping:
        return Symbols.shopping_bag;
      case Category.petrolStations:
        return Symbols.local_gas_station;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    searchController.dispose();
    super.dispose();
  }
}

// Grid Painter for map background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.0;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
