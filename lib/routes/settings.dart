import 'package:flutter/material.dart';
import 'package:googleapis/servicecontrol/v2.dart';
import '../state/google_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/routes/settings_comp/user_cards.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    final gUser = ref.watch(GoogleUserProvider);
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: gUser.when(
        data: (d) {
          return Container(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    spacing: 10,
                    children: [
                      if (d.isSignedIn ?? false)
                        Google_Card(
                          name: d.name ?? 'User',
                          email: d.email ?? 'N/A',
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Syncing"),
                          Switch(
                            value: false,
                            onChanged: (v) => print('syncing enabled'),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Enable Timetable alarms"),
                          Switch(
                            value: false,
                            onChanged: (v) => print('syncing enabled'),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sync Data With P's Books"),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text("Login"),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sync With Google"),
                          if (!d.isSignedIn)
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(authServiceProvider)
                                      .getDriveApi();
                                  await ref
                                      .read(GoogleUserProvider.notifier)
                                      .updateState('', '', true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Signed in successfully'),
                                    ),
                                  );
                                } catch (e, h) {
                                  print(h);
                                  print(e);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Sign in failed or was cancelled',
                                      ),
                                    ),
                                  );
                                }

                                // invalidate the providers so isSignedIn and displayName refresh
                                ref.invalidate(isSignedInProvider);
                                ref.invalidate(displayNameProvider);
                              },
                              child: Text("Login"),
                            ),
                          if (d.isSignedIn)
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await ref.read(authServiceProvider).signOut();
                                  await ref
                                      .read(GoogleUserProvider.notifier)
                                      .updateState('', '', false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Logged out successfully'),
                                    ),
                                  );
                                } catch (e, h) {
                                  print(h);
                                  print(e);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Log out failed or was cancelled',
                                      ),
                                    ),
                                  );
                                }

                                // invalidate the providers so isSignedIn and displayName refresh
                                ref.invalidate(isSignedInProvider);
                                ref.invalidate(displayNameProvider);
                              },
                              child: Text("Sign Out"),
                            ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Delete App Data"),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text("Delete"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () {
          return Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return Center(child: Text('Error: $error'));
        },
      ),
    );
  }
}
