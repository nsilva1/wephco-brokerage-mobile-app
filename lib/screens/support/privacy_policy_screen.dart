import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _companyName = "Wephco Brokerage";
  static const String _contactEmail = "contact@wephco.com";
  static const String _lastUpdated = "April 2026";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Your Privacy Matters",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Last updated: $_lastUpdated",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _intro(context),
          _section(
            context,
            number: "1",
            title: "Information We Collect",
            content: [
              _paragraph(
                "We collect the following information when you register and use $_companyName:",
              ),
              _bullet("Full name and email address"),
              _bullet("Bank Verification Number (BVN) and National Identification Number (NIN) for KYC compliance"),
              _bullet("Bank account details including account number, account name, and bank name"),
              _bullet("Device information and Firebase Cloud Messaging (FCM) token for push notifications"),
              _bullet("Activity data including leads created, properties viewed, and deals closed"),
              _bullet("Transaction history including commission credits and withdrawal requests"),
            ],
          ),
          _section(
            context,
            number: "2",
            title: "How We Use Your Information",
            content: [
              _paragraph("We use the information we collect to:"),
              _bullet("Verify your identity in compliance with Nigerian financial regulations (CBN KYC guidelines)"),
              _bullet("Process commission payments and withdrawal requests to your registered bank account"),
              _bullet("Send push notifications about withdrawal status, lead updates, and important account activity"),
              _bullet("Maintain your account and provide customer support"),
              _bullet("Detect and prevent fraud or unauthorised access"),
              _bullet("Improve the performance and features of the app"),
            ],
          ),
          _section(
            context,
            number: "3",
            title: "Data Storage & Security",
            content: [
              _paragraph(
                "Your data is stored securely on Google Firebase infrastructure, which provides enterprise-grade encryption at rest and in transit. Sensitive information such as BVN and bank details are stored with restricted access controls.",
              ),
              _paragraph(
                "A local cache of your profile data is stored on your device using Hive to enable offline access. This data is scoped to your device and is cleared when you log out.",
              ),
              _paragraph(
                "We do not store your login password on your device in plain text. If you enable biometric login, your credentials are stored using your device's secure storage.",
              ),
            ],
          ),
          _section(
            context,
            number: "4",
            title: "Sharing Your Information",
            content: [
              _paragraph(
                "We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:",
              ),
              _bullet("With Flutterwave, our payment processing partner, solely to verify your bank account and process withdrawals"),
              _bullet("With regulatory or law enforcement authorities if required by Nigerian law"),
              _bullet("With Firebase and Google Cloud services strictly for app infrastructure and crash reporting"),
              _paragraph(
                "All third-party services we use are bound by their own privacy policies and data processing agreements.",
              ),
            ],
          ),
          _section(
            context,
            number: "5",
            title: "KYC Data & Financial Regulations",
            content: [
              _paragraph(
                "As a financial services platform operating in Nigeria, we are required by law to collect and verify identity documents including BVN and NIN. This is mandated by the Central Bank of Nigeria (CBN) and the Nigerian Financial Intelligence Unit (NFIU).",
              ),
              _paragraph(
                "KYC data is used exclusively for identity verification and fraud prevention. It is never shared with third parties except as required by law.",
              ),
            ],
          ),
          _section(
            context,
            number: "6",
            title: "Push Notifications",
            content: [
              _paragraph(
                "We use Firebase Cloud Messaging to send you notifications about your account activity. Your FCM device token is stored against your account to enable targeted notifications.",
              ),
              _paragraph(
                "You can disable push notifications at any time through your device settings. Note that disabling notifications may mean you miss important updates about your withdrawals and leads.",
              ),
              _paragraph(
                "When you log out, your FCM token is removed from our servers so you no longer receive notifications on that device.",
              ),
            ],
          ),
          _section(
            context,
            number: "7",
            title: "Data Retention",
            content: [
              _paragraph(
                "We retain your personal data for as long as your account is active. If you request account deletion, we will remove your personal data within 30 days, except where we are legally required to retain it (for example, transaction records required for financial audit purposes).",
              ),
            ],
          ),
          _section(
            context,
            number: "8",
            title: "Your Rights",
            content: [
              _paragraph("You have the right to:"),
              _bullet("Request a copy of the personal data we hold about you"),
              _bullet("Request correction of any inaccurate data"),
              _bullet("Request deletion of your account and associated data"),
              _bullet("Withdraw consent for data processing where consent is the legal basis"),
              _paragraph(
                "To exercise any of these rights, please contact us at $_contactEmail.",
              ),
            ],
          ),
          _section(
            context,
            number: "9",
            title: "Cookies & Analytics",
            content: [
              _paragraph(
                "This mobile application does not use browser cookies. We use Firebase Crashlytics to collect anonymous crash reports to help us identify and fix technical issues. These reports do not contain personally identifiable information.",
              ),
            ],
          ),
          _section(
            context,
            number: "10",
            title: "Children's Privacy",
            content: [
              _paragraph(
                "$_companyName is intended for use by adults aged 18 and above. We do not knowingly collect personal information from anyone under the age of 18. If you believe a minor has provided us with personal information, please contact us immediately.",
              ),
            ],
          ),
          _section(
            context,
            number: "11",
            title: "Changes to This Policy",
            content: [
              _paragraph(
                "We may update this Privacy Policy from time to time to reflect changes in our practices or applicable law. We will notify you of any material changes via push notification or email. Continued use of the app after changes are posted constitutes acceptance of the updated policy.",
              ),
            ],
          ),
          _section(
            context,
            number: "12",
            title: "Contact Us",
            content: [
              _paragraph(
                "If you have any questions, concerns, or requests regarding this Privacy Policy or how we handle your data, please contact us:",
              ),
              _bullet("Email: $_contactEmail"),
              _bullet("In-app: Settings → Contact Support"),
            ],
          ),

          // Footer
          const SizedBox(height: 8),
          Center(
            child: Text(
              "© ${DateTime.now().year} $_companyName. All rights reserved.",
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _intro(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        "This Privacy Policy describes how $_companyName collects, uses, and protects your personal information when you use our mobile application. By using this app, you agree to the practices described in this policy.",
        style: const TextStyle(
          fontSize: 14,
          color: Colors.blueGrey,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String number,
    required String title,
    required List<Widget> content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...content,
        ],
      ),
    );
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.blueGrey,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: CircleAvatar(
              radius: 3,
              backgroundColor: Colors.blueGrey,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blueGrey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}