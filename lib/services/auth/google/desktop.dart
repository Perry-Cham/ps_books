// services/auth/desktop_auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'abstract.dart';

class DesktopAuthService implements AuthService {
  // Desktop app client credentials from Google Cloud Console
  // These are intentionally not secret — Google designed Desktop app
  // client type for exactly this public client scenario
  static final id = String.fromEnvironment(
    'DRIVE_CLIENT_ID',
    defaultValue: "UNKNOWN",
  );
  static final _clientId = "338563215929-tshvf72vgi9aso3hnspubi6ba120sjr5.apps.googleusercontent.com";
  static const _redirectPort = 8080;
  static const _redirectUri = 'http://localhost:$_redirectPort';
  static const _scopes = [drive.DriveApi.driveFileScope];

  // prefs keys
  static const _accessTokenKey = 'drive_access_token';
  static const _refreshTokenKey = 'drive_refresh_token';
  static const _tokenExpiryKey = 'drive_token_expiry';
  static const _displayNameKey = 'drive_display_name';
  static const _emailKey = 'drive_email';

  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  String? _displayName;
  String? _userEmail;
  String? _folderId;

  // ── PKCE HELPERS ──

  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  // ── TOKEN PERSISTENCE ──

  Future<void> _loadSavedTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    _displayName = prefs.getString(_displayNameKey);
    _userEmail = prefs.getString(_emailKey);
    final expiryMs = prefs.getInt(_tokenExpiryKey);
    if (expiryMs != null) {
      _tokenExpiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
    }
  }

  Future<void> _saveTokens() async {
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken != null) {
      await prefs.setString(_accessTokenKey, _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString(_refreshTokenKey, _refreshToken!);
    }
    if (_tokenExpiry != null) {
      await prefs.setInt(_tokenExpiryKey, _tokenExpiry!.millisecondsSinceEpoch);
    }
    if (_displayName != null) {
      await prefs.setString(_displayNameKey, _displayName!);
    }
    if (_userEmail != null) {
      await prefs.setString(_emailKey, _userEmail!);
    }
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_displayNameKey);
    await prefs.remove(_emailKey);
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    _displayName = null;
    _userEmail = null;
  }

  // ── TOKEN REFRESH ──

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      body: {
        'client_id': _clientId,
        'refresh_token': _refreshToken,
        'grant_type': 'refresh_token',
        // no client_secret — Desktop app type + PKCE does not need it
      },
    );

    if (response.statusCode != 200) {
      print('Token refresh failed: ${response.body}');
      return false;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _accessToken = data['access_token'] as String;
    _tokenExpiry = DateTime.now().add(
      Duration(seconds: data['expires_in'] as int),
    );

    await _saveTokens();
    return true;
  }

  // ── BUILD DRIVE API FROM TOKEN ──

  Future<drive.DriveApi> _buildDriveApi() async {
    final credentials = auth.AccessCredentials(
      auth.AccessToken('Bearer', _accessToken!, _tokenExpiry!.toUtc()),
      _refreshToken,
      _scopes,
    );

    final client = auth.authenticatedClient(http.Client(), credentials);
    final driveD = drive.DriveApi(client);

    //Get
    _folderId = await getOrCreateAppFolder(driveD);
    return driveD;
  }

  @override
  Future<String?> get folderId async {
    if (_folderId != null) return _folderId;
    await getDriveApi();
    return _folderId;
  }

  // ── FETCH USER INFO ──

  Future<void> _fetchUserInfo() async {
    if (_accessToken == null) return;
    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _displayName = data['name'] as String?;
        _userEmail = data['email'] as String?;
        await _saveTokens();
      }
    } catch (e) {
      print('Could not fetch user info: $e');
    }
  }

  // ── FULL OAUTH BROWSER FLOW ──

  Future<drive.DriveApi?> _performOAuthFlow() async {
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);
    final state = _generateCodeVerifier(); // random CSRF token

    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'response_type': 'code',
      'scope': _scopes.join(' '),
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'state': state,
      'access_type': 'offline',
      'prompt': 'consent',
    });

    final codeCompleter = Completer<String?>();
    HttpServer? server;

    try {
      server = await HttpServer.bind('localhost', _redirectPort);

      // listen for the redirect in the background
      server.listen((request) async {
        final code = request.uri.queryParameters['code'];
        final returnedState = request.uri.queryParameters['state'];
        final error = request.uri.queryParameters['error'];

        // always respond to the browser so it does not hang
        final htmlResponse = error != null
            ? '''
              <html><body>
                <h2>Sign in failed</h2>
                <p>$error — you can close this tab.</p>
              </body></html>
            '''
            : '''
              <html><body>
                <h2>Signed in successfully</h2>
                <p>You can close this tab and return to P's Books.</p>
                <script>window.close()</script>
              </body></html>
            ''';

        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.html
          ..write(htmlResponse);
        await request.response.close();

        if (error != null) {
          codeCompleter.complete(null);
          return;
        }

        // verify state to prevent CSRF attacks
        if (returnedState == state && code != null) {
          codeCompleter.complete(code);
        } else {
          codeCompleter.complete(null);
        }
      });

      // open the user's browser
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);

      // wait for the redirect — timeout after 5 minutes
      final code = await codeCompleter.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => null,
      );

      if (code == null) return null;

      return await _exchangeCodeForTokens(code, codeVerifier);
    } finally {
      await server?.close();
    }
  }

  Future<drive.DriveApi?> _exchangeCodeForTokens(
    String code,
    String codeVerifier,
  ) async {
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      body: {
        'client_id': _clientId,
        'code': code,
        'code_verifier': codeVerifier,
        'grant_type': 'authorization_code',
        'redirect_uri': _redirectUri,
        // no client_secret — Desktop app client type with PKCE
      },
    );

    if (response.statusCode != 200) {
      print('Token exchange failed: ${response.body}');
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _accessToken = data['access_token'] as String;
    _refreshToken = data['refresh_token'] as String?;
    _tokenExpiry = DateTime.now().add(
      Duration(seconds: data['expires_in'] as int),
    );

    await _fetchUserInfo();
    await _saveTokens();

    return await _buildDriveApi();
  }

  // ── PUBLIC INTERFACE ──

  @override
  Future<drive.DriveApi?> getDriveApi() async {
    // load any saved tokens first
    await _loadSavedTokens();

    // have a valid non-expired token
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _buildDriveApi();
    }

    // token expired but we have a refresh token
    if (_refreshToken != null) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) return _buildDriveApi();
    }

    // no valid token at all — full browser flow
    return await _performOAuthFlow();
  }

  @override
  Future<bool> get isSignedIn async {
    await _loadSavedTokens();
    if (_refreshToken == null) return false;
    // try refreshing to confirm the token is still valid
    if (_accessToken == null ||
        _tokenExpiry == null ||
        DateTime.now().isAfter(_tokenExpiry!)) {
      return await _refreshAccessToken();
    }
    return true;
  }

  @override
  Future<String?> get displayName async {
    await _loadSavedTokens();
    return _displayName;
  }

  @override
  Future<String?> get email async {
    await _loadSavedTokens();
    return _userEmail;
  }

  @override
  Future<void> signOut() async {
    // revoke the token with Google so it cannot be used again
    if (_accessToken != null) {
      try {
        await http.post(
          Uri.parse('https://oauth2.googleapis.com/revoke'),
          body: {'token': _accessToken},
        );
      } catch (_) {
        // revocation failing is not fatal — clear locally regardless
      }
    }
    await _clearTokens();
  }

  Future<String> getOrCreateAppFolder(drive.DriveApi driveApi) async {
    // 1. Search for the directory by name
    final String query =
        "name = 'P\'s Books' and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
    final folderList = await driveApi.files.list(q: query);

    if (folderList.files != null && folderList.files!.isNotEmpty) {
      // 2. Folder exists! Return the ID
      return folderList.files!.first.id!;
    } else {
      // 3. Folder doesn't exist! Create it now
      var folderMetadata = drive.File()
        ..name = "P's Books"
        ..mimeType = 'application/vnd.google-apps.folder';

      var folder = await driveApi.files.create(folderMetadata);
      return folder.id!;
    }
  }
}
