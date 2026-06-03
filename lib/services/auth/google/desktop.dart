import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'abstract.dart';

const id = String.fromEnvironment('DRIVE_CLIENT_ID');
const secret = String.fromEnvironment('DRIVE_CLIENT_SECRET');

/// Custom OAuth2 client for Google's endpoints.
///
/// Uses the authorization code flow with PKCE (enabled by default in
/// [OAuth2Client.getTokenWithAuthCodeFlow]).
class GoogleOAuth2Client extends OAuth2Client {
  GoogleOAuth2Client()
      : super(
    authorizeUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
    tokenUrl: 'https://oauth2.googleapis.com/token',
    redirectUri: 'http://localhost:8080',
    customUriScheme: 'http://localhost:8080',
  );
}

class DesktopAuthService implements AuthService {
  static const _scopes = [
    drive.DriveApi.driveFileScope,
    'openid',
  ];

  static const _oauthScopes = [
    'openid',
    'profile',
    'email',
    'https://www.googleapis.com/auth/drive.file',
  ];

  /// Storage keys for manually persisted token data.
  static const _keyAccessToken = 'google_access_token';
  static const _keyRefreshToken = 'google_refresh_token';
  static const _keyExpirationDate = 'google_token_expiration_date';
  static const _keyTokenScope = 'google_token_scope';

  String? _folderId;
  static drive.DriveApi? driveInst;
  static final _oauthClient = GoogleOAuth2Client();

  // ── Uncomment below to use flutter_secure_storage instead of SharedPreferences ──
  //
  // static const _secureStorage = FlutterSecureStorage(
  //   aOptions: AndroidOptions(encryptedSharedPreferences: true),
  //   iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  // );
  //
  // static const _secureKeyAccessToken = 'google_access_token';
  // static const _secureKeyRefreshToken = 'google_refresh_token';
  // static const _secureKeyExpirationDate = 'google_token_expiration_date';
  // static const _secureKeyTokenScope = 'google_token_scope';

  // ── TOKEN PERSISTENCE (SharedPreferences) ──

