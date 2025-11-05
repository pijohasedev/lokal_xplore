// File: lib/screens/poi_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../models/poi.dart';
import '../services/favorites_service.dart';

class POIDetailScreen extends StatefulWidget {
  final POI poi;
  final Function(String, POI?) onNavigate;

  const POIDetailScreen({Key? key, required this.poi, required this.onNavigate})
    : super(key: key);

  @override
  State<POIDetailScreen> createState() => _POIDetailScreenState();
}

class _POIDetailScreenState extends State<POIDetailScreen> {
  bool isFavorite = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final fav = await FavoritesService.isFavorite(widget.poi.id);
    setState(() {
      isFavorite = fav;
      isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await FavoritesService.toggleFavorite(widget.poi.id);
    setState(() {
      isFavorite = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              newStatus ? Symbols.favorite : Symbols.heart_broken,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(newStatus ? 'Added to favorites!' : 'Removed from favorites'),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: newStatus ? Colors.red[600] : Colors.grey[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Symbols.arrow_back, color: Colors.black87),
              ),
              onPressed: () => onNavigate('list', null),
            ),
            actions: [
              IconButton(
                icon: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Symbols.favorite,
                          color: isFavorite ? Colors.red[600] : Colors.black87,
                          fill: isFavorite ? 1.0 : 0.0, // Filled when favorite!
                        ),
                ),
                onPressed: isLoading ? null : _toggleFavorite,
              ),
              IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Symbols.share, color: Colors.black87),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!')),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.poi.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          _getCategoryIcon(widget.poi.category),
                          size: 80,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Badge
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
                          child: Text(
                            widget.poi.category.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          widget.poi.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Rating & Distance
                        Row(
                          children: [
                            Icon(
                              Symbols.star,
                              color: Colors.amber[600],
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.poi.rating}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' (${widget.poi.reviews} reviews)',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Symbols.location_on,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.poi.distance,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.poi.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Address Card
                        _buildInfoCard(
                          icon: Symbols.location_on,
                          title: 'Address',
                          content: widget.poi.address,
                        ),
                        const SizedBox(height: 12),

                        // Hours Card
                        _buildInfoCard(
                          icon: Symbols.access_time,
                          title: 'Hours',
                          content: 'Open now\nMon-Sun: 9:00 AM - 9:00 PM',
                        ),
                        const SizedBox(height: 12),

                        // Contact Card
                        _buildInfoCard(
                          icon: Symbols.phone,
                          title: 'Contact',
                          content: '+60 3-1234 5678',
                        ),
                        const SizedBox(height: 24),

                        // Reviews Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Reviews',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('See all'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Sample Reviews
                        _buildReviewCard(
                          name: 'Ahmad Ibrahim',
                          rating: 5.0,
                          comment:
                              'Great place! Highly recommended. The atmosphere is amazing and the service is excellent.',
                          initials: 'AI',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildReviewCard(
                          name: 'Siti Nurhaliza',
                          rating: 4.5,
                          comment: 'Very nice location. Would visit again!',
                          initials: 'SN',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 100), // Space for button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening directions to ${widget.poi.name}...'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Symbols.navigation, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Get Directions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required double rating,
    required String comment,
    required String initials,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Symbols.star, color: Colors.amber[600], size: 16),
              const SizedBox(width: 4),
              Text(
                '$rating',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
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
}
