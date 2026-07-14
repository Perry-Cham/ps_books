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
import 'package:ps_books/services/data_handler.dart';
import 'package:file_picker/file_picker.dart';

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

                        // --- Export Section ---
                        _SettingsSection(
                          title: "Export",
                          children: [
                            _SettingsTile(
                              icon: Icons.import_export_outlined,
                              iconColor: Colors.purpleAccent,
                              title: "Export Books",
                              subtitle: "Copies book files to a chosen folder",
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: _exportButtonStyle(),
                                    onPressed: () =>
                                        _handleExportBooks(context, ref),
                                    child: const Text("Export"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: _importButtonStyle(),
                                    onPressed: () =>
                                        _handleImportBooks(context, ref),
                                    child: const Text("Import"),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            _SettingsTile(
                              icon: Icons.backup_outlined,
                              iconColor: Colors.purpleAccent,
                              title: "Export AppData",
                              subtitle: "Full backup as .pbf file",
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: _exportButtonStyle(),
                                    onPressed: () =>
                                        _handleExportAppData(context, ref),
                                    child: const Text("Export"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: _importButtonStyle(),
                                    onPressed: () =>
                                        _handleImportAppData(context, ref),
                                    child: const Text("Import"),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            _SettingsTile(
                              icon: Icons.calendar_month_outlined,
                              iconColor: Colors.blueAccent,
                              title: "Export Timetable",
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: _exportButtonStyle(),
                                    onPressed: () =>
                                        _handleExportTimetable(context, ref),
                                    child: const Text("Export"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: _importButtonStyle(),
                                    onPressed: () =>
                                        _handleImportTimetable(context, ref),
                                    child: const Text("Import"),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            _SettingsTile(
                              icon: Icons.ads_click_outlined,
                              iconColor: Colors.orangeAccent,
                              title: "Export Targets",
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: _exportButtonStyle(),
                                    onPressed: () =>
                                        _handleExportTargets(context, ref),
                                    child: const Text("Export"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: _importButtonStyle(),
                                    onPressed: () =>
                                        _handleImportTargets(context, ref),
                                    child: const Text("Import"),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            _SettingsTile(
                              icon: Icons.sticky_note_2_outlined,
                              iconColor: Colors.tealAccent,
                              title: "Export Notes",
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: _exportButtonStyle(),
                                    onPressed: () =>
                                        _handleExportNotes(context, ref),
                                    child: const Text("Export"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: _importButtonStyle(),
                                    onPressed: () =>
                                        _handleImportNotes(context, ref),
                                    child: const Text("Import"),
                                  ),
                                ],
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

// ── Export / Import Handlers ──

Future<void> _handleExportBooks(BuildContext context, WidgetRef ref) async {
  try {
    final success = await DataHandler().exportBooks();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "Books exported successfully." : "Failed to export books.")),
      );
    }
  } catch (e, st) {
    print(e);
    print(st);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error exporting books.")),
      );
    }
  }
}

Future<void> _handleImportBooks(BuildContext context, WidgetRef ref) async {
  try {
    final msg = await Pick_Books().pickbooks();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.state == "Success" ? "Books imported successfully." : msg.message)),
      );
    }
  } catch (e, st) {
    print(e);
    print(st);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error importing books.")),
      );
    }
  }
}

Future<void> _handleExportAppData(BuildContext context, WidgetRef ref) async {
  try {
    final success = await DataHandler().exportPBF();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "App data exported successfully." : "Export cancelled or failed.")),
      );
    }
  } catch (e, st) {
    print(e);
    print(st);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error exporting app data.")),
      );
    }
  }
}

Future<void> _handleImportAppData(BuildContext context, WidgetRef ref) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.single.path;
    if (filePath == null) return;
    final success = await DataHandler().importPBF(filePath);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "App data imported successfully." : "Import failed.")),
      );
    }
  } catch (e, st) {
    print(e);
    print(st);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error importing app data.")),
      );
    }
  }
}

Future<void> _handleExportTimetable(BuildContext context, WidgetRef ref) async {
  try {
    final success = await DataHandler().exportTimetable();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "Timetable exported successfully." : "Export cancelled or failed.")),
      );
    }
  } catch (e, st) {
    print(e);
    print(st);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error exporting timetable.")),
      );
    }
  }
}

Future<void> _handleImportTimetable(BuildContext context, WidgetRef ref) async {
  try {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.single.path;
    if (filePath == null) return;
    final success = await DataHandler().importPBF(filePath);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "Timetable imported successfully." : "Import failed.")),
      );
    }
  } catch (e, st) {
    print(e);
    print(st);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error importing timetable.")),
      );
    }
  }
}

Future<void> _handleExportTargets(BuildContext context, WidgetRef ref) async {
  try {
    final success = await DataHandler().exportTargets();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "Targets exported successfully." : "Export cancelled or failed.")),
      );
    }
  } catch (e, st) {
    print(e);
    print(st);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error exporting targets.")),
      );
    }
  }
}

Future<void> _handleImportTargets(BuildContext context, WidgetRef ref) async {
  try {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.single.path;
    if (filePath == null) return;
    final success = await DataHandler().importPBF(filePath);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "Targets imported successfully." : "Import failed.")),
      );
    }
  } catch (e, st) {
    print(e);
    print(st);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error importing targets.")),
      );
    }
  }
}

Future<void> _handleExportNotes(BuildContext context, WidgetRef ref) async {
  try {
    final success = await DataHandler().exportNotes();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "Notes exported successfully." : "Export cancelled or failed.")),
      );
    }
  } catch (e, st) {
    print(e);
    print(st);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error exporting notes.")),
      );
    }
  }
}

Future<void> _handleImportNotes(BuildContext context, WidgetRef ref) async {
  try {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.single.path;
    if (filePath == null) return;
    final success = await DataHandler().importPBF(filePath);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "Notes imported successfully." : "Import failed.")),
      );
    }
  } catch (e, st) {
    print(e);
    print(st);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error importing notes.")),
      );
    }
  }
}

// ── Button Style Helpers ──

ButtonStyle _exportButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.purpleAccent.withValues(alpha: 0.2),
    foregroundColor: Colors.purpleAccent,
    elevation: 0,
    side: const BorderSide(color: Colors.purpleAccent),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    textStyle: const TextStyle(fontSize: 12),
  );
}

ButtonStyle _importButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
    foregroundColor: Colors.blueAccent,
    elevation: 0,
    side: const BorderSide(color: Colors.blueAccent),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    textStyle: const TextStyle(fontSize: 12),
  );
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