  /// Saves the token response fields to SharedPreferences.
  Future<void> _saveTokenToStorage(AccessTokenResponse token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, token.accessToken!);
    if (token.refreshToken != null) {
      await prefs.setString(_keyRefreshToken, token.refreshToken!);
    }
    if (token.expirationDate != null) {
      await prefs.setString(
        _keyExpirationDate,
        token.expirationDate!.millisecondsSinceEpoch.toString(),
      );
    }
    if (token.scope != null) {
      await prefs.setString(_keyTokenScope, jsonEncode(token.scope));
    }
  }

  /// Reads a previously stored token from SharedPreferences.
  ///
  /// Returns `null` if no valid token data is found.
  Future<AccessTokenResponse?> _loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_keyAccessToken);
    final refreshToken = prefs.getString(_keyRefreshToken);
    final expirationStr = prefs.getString(_keyExpirationDate);
    final scopeStr = prefs.getString(_keyTokenScope);

    if (accessToken == null || expirationStr == null) return null;

    final expirationMs = int.tryParse(expirationStr);
    if (expirationMs == null) return null;

    List<String>? scopes;
    if (scopeStr != null) {
      final decoded = jsonDecode(scopeStr);
      if (decoded is List) {
        scopes = decoded.cast<String>();
      }
    }

    return AccessTokenResponse.fromMap({
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expiration_date': expirationMs,
      'scope': scopes,
      'token_type': 'Bearer',
    });
  }

  /// Removes all stored token data from SharedPreferences.
  Future<void> _clearTokenStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyExpirationDate);
    await prefs.remove(_keyTokenScope);
  }

  // ── Uncomment below for flutter_secure_storage persistence ──
  //
  // /// Saves the token response fields to flutter_secure_storage.
  // Future<void> _saveTokenToSecureStorage(AccessTokenResponse token) async {
  //   await _secureStorage.write(
  //     key: _secureKeyAccessToken,
  //     value: token.accessToken,
  //   );
  //   if (token.refreshToken != null) {
  //     await _secureStorage.write(
  //       key: _secureKeyRefreshToken,
  //       value: token.refreshToken,
  //     );
  //   }
  //   if (token.expirationDate != null) {
  //     await _secureStorage.write(
  //       key: _secureKeyExpirationDate,
  //       value: token.expirationDate!.millisecondsSinceEpoch.toString(),
  //     );
  //   }
  //   if (token.scope != null) {
  //     await _secureStorage.write(
  //       key: _secureKeyTokenScope,
  //       value: jsonEncode(token.scope),
  //     );
  //   }
  // }
  //
  // /// Reads a previously stored token from flutter_secure_storage.
  // Future<AccessTokenResponse?> _loadTokenFromSecureStorage() async {
  //   final accessToken = await _secureStorage.read(key: _secureKeyAccessToken);
  //   final refreshToken =
  //       await _secureStorage.read(key: _secureKeyRefreshToken);
  //   final expirationStr =
  //       await _secureStorage.read(key: _secureKeyExpirationDate);
  //   final scopeStr = await _secureStorage.read(key: _secureKeyTokenScope);
  //
  //   if (accessToken == null || expirationStr == null) return null;
  //
  //   final expirationMs = int.tryParse(expirationStr);
  //   if (expirationMs == null) return null;
  //
  //   List<String>? scopes;
  //   if (scopeStr != null) {
  //     final decoded = jsonDecode(scopeStr);
  //     if (decoded is List) {
  //       scopes = decoded.cast<String>();
  //     }
  //   }
  //
  //   return AccessTokenResponse.fromMap({
  //     'access_token': accessToken,
  //     'refresh_token': refreshToken,
  //     'expiration_date': expirationMs,
  //     'scope': scopes,
  //     'token_type': 'Bearer',
  //   });
  // }
  //
  // /// Removes all stored token data from flutter_secure_storage.
  // Future<void> _clearSecureTokenStorage() async {
  //   await _secureStorage.delete(key: _secureKeyAccessToken);
  //   await _secureStorage.delete(key: _secureKeyRefreshToken);
  //   await _secureStorage.delete(key: _secureKeyExpirationDate);
  //   await _secureStorage.delete(key: _secureKeyTokenScope);
  // }

  // ── TOKEN ACQUISITION & REFRESH ──

  /// Performs the full authorization code flow via [OAuth2Client] and
  /// persists the resulting token manually.
  ///
  /// This opens the system browser for user consent, captures the redirect,
  /// and exchanges the authorization code for access and refresh tokens.
  /// The tokens are then stored in local storage for later retrieval.
  Future<AccessTokenResponse> _performAuthCodeFlow() async {
    final tokenResponse = await _oauthClient.getTokenWithAuthCodeFlow(
      clientId: id,
      clientSecret: secret,
      scopes: _oauthScopes,
      enablePKCE: true,
      enableState: true,
      webAuthOpts: {'useWebview': false},
    );

    if (!tokenResponse.isValid()) {
      throw Exception(
        'OAuth2 auth code flow failed: '
            '${tokenResponse.error} - ${tokenResponse.errorDescription}',
      );
    }

    // Store the token manually
    await _saveTokenToStorage(tokenResponse);
    // await _saveTokenToSecureStorage(tokenResponse);

    return tokenResponse;
  }

  /// Attempts to refresh the access token using the stored refresh token.
  ///
  /// If the server does not return a new refresh token in its response,
  /// the old refresh token is preserved (Google typically only returns
  /// a refresh token on the first authorization; subsequent refreshes
  /// omit it).
  Future<AccessTokenResponse> _refreshStoredToken(
      AccessTokenResponse currentToken,
      ) async {
    if (currentToken.refreshToken == null) {
      // No refresh token available — must re-authorize from scratch
      return _performAuthCodeFlow();
    }

    final oldRefreshToken = currentToken.refreshToken;

    final refreshedResponse = await _oauthClient.refreshToken(
      oldRefreshToken!,
      clientId: id,
      clientSecret: secret,
      scopes: _oauthScopes,
    );

    if (!refreshedResponse.isValid()) {
      // If refresh fails (e.g. invalid_grant), clear storage and
      // fall back to a full re-authorization
      await _clearTokenStorage();
      // await _clearSecureTokenStorage();
      return _performAuthCodeFlow();
    }

    // Preserve the old refresh token if the server didn't return a new one
    if (refreshedResponse.refreshToken == null) {
      refreshedResponse.refreshToken = oldRefreshToken;
    }

    // Persist the refreshed token
    await _saveTokenToStorage(refreshedResponse);
    // await _saveTokenToSecureStorage(refreshedResponse);

    return refreshedResponse;
  }

  /// Returns a valid, non-expired [AccessTokenResponse].
  ///
  /// This is the central token-acquisition method. It:
  /// 1. Checks local storage for an existing token.
  /// 2. If the token is still valid, returns it immediately.
  /// 3. If the token is expired but has a refresh token, refreshes it.
  /// 4. If no token exists, kicks off the full auth code flow.
  Future<AccessTokenResponse> _getValidToken() async {
    // Try loading from manual storage first
    var token = await _loadTokenFromStorage();
    // var token = await _loadTokenFromSecureStorage();

    if (token != null && token.isValid()) {
      if (!token.isExpired()) {
        return token;
      }

      // Token exists but is expired — try to refresh
      token = await _refreshStoredToken(token);
      return token;
    }

    // No stored token or invalid — perform full auth code flow
    return _performAuthCodeFlow();
  }

  // ── BUILD DRIVE API FROM TOKEN ──

  Future<drive.DriveApi> _buildDriveApi(
      String accessToken,
      DateTime expiry,
      String refreshToken,
      ) async {
    final credentials = auth.AccessCredentials(
      auth.AccessToken('Bearer', accessToken, expiry.toUtc()),
      refreshToken,
      _scopes,
    );

    final client = auth.authenticatedClient(http.Client(), credentials);
    final driveApi = drive.DriveApi(client);

    _folderId = await getOrCreateAppFolder(driveApi);
    driveInst = driveApi;
    return driveApi;
  }

  // ── PUBLIC INTERFACE ──

  @override
  Future<String?> get folderId async {
    if (_folderId != null) return _folderId;
    await getDriveApi();
    return _folderId;
  }

  @override
  Future<drive.DriveApi?> getDriveApi() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isSignedIn = prefs.getBool('google_signed_in') ?? false;

    final token = await _getValidToken();

    // If first time signing in, fetch and store user info
    if (!isSignedIn) {
      try {
        final userInfo = await _fetchUserInfo(token.accessToken!);
        await prefs.setString('given_name', userInfo['name'] ?? '');
        await prefs.setString('google_email', userInfo['email'] ?? '');
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

  /// Fetches the authenticated user's profile from Google's userinfo endpoint.
  Future<Map<String, dynamic>> _fetchUserInfo(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch user info: ${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Returns the user's display name, preferring cached data in
  /// SharedPreferences and falling back to a live API call.
  ///
  /// Also extracts and caches the user's email and profile picture URL
  /// from the userinfo response, which can be passed to a
  /// `GoogleUserState` provider.
  // TODO: Extract name, email, and profile picture from the data
  //       and pass them to the Google_User_State function.
  Future<Map<String, String?>?> getUserInfo() async {
    final token = await _loadTokenFromStorage();
    // final token = await _loadTokenFromSecureStorage();

    if (token == null) return null;

    // Ensure the token is still valid (refresh if needed)
    final validToken = await _getValidToken();

    try {
      final userInfo = await _fetchUserInfo(validToken.accessToken!);
     print(userInfo);
      // Cache the user info locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('given_name', userInfo['name'] ?? '');
      await prefs.setString('google_email', userInfo['email'] ?? '');
      await prefs.setString(
        'google_profile_picture',
        userInfo['picture'] ?? '',
      );

      return {
        'name': userInfo['name'] as String?,
        'email': userInfo['email'] as String?,
        'picture': userInfo['picture'] as String?,
      };
    } catch (e) {
      print('Failed to fetch user info: $e');
      return null;
    }
  }

  @override
  Future<bool> get isSignedIn async {
    final token = await _loadTokenFromStorage();
    // final token = await _loadTokenFromSecureStorage();

    if (token == null) return false;

    if (token.isExpired()) {
      try {
        await _refreshStoredToken(token);
        return true;
      } catch (_) {
        return false;
      }
    }

    return true;
  }

  @override
  Future<String?> get displayName async {
    final prefs = await SharedPreferences.getInstance();

    // Return cached name if available
    final cachedName = prefs.getString('given_name');
    if (cachedName != null) return cachedName;

    // Otherwise fetch from the API
    try {
      final validToken = await _getValidToken();
      final userInfo = await _fetchUserInfo(validToken.accessToken!);
      final name = userInfo['name'] as String?;
      if (name != null) {
        await prefs.setString('given_name', name);
      }
      return name;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> get email async {
    final prefs = await SharedPreferences.getInstance();

    // Return cached email if available (was returning given_name before — now fixed)
    final cachedEmail = prefs.getString('google_email');
    if (cachedEmail != null) return cachedEmail;

    // Otherwise fetch from the API
    try {
      final validToken = await _getValidToken();
      final userInfo = await _fetchUserInfo(validToken.accessToken!);
      final email = userInfo['email'] as String?;
      if (email != null) {
        await prefs.setString('google_email', email);
      }
      return email;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('given_name');
    await prefs.remove('google_email');
    await prefs.remove('google_profile_picture');
    await prefs.remove('google_signed_in');

    // Clear manually stored tokens
    await _clearTokenStorage();
    // await _clearSecureTokenStorage();

    // Reset in-memory state
    driveInst = null;
    _folderId = null;
  }

  Future<String> getOrCreateAppFolder(drive.DriveApi driveApi) async {
    const String query =
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