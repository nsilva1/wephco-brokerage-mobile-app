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

  // ── Developer portfolio & analytics ─────────────────────────────────────────

  /// Every listing owned by [developerId], verified or not, newest first.
  List<Property> portfolio(String developerId) {
    if (developerId.isEmpty) return [];
    return _properties.where((p) => p.developerId == developerId).toList();
  }

  /// Property ids already counted this session, so re-opening a listing
  /// doesn't inflate its view count.
  final Set<String> _viewedThisSession = {};

  /// Counts a view of [propertyId] by [viewerId]. Developers viewing their
  /// own listing aren't counted. Fire-and-forget: failures are only logged.
  Future<void> recordView({
    required String propertyId,
    required String viewerId,
  }) async {
    if (propertyId.isEmpty || !_viewedThisSession.add(propertyId)) return;

    final index = _properties.indexWhere((p) => p.id == propertyId);
    if (index != -1 && _properties[index].developerId == viewerId) return;

    try {
      await _db.collection('properties').doc(propertyId).update({
        'views': FieldValue.increment(1),
      });
      if (index != -1) {
        final property = _properties[index];
        _properties[index] = property.copyWith(views: property.views + 1);
        notifyListeners();
      }
    } catch (e) {
      _viewedThisSession.remove(propertyId); // allow a retry next open
      debugPrint("Record View Error: $e");
    }
  }

  /// Number of leads agents have logged against [propertyId], or null when
  /// the count can't be read (e.g. offline or blocked by security rules).
  Future<int?> leadCountFor(String propertyId) async {
    try {
      final snapshot = await _db
          .collection('leads')
          .where('propertyId', isEqualTo: propertyId)
          .count()
          .get();
      return snapshot.count;
    } catch (e) {
      debugPrint("Lead Count Error: $e");
      return null;
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
        ...property.toMap(),
        'images': imageUrls,
        'pdfUrl': pdfUrl.isEmpty ? null : pdfUrl,
        'interests': [],
        'views': 0,
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

  /// The cached listing [propertyId] if [developerId] owns it, else null.
  /// Firestore security rules should enforce the same check server-side.
  Property? _ownedListing(String? propertyId, String developerId) {
    if (propertyId == null || developerId.isEmpty) return null;
    final existing = getPropertyById(propertyId);
    return existing?.developerId == developerId ? existing : null;
  }

  /// Saves a developer's edits to their own listing.
  ///
  /// The final image list is [keptImageUrls] followed by uploads of
  /// [newImageFiles]. The brochure is replaced by [newPdfFile], cleared when
  /// [removePdf] is true, and otherwise left alone. Review status, featured
  /// flag, ownership, stars and views can't be changed here.
  Future<String?> updateProperty({
    required Property property,
    required String developerId,
    required List<String> keptImageUrls,
    List<File> newImageFiles = const [],
    File? newPdfFile,
    bool removePdf = false,
  }) async {
    final existing = _ownedListing(property.id, developerId);
    if (existing == null) return "You can only edit your own listings.";

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final images = [
        ...keptImageUrls,
        ...await _uploadImages(newImageFiles, timestamp),
      ];

      String pdfUrl = removePdf ? '' : existing.pdfUrl;
      if (newPdfFile != null) {
        final pdfRef = _storage
            .ref()
            .child('properties/brochures/$timestamp.pdf');
        await pdfRef.putFile(newPdfFile);
        pdfUrl = await pdfRef.getDownloadURL();
      }

      final updates = property.toMap()
        // Admin-controlled fields stay as they are.
        ..remove('verified')
        ..remove('featured')
        ..remove('developerId')
        ..['images'] = images
        ..['pdfUrl'] = pdfUrl.isEmpty ? null : pdfUrl
        ..['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection('properties').doc(existing.id).update(updates);

      final index = _properties.indexWhere((p) => p.id == existing.id);
      if (index != -1) {
        _properties[index] = property.copyWith(
          images: images,
          pdfUrl: pdfUrl,
          verified: existing.verified,
          featured: existing.featured,
          developerId: existing.developerId,
          interests: existing.interests,
          views: existing.views,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now(),
        );
        await HiveService.instance.saveAllProperties(_properties);
        notifyListeners();
      }

      // Clean up files the listing no longer references.
      final removedFiles = [
        ...existing.images.where((url) => !images.contains(url)),
        if (existing.pdfUrl.isNotEmpty && existing.pdfUrl != pdfUrl)
          existing.pdfUrl,
      ];
      await _deleteStorageFiles(removedFiles);

      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Failed to update property.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  /// Deletes a developer's own listing along with its images and brochure.
  Future<String?> deleteProperty({
    required String propertyId,
    required String developerId,
  }) async {
    final existing = _ownedListing(propertyId, developerId);
    if (existing == null) return "You can only delete your own listings.";

    try {
      await _db.collection('properties').doc(propertyId).delete();
      _properties.removeWhere((p) => p.id == propertyId);
      await HiveService.instance.saveAllProperties(_properties);
      notifyListeners();

      await _deleteStorageFiles([
        ...existing.images,
        if (existing.pdfUrl.isNotEmpty) existing.pdfUrl,
      ]);
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Failed to delete property.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  /// Best-effort removal of uploaded files. Handles mobile download URLs
  /// (firebasestorage.googleapis.com) and the web dashboard's public URLs
  /// (`storage.googleapis.com/<bucket>/<path>`). Failures are only logged —
  /// the listing change has already succeeded.
  Future<void> _deleteStorageFiles(List<String> urls) async {
    for (final url in urls) {
      try {
        final uri = Uri.parse(url);
        final Reference ref = uri.host == 'storage.googleapis.com'
            ? _storage.ref(uri.pathSegments.skip(1).join('/'))
            : _storage.refFromURL(url);
        await ref.delete();
      } catch (e) {
        debugPrint("Storage cleanup skipped for $url: $e");
      }
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