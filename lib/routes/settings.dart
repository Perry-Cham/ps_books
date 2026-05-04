import 'package:flutter/material.dart';
import '../state/google_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Settings extends ConsumerWidget {
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
                          final authService = ref.read(authServiceProvider);
                          final driveApi = await authService.getDriveApi();

                          if (driveApi == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sign in failed or was cancelled',
                                ),
                              ),
                            );
                            return;
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
