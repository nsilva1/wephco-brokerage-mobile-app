import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/models/property.dart';
import 'package:wephco_brokerage/providers/property_provider.dart';
import 'package:wephco_brokerage/screens/properties/property_details.dart';
import '../../utils/helper_functions.dart';

class StarredPropertiesScreen extends StatelessWidget {
  final String userId;

  const StarredPropertiesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final starred = context.watch<PropertyProvider>().starredProperties(userId);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FB),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF061A0A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Starred Properties",
          style: TextStyle(
            color: Color(0xFF061A0A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _CountBadge(count: starred.length),
          ),
        ],
      ),
      body: starred.isEmpty
          ? _EmptyState()
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: starred.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                return _StarredPropertyCard(
                  property: starred[index],
                  userId: userId,
                );
              },
            ),
    );
  }
}

// ── Count badge in app bar ─────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF061A0A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count ${count == 1 ? 'property' : 'properties'}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border_rounded,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No starred properties yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the bookmark icon on any property\nto save it here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Starred property card ──────────────────────────────────────────────────
class _StarredPropertyCard extends StatefulWidget {
  final Property property;
  final String userId;

  const _StarredPropertyCard({
    required this.property,
    required this.userId,
  });

  @override
  State<_StarredPropertyCard> createState() => _StarredPropertyCardState();
}

class _StarredPropertyCardState extends State<_StarredPropertyCard> {
  bool _isRemoving = false;

  Future<void> _removestar() async {
    setState(() => _isRemoving = true);
    final error = await context.read<PropertyProvider>().toggleInterest(
          propertyId: widget.property.id!,
          userId: widget.userId,
        );
    if (!mounted) return;
    setState(() => _isRemoving = false);
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
    final property = widget.property;

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
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  property.image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF333333).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    property.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Remove star button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _isRemoving ? null : _removestar,
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
                    child: _isRemoving
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF061A0A),
                            ),
                          )
                        : const Icon(
                            Icons.bookmark_rounded,
                            color: Color(0xFF1B5E20),
                            size: 22,
                          ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF000000),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const Icon(Icons.verified_user_rounded,
                        color: Color(0xFFC8E6C9), size: 24),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  property.location,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
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
                            fontSize: 11,
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
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetails(
                                propertyId: property.id!),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF061A0A),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "View Details",
                          style: TextStyle(
                            fontSize: 15,
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