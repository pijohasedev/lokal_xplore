// File: lib/widgets/poi_image.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../models/poi.dart';

class POIImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Category? category;
  final BorderRadius? borderRadius;

  const POIImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.category,
    this.borderRadius,
  }) : super(key: key);

  IconData _getCategoryIcon(Category? cat) {
    if (cat == null) return Symbols.image;
    switch (cat) {
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blue[600],
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 40,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                'Image unavailable',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
