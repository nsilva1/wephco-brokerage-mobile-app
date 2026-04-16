import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../services/hive_service.dart';
import '../models/lead.dart';
import '../data/mock_data.dart';

class LeadProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Lead> _leads = [];
  bool _isLoading = false;
  String _searchQuery = "";

  // Getters
  List<Lead> get leads => _leads;
  bool get isLoading => _isLoading;

  LeadProvider() {
    // 1. Load from Hive/Mock immediately so the screen isn't empty
    _leads = MockData.fakeLeads;
    
    // 2. We don't fetch in the constructor directly because HiveService 
    // currentUser might be null during the very first app boot.
    // Instead, we trigger this from the UI or an Auth Listener.
  }

  /// Adds a new lead to Firestore and updates local state/cache
  Future<bool> addLead(Lead lead) async {
    // RULE 3: Auth Before Queries
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // RULE 1: Strict Paths
      final leadsCollection = _db.collection('leads');

      final dateNow = DateTime.now();
          

      // Prepare data (ensure userId is set to current user)
      final leadData = lead.toMap();
      leadData['userId'] = user.uid;
      leadData['createdAt'] = FieldValue.serverTimestamp();

      // Firebase Operation
      DocumentReference docRef = await leadsCollection.add(leadData);
      
      // Create updated lead object with the generated ID
      final savedLead = Lead(
      id: docRef.id,
      name: lead.name,
      email: lead.email,
      phone: lead.phone,
      userId: user.uid,
      propertyId: lead.propertyId,
      budget: lead.budget,
      source: lead.source,
      status: lead.status,
      createdAt: dateNow,
      currency: lead.currency,
    );

      // 4. Update local state (Prepend to list for "newest first")
      _leads.insert(0, savedLead);

      // 3. Update Local Cache (Hive)
      await HiveService.instance.saveAllLeads(_leads);

      return true;
    } catch (e, stack) {
      await FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Lead Creation Failed');
      debugPrint("Lead Creation Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchLeads(String userId) async {
    // RULE 3: Auth Before Queries
    if (FirebaseAuth.instance.currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // RULE 1: Strict Paths
      // Mandatory path: /artifacts/{appId}/public/data/{collectionName}
      const String appId = 'wephco-brokerage'; 
      final leadsCollection = _db
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('leads');

      // RULE 2: No Complex Queries
      // We avoid .orderBy() in the Firestore query to prevent index errors.
      // We fetch the collection and handle logic in memory.
      QuerySnapshot snapshot = await leadsCollection.get();

      // Convert docs to models
      List<Lead> allLeads = snapshot.docs.map((doc) {
        return Lead.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Filter in memory: Only keep leads belonging to the passed userId
      List<Lead> userLeads = allLeads.where((lead) => lead.userId == userId).toList();

      // Sort in memory: Newest first
      userLeads.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

      // 3. Update Local Cache (Hive)
      await HiveService.instance.saveAllLeads(userLeads);

      // 4. Update local state
      _leads = userLeads;
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
    
    final query = _searchQuery.toLowerCase();
    return _leads.where((l) {
      final name = (l.name ?? '').toLowerCase();
      final email = (l.email ?? '').toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners(); 
  }
}