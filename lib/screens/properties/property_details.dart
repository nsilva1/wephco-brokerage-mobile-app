import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wephco_brokerage/providers/property_provider.dart';
import 'package:wephco_brokerage/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/helper_functions.dart';
import '../../models/property.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import './properties.dart';

class PropertyDetails extends StatefulWidget {
  final String propertyId;

  const PropertyDetails({super.key, this.propertyId = ''});

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails>
    with SingleTickerProviderStateMixin {
  late String _id;
  bool _isSharing = false;
  late final AnimationController _fadeController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 600),
);

late final Animation<double> _fadeAnimation = CurvedAnimation(
  parent: _fadeController,
  curve: Curves.easeOut,
);

  static const Color _brandGreen = Color(0xFF1B5E20);
  static const Color _lightGreen = Color(0xFF2E7D32);
  static const Color _accentGold = Color(0xFFB8963E);
  static const Color _bgColor = Color(0xFFF4F6F4);
  static const Color _cardBg = Colors.white;
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _id = widget.propertyId;
    _fadeController.forward();

    final viewerId = context.read<UserProvider>().currentUser?.id ?? '';
    context
        .read<PropertyProvider>()
        .recordView(propertyId: _id, viewerId: viewerId);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final Property? property = propertyProvider.getPropertyById(_id);
    final bool loading = propertyProvider.isLoading;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _header(property),
                ),
              ),
              if (loading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _brandGreen,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (property == null)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: _textMuted),
                        SizedBox(height: 12),
                        Text(
                          'Property not found',
                          style: TextStyle(color: _textMuted, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(child: _imageSection(property)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _titleSection(property),
                        const SizedBox(height: 16),
                        _tagsRow(property),
                        const SizedBox(height: 20),
                        _priceCard(property),
                        if (_hasKeyFacts(property)) ...[
                          const SizedBox(height: 16),
                          _keyFactsRow(property),
                        ],
                        const SizedBox(height: 16),
                        _detailsGrid(property),
                        if (property.units.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _unitsCard(property),
                        ],
                        if (property.agent != null) ...[
                          const SizedBox(height: 16),
                          _agentCard(property.agent!),
                        ],
                        if (property.interests.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _interestsSection(property),
                        ],
                        const SizedBox(height: 16),
                        _descriptionCard(property),
                        const SizedBox(height: 24),
                        _shareButton(property),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(Property? property) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 14, color: _brandGreen),
                SizedBox(width: 6),
                Text(
                  'Back',
                  style: TextStyle(
                    color: _brandGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (property?.verified == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _lightGreen.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 16, color: _lightGreen),
                SizedBox(width: 6),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: _lightGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _imageSection(Property property) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: PropertyImageCarousel(
          images: property.images,
          height: 280,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _titleSection(Property property) {
    final bool hasMap = property.googleMapLocation.trim().isNotEmpty;

    final Widget locationRow = Row(
      children: [
        Icon(
          Icons.location_on_rounded,
          size: 14,
          color: hasMap ? _lightGreen : _textMuted,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            property.location,
            style: TextStyle(
              fontSize: 13,
              color: hasMap ? _lightGreen : _textMuted,
              fontWeight: hasMap ? FontWeight.w600 : FontWeight.w500,
              decoration: hasMap ? TextDecoration.underline : null,
              decorationColor: _lightGreen,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasMap) ...[
          const SizedBox(width: 6),
          const Icon(Icons.open_in_new_rounded, size: 13, color: _lightGreen),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _textDark,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        if (hasMap)
          InkWell(
            onTap: () => _openMap(property),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: locationRow,
            ),
          )
        else
          locationRow,
      ],
    );
  }

  Future<void> _openMap(Property property) async {
    final opened = await openMapLocation(property.googleMapLocation);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open the map for this property.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Widget _tagsRow(Property property) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (property.featured)
          _tag('★ Featured', _accentGold, Colors.white),
        _tag(property.status, _brandGreen, Colors.white),
        if (property.tag.isNotEmpty)
          _tag(property.tag, const Color(0xFFF0F4FF), const Color(0xFF3B5BDB)),
        if (property.category.isNotEmpty)
          _tag(property.category, const Color(0xFFFFF8E1), _accentGold),
      ],
    );
  }

  Widget _tag(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _priceCard(Property property) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_brandGreen, _lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _brandGreen.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LISTING PRICE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatCurrency(property.price,
                        compact: true, currency: property.currency)
                    .replaceAll('.00', ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          if (property.yieldValue != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'PROJ. YIELD',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${property.yieldValue}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  bool _hasKeyFacts(Property property) =>
      property.bedroom.isNotEmpty ||
      property.bathroom.isNotEmpty ||
      property.squareFoot.isNotEmpty;

  /// ['2', '3', '4'] → "2 – 4", ['3'] → "3"
  String _formatRange(List<String> values) {
    if (values.isEmpty) return '—';
    if (values.length == 1) return values.first;
    return '${values.first} – ${values.last}';
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  Widget _keyFactsRow(Property property) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: _cardDecoration,
      child: Row(
        children: [
          _keyFact(Icons.bed_rounded, _formatRange(property.bedroom), 'Beds'),
          _keyFactDivider(),
          _keyFact(
              Icons.bathtub_rounded, _formatRange(property.bathroom), 'Baths'),
          _keyFactDivider(),
          _keyFact(Icons.square_foot_rounded,
              _formatRange(property.squareFoot), 'Sq ft'),
        ],
      ),
    );
  }

  Widget _keyFact(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _brandGreen, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _keyFactDivider() =>
      Container(width: 1, height: 40, color: Colors.grey.shade200);

  Widget _unitsCard(Property property) {
    const headerStyle = TextStyle(
      fontSize: 11,
      color: _textMuted,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );
    const cellStyle = TextStyle(
      fontSize: 14,
      color: _textDark,
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVAILABLE UNITS',
            style: TextStyle(
              fontSize: 11,
              color: _textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: Text('BEDS', style: headerStyle)),
              Expanded(child: Text('BATHS', style: headerStyle)),
              Expanded(child: Text('SQ FT', style: headerStyle)),
            ],
          ),
          for (final unit in property.units) ...[
            Divider(height: 20, color: Colors.grey.shade100),
            Row(
              children: [
                Expanded(
                    child: Text(unit.bedroom.isEmpty ? '—' : unit.bedroom,
                        style: cellStyle)),
                Expanded(
                    child: Text(unit.bathroom.isEmpty ? '—' : unit.bathroom,
                        style: cellStyle)),
                Expanded(
                    child: Text(
                        unit.squareFoot.isEmpty ? '—' : unit.squareFoot,
                        style: cellStyle)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _agentCard(PropertyAgent agent) {
    return Container(
      decoration: _cardDecoration,
      child: Column(
        children: [
          _detailRow(
            Icons.person_rounded,
            'Listing Agent',
            agent.name.isNotEmpty ? agent.name : '—',
            showDivider: agent.phone.isNotEmpty || agent.email.isNotEmpty,
          ),
          if (agent.phone.isNotEmpty)
            _detailRow(
              Icons.phone_rounded,
              'Phone',
              agent.phone,
              showDivider: agent.email.isNotEmpty,
              valueColor: _lightGreen,
              onTap: () => callPhone(agent.phone).catchError((_) {}),
            ),
          if (agent.email.isNotEmpty)
            _detailRow(
              Icons.email_rounded,
              'Email',
              agent.email,
              showDivider: false,
              valueColor: _lightGreen,
              onTap: () => sendEmail(toEmail: agent.email),
            ),
        ],
      ),
    );
  }

  Widget _detailsGrid(Property property) {
    final bool hasMap = property.googleMapLocation.trim().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _detailRow(
            Icons.business_rounded,
            'Developer',
            property.developer,
            showDivider: true,
          ),
          _detailRow(
            Icons.location_city_rounded,
            'Category',
            property.category.isNotEmpty ? property.category : '—',
            showDivider: hasMap || property.pdfUrl.isNotEmpty,
          ),
          if (hasMap)
            _detailRow(
              Icons.map_rounded,
              'Map Location',
              'View on Google Maps',
              showDivider: property.pdfUrl.isNotEmpty,
              valueColor: _lightGreen,
              onTap: () => _openMap(property),
            ),
          if (property.pdfUrl.isNotEmpty)
            _detailRow(
              Icons.picture_as_pdf_rounded,
              'Brochure',
              'PDF Available',
              showDivider: false,
              valueColor: _accentGold,
            ),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool showDivider = true,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _brandGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? _textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.north_east_rounded, size: 16, color: _lightGreen),
        ],
      ),
    );

    return Column(
      children: [
        if (onTap == null)
          content
        else
          InkWell(
            onTap: onTap,
            child: content,
          ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade100,
            indent: 64,
          ),
      ],
    );
  }

  Widget _interestsSection(Property property) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HIGHLIGHTS',
            style: TextStyle(
              fontSize: 11,
              color: _textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: property.interests
                .map(
                  (interest) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _brandGreen.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 13, color: _brandGreen),
                        const SizedBox(width: 5),
                        Text(
                          interest,
                          style: const TextStyle(
                            color: _brandGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _descriptionCard(Property property) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DESCRIPTION',
            style: TextStyle(
              fontSize: 11,
              color: _textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            property.description,
            style: const TextStyle(
              fontSize: 15,
              color: _textDark,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shareButton(Property property) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSharing ? null : () => _sharePropertyDetails(property),
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandGreen,
          disabledBackgroundColor: _brandGreen.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSharing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Preparing brochure...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.ios_share_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Send Details to Client',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _sharePropertyDetails(Property property) async {
    setState(() => _isSharing = true);

    try {
      final String price = formatCurrency(
        property.price,
        currency: property.currency,
      ).replaceAll('.00', '');

      final String yieldLine = property.yieldValue != null
          ? '\n📈 Projected Yield: ${property.yieldValue}%'
          : '';

      final String highlightsLine = property.interests.isNotEmpty
          ? '\n✅ Highlights: ${property.interests.join(', ')}'
          : '';

      final String mapLine = property.googleMapLocation.trim().isNotEmpty
          ? '\n🗺️ View on map: ${property.googleMapLocation.trim()}'
          : '';

      final List<String> facts = [
        if (property.bedroom.isNotEmpty)
          '${_formatRange(property.bedroom)} bed',
        if (property.bathroom.isNotEmpty)
          '${_formatRange(property.bathroom)} bath',
        if (property.squareFoot.isNotEmpty)
          '${_formatRange(property.squareFoot)} sq ft',
      ];
      final String factsLine =
          facts.isNotEmpty ? '\n🛏️ ${facts.join(' · ')}' : '';

      final String shareText = '''
🏠 *PROPERTY LISTING*

*${property.title}*
📍 Location: ${property.location}$mapLine
💰 Price: $price$yieldLine$factsLine
🏢 Developer: ${property.developer}$highlightsLine

*Description:*
${property.description}

Interested? Contact me to schedule a viewing!
''';

      // If there's a PDF, download it and share alongside the text
      if (property.pdfUrl.isNotEmpty) {
        final XFile? pdfFile = await _downloadPdf(property);
        if (pdfFile != null) {
          await SharePlus.instance.share(ShareParams(
            text: shareText,
            subject: 'Property Listing: ${property.title}',
            title: 'Property Listing: ${property.title}',
            files: [pdfFile],
          ));
          return;
        }
      }

      // Fallback: share text only
      await SharePlus.instance.share(ShareParams(
        text: shareText,
        subject: 'Property Listing: ${property.title}',
        title: 'Property Listing: ${property.title}',
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share property: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<XFile?> _downloadPdf(Property property) async {
    try {
      final response = await http.get(Uri.parse(property.pdfUrl));
      if (response.statusCode != 200) return null;

      final tempDir = await getTemporaryDirectory();
      final safeTitle = property.title
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');
      final filePath = '${tempDir.path}/${safeTitle}_brochure.pdf';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return XFile(filePath, mimeType: 'application/pdf');
    } catch (_) {
      return null; // silently fall back to text-only share
    }
  }
}