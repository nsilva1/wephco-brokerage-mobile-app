import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

// Helper function to launch the phone dialer
Future<void> callPhone(String phoneNumber) async {
  final Uri phoneUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );

  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    throw Exception('Could not launch phone dialer');
  }
}

// Helper function to launch the email client
Future<void> sendEmail({
  required String toEmail,
  String subject = '',
  String body = '',
}) async {
  // Use queryParameters for automatic, safe encoding
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: toEmail,
    queryParameters: {
      'subject': subject,
      'body': body,
    },
  );

  // Use externalApplication mode to ensure it opens the native mail client
  try {
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch email client for $toEmail');
    }
  } catch (e) {
    debugPrint('Error launching email: $e');
  }
}


String formatCurrency(double amount, {bool compact = false, String currency = 'NGN'}) {
  String symbol = currency == 'USD' ? '\$' : '₦';

    if (compact) {
      if (amount >= 1000000000) return "$symbol${(amount / 1000000000).toStringAsFixed(1)}B";
      if (amount >= 1000000) return "$symbol${(amount / 1000000).toStringAsFixed(1)}M";
      if (amount >= 1000) return "$symbol${(amount / 1000).toStringAsFixed(1)}k";
    }

    // add commas every 3 digits
    String formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    );
    
    return "$symbol$formatted";
  }