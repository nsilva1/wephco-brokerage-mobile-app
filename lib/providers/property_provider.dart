import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../services/hive_service.dart';
import '../models/property.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class PropertyProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
    fetchProperties();
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
  try {
    return _properties.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners(); // Rebuilds the UI as the user types
  }

  Future<String?> addProperty({
    required File imageFile,
    File? pdfFile,
    required Property property,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 1. Upload image to Firebase Storage
      final imageRef = _storage
          .ref()
          .child('properties/images/$timestamp.jpg');
      await imageRef.putFile(imageFile);
      final imageUrl = await imageRef.getDownloadURL();

      // 2. Upload PDF if provided
      String pdfUrl = '';
      if (pdfFile != null) {
        final pdfRef = _storage
            .ref()
            .child('properties/brochures/$timestamp.pdf');
        await pdfRef.putFile(pdfFile);
        pdfUrl = await pdfRef.getDownloadURL();
      }

      // 3. Write to Firestore
      final docRef = await _db.collection('properties').add({
        'title': property.title,
        'developer': property.developer,
        'location': property.location,
        'price': property.price,
        'yield': property.yieldValue,
        'status': property.status,
        'description': property.description,
        'image': imageUrl,
        'currency': property.currency,
        'tag': property.tag,
        'pdfUrl': pdfUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. Update local list
      final newProperty = property.copyWith(
        id: docRef.id,
        image: imageUrl,
        pdfUrl: pdfUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _properties.insert(0, newProperty);
      await HiveService.instance.saveAllProperties(_properties);
      notifyListeners();

      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Failed to add property.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<String?> updateProperty({
    required String propertyId,
    File? newImageFile,
    File? newPdfFile,
    required Property property,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final Map<String, dynamic> updates = {
        'title': property.title,
        'developer': property.developer,
        'location': property.location,
        'price': property.price,
        'yield': property.yieldValue,
        'status': property.status,
        'description': property.description,
        'currency': property.currency,
        'tag': property.tag,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Upload new image if changed
      if (newImageFile != null) {
        final imageRef = _storage
            .ref()
            .child('properties/images/$timestamp.jpg');
        await imageRef.putFile(newImageFile);
        updates['image'] = await imageRef.getDownloadURL();
      }

      // Upload new PDF if changed
      if (newPdfFile != null) {
        final pdfRef = _storage
            .ref()
            .child('properties/brochures/$timestamp.pdf');
        await pdfRef.putFile(newPdfFile);
        updates['pdfUrl'] = await pdfRef.getDownloadURL();
      }

      // Update Firestore
      await _db.collection('properties').doc(propertyId).update(updates);

      // Update local list
      final index = _properties.indexWhere((p) => p.id == propertyId);
      if (index != -1) {
        _properties[index] = property.copyWith(
          id: propertyId,
          image: updates['image'] ?? property.image,
          pdfUrl: updates['pdfUrl'] ?? property.pdfUrl,
          updatedAt: DateTime.now(),
        );
        await HiveService.instance.saveAllProperties(_properties);
        notifyListeners();
      }

      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Failed to update property.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<String?> deleteProperty(String propertyId) async {
    try {
      await _db.collection('properties').doc(propertyId).delete();
      _properties.removeWhere((p) => p.id == propertyId);
      await HiveService.instance.saveAllProperties(_properties);
      notifyListeners();
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Failed to delete property.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<String?> updatePropertyStatus(
    String propertyId,
    String status,
  ) async {
    try {
      await _db.collection('properties').doc(propertyId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final index = _properties.indexWhere((p) => p.id == propertyId);
      if (index != -1) {
        _properties[index] = _properties[index].copyWith(status: status);
        notifyListeners();
        await HiveService.instance.saveAllProperties(_properties);
      }

      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Failed to update status.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<String?> updatePropertyTag(
    String propertyId,
    String tag,
  ) async {
    try {
      await _db.collection('properties').doc(propertyId).update({
        'tag': tag,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final index = _properties.indexWhere((p) => p.id == propertyId);
      if (index != -1) {
        _properties[index] = _properties[index].copyWith(tag: tag);
        notifyListeners();
        await HiveService.instance.saveAllProperties(_properties);
      }

      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Failed to update tag.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }
}