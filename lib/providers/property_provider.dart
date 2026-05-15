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

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;

  PropertyProvider() {
    _properties = HiveService.instance.allCachedProperties;
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    _isLoading = true;
    notifyListeners();

    try {
      final QuerySnapshot snapshot =
          await _db.collection('properties').get();

      List<Property> fetched = snapshot.docs.map((doc) {
        return Property.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      fetched.sort((a, b) {
        final dateA = a.createdAt;
        final dateB = b.createdAt;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

      await HiveService.instance.saveAllProperties(fetched);
      _properties = fetched;
    } catch (e, stack) {
      await FirebaseCrashlytics.instance
          .recordError(e, stack, reason: 'Property Fetch Failed');
      debugPrint("Property Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Search & Filtering ---

  List<Property> get filteredProperties {
    if (_searchQuery.isEmpty) return _properties;
    return _properties.where((p) {
      final title = p.title.toLowerCase();
      final location = p.location.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || location.contains(query);
    }).toList();
  }

  /// Returns all verified properties that [userId] has starred.
  List<Property> starredProperties(String userId) {
    return _properties
        .where((p) => p.verified && p.interests.contains(userId))
        .toList();
  }

  /// Toggles the star/interest for [userId] on [propertyId].
  /// Returns an error string on failure, or null on success.
  Future<String?> toggleInterest({
    required String propertyId,
    required String userId,
  }) async {
    final index = _properties.indexWhere((p) => p.id == propertyId);
    if (index == -1) return "Property not found.";

    final property = _properties[index];
    final alreadyStarred = property.interests.contains(userId);

    // Optimistic update
    final updatedInterests = List<String>.from(property.interests);
    if (alreadyStarred) {
      updatedInterests.remove(userId);
    } else {
      updatedInterests.add(userId);
    }
    _properties[index] = property.copyWith(interests: updatedInterests);
    notifyListeners();

    try {
      await _db.collection('properties').doc(propertyId).update({
        'interests': alreadyStarred
            ? FieldValue.arrayRemove([userId])
            : FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await HiveService.instance.saveAllProperties(_properties);
      return null;
    } on FirebaseException catch (e) {
      _properties[index] = property; // roll back
      notifyListeners();
      return e.message ?? "Failed to update interest.";
    } catch (e) {
      _properties[index] = property;
      notifyListeners();
      return "An unexpected error occurred.";
    }
  }

  Property? getPropertyById(String id) {
    try {
      return _properties.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Upload helpers ──────────────────────────────────────────────────────────

  /// Uploads a list of image files and returns their download URLs.
  Future<List<String>> _uploadImages(
      List<File> imageFiles, int baseTimestamp) async {
    final urls = <String>[];
    for (int i = 0; i < imageFiles.length; i++) {
      final ref = _storage
          .ref()
          .child('properties/images/${baseTimestamp}_$i.jpg');
      await ref.putFile(imageFiles[i]);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  // ── CRUD ────────────────────────────────────────────────────────────────────

  Future<String?> addProperty({
    required List<File> imageFiles,
    File? pdfFile,
    required Property property,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Upload all images
      final imageUrls = await _uploadImages(imageFiles, timestamp);

      // Upload PDF if provided
      String pdfUrl = '';
      if (pdfFile != null) {
        final pdfRef = _storage
            .ref()
            .child('properties/brochures/$timestamp.pdf');
        await pdfRef.putFile(pdfFile);
        pdfUrl = await pdfRef.getDownloadURL();
      }

      // Write to Firestore
      final docRef = await _db.collection('properties').add({
        'title': property.title,
        'developer': property.developer,
        'location': property.location,
        'price': property.price,
        'yield': property.yieldValue,
        'status': property.status,
        'description': property.description,
        'images': imageUrls,
        'currency': property.currency,
        'tag': property.tag,
        'pdfUrl': pdfUrl,
        'interests': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final newProperty = property.copyWith(
        id: docRef.id,
        images: imageUrls,
        pdfUrl: pdfUrl,
        interests: [],
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
    List<File>? newImageFiles, // null = keep existing images
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

      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        updates['images'] =
            await _uploadImages(newImageFiles, timestamp);
      }

      if (newPdfFile != null) {
        final pdfRef = _storage
            .ref()
            .child('properties/brochures/$timestamp.pdf');
        await pdfRef.putFile(newPdfFile);
        updates['pdfUrl'] = await pdfRef.getDownloadURL();
      }

      await _db
          .collection('properties')
          .doc(propertyId)
          .update(updates);

      final index = _properties.indexWhere((p) => p.id == propertyId);
      if (index != -1) {
        _properties[index] = property.copyWith(
          id: propertyId,
          images: (updates['images'] as List<String>?) ??
              property.images,
          pdfUrl: (updates['pdfUrl'] as String?) ?? property.pdfUrl,
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
      String propertyId, String status) async {
    try {
      await _db.collection('properties').doc(propertyId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final index = _properties.indexWhere((p) => p.id == propertyId);
      if (index != -1) {
        _properties[index] =
            _properties[index].copyWith(status: status);
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
      String propertyId, String tag) async {
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