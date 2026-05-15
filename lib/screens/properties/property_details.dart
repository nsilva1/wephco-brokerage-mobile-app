import 'package:flutter/material.dart';
import 'package:wephco_brokerage/providers/property_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/helper_functions.dart';
import '../../models/property.dart';
import 'package:share_plus/share_plus.dart';
import './properties.dart'; // imports PropertyImageCarousel

class PropertyDetails extends StatefulWidget {
  final String propertyId;

  const PropertyDetails({super.key, this.propertyId = ''});

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  late String _id;

  @override
  void initState() {
    super.initState();
    _id = widget.propertyId;
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final Property? property = propertyProvider.getPropertyById(_id);
    final bool loading = propertyProvider.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 30),
              if (property != null)
                Text(
                  property.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              if (loading)
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                )
              else if (property == null)
                const Center(child: Text('Property not found'))
              else ...[
                _propertyCard(property),
                const SizedBox(height: 20),
                _shareButton(property),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return TextButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back),
      label: const Text("Back"),
    );
  }

  Widget _propertyCard(Property property) {
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
          // ── Full-height image carousel ──────────────────────────────────
          PropertyImageCarousel(
            images: property.images,
            height: 300,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),

          // ── Content ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF333333),
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
                    const Icon(Icons.verified_user_rounded,
                        color: Color(0xFFC8E6C9), size: 28),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _detailColumn("PRICE",
                        formatCurrency(property.price, compact: true, currency: property.currency)
                            .replaceAll('.00', '')),
                    _detailColumn("Developer", property.developer),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _detailColumn("Location", property.location),
                    if (property.yieldValue != null)
                      _detailColumn("Projected Yield",
                          property.yieldValue.toString()),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(height: 5, color: Colors.grey.shade300),
                const SizedBox(height: 20),
                _detailColumn("Description", property.description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade400,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          value,
          overflow: TextOverflow.clip,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }

  Widget _shareButton(Property property) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => _sharePropertyDetails(property),
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF235F23)),
        child: const Text(
          "Send Details to Client",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  void _sharePropertyDetails(Property property) {
    final String price = formatCurrency(
      property.price,
      currency: property.currency,
    ).replaceAll('.00', '');

    final String shareText = '''
🏠 *PROPERTY FOR SALE*

*${property.title}*
📍 Location: ${property.location}
💰 Price: $price
🏢 Developer: ${property.developer}

*Description:*
${property.description}

Interested? Contact me for more details or to schedule a viewing!
    ''';

    SharePlus.instance.share(ShareParams(
      text: shareText,
      subject: 'Property Listing: ${property.title}',
      title: 'Property Listing: ${property.title}',
    ));
  }
}