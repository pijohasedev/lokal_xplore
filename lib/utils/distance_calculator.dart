// File: lib/utils/distance_calculator.dart

import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/poi.dart';

class DistanceCalculator {
  /// Calculate distance between two coordinates in kilometers
  /// Using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth radius in km

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// Format distance to readable string
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  /// Get POIs sorted by distance from a point
  static List<POI> sortPOIsByDistance(List<POI> pois, LatLng centerPoint) {
    // Create a list with POI and calculated distance
    final poisWithDistance = pois.map((poi) {
      final distance = calculateDistance(
        centerPoint.latitude,
        centerPoint.longitude,
        poi.lat,
        poi.lng,
      );
      return {'poi': poi, 'distance': distance};
    }).toList();

    // Sort by distance (nearest first)
    poisWithDistance.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    // Return sorted POI list
    return poisWithDistance.map((item) => item['poi'] as POI).toList();
  }

  /// Update POI distance field based on current location
  static List<POI> updatePOIDistances(List<POI> pois, LatLng currentLocation) {
    return pois.map((poi) {
      final distance = calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        poi.lat,
        poi.lng,
      );

      // Create new POI with updated distance
      return POI(
        id: poi.id,
        name: poi.name,
        category: poi.category,
        address: poi.address,
        rating: poi.rating,
        distance: formatDistance(distance),
        image: poi.image,
        lat: poi.lat,
        lng: poi.lng,
        description: poi.description,
        reviews: poi.reviews,
      );
    }).toList();
  }
}
