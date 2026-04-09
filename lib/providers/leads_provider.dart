import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../services/hive_service.dart';
import '../models/lead.dart';

class LeadProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Lead> _leads = [];
  bool _isLoading = false;
  String _searchQuery = "";

  // Getters
  List<Lead> get leads => _leads;
  bool get isLoading => _isLoading;

  LeadProvider() {
    // 1. Load from Hive immediately so the screen isn't empty
    _leads = HiveService.instance.allCachedLeads;
    
    // 2. Fetch fresh data from Firestore
    fetchLeads(HiveService.instance.currentUser!.id);
  }

  Future<void> fetchLeads(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (FirebaseAuth.instance.currentUser == null) return;

      // Fetch from Firestore (ordered by newest first)
      QuerySnapshot snapshot = await _db
          .collection('leads')
          .orderBy('createdAt', descending: true)
          .get();

      // Convert docs to models
      List<Lead> fetchedLeads = snapshot.docs.map((doc) {
        return Lead.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Filter in memory: Only keep leads belonging to the passed userId
      List<Lead> filteredLeads = fetchedLeads.where((lead) {
        // Ensure your Lead model has a userId field
        return lead.userId == userId;
      }).toList();


      // 3. Update Local Cache (Hive)
      await HiveService.instance.saveAllLeads(filteredLeads);

      // 4. Update local state
      _leads = filteredLeads;
    } catch (e, stack) {
      await FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Lead Fetch Failed');
      debugPrint("Lead Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Search & Filtering Logic ---
  
  List<Lead> get filteredLeads {
    if (_searchQuery.isEmpty) return _leads;
    
    return _leads.where((l) {
      final name = l.name.toLowerCase();
      final email = l.email.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners(); // Rebuilds the UI as the user types
  }
}