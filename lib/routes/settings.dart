import 'package:flutter/material.dart';
import 'package:ps_books/services/auth/google/desktop.dart';
import '../state/google_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/routes/settings_comp/user_cards.dart';


class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Container(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              border: BoxBorder.all(width: 2),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            width: 400,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                spacing: 10,
                children: [
                  //TODO: Add logic that checks authstate and allows this card to render when its true
                  if(false) Google_Card(name: 'perry', email:'xxxxx'),
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
                      ElevatedButton(onPressed: () {}, child: Text("Login")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Sync With Google"),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await ref.read(authServiceProvider).getDriveApi();
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Signed in successfully',
                                ),
                              ),
                            );

                          } catch (e) {
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
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Delete App Data"),
                      ElevatedButton(onPressed: () {}, child: Text("Delete")),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
