// services/auth/mobile_auth_service.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'abstract.dart';

class MobileAuthService implements AuthService {
  static final _googleSignIn = GoogleSignIn.instance;
  String? userName;
  String? userEmail;
  String? _folderId;

  @override
  Future<drive.DriveApi?> getDriveApi() async {
    try {
      await _googleSignIn.initialize();

      // try silent sign in first — avoids showing the picker
      // every time the user opens the app

      GoogleSignInAccount? account = await _googleSignIn
          .attemptLightweightAuthentication();

      // silent failed — do interactive sign in
      account ??= await _googleSignIn.authenticate();

      userName = account.displayName;
      userEmail = account.email;

      final authClient = await account.authorizationClient.authorizeScopes([
        drive.DriveApi.driveFileScope,
      ]);

      // Note: In v7+, we use the authenticatedClient from the account
      final client = authClient.authClient(
        scopes: [drive.DriveApi.driveFileScope],
      );

      final driveD = drive.DriveApi(client);

      //Get
      _folderId = await getOrCreateAppFolder(driveD);
      return driveD;
    } catch (e) {
      print('Mobile auth error: $e');
      return null;
    }
  }

  @override
  Future<bool> get isSignedIn async {
    // signInSilently returns null if not signed in
    final account = await _googleSignIn.attemptLightweightAuthentication();
    return account != null;
  }

  @override
  Future<String?> get folderId async {
    if (_folderId != null) return _folderId;
    await getDriveApi();
    return _folderId;
  }

  // TODO: make these actually return the email and displaynam
  @override
  Future<String?> get displayName async {
    return "Unknown";
  }

  @override
  Future<String?> get email async {
    return "Unknown";
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
