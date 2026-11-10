import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'property.g.dart';

// Mirrors the web `IProperty` / `IPropertyAgent` / `IPropertyUnit` interfaces.
//
// Fields the web types as `string | number | (string | number)[]` (bedroom,
// bathroom, square_foot) are normalised to `List<String>` on mobile: a single
// value becomes a one-item list. `toMap()` converts them back.

@HiveType(typeId: 8)
class PropertyAgent extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String phone;

  PropertyAgent({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory PropertyAgent.fromMap(Map<String, dynamic> map) {
    return PropertyAgent(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
      };
}

@HiveType(typeId: 9)
class PropertyUnit extends HiveObject {
  @HiveField(0)
  final String bedroom;
  @HiveField(1)
  final String bathroom;
  @HiveField(2)
  final String squareFoot;

  PropertyUnit({
    required this.bedroom,
    required this.bathroom,
    required this.squareFoot,
  });

  factory PropertyUnit.fromMap(Map<String, dynamic> map) {
    return PropertyUnit(
      bedroom: map['bedroom']?.toString() ?? '',
      bathroom: map['bathroom']?.toString() ?? '',
      squareFoot: map['square_foot']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'bedroom': _toFirestoreScalar(bedroom),
        'bathroom': _toFirestoreScalar(bathroom),
        'square_foot': _toFirestoreScalar(squareFoot),
      };
}

@HiveType(typeId: 3)
class Property extends HiveObject {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String developer;
  @HiveField(3)
  final String location;
  @HiveField(4)
  final double price;
  @HiveField(5)
  final double? yieldValue;
  /// 'Available' | 'Under Offer' | 'Sold'
  @HiveField(6)
  final String status;
  @HiveField(7)
  final String description;
  @HiveField(8)
  final List<String> images;
  @HiveField(9)
  final DateTime? createdAt;
  /// 'USD' | 'NGN'
  @HiveField(10)
  final String currency;
  /// 'Local' | 'International'
  @HiveField(11)
  final String tag;
  /// Empty when there is no brochure (web stores `null`).
  @HiveField(12)
  final String pdfUrl;
  @HiveField(13)
  final DateTime? updatedAt;
  /// 'Rent' | 'Lease' | 'Sale'
  @HiveField(14)
  final String category;
  @HiveField(15)
  final bool verified;
  @HiveField(16)
  final List<String> interests;
  /// Shareable Google Maps link for the property, e.g.
  /// https://maps.app.goo.gl/gHfd2k4Mmwopij2V6 — empty when not provided.
  @HiveField(17, defaultValue: '')
  final String googleMapLocation;
  @HiveField(18, defaultValue: <String>[])
  final List<String> bedroom;
  @HiveField(19, defaultValue: <String>[])
  final List<String> bathroom;
  @HiveField(20, defaultValue: <String>[])
  final List<String> squareFoot;
  @HiveField(21, defaultValue: <PropertyUnit>[])
  final List<PropertyUnit> units;
  @HiveField(22, defaultValue: false)
  final bool featured;
  @HiveField(23)
  final PropertyAgent? agent;
  /// uid of the Developer account that owns this listing — empty for
  /// properties added by agents or the admin dashboard.
  @HiveField(24, defaultValue: '')
  final String developerId;
  /// Times the details screen was opened by someone other than the developer.
  @HiveField(25, defaultValue: 0)
  final int views;

  Property({
    this.id,
    required this.title,
    required this.developer,
    required this.location,
    required this.price,
    this.yieldValue,
    required this.status,
    required this.description,
    required this.images,
    this.createdAt,
    required this.currency,
    required this.tag,
    required this.pdfUrl,
    this.updatedAt,
    required this.category,
    required this.verified,
    this.interests = const [],
    this.googleMapLocation = '',
    this.bedroom = const [],
    this.bathroom = const [],
    this.squareFoot = const [],
    this.units = const [],
    this.featured = false,
    this.agent,
    this.developerId = '',
    this.views = 0,
  });

  factory Property.fromMap(Map<String, dynamic> map, [String? docId]) {
    // Web writes `yieldValue`; older mobile-created docs used `yield`.
    final rawYield = map['yieldValue'] ?? map['yield'];

    return Property(
      id: docId ?? map['id'],
      title: map['title'] ?? '',
      developer: map['developer'] ?? '',
      location: map['location'] ?? '',
      price: (map['price'] as num? ?? 0).toDouble(),
      yieldValue: rawYield is num ? rawYield.toDouble() : null,
      status: map['status'] ?? 'Available',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      currency: map['currency'] ?? '',
      createdAt: _toDate(map['createdAt']),
      tag: map['tag'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      updatedAt: _toDate(map['updatedAt']),
      category: map['category'] ?? '',
      verified: map['verified'] ?? false,
      interests: List<String>.from(map['interests'] ?? []),
      googleMapLocation: map['googleMapLocation'] ?? '',
      bedroom: _toStringList(map['bedroom']),
      bathroom: _toStringList(map['bathroom']),
      squareFoot: _toStringList(map['square_foot']),
      units: (map['units'] as List? ?? [])
          .whereType<Map>()
          .map((u) => PropertyUnit.fromMap(Map<String, dynamic>.from(u)))
          .toList(),
      featured: map['featured'] == true,
      agent: map['agent'] is Map
          ? PropertyAgent.fromMap(Map<String, dynamic>.from(map['agent']))
          : null,
      developerId: map['developerId'] ?? '',
      views: (map['views'] as num? ?? 0).toInt(),
    );
  }

  /// Firestore fields in the web `IProperty` shape. Leaves out `id`,
  /// `interests`, `views`, `createdAt` and `updatedAt`, which callers manage
  /// (interests and views are counters updated atomically).
  Map<String, dynamic> toMap() => {
        'title': title,
        'developer': developer,
        'location': location,
        'googleMapLocation': googleMapLocation,
        'price': price,
        'yieldValue': yieldValue,
        'status': status,
        'description': description,
        'images': images,
        'currency': currency,
        'tag': tag,
        'pdfUrl': pdfUrl.isEmpty ? null : pdfUrl,
        'category': category,
        'bedroom': _fromStringList(bedroom),
        'bathroom': _fromStringList(bathroom),
        'square_foot': _fromStringList(squareFoot),
        'units': units.map((u) => u.toMap()).toList(),
        'verified': verified,
        'featured': featured,
        'agent': agent?.toMap(),
        'developerId': developerId,
      };

  Property copyWith({
    String? id,
    String? title,
    String? developer,
    String? location,
    double? price,
    double? yieldValue,
    String? status,
    String? description,
    List<String>? images,
    DateTime? createdAt,
    String? currency,
    String? tag,
    String? pdfUrl,
    DateTime? updatedAt,
    String? category,
    bool? verified,
    List<String>? interests,
    String? googleMapLocation,
    List<String>? bedroom,
    List<String>? bathroom,
    List<String>? squareFoot,
    List<PropertyUnit>? units,
    bool? featured,
    PropertyAgent? agent,
    String? developerId,
    int? views,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      developer: developer ?? this.developer,
      location: location ?? this.location,
      price: price ?? this.price,
      yieldValue: yieldValue ?? this.yieldValue,
      status: status ?? this.status,
      description: description ?? this.description,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      currency: currency ?? this.currency,
      tag: tag ?? this.tag,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      verified: verified ?? this.verified,
      interests: interests ?? this.interests,
      googleMapLocation: googleMapLocation ?? this.googleMapLocation,
      bedroom: bedroom ?? this.bedroom,
      bathroom: bathroom ?? this.bathroom,
      squareFoot: squareFoot ?? this.squareFoot,
      units: units ?? this.units,
      featured: featured ?? this.featured,
      agent: agent ?? this.agent,
      developerId: developerId ?? this.developerId,
      views: views ?? this.views,
    );
  }
}

/// Mobile writes Firestore Timestamps; the web dashboard writes ISO strings.
DateTime? _toDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// `string | number | (string | number)[]` → `List<String>`.
List<String> _toStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.where((v) => v != null).map((v) => v.toString()).toList();
  }
  final s = value.toString();
  return s.isEmpty ? [] : [s];
}

/// `List<String>` → a single value when there is one, otherwise a list.
dynamic _fromStringList(List<String> values) {
  if (values.isEmpty) return '';
  if (values.length == 1) return _toFirestoreScalar(values.first);
  return values.map(_toFirestoreScalar).toList();
}

/// Writes numeric strings back as numbers, matching what the web sends.
dynamic _toFirestoreScalar(String value) => num.tryParse(value) ?? value;
