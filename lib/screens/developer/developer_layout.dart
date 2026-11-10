import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/providers/user_provider.dart';
import 'package:wephco_brokerage/screens/developer/developer_portfolio.dart';
import 'package:wephco_brokerage/screens/main_layout.dart' show logout;

/// Home shell for users whose role is 'Developer'. Agents get [MainLayout].
class DeveloperLayout extends StatelessWidget {
  const DeveloperLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Wephco Developers"),
          backgroundColor: const Color(0xFF064E3B),
          foregroundColor: Colors.white,
          actions: const [
            _AccountMenu(),
            SizedBox(width: 8),
          ],
        ),
        body: const DeveloperPortfolioScreen(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/properties/add'),
          backgroundColor: const Color(0xFF064E3B),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_home_work_outlined),
          label: const Text("Add Property",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu();

  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    return PopupMenuButton<String>(
      tooltip: 'Account',
      icon: const Icon(Icons.account_circle_outlined),
      // Open below the icon with a small gap, pulled in from the screen edge.
      position: PopupMenuPosition.under,
      offset: const Offset(-8, 6),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      onSelected: (value) {
        if (value == 'logout') {
          logout(context);
        } else {
          Navigator.pushNamed(context, value);
        }
      },
      itemBuilder: (_) => [
        if (user != null) ...[
          PopupMenuItem<String>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: _textMuted),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
        ],
        _item('/profile', Icons.person_outline, 'Profile'),
        _item('/settings', Icons.settings_outlined, 'Settings'),
        _item('/support', Icons.support_agent_outlined, 'Support'),
        const PopupMenuDivider(),
        _item('logout', Icons.logout, 'Logout', color: Colors.redAccent),
      ],
    );
  }

  PopupMenuItem<String> _item(
    String value,
    IconData icon,
    String label, {
    Color color = _textDark,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color == _textDark ? _textMuted : color),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
