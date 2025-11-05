// File: lib/models/poi.dart

// Ini macam 'type' dalam TypeScript
// Kita define jenis-jenis category yang ada
enum Category { food, attractions, shopping, petrolStations }

// Extension untuk convert Category to String yang cantik
extension CategoryExtension on Category {
  String get displayName {
    switch (this) {
      case Category.food:
        return 'Food';
      case Category.attractions:
        return 'Attractions';
      case Category.shopping:
        return 'Shopping';
      case Category.petrolStations:
        return 'Petrol Stations';
    }
  }
}

// POI Class - macam interface POI dalam TypeScript
class POI {
  final String id;
  final String name;
  final Category category;
  final String address;
  final double rating;
  final String distance;
  final String image;
  final double lat;
  final double lng;
  final String description;
  final int reviews;

  // Constructor - untuk create POI object
  POI({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.rating,
    required this.distance,
    required this.image,
    required this.lat,
    required this.lng,
    required this.description,
    required this.reviews,
  });
}
