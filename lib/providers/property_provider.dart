import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../services/hive_service.dart';
import '../models/property.dart';
// import '../data/mock_data.dart';

class PropertyProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Property> _properties = [];
  bool _isLoading = false;
  String _searchQuery = "";

  // Getters
  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;

  PropertyProvider() {
    // 1. Load from Hive immediately so the screen isn't empty
    // _properties = HiveService.instance.allCachedProperties;
    _properties = HiveService.instance.allCachedProperties;
    
    // 2. Fetch fresh data from Firestore
    // fetchProperties();
  }

  Future<void> fetchProperties() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch from Firestore (ordered by newest first)
      QuerySnapshot snapshot = await _db
          .collection('properties').get();

      // Convert docs to models
      List<Property> fetched = snapshot.docs.map((doc) {
        return Property.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // sort fetched properties
      fetched.sort((a, b) {
        final dateA = a.createdAt;
        final dateB = b.createdAt;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1; // Nulls move to the end
        if (dateB == null) return -1;

        return dateB.compareTo(dateA); // Descending order
      });

      // 3. Update Local Cache (Hive)
      await HiveService.instance.saveAllProperties(fetched);

      // 4. Update local state
      _properties = fetched;
    } catch (e, stack) {
      await FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Property Fetch Failed');
      debugPrint("Property Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Search & Filtering Logic ---
  
  List<Property> get filteredProperties {
    if (_searchQuery.isEmpty) return _properties;
    
    return _properties.where((p) {
      final title = p.title.toLowerCase();
      final location = p.location.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || location.contains(query);
    }).toList();
  }

  // Returns a property by its ID from the currently loaded list
Property? getPropertyById(String id) {
  _isLoading = true;

  try {
    return _properties.firstWhere((property) => property.id == id);
  } catch (e) {
    // Returns null if no property matches the ID
    return null; 
  } finally {
    _isLoading = false;
  }
}

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners(); // Rebuilds the UI as the user types
  }
}