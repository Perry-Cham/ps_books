// providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth/google/auth_service.dart';
import '../services/auth/google/abstract.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';

// single instance shared across the app
final authServiceProvider = Provider<AuthService>((ref) {
  return createAuthService();
});

// whether the user is currently signed in
final isSignedInProvider = FutureProvider<bool>((ref) async {
  return ref.watch(authServiceProvider).isSignedIn;
});

// the user's display name
final displayNameProvider = FutureProvider<String?>((ref) async {
  return ref.watch(authServiceProvider).displayName;
});

class UserAccounts {
  final PsBooks? psBooksUser;
  final GoogleUser? googleUser;

  UserAccounts({this.psBooksUser, this.googleUser});

  UserAccounts copyWith({PsBooks? psBooksUser, GoogleUser? googleUser}) {
    return UserAccounts(
      psBooksUser: psBooksUser ?? this.psBooksUser,
      googleUser: googleUser ?? this.googleUser,
    );
  }
}

class UserAccountsNotifier extends AsyncNotifier<UserAccounts> {
  @override
  Future<UserAccounts> build() async {
    final prefs = await SharedPreferences.getInstance();

    final gName = prefs.getString('given_name');
    final gEmail = prefs.getString('google_email');
    final gIsSignedIn = prefs.getBool('google_signed_in') ?? false;
    final googleUser = GoogleUser(
      name: gName,
      email: gEmail,
      isSignedIn: gIsSignedIn,
    );

    final psName = prefs.getString('ps_user_name') ?? '';
    final psIsSignedIn = prefs.getBool('ps_signed_in') ?? false;
    final psBooksUser = PsBooks(name: psName, isSignedIn: psIsSignedIn);

    return UserAccounts(psBooksUser: psBooksUser, googleUser: googleUser);
  }

  Future<void> updateGoogleUser(
    String? name,
    String? email,
    bool isSignedIn,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) await prefs.setString('given_name', name);
    if (email != null) await prefs.setString('google_email', email);
    await prefs.setBool('google_signed_in', isSignedIn);

    final current = await future;
    state = AsyncData(
      current.copyWith(
        googleUser: GoogleUser(name: name, email: email, isSignedIn: isSignedIn),
      ),
    );
  }

  Future<void> updatePsBooksUser(String name, bool isSignedIn) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('ps_user_name', name);
    await prefs.setBool('ps_signed_in', isSignedIn);

    final current = await future;
    state = AsyncData(
      current.copyWith(psBooksUser: PsBooks(name: name, isSignedIn: isSignedIn)),
    );
  }

  Future<void> logout(String accountType) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await future;

    if (accountType == 'google') {
      await prefs.remove('given_name');
      await prefs.remove('google_email');
      await prefs.setBool('google_signed_in', false);
      state = AsyncData(
        current.copyWith(googleUser: GoogleUser(isSignedIn: false)),
      );
    } else if (accountType == 'psBooks') {
      await prefs.remove('ps_user_name');
      await prefs.setBool('ps_signed_in', false);
      state = AsyncData(
        current.copyWith(psBooksUser: PsBooks(isSignedIn: false)),
      );
    }
  }
}

final userAccountsProvider =
    AsyncNotifierProvider<UserAccountsNotifier, UserAccounts>(
      UserAccountsNotifier.new,
    );

class PsBooks {
  final String name;
  final bool isSignedIn;

  PsBooks({this.isSignedIn = false, this.name = ''});
  PsBooks copyWith({bool? signedIn, String? name}) {
    return PsBooks(isSignedIn: signedIn ?? isSignedIn, name: name ?? this.name);
  }
}

class GoogleUser {
  final String? name;
  final String? email;
  final bool isSignedIn;

  GoogleUser({this.name, this.email, this.isSignedIn = false});

  GoogleUser copyWith({String? name, String? email, bool? isSignedIn}) {
    return GoogleUser(
      name: name ?? this.name,
      email: email ?? this.email,
      isSignedIn: isSignedIn ?? this.isSignedIn,
    );
  }
}

final driveBooksProvider = FutureProvider<List<drive.File>>((ref) async {
  final authService = ref.watch(authServiceProvider);

  // 1. Get the Drive API instance
  final driveApi = await authService.getDriveApi();
  if (driveApi == null) {
    throw Exception('Failed to authenticate with Google Drive');
  }

  // 2. Get the Folder ID (This method already handles creation if missing)
  final folderId = await authService.folderId;
  if (folderId == null) {
    throw Exception('Could not locate or create app folder');
  }

  // 3. Fetch the metadata for files inside that folder
  final String query = "'$folderId' in parents and trashed = false";
  final  fileList = await driveApi.files.list(
    q: query,
    $fields: "files(id, name, mimeType, size, modifiedTime, thumbnailLink)",
  );

  return fileList.files ?? [];
});
