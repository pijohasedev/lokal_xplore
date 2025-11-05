// File: lib/screens/poi_list_screen.dart

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../data/mock_pois.dart';
import '../models/poi.dart';
import '../services/favorites_service.dart';
import '../widgets/category_selector.dart';

class POIListScreen extends StatefulWidget {
  final Function(String, POI?) onNavigate;

  const POIListScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<POIListScreen> createState() => _POIListScreenState();
}

class _POIListScreenState extends State<POIListScreen> {
  Category? selectedCategory; // null = "All"
  String searchQuery = ''; // ← ADD THIS
  TextEditingController searchController = TextEditingController();

  // Filter POIs based on selected category
  List<POI> get filteredPOIs {
    var pois = mockPOIs;

    // Filter by category
    if (selectedCategory != null) {
      pois = pois.where((poi) => poi.category == selectedCategory).toList();
    }

    // Filter by search
    if (searchQuery.isNotEmpty) {
      pois = pois.where((poi) {
        return poi.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            poi.address.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return pois;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      // App Bar (Header)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back, color: Colors.black87),
          onPressed: () => widget.onNavigate('map', null),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokal Xplore',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${filteredPOIs.length} places found',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // ADD SEARCH BAR HERE
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search places...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Symbols.search, color: Colors.blue[600]),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Symbols.close, color: Colors.grey[600]),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                            searchController.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Category Selector
          CategorySelector(
            selectedCategory: selectedCategory,
            onCategoryChange: (category) {
              setState(() {
                selectedCategory = category;
              });
            },
          ),

          // POI List
          Expanded(
            child: filteredPOIs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPOIs.length,
                    itemBuilder: (context, index) {
                      final poi = filteredPOIs[index];
                      return _buildPOICard(poi);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPOICard(POI poi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => widget.onNavigate('detail', poi),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  poi.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
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

              FutureBuilder<bool>(
                future: FavoritesService.isFavorite(poi.id),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Symbols.favorite,
                          size: 14,
                          color: Colors.white,
                          fill: 1.0,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      poi.address,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Rating
                        Icon(Symbols.star, size: 16, color: Colors.amber[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${poi.rating}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${poi.reviews})',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Distance
                        Icon(
                          Symbols.location_on,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          poi.distance,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Navigation Button
              IconButton(
                icon: Icon(Symbols.near_me, color: Colors.blue[600]),
                onPressed: () {
                  // TODO: Open Google Maps
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Navigate to ${poi.name}')),
                  );
                },
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
    searchController.dispose();
    super.dispose();
  }
}
