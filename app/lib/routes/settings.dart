import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/helpers/pickBooks.dart';
import 'package:ps_books/state/global_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ps_books/routes/login.dart';
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
    final accounts = ref.watch(userAccountsProvider);
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error loading preferences: $err')),
        ),
      ),
      data: (settings) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Settings",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.transparent, // Blends with Scaffold
            elevation: 0,
          ),
          body: accounts.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: primaryAccent),
            ),
            error: (error, stackTrace) => Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            data: (d) {
              final googleUser = d.googleUser;
              return Center(
                child: ConstrainedBox(
                  // Allows it to look good on wide screens (tablets/desktop) without stretching
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (googleUser != null && googleUser.isSignedIn) ...[
                          Google_Card(
                            name: googleUser.name ?? 'User',
                            email: googleUser.email ?? 'N/A',
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (d.psBooksUser != null && d.psBooksUser!.isSignedIn) ...[
                          // You might want to add a PsBooks_Card here if needed
                          ListTile(
                            title: Text("P's Books Account: ${d.psBooksUser!.name}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.logout),
                              onPressed: () => ref.read(userAccountsProvider.notifier).logout('psBooks'),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // --- Appearance Section ---
                        _SettingsSection(
                          title: "Appearance",
                          children: [
                            _SettingsTile(
                              icon: settings.appTheme == AppTheme.dark
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              title: "Dark Mode",
                              trailing: Switch(
                                activeThumbColor: primaryAccent,
                                value: settings.appTheme == AppTheme.dark,
                                onChanged: (v) {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .updateTheme(
                                        v ? AppTheme.dark : AppTheme.light,
                                      );
                                },
                              ),
                            ),
                          ],
                        ),

                        // --- Syncing Section ---
                        _SettingsSection(
                          title: "Syncing",
                          children: [
                            _SettingsTile(
                              icon: Icons.sync,
                              title: "Syncing",
                              trailing: Switch(
                                activeThumbColor: primaryAccent,
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
                                activeThumbColor: primaryAccent,
                                value: settings.enableTimetableAlarms,
                                onChanged: (v) {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .updateAlarms(v);
                                },
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
                              trailing: d.psBooksUser == null || !d.psBooksUser!.isSignedIn
                                  ? ElevatedButton(
                                      style: _primaryButtonStyle(),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return LoginPage();
                                            },
                                          ),
                                        );
                                      },
                                      child: const Text("Login"),
                                    )
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark
                                            ? Colors.white12
                                            : Colors.black12,
                                        foregroundColor: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        elevation: 0,
                                      ),
                                      onPressed: () =>
                                          ref.read(userAccountsProvider.notifier).logout('psBooks'),
                                      child: const Text("Sign Out"),
                                    ),
                            ),
                            const Divider(height: 1),
                            _SettingsTile(
                              icon: Icons.g_mobiledata,
                              title: "Sync With Google",
                              trailing: googleUser == null || !googleUser.isSignedIn
                                  ? ElevatedButton(
                                      style: _primaryButtonStyle(),
                                      onPressed: () =>
                                          _handleGoogleSignIn(context, ref),
                                      child: const Text("Login"),
                                    )
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark
                                            ? Colors.white12
                                            : Colors.black12,
                                        foregroundColor: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        elevation: 0,
                                      ),
                                      onPressed: () =>
                                          _handleGoogleSignOut(context, ref),
                                      child: const Text("Sign Out"),
                                    ),
                            ),
                          ],
                        ),

                        // --- Danger Section ---
                        _SettingsSection(
                          title: "Danger Zone",
                          titleColor: Colors.redAccent,
                          borderColor: Colors.red.withValues(alpha: 0.3),
                          children: [
                            _SettingsTile(
                              icon: Icons.delete_forever,
                              iconColor: Colors.redAccent,
                              title: "Delete App Data",
                              titleColor: Colors.redAccent,
                              subtitle:
                                  "Clears all local books and preferences",
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent.withValues(
                                    alpha: 0.2,
                                  ),
                                  foregroundColor: Colors.redAccent,
                                  elevation: 0,
                                  side: const BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                onPressed: () =>
                                    _handleDeleteAppData(context, ref),
                                child: const Text("Delete"),
                              ),
                            ),
                            _SettingsTile(
                              icon: Icons.import_export_outlined,
                              iconColor: Colors.purpleAccent,
                              title: "Export Books",
                              subtitle: "Exports all books to a chosen folder",
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purpleAccent
                                      .withValues(alpha: 0.2),
                                  foregroundColor: Colors.purpleAccent,
                                  elevation: 0,
                                  side: const BorderSide(
                                    color: Colors.purpleAccent,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    final success = await Pick_Books()
                                        .exportBooks();
                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Your books have been exported to your chosen directory.",
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "There was an error exporting your books.",
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e, h) {
                                    print(e);
                                    print(h);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "There was an error exporting your books.",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text("Export"),
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
      },
    );
  }
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
    await ref.read(userAccountsProvider.notifier).updateGoogleUser('', '', true);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signed in successfully')));
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
    await ref.read(userAccountsProvider.notifier).logout('google');
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
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
      title: const Text('Delete all app data?'),
      content: const Text(
        'This will delete local books, preferences, and sign you out. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Clearing app data...')));
  }

  try {
    try {
      await ref.read(authServiceProvider).signOut();
    } catch (e) {
      print('Sign out error: $e');
    }

    try {
      await ref.read(userAccountsProvider.notifier).logout('google');
      await ref.read(userAccountsProvider.notifier).logout('psBooks');
    } catch (e) {
      print('Failed to update user accounts state: $e');
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
    final booksDir = Directory('$docsDir/booksDir');
    final tempDir = await getTemporaryDirectory();

    await tempDir.delete(recursive: true);
    await booksDir.delete(recursive: true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    ref.invalidate(isSignedInProvider);
    ref.invalidate(displayNameProvider);
    ref.invalidate(userAccountsProvider);
    ref.invalidate(driveBooksProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('App data cleared')));
    }
  } catch (e, st) {
    print(e);
    print(st);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to clear app data')));
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
  final Color? titleColor;
  final Color? borderColor;

  const _SettingsSection({
    required this.title,
    required this.children,
    this.titleColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                color: titleColor ?? theme.textTheme.titleMedium?.color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
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
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? theme.iconTheme.color?.withValues(alpha: 0.7),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? theme.textTheme.bodyLarge?.color,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
                fontSize: 13,
              ),
            )
          : null,
      trailing: trailing,
    );
  }
}
