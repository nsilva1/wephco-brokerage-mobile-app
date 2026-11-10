import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/models/property.dart';
import 'package:wephco_brokerage/providers/property_provider.dart';
import 'package:wephco_brokerage/providers/user_provider.dart';
import 'package:wephco_brokerage/screens/developer/developer_property_analytics.dart';
import 'package:wephco_brokerage/utils/helper_functions.dart';

enum _PortfolioFilter { all, live, pending }

class DeveloperPortfolioScreen extends StatefulWidget {
  const DeveloperPortfolioScreen({super.key});

  @override
  State<DeveloperPortfolioScreen> createState() =>
      _DeveloperPortfolioScreenState();
}

class _DeveloperPortfolioScreenState extends State<DeveloperPortfolioScreen> {
  static const Color _brandGreen = Color(0xFF1B5E20);
  static const Color _textMuted = Color(0xFF6B7280);

  _PortfolioFilter _filter = _PortfolioFilter.all;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final propertyProvider = context.watch<PropertyProvider>();
    final portfolio = propertyProvider.portfolio(user?.id ?? '');

    final live = portfolio.where((p) => p.verified).toList();
    final pending = portfolio.where((p) => !p.verified).toList();
    final shown = switch (_filter) {
      _PortfolioFilter.all => portfolio,
      _PortfolioFilter.live => live,
      _PortfolioFilter.pending => pending,
    };

    final totalViews = portfolio.fold<int>(0, (sum, p) => sum + p.views);
    final totalStars =
        portfolio.fold<int>(0, (sum, p) => sum + p.interests.length);

    return Container(
      color: const Color(0xFFF7F9FB),
      child: RefreshIndicator(
        color: _brandGreen,
        onRefresh: propertyProvider.fetchProperties,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          // Bottom padding keeps the last card clear of the FAB.
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
          children: [
            Text(
              "Hi ${_firstName(user?.name)}",
              style: const TextStyle(fontSize: 14, color: _textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              "Your Portfolio",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _summaryTile(Icons.home_work_rounded, '${portfolio.length}',
                    'Listings'),
                const SizedBox(width: 12),
                _summaryTile(
                    Icons.visibility_rounded, '$totalViews', 'Total views'),
                const SizedBox(width: 12),
                _summaryTile(
                    Icons.bookmark_rounded, '$totalStars', 'Total stars'),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: [
                _filterChip(_PortfolioFilter.all, 'All (${portfolio.length})'),
                _filterChip(_PortfolioFilter.live, 'Live (${live.length})'),
                _filterChip(_PortfolioFilter.pending,
                    'Pending review (${pending.length})'),
              ],
            ),
            const SizedBox(height: 16),
            if (propertyProvider.isLoading && portfolio.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(
                  child: CircularProgressIndicator(
                      color: _brandGreen, strokeWidth: 2),
                ),
              )
            else if (shown.isEmpty)
              _emptyState(portfolio.isEmpty)
            else
              for (final property in shown) ...[
                _PortfolioCard(property: property),
                const SizedBox(height: 14),
              ],
          ],
        ),
      ),
    );
  }

  String _firstName(String? name) {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? 'there' : trimmed.split(' ').first;
  }

  Widget _summaryTile(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: _brandGreen, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: _textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(_PortfolioFilter value, String label) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: _brandGreen,
      labelStyle: TextStyle(
        color: selected ? Colors.white : _textMuted,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      showCheckmark: false,
      side: BorderSide(color: selected ? _brandGreen : const Color(0xFFE2E8F0)),
      backgroundColor: Colors.white,
    );
  }

  Widget _emptyState(bool noListingsAtAll) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(Icons.home_work_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            noListingsAtAll
                ? "You haven't listed any properties yet."
                : "No properties in this view.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          if (noListingsAtAll) ...[
            const SizedBox(height: 6),
            Text(
              "Tap \"Add Property\" to create your first listing.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final Property property;

  const _PortfolioCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final cover = property.images.isNotEmpty ? property.images.first : null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DeveloperPropertyAnalytics(propertyId: property.id ?? ''),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: cover == null
                      ? _placeholder()
                      : Image.network(
                          cover,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReviewBadge(verified: property.verified),
                    const SizedBox(height: 6),
                    Text(
                      property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCurrency(property.price,
                              compact: true, currency: property.currency)
                          .replaceAll('.00', ''),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _stat(Icons.visibility_outlined, '${property.views}'),
                        const SizedBox(width: 16),
                        _stat(Icons.bookmark_border_rounded,
                            '${property.interests.length}'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );

  Widget _stat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

/// "Live" for verified listings, "Pending review" otherwise.
class ReviewBadge extends StatelessWidget {
  final bool verified;

  const ReviewBadge({super.key, required this.verified});

  @override
  Widget build(BuildContext context) {
    final color = verified ? const Color(0xFF2E7D32) : const Color(0xFFB45309);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            verified ? 'Live' : 'Pending review',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
