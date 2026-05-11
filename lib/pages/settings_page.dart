import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:su/core/constants/app_colors.dart';
import 'package:su/core/constants/app_text_styles.dart';
import 'package:su/services/device_tracking_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper to timeout SharedPreferences.getInstance()
Future<SharedPreferences?> _getPrefsSafe([Duration timeout = const Duration(seconds: 5)]) async {
  try {
    return await Future.any([
      SharedPreferences.getInstance(),
      Future.delayed(timeout, () => throw TimeoutException('timeout')),
    ]);
  } catch (e) {
    return null;
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text('Quick access to all features', style: AppTextStyles.body),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    // My Profile
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SettingsTile(
                        item: const _SettingItem(
                          icon: Icons.person_rounded,
                          label: 'My Profile',
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        ),
                      ),
                    ),

                    // Changelog
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SettingsTile(
                        item: const _SettingItem(
                          icon: Icons.history_rounded,
                          label: 'Changelog',
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangelogPage(),
                          ),
                        ),
                      ),
                    ),

                    
                    // Contribute
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SettingsTile(
                        item: const _SettingItem(
                          icon: Icons.volunteer_activism_rounded,
                          label: 'Contribute',
                        ),
                        onTap: () => launchUrl(
                          Uri.parse(
                            'mailto:christosgeorge7@gmail.com?subject=Contributing to SU BCA App',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Settings item model ───────────────────────────────────────────────────────
class _SettingItem {
  final IconData icon;
  final String label;
  const _SettingItem({required this.icon, required this.label});
}

// ── Settings tile ─────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final _SettingItem item;
  final VoidCallback? onTap;
  const _SettingsTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(item.label, style: AppTextStyles.tileLabel)),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.chevron,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile page ──────────────────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadName() async {
    final prefs = await _getPrefsSafe();
    if (prefs != null && mounted) {
      final name = prefs.getString('chat_username') ?? '';
      setState(() {
        _displayName = name;
        _nameController.text = name;
      });
    }
  }

  Future<void> _saveName() async {
    final prefs = await _getPrefsSafe();
    if (prefs != null) {
      await prefs.setString('chat_username', _nameController.text.trim());
    }
    if (mounted) {
      setState(() => _displayName = _nameController.text.trim());
    }

    try {
      await DeviceTrackingService.sendDeviceInfo();
      debugPrint('Device info sent from ProfilePage');
    } catch (e) {
      debugPrint('Error sending device info: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Name updated!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = _displayName.isNotEmpty
        ? _displayName[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Profile', style: AppTextStyles.appBarTitle),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 42,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _displayName.isEmpty ? 'Set your name' : _displayName,
              style: AppTextStyles.body.copyWith(fontSize: 15),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display Name',
                  style: AppTextStyles.tileLabel.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  onSubmitted: (_) => _saveName(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    hintText: 'Enter your name...',
                    hintStyle: TextStyle(color: AppColors.muted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This is how others will see you in chat',
                  style: AppTextStyles.body.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveName,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Save Name',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.tileLabel.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Changelog page ────────────────────────────────────────────────────────────
class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  static const _changelog = [
    _ChangelogEntry(
      version: 'v1.0.1',
      date: 'Mar 2026',
      changes: [
        '💬 Group chat — talk with everyone in real time',
        '🌐 Web support — access from any browser',
        '⚙️ Settings page added',
      ],
    ),
    _ChangelogEntry(
      version: 'v1.0.0',
      date: 'Mar 2026',
      changes: [
        '🚀 Initial release',
        '📚 Browse all 6 semesters',
        '📄 View PDFs and code files',
        '🔍 GitHub powered content',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Changelog', style: AppTextStyles.appBarTitle),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text("What's new in SU BCA", style: AppTextStyles.body),
          const SizedBox(height: 16),
          ..._changelog.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ChangelogCard(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Changelog model ───────────────────────────────────────────────────────────
class _ChangelogEntry {
  final String version;
  final String date;
  final List<String> changes;
  const _ChangelogEntry({
    required this.version,
    required this.date,
    required this.changes,
  });
}

// ── Changelog card ────────────────────────────────────────────────────────────
class _ChangelogCard extends StatelessWidget {
  final _ChangelogEntry entry;
  const _ChangelogCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.version,
                style: AppTextStyles.heading.copyWith(fontSize: 20),
              ),
              Text(
                entry.date,
                style: AppTextStyles.body.copyWith(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xffF0E8E0)),
          const SizedBox(height: 12),
          ...entry.changes.map(
            (change) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      change,
                      style: AppTextStyles.tileLabel.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── About page ────────────────────────────────────────────────────────────────
// Has its own Scaffold + AppBar since HomePage no longer provides one.
// Settings icon in the AppBar navigates to SettingsPage.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,           // no back arrow (it's a tab)
        title: Text('About App', style: AppTextStyles.appBarTitle),
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(            // ← opens SettingsPage
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
            child: const Padding(
              padding: EdgeInsets.only(right: 24),
              child: Icon(Icons.settings_rounded, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),

          // App logo
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'SU BCA',
              style: AppTextStyles.heading.copyWith(fontSize: 28),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Version 1.0.1',
              style: AppTextStyles.body.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),

          // Features card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Features',
                  style: AppTextStyles.tileLabel.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                _FeatureItem(
                  icon: Icons.menu_book_rounded,
                  text: 'Browse notes by semester',
                ),
                _FeatureItem(
                  icon: Icons.code_rounded,
                  text: 'View code files with syntax highlighting',
                ),
                _FeatureItem(
                  icon: Icons.description_rounded,
                  text: 'Read PDF documents',
                ),
                _FeatureItem(
                  icon: Icons.chat_rounded,
                  text: 'Group chat with peers',
                ),
                _FeatureItem(
                  icon: Icons.cloud_rounded,
                  text: 'Cloud-powered content from GitHub',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Connect / social card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  icon: FontAwesomeIcons.github,
                  color: const Color(0xFF333333),
                  url: 'https://github.com/S488U',
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  icon: FontAwesomeIcons.instagram,
                  color: const Color(0xFFE1306C),
                  url: 'https://instagram.com/christo_s_george',
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  icon: FontAwesomeIcons.mugHot,
                  color: const Color(0xFFFFDD00),
                  url: 'https://buymeacoffee.com/s488u',
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  icon: FontAwesomeIcons.envelope,
                  color: const Color(0xFFEA4335),
                  url: 'mailto:christosgeorge0@gmail.com',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Made with love
          Center(
            child: Column(
              children: [
                Text(
                  'Made with ❤️ for Geeks',
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Source: S488U  |  Developer: Christo',
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTextStyles.body.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final FaIconData icon;
  final Color color;
  final String url;
  const _SocialButton({
    required this.icon,
    required this.color,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: FaIcon(icon, color: color, size: 26)),
      ),
    );
  }
}