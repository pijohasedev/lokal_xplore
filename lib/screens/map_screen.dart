// File: lib/screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../data/mock_pois.dart';
import '../models/poi.dart';
import '../services/favorites_service.dart';
import '../utils/distance_calculator.dart'; // ← ADD THIS
import '../widgets/bottom_nav.dart';
import '../widgets/category_selector.dart';
import '../widgets/poi_image.dart'; // ← ADD THIS

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
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  LatLng currentMapCenter = const LatLng(3.1570, 101.7118);
  List<POI> nearbyPOIs = [];

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(3.1570, 101.7118),
    zoom: 13.5,
  );

  @override
  void initState() {
    super.initState();
    _updateNearbyPOIs();
    _createMarkers();
  }

  void _updateNearbyPOIs() {
    setState(() {
      nearbyPOIs = DistanceCalculator.sortPOIsByDistance(
        filteredPOIs,
        currentMapCenter,
      );
    });
  }

  List<POI> get filteredPOIs {
    var pois = mockPOIs;

    if (selectedCategory != null) {
      pois = pois.where((poi) => poi.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      pois = pois.where((poi) {
        return poi.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            poi.address.toLowerCase().contains(searchQuery.toLowerCase()) ||
            poi.category.displayName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
      }).toList();
    }

    pois = DistanceCalculator.updatePOIDistances(pois, currentMapCenter);
    pois = DistanceCalculator.sortPOIsByDistance(pois, currentMapCenter);

    return pois;
  }

  void _createMarkers() {
    final newMarkers = <Marker>{};

    for (var poi in filteredPOIs) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(poi.id),
          position: LatLng(poi.lat, poi.lng),
          infoWindow: InfoWindow(
            title: poi.name,
            snippet: '⭐ ${poi.rating} • ${poi.distance}\nTap to view details',
            onTap: () => widget.onNavigate('detail', poi),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(poi.category),
          ),
          consumeTapEvents: true,
          onTap: () {
            _showPOIBottomSheet(poi);
          },
        ),
      );
    }

    setState(() {
      markers = newMarkers;
    });
  }

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

  void _onCameraMove(CameraPosition position) {
    setState(() {
      currentMapCenter = position.target;
    });
  }

  void _onCameraIdle() {
    _updateNearbyPOIs();
    _createMarkers();
  }

  void _onCategoryChanged(Category? category) {
    setState(() {
      selectedCategory = category;
    });
    _updateNearbyPOIs();
    _createMarkers();
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _updateNearbyPOIs();
    _createMarkers();
  }

  void _clearSearch() {
    setState(() {
      searchQuery = '';
      searchController.clear();
    });
    _updateNearbyPOIs();
    _createMarkers();
    FocusScope.of(context).unfocus();
  }

  void _onNearMePressed() async {
    try {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: LatLng(3.1570, 101.7118),
            zoom: 14.0,
            tilt: 45.0,
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Symbols.location_searching, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Centering map...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not get location'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showPOIBottomSheet(POI poi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                POIImage(
                  imageUrl: poi.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  category: poi.category,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poi.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Symbols.star,
                            size: 16,
                            color: Colors.amber[600],
                            fill: 1.0,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${poi.rating}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            poi.distance,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          poi.category.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Symbols.navigation, color: Colors.blue[600]),
                    label: const Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.blue[600]!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onNavigate('detail', poi);
                    },
                    icon: const Icon(Symbols.info, color: Colors.white),
                    label: const Text('Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.food:
        return Symbols.restaurant;
      case Category.attractions:
        return Symbols.location_city;
      case Category.shopping:
        return Symbols.shopping_cart;
      case Category.petrolStations:
        return Symbols.local_gas_station;
    }
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.green[600]!;
      case 1:
        return Colors.blue[600]!;
      case 2:
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            mapType: MapType.normal,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            padding: const EdgeInsets.only(top: 400, bottom: 100),
          ),
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
          SafeArea(
            child: Column(
              children: [
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
                              Symbols.location_on,
                              color: Colors.white,
                              size: 16,
                              fill: 1.0,
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
                      controller: searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search restaurants, attractions...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(
                          Symbols.search,
                          color: Colors.blue[600],
                        ),
                        suffixIcon: searchQuery.isNotEmpty
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
                              _updateNearbyPOIs();
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
                CategorySelector(
                  selectedCategory: selectedCategory,
                  onCategoryChange: _onCategoryChanged,
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 220,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: nearbyPOIs.take(3).length,
                itemBuilder: (context, index) {
                  final poi = nearbyPOIs[index];
                  return _buildTrendingCard(poi, index);
                },
              ),
            ),
          ),
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
                          _updateNearbyPOIs();
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
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _onNearMePressed,
                  backgroundColor: Colors.blue[600],
                  child: const Icon(
                    Symbols.my_location,
                    color: Colors.white,
                    fill: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
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
      bottomNavigationBar: BottomNav(
        activeIndex: activeNavIndex,
        onTabChange: (index) {
          setState(() {
            activeNavIndex = index;
          });
          if (index == 1) {
            widget.onNavigate('favorites', null);
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile coming soon!')),
            );
          }
        },
      ),
    );
  }

  Widget _buildTrendingCard(POI poi, int index) {
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  POIImage(
                    imageUrl: poi.image,
                    width: double.infinity,
                    height: 90,
                    fit: BoxFit.cover,
                    category: poi.category,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getRankColor(index),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Symbols.location_on,
                            color: Colors.white,
                            size: 14,
                            fill: 1.0,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '#${index + 1} Nearest',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
                        child: Row(
                          children: [
                            const Icon(
                              Symbols.star,
                              color: Colors.white,
                              size: 12,
                              fill: 1.0,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${poi.rating}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  FutureBuilder<bool>(
                    future: FavoritesService.isFavorite(poi.id),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Symbols.favorite,
                              size: 12,
                              color: Colors.white,
                              fill: 1.0,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
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
                              fill: 1.0,
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
                        Row(
                          children: [
                            Icon(
                              Symbols.navigation,
                              size: 12,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              poi.distance,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

  @override
  void dispose() {
    _mapController?.dispose();
    searchController.dispose();
    super.dispose();
  }
}
