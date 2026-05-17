import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import '../state/google_auth.dart';
import 'package:ps_books/routes/settings_comp/user_cards.dart';

// --- Theme Colors ---
const Color bgColor = Color(0xFF1B1227);
const Color cardColor = Color(0xFF2A1C3D); // Slightly lighter purple for cards
const Color primaryAccent = Color(0xFF7C3AED); // Vibrant purple accent

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gUser = ref.watch(GoogleUserProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent, // Blends with Scaffold
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: gUser.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: primaryAccent),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
        ),
        data: (d) {
          return Center(
            child: ConstrainedBox(
              // Allows it to look good on wide screens (tablets/desktop) without stretching
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (d.isSignedIn ?? false) ...[
                      Google_Card(
                        name: d.name ?? 'User',
                        email: d.email ?? 'N/A',
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- Syncing Section ---
                    _SettingsSection(
                      title: "Syncing",
                      children: [
                        _SettingsTile(
                          icon: Icons.sync,
                          title: "Syncing",
                          trailing: Switch(
                            activeColor: primaryAccent,
                            value: false,
                            onChanged: (v) => print('syncing enabled'),
                          ),
                        ),
                      ],
                    ),

                    // --- Study Features Section ---
                    _SettingsSection(
                      title: "Study Features",
                      children: [
                        _SettingsTile(
                          icon: Icons.alarm,
                          title: "Enable Timetable alarms",
                          trailing: Switch(
                            activeColor: primaryAccent,
                            value: false,
                            onChanged: (v) => print('alarms enabled'),
                          ),
                        ),
                      ],
                    ),

                    // --- Accounts Section ---
                    _SettingsSection(
                      title: "Accounts",
                      children: [
                        _SettingsTile(
                          icon: Icons.cloud_sync,
                          title: "Sync Data With P's Books",
                          trailing: ElevatedButton(
                            style: _primaryButtonStyle(),
                            onPressed: () {},
                            child: const Text("Login"),
                          ),
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        _SettingsTile(
                          icon: Icons.g_mobiledata,
                          title: "Sync With Google",
                          trailing: !d.isSignedIn
                              ? ElevatedButton(
                            style: _primaryButtonStyle(),
                            onPressed: () => _handleGoogleSignIn(context, ref),
                            child: const Text("Login"),
                          )
                              : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white12,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            onPressed: () => _handleGoogleSignOut(context, ref),
                            child: const Text("Sign Out"),
                          ),
                        ),
                      ],
                    ),

                    // --- Danger Section ---
                    _SettingsSection(
                      title: "Danger Zone",
                      titleColor: Colors.redAccent,
                      borderColor: Colors.red.withOpacity(0.3),
                      children: [
                        _SettingsTile(
                          icon: Icons.delete_forever,
                          iconColor: Colors.redAccent,
                          title: "Delete App Data",
                          titleColor: Colors.redAccent,
                          subtitle: "Clears all local books and preferences",
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(0.2),
                              foregroundColor: Colors.redAccent,
                              elevation: 0,
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                            onPressed: () => _handleDeleteAppData(context, ref),
                            child: const Text("Delete"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Button Style Helper ---
  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryAccent,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  // --- Logic Methods extracted to keep UI clean ---

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authServiceProvider).getDriveApi();
      await ref.read(GoogleUserProvider.notifier).updateState('', '', true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in successfully')),
        );
      }
    } catch (e, h) {
      print(h);
      print(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in failed or was cancelled')),
        );
      }
    }
    ref.invalidate(isSignedInProvider);
    ref.invalidate(displayNameProvider);
  }

  Future<void> _handleGoogleSignOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authServiceProvider).signOut();
      await ref.read(GoogleUserProvider.notifier).updateState('', '', false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
      }
    } catch (e, h) {
      print(h);
      print(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log out failed or was cancelled')),
        );
      }
    }
    ref.invalidate(isSignedInProvider);
    ref.invalidate(displayNameProvider);
  }

  Future<void> _handleDeleteAppData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text('Delete all app data?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will delete local books, preferences, and sign you out. This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clearing app data...')),
      );
    }

    try {
      try {
        await ref.read(authServiceProvider).signOut();
      } catch (e) {
        print('Sign out error: $e');
      }

      try {
        await ref.read(GoogleUserProvider.notifier).updateState('', '', false);
      } catch (e) {
        print('Failed to update google user state: $e');
      }

      final db = DBProvider().db;
      await db.transaction(() async {
        await db.delete(db.books).go();
        await db.delete(db.collections).go();
        await db.delete(db.timetableDays).go();
        await db.delete(db.timetableSessions).go();
        await db.delete(db.targetSubjects).go();
        await db.delete(db.targetTopics).go();
        await db.delete(db.savedBooks).go();
      });

      final docsDir = await getApplicationDocumentsDirectory();
      final tempDir = await getTemporaryDirectory();

      Future<void> deleteContents(Directory dir) async {
        if (!await dir.exists()) return;
        await for (final entity in dir.list(recursive: false)) {
          try {
            await entity.delete(recursive: true);
          } catch (e) {
            print('Failed to delete ${entity.path}: $e');
          }
        }
      }

      await deleteContents(docsDir);
      await deleteContents(tempDir);

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      ref.invalidate(isSignedInProvider);
      ref.invalidate(displayNameProvider);
      ref.invalidate(GoogleUserProvider);
      ref.invalidate(driveBooksProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App data cleared')),
        );
      }
    } catch (e, st) {
      print(e);
      print(st);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to clear app data')),
        );
      }
    }
  }
}

// ============================================================================
// UI HELPER WIDGETS
// ============================================================================

/// Helper widget to group settings into nice rounded cards with titles
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color titleColor;
  final Color? borderColor;

  const _SettingsSection({
    required this.title,
    required this.children,
    this.titleColor = Colors.white,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: borderColor != null ? Border.all(color: borderColor!) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget to standardize the layout of each setting item
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final Color iconColor;
  final Color titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.iconColor = Colors.white70,
    this.titleColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle!,
        style: const TextStyle(color: Colors.white54, fontSize: 13),
      )
          : null,
      trailing: trailing,
    );
  }
}