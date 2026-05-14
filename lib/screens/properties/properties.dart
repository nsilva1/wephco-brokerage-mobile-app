import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/models/property.dart';
import 'package:wephco_brokerage/providers/property_provider.dart';
import 'package:wephco_brokerage/providers/user_provider.dart';
import 'package:wephco_brokerage/screens/properties/property_details.dart';
import 'package:wephco_brokerage/screens/properties/starred_properties_screen.dart';
import '../../utils/helper_functions.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(const Duration(days: 30));
    final allProperties = context
        .watch<PropertyProvider>()
        .filteredProperties
        .where((property) => property.verified == true)
        .toList();

    // Read current user ID — adjust to your auth provider's getter
    final currentUserId =
        context.watch<UserProvider>().currentUser?.id ?? '';

    final localProperties = allProperties.where((p) {
      final isLocal = p.tag.toLowerCase() == 'local';
      final isRecent = p.createdAt!.isAfter(oneMonthAgo);
      return isLocal && isRecent;
    }).toList();

    final internationalProperties = allProperties
        .where((p) => p.tag.toLowerCase() == 'international')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header + Search ────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Property Listings",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      // ── Starred properties shortcut ────────────────────
                      IconButton(
                        tooltip: "Starred Properties",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StarredPropertiesScreen(
                                userId: currentUserId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.bookmarks_rounded,
                          color: Color(0xFF061A0A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _searchInput(),
                ],
              ),
            ),

            // ── Tab Bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTabBar(
                localCount: localProperties.length,
                internationalCount: internationalProperties.length,
              ),
            ),

            const SizedBox(height: 8),

            // ── Tab Views ──────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _propertiesListView(localProperties, currentUserId),
                  _propertiesListView(internationalProperties, currentUserId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Custom pill-style tab bar ──────────────────────────────────────────────
  Widget _buildTabBar({
    required int localCount,
    required int internationalCount,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF061A0A),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_city_rounded, size: 16),
                const SizedBox(width: 6),
                const Text("Local"),
                const SizedBox(width: 6),
                _countBadge(localCount),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.public_rounded, size: 16),
                const SizedBox(width: 6),
                const Text("International"),
                const SizedBox(width: 6),
                _countBadge(internationalCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _countBadge(int count) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(count),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$count',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ── Search input ───────────────────────────────────────────────────────────
  Widget _searchInput() {
    return TextField(
      onChanged: (value) =>
          context.read<PropertyProvider>().updateSearch(value),
      decoration: InputDecoration(
        hintText: "Search by title or location...",
        prefixIcon: const Icon(Icons.search, color: Color(0xFF235F23)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  // ── Scrollable list for a tab ──────────────────────────────────────────────
  Widget _propertiesListView(List<Property> properties, String userId) {
    if (properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              "No properties found.",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: properties.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final property = properties[index];
        return _propertyCard(property, userId);
      },
    );
  }

  // ── Property card ──────────────────────────────────────────────────────────
  Widget _propertyCard(Property property, String userId) {
    final isStarred = property.interests.contains(userId);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section with Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  property.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                ),
              ),
              // Status badge (bottom-left)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF333333).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    property.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // ── Star / bookmark button (top-right) ──────────────────────
              Positioned(
                top: 12,
                right: 12,
                child: _StarButton(
                  propertyId: property.id!,
                  userId: userId,
                  isStarred: isStarred,
                ),
              ),
            ],
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF000000),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFFC8E6C9),
                      size: 28,
                    ),
                  ],
                ),
                Text(
                  property.location,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PRICE",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          formatCurrency(property.price,
                                  currency: property.currency)
                              .replaceAll('.00', ''),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertyDetails(
                                  propertyId: property.id!),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF061A0A),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "View Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Extracted star button widget (handles its own loading state) ──────────────
class _StarButton extends StatefulWidget {
  final String propertyId;
  final String userId;
  final bool isStarred;

  const _StarButton({
    required this.propertyId,
    required this.userId,
    required this.isStarred,
  });

  @override
  State<_StarButton> createState() => _StarButtonState();
}

class _StarButtonState extends State<_StarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isLoading || widget.userId.isEmpty) return;

    // Play bounce animation
    await _animController.forward();
    _animController.reverse();

    setState(() => _isLoading = true);

    final error = await context.read<PropertyProvider>().toggleInterest(
          propertyId: widget.propertyId,
          userId: widget.userId,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF061A0A),
                  ),
                )
              : Icon(
                  widget.isStarred
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: widget.isStarred
                      ? const Color(0xFF1B5E20)
                      : Colors.grey.shade400,
                  size: 22,
                ),
        ),
      ),
    );
  }
}