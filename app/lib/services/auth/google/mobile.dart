import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'abstract.dart';

// Ensure this uses compile-time const mapping
const String id = String.fromEnvironment('DRIVE_CLIENT_ID_MOBILE');
const String serverId = String.fromEnvironment("DRIVE_CLIENT_SERVER_ID");

class MobileAuthService implements AuthService {
  // Use the modern singleton pattern instance 
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  GoogleSignInAccount? _currentUser;
  String? _folderId;

  // Group your scopes together
  final List<String> _scopes = [
    drive.DriveApi.driveFileScope,
    'email',
    'profile',
  ];

  /// MUST be called and awaited once at app startup (e.g., in main.dart 
  /// or when initializing your auth services dependencies).
  Future<void> init() async {
    await _googleSignIn.initialize(
      clientId: id,
    );
  }

  @override
  Future<drive.DriveApi?> getDriveApi() async {
    try {
      // 1. Try silent recovery/authentication first
      _currentUser ??= await _googleSignIn.attemptLightweightAuthentication();

      // Silent failed — use the modern system picker entry point
      _currentUser ??= await _googleSignIn.authenticate();

      if (_currentUser == null) return null;

      // 2. AUTHORIZATION STEP: Request scope permissions explicitly
      final authorization = await _currentUser!.authorizationClient.authorizeScopes(_scopes);

      // 3. GET CLIENT: Use the updated extension naming mapping pattern
      final client = authorization.authClient(scopes: _scopes);

      final driveD = drive.DriveApi(client);

      // Get or create the directory
      _folderId = await getOrCreateAppFolder(driveD);
      return driveD;
    } catch (e) {
      print('Mobile auth error: $e');
      return null;
    }
  }

  @override
  Future<bool> get isSignedIn async {
    if (_currentUser != null) return true;
    _currentUser = await _googleSignIn.attemptLightweightAuthentication();;
    return _currentUser != null;
  }

  @override
  Future<String?> get folderId async {
    if (_folderId != null) return _folderId;
    await getDriveApi();
    return _folderId;
  }

  @override
  Future<String?> get displayName async {
      _currentUser ??= await _googleSignIn.attemptLightweightAuthentication();

    return _currentUser?.displayName;
  }

  @override
  Future<String?> get email async {

      _currentUser ??= await _googleSignIn.attemptLightweightAuthentication();

    return _currentUser?.email;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _folderId = null;
  }
}