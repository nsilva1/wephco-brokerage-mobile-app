import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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


// Helper function to open a Google Maps link (e.g. https://maps.app.goo.gl/xxxx)
// in the Maps app, falling back to the browser.
// Returns true when the link was handed off successfully.
Future<bool> openMapLocation(String mapUrl) async {
  final String trimmed = mapUrl.trim();
  if (trimmed.isEmpty) return false;

  final Uri? mapUri = Uri.tryParse(
    trimmed.startsWith('http') ? trimmed : 'https://$trimmed',
  );
  if (mapUri == null || !mapUri.hasAuthority) return false;

  try {
    // externalApplication lets Android/iOS hand the link to Google Maps
    if (await launchUrl(mapUri, mode: LaunchMode.externalApplication)) {
      return true;
    }
    // Some devices have no app registered for the link — try an in-app webview
    return await launchUrl(mapUri, mode: LaunchMode.inAppBrowserView);
  } catch (e) {
    debugPrint('Error launching map location $trimmed: $e');
    return false;
  }
}

String formatCurrency(double amount, {bool compact = false, String currency = 'NGN'}) {
  String symbol = currency == 'USD' ? '\$' : '₦';

    if (compact) {
      if (amount >= 1000000000) return "$symbol${(amount / 1000000000000).toStringAsFixed(1)}T";
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

  String formatSmartDate(DateTime? dateTime) {
  if (dateTime == null) return 'N/A';
  
  final now = DateTime.now();
  final difference = now.difference(dateTime).inDays;

  if (difference == 0) return "Today";
  if (difference == 1) return "Yesterday";
  
  return DateFormat('d MMM y').format(dateTime);
}