import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/models/property.dart';
import 'package:wephco_brokerage/providers/property_provider.dart';
import 'package:wephco_brokerage/providers/user_provider.dart';
import 'package:wephco_brokerage/screens/developer/developer_portfolio.dart'
    show ReviewBadge;
import 'package:wephco_brokerage/screens/properties/properties.dart'
    show PropertyImageCarousel;
import 'package:wephco_brokerage/screens/properties/add_property.dart';
import 'package:wephco_brokerage/screens/properties/property_details.dart';
import 'package:wephco_brokerage/utils/helper_functions.dart';

/// Simple performance numbers for one of the developer's own listings.
class DeveloperPropertyAnalytics extends StatefulWidget {
  final String propertyId;

  const DeveloperPropertyAnalytics({super.key, required this.propertyId});

  @override
  State<DeveloperPropertyAnalytics> createState() =>
      _DeveloperPropertyAnalyticsState();
}

class _DeveloperPropertyAnalyticsState
    extends State<DeveloperPropertyAnalytics> {
  static const Color _brandGreen = Color(0xFF1B5E20);
  static const Color _lightGreen = Color(0xFF2E7D32);
  static const Color _bgColor = Color(0xFFF4F6F4);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF6B7280);

  late Future<int?> _leadCount;
  bool _isDeleting = false;

  Future<void> _confirmDelete(Property property, String developerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this listing?'),
        content: Text(
          '"${property.title}" and its photos and brochure will be '
          'permanently removed. Its views and stars will be lost. '
          'This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final error = await context.read<PropertyProvider>().deleteProperty(
          propertyId: property.id ?? '',
          developerId: developerId,
        );
    if (!mounted) return;
    setState(() => _isDeleting = false);

    final messenger = ScaffoldMessenger.of(context);
    if (error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red.shade700),
      );
      return;
    }
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Listing deleted.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _leadCount =
        context.read<PropertyProvider>().leadCountFor(widget.propertyId);
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final property = propertyProvider.getPropertyById(widget.propertyId);
    final developerId = context.watch<UserProvider>().currentUser?.id ?? '';
    final portfolio = propertyProvider.portfolio(developerId);

    final isOwner = property != null &&
        developerId.isNotEmpty &&
        property.developerId == developerId;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text("Listing Analytics"),
        backgroundColor: const Color(0xFF064E3B),
        foregroundColor: Colors.white,
        actions: [
          if (isOwner) ...[
            IconButton(
              tooltip: 'Edit listing',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _isDeleting
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddPropertyScreen(property: property),
                        ),
                      ),
            ),
            IconButton(
              tooltip: 'Delete listing',
              icon: _isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.delete_outline),
              onPressed: _isDeleting
                  ? null
                  : () => _confirmDelete(property, developerId),
            ),
          ],
        ],
      ),
      body: property == null
          ? const Center(
              child: Text('Property not found',
                  style: TextStyle(color: _textMuted, fontSize: 16)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PropertyImageCarousel(
                  images: property.images,
                  height: 180,
                  borderRadius: BorderRadius.circular(16),
                ),
                const SizedBox(height: 16),
                ReviewBadge(verified: property.verified),
                const SizedBox(height: 8),
                Text(
                  property.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${property.location} · ${formatCurrency(property.price, compact: true, currency: property.currency).replaceAll('.00', '')}',
                  style: const TextStyle(fontSize: 14, color: _textMuted),
                ),
                if (!property.verified) ...[
                  const SizedBox(height: 16),
                  _pendingNotice(),
                ],
                const SizedBox(height: 20),
                _sectionLabel('PERFORMANCE'),
                const SizedBox(height: 10),
                _kpiGrid(property),
                const SizedBox(height: 20),
                if (portfolio.length > 1) ...[
                  _sectionLabel('SHARE OF YOUR PORTFOLIO'),
                  const SizedBox(height: 10),
                  _portfolioShareCard(property, portfolio),
                  const SizedBox(height: 20),
                ],
                _sectionLabel('LISTING QUALITY'),
                const SizedBox(height: 10),
                _qualityCard(property),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PropertyDetails(propertyId: property.id ?? ''),
                      ),
                    ),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text("See listing as agents see it"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _brandGreen,
                      side: const BorderSide(color: _brandGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: _textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );

  Widget _pendingNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "This listing is awaiting review by the Wephco team. Agents "
              "can't see it yet, so it won't collect views or stars until "
              "it's approved.",
              style: TextStyle(fontSize: 13, color: Color(0xFF7C2D12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiGrid(Property property) {
    final stars = property.interests.length;
    final views = property.views;
    final daysListed = property.createdAt == null
        ? null
        : DateTime.now().difference(property.createdAt!).inDays;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _kpiTile(Icons.visibility_rounded, '$views', 'Times viewed'),
        _kpiTile(Icons.bookmark_rounded, '$stars', 'Stars from agents'),
        _kpiTile(
          Icons.percent_rounded,
          views == 0 ? '—' : '${(stars / views * 100).toStringAsFixed(1)}%',
          'Viewers who starred',
        ),
        FutureBuilder<int?>(
          future: _leadCount,
          builder: (context, snapshot) {
            final value = switch (snapshot.connectionState) {
              ConnectionState.done => snapshot.data?.toString() ?? '—',
              _ => '…',
            };
            return _kpiTile(Icons.people_alt_rounded, value, 'Agent leads');
          },
        ),
        _kpiTile(
          Icons.calendar_today_rounded,
          daysListed == null ? '—' : '$daysListed',
          daysListed == 1 ? 'Day listed' : 'Days listed',
        ),
        _kpiTile(
          Icons.trending_up_rounded,
          daysListed == null || daysListed == 0
              ? '—'
              : (views / daysListed).toStringAsFixed(1),
          'Views per day',
        ),
      ],
    );
  }

  Widget _kpiTile(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: _lightGreen, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _portfolioShareCard(Property property, List<Property> portfolio) {
    final totalViews = portfolio.fold<int>(0, (s, p) => s + p.views);
    final totalStars =
        portfolio.fold<int>(0, (s, p) => s + p.interests.length);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _shareBar('Views', property.views, totalViews),
          const SizedBox(height: 14),
          _shareBar('Stars', property.interests.length, totalStars),
        ],
      ),
    );
  }

  Widget _shareBar(String label, int value, int total) {
    final share = total == 0 ? 0.0 : value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textDark)),
            Text(
              total == 0
                  ? 'No data yet'
                  : '${(share * 100).toStringAsFixed(0)}%  ($value of $total)',
              style: const TextStyle(fontSize: 12, color: _textMuted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: share,
            minHeight: 8,
            backgroundColor: const Color(0xFFE8F5E9),
            color: _lightGreen,
          ),
        ),
      ],
    );
  }

  /// Things that make a listing more attractive to agents.
  Widget _qualityCard(Property property) {
    final checks = <(String, bool)>[
      ('At least 3 photos', property.images.length >= 3),
      ('Description of 100+ characters',
          property.description.trim().length >= 100),
      ('Bedrooms, bathrooms or size',
          property.bedroom.isNotEmpty ||
              property.bathroom.isNotEmpty ||
              property.squareFoot.isNotEmpty),
      ('Google Maps link', property.googleMapLocation.trim().isNotEmpty),
      ('Brochure PDF', property.pdfUrl.isNotEmpty),
      ('Agent contact details', property.agent != null),
    ];
    final done = checks.where((c) => c.$2).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$done of ${checks.length} complete',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          for (final (label, ok) in checks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(
                    ok
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: ok ? _lightGreen : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: ok ? _textDark : _textMuted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
