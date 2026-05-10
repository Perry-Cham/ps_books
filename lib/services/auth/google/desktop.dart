// services/auth/desktop_auth_service.dart
import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:oauth2_client/oauth2_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'abstract.dart';
import 'package:oauth2_client/oauth2_helper.dart';

class GoogleOAuth2Client extends OAuth2Client {
  //static const String redirectUri = 'http://localhost:8080';

  GoogleOAuth2Client()
    : super(
        authorizeUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
        tokenUrl: 'https://oauth2.googleapis.com/token',
        redirectUri: 'http://localhost:8080',
        customUriScheme: 'http://localhost:8080',
      );
}

class DesktopAuthService implements AuthService {
  // Desktop app client credentials from Google Cloud Console
  static final id = String.fromEnvironment(
    'DRIVE_CLIENT_ID',
    defaultValue: "UNKNOWN",
  );
  static const _scopes = [drive.DriveApi.driveFileScope, 'openid'];

  String? _folderId;
  static drive.DriveApi? driveInst;
  static final _oauthClient = GoogleOAuth2Client();
  static final helper = OAuth2Helper(
    _oauthClient,
    grantType: OAuth2Helper.authorizationCode,
    clientId:
        '338563215929-tshvf72vgi9aso3hnspubi6ba120sjr5.apps.googleusercontent.com',
    clientSecret: "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",
    webAuthOpts: {"useWebview": false},
    scopes: [
      'openid',
      'profile',
      'email',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  // ── BUILD DRIVE API FROM TOKEN ──

  Future<drive.DriveApi> _buildDriveApi(
    String token,
    DateTime expiry,
    String refresh,
  ) async {
    final credentials = auth.AccessCredentials(
      auth.AccessToken('Bearer', token, expiry.toUtc()),
      refresh,
      _scopes,
    );

    final client = auth.authenticatedClient(http.Client(), credentials);
    final driveApi = drive.DriveApi(client);

    _folderId = await getOrCreateAppFolder(driveApi);
    driveInst = driveApi;
    return driveApi;
  }

  @override
  Future<String?> get folderId async {
    if (_folderId != null) return _folderId;
    await getDriveApi();
    return _folderId;
  }

  // ── FULL OAUTH BROWSER FLOW ──

  /*  Future<drive.DriveApi?> _performOAuthFlow() async {
    try {
      // oauth2_client handles the entire flow:
      // - PKCE code verifier/challenge generation
      // - Building authorization URL with state parameter
      // - Starting local HTTP server for redirect
      // - Opening browser via url_launcher
      // - Waiting for callback and extracting code
      // - Exchanging code for tokens

      final token = await helper.getToken();

      return _buildDriveApi(
        token.accessToken!,
        token.expirationDate!,
        token.refreshToken!,
      );
    } catch (e) {
      print('OAuth flow failed: $e');
      return null;
    }
  }
 */
  // ── PUBLIC INTERFACE ──

  @override
  Future<drive.DriveApi?> getDriveApi() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isSignedIn = prefs.getBool('google_signed_in') ?? false;
    print("token");
    print(await helper.getTokenFromStorage());
    final token = await helper.getTokenFromStorage() ?? await helper.getToken();

    // If first time signing in, fetch and store user info
    if (!isSignedIn) {
      try {
        final data = await helper.get(
          'https://www.googleapis.com/oauth2/v3/userinfo',
        );
        final userInfo = jsonDecode(data.body);
        print(userInfo);
        print(userInfo);
        await prefs.setString('given_name', userInfo['name']);
        await prefs.setString('google_email', userInfo['email']);
      } catch (e) {
        print('Failed to fetch user info: $e');
      }
      await prefs.setBool('google_signed_in', true);
    }
    if (driveInst != null) return driveInst;
    return _buildDriveApi(
      token.accessToken!,
      token.expirationDate!,
      token.refreshToken!,
    );
  }

  //TODO: Let this function extract name, email, profile picture form the data and pass it to the Google_User_State function
  Future<void> getUserInfo() async {
    final token = await helper.getTokenFromStorage();
    if (token != null) {
      if (token.isExpired()) {
        await helper.refreshToken(token);
        final data = await helper.get(
          'https://www.googleapis.com/oauth2/v3/userinfo',
        );
        return jsonDecode(data.body)['given_name'];
      }

      final data = await helper.get(
        'https://www.googleapis.com/oauth2/v3/userinfo',
      );

      return jsonDecode(data.body)['given_name'];
    } else {
      return null;
    }
  }

  @override
  Future<bool> get isSignedIn async {
    final token = await helper.getTokenFromStorage();

    if (token == null) return false;
    if (token.isExpired()) {
      await helper.refreshToken(token);
    }
    return true;
  }

  @override
  Future<String?> get displayName async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('given_name');
    if (name != null) {
      return name;
    }

    final token = await helper.getTokenFromStorage();
    if (token != null) {
      if (token.isExpired()) {
        await helper.refreshToken(token);
        final data = await helper.get(
          'https://www.googleapis.com/oauth2/v3/userinfo',
        );
        return jsonDecode(data.body)['given_name'];
      }

      final data = await helper.get(
        'https://www.googleapis.com/oauth2/v3/userinfo',
      );

      prefs.setString('google_user', jsonDecode(data.body)['given_name']);
      return jsonDecode(data.body)['given_name'];
    } else {
      return null;
    }
  }

  @override
  Future<String?> get email async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('given_name');
    if (name != null) {
      return name;
    }

    final token = await helper.getTokenFromStorage();
    if (token != null) {
      if (token.isExpired()) {
        await helper.refreshToken(token);
        final data = await helper.get(
          'https://www.googleapis.com/oauth2/v3/userinfo',
        );
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('google_email', jsonDecode(data.body)['email']);
        return jsonDecode(data.body)['email'];
      }

      final data = await helper.get(
        'https://www.googleapis.com/oauth2/v3/userinfo',
      );
      return jsonDecode(data.body)['email'];
    } else {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('given_name');
    await prefs.remove('email');
    await prefs.remove('google_signed_in');
    await helper.removeAllTokens();
  }

  Future<String> getOrCreateAppFolder(drive.DriveApi driveApi) async {
    final String query =
        "name = 'P\\'s Books' and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
    final folderList = await driveApi.files.list(q: query);

    if (folderList.files != null && folderList.files!.isNotEmpty) {
      return folderList.files!.first.id!;
    } else {
      var folderMetadata = drive.File()
        ..name = "P's Books"
        ..mimeType = 'application/vnd.google-apps.folder';

      var folder = await driveApi.files.create(folderMetadata);
      return folder.id!;
    }
  }
}
