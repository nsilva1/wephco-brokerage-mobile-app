import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // — Account —
          _sectionLabel("Account"),
          _settingsCard(children: [
            _settingsTile(
              context,
              icon: Icons.lock_outline,
              label: "Change Password",
              onTap: () {
                Navigator.pushNamed(context, '/change-password');
              }, // navigate to change password screen
            ),
            _divider(),
            _settingsTile(
              context,
              icon: Icons.verified_user_outlined,
              label: "Verification & Banking",
              onTap: () {
                Navigator.pushNamed(context, '/kyc');
              }, // navigate to KYC screen
            ),
            _divider(),
            _settingsTile(
              context,
              icon: Icons.fingerprint,
              label: "Biometric Login",
              trailing: Switch(
              value: false,
              // value: context.watch<UserProvider>().isBiometricEnabled,
              onChanged: (val) async {
                // if (val) {
                //   _showReEnterPasswordSheet(context);
                // } else {
                //   await context.read<UserProvider>().setBiometric(false);
                //   await context.read<UserProvider>().disableBiometric();
                // }
              },
              activeThumbColor: Theme.of(context).primaryColor,
            ),)
          ]),
          const SizedBox(height: 20),

          // — Notifications —
          _sectionLabel("Notifications"),
          _settingsCard(children: [
            _settingsTile(
              context,
              icon: Icons.notifications_outlined,
              label: "Push Notifications",
              trailing: Switch(
                value: context.watch<UserProvider>().settings.pushNotificationsEnabled,
                onChanged: (val) {
                  context.read<UserProvider>().setPushNotifications(val);
                },
                activeThumbColor: Theme.of(context).primaryColor,
              ),
            ),
            _divider(),
            _settingsTile(
              context,
              icon: Icons.email_outlined,
              label: "Email Notifications",
              trailing: Switch(
                value: context.watch<UserProvider>().settings.emailNotificationsEnabled,
                onChanged: (val) {
                  context.read<UserProvider>().setEmailNotifications(val);
                },
                activeThumbColor: Theme.of(context).primaryColor,
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // — Support —
          _sectionLabel("Support"),
          _settingsCard(children: [
            _settingsTile(
              context,
              icon: Icons.help_outline,
              label: "Help & FAQ",
              onTap: () {
                Navigator.pushNamed(context, '/faq');
              },
            ),
            _divider(),
            _settingsTile(
              context,
              icon: Icons.privacy_tip_outlined,
              label: "Privacy Policy",
              onTap: () {
                Navigator.pushNamed(context, '/privacy-policy');
              },
            ),
            _divider(),
            _settingsTile(
              context,
              icon: Icons.description_outlined,
              label: "Contact Support",
              onTap: () {
                Navigator.pushNamed(context, '/support');
              },
            ),
          ]),
          const SizedBox(height: 20),

          // — App —
          _sectionLabel("App"),
          _settingsCard(children: [
            _settingsTile(
              context,
              icon: Icons.info_outline,
              label: "Version",
              trailing: const Text("1.0.0", style: TextStyle(color: Colors.blueGrey, fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 20),

          // — Logout —
          _settingsCard(children: [
            _settingsTile(
              context,
              icon: Icons.logout,
              label: "Logout",
              iconColor: Colors.redAccent,
              labelColor: Colors.redAccent,
              onTap: () => _confirmLogout(context),
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.blueGrey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? labelColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 20, color: iconColor ?? Colors.blueGrey),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: labelColor ?? const Color(0xFF1A1C1E),
        ),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: Colors.blueGrey, size: 18) : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 52, color: Color(0xFFF1F5F9));

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.blueGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<UserProvider>(ctx, listen: false).logout();
              if(!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(ctx, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}