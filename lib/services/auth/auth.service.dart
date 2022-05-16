import 'dart:async';

import 'package:awesome_poll_app/utils/commons.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_database/firebase_database.dart';
import 'package:injectable/injectable.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

Logger logger = Logger.of('AuthService');

//this only provides a uid within the tree
//forces an rebuild of the entire app when the auth state is changing
class AuthCubit extends Cubit<String?> {
  final AuthService auth;
  late final StreamSubscription _subscription;
  AuthCubit({required this.auth}) : super(null) {
    _subscription = auth.uidChanges.listen((e) => emit(e));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

//forcing login screen to not show when logged in
class AuthObserver extends AutoRouterObserver {
  late final AppRouter rootRouter;

  AuthObserver({required this.rootRouter});

  @override
  void didPush(Route route, Route? previousRoute) async {
    var auth = getIt.get<AuthService>();
    await auth.initialized;
    if (auth.isLoggedIn() &&
        route.settings.name == const LoginRoute().routeName) {
      rootRouter.navigate(const MainRoute());
    }
  }
}

//provides global authentication state, multiple login/logout/registration functionality
//TODO google auth and others, the auth calls seem quiet different for android/web
abstract class AuthService {
  bool isLoggedIn();
  Future<String> getUserTokenId();

  /// Registers a new user.
  /// Throws a [RegisterException] if registering did not succeed
  Future<void> registerWithEmailAndPassword(
      String email, String password, String passwordRepeat);

  /// Changes the password of the user
  Future<bool> changePassword(
      String oldPassword, String newPassword, String passwordRepeat);

  /// Authenticates the user with the given data
  /// Throws a [LoginException] if the login did not succeed
  Future<void> loginWithEmailAndPassword(String email, String password);

  /// Logout the current user.
  Future<void> logout();

  /// Stream that sends an event, when the user id changes
  Stream<String?> get uidChanges;

  /// Futer that completes, after successful login
  Future<void> get initialized;

  /// Delete the account of the current user and all user related data, if the password is correct
  Future<void> deleteAccount(String password);

  /// Returns the current user id
  String get uid;

  Future<String> hashedID(String pollID);

  @disposeMethod
  Future<void> dispose();
}

class RegisterException implements Exception {
  /// Can be one of the following:
  ///   - "passwords-differ" if the given password and the repeated password are different
  ///   - "weak-password" if the given password is too weak (the only rule seems to be at least 6 chars)
  ///   - "email-already-in-use" if the email address is already registered
  final String code;

  // constructor - initializes msg as given
  RegisterException(this.code);
}

class LoginException implements Exception {
  /// Can be one of the following:
  ///   - "user-not-found" if the email does not exist as user
  ///   - "wrong-password" if the password is wrong for the given email
  final String code;

  // constructor - initializes msg as given
  LoginException(this.code);
}

//firebase implementation of AuthService
@firebase
@LazySingleton(as: AuthService) //lazy because they must be mutually exclusive
class FirebaseLogin implements AuthService {
  bool _loggedIn = false;
  int intialSalt = Random().nextInt(1000);

  late fb.FirebaseAuth _auth;

  StreamSubscription? _authChanges;

  final Completer<void> _initialized = Completer();

  FirebaseLogin() {
    _auth = fb.FirebaseAuth.instance;
    logger.info('initializing firebase login');
    _authChanges = _auth.authStateChanges().listen((fb.User? user) {
      if (user == null) {
        _loggedIn = false;
      } else {
        _loggedIn = true;
        setSalt(intialSalt.toString());
      }
      if (!_initialized.isCompleted) {
        _initialized.complete();
      }
    });
  }

  @override
  Stream<String?> get uidChanges => _auth.authStateChanges().map((e) => e?.uid);

  @override
  Future<void> get initialized => _initialized.future;

  @override
  bool isLoggedIn() {
    return _loggedIn;
  }

  @override
  Future<String> getUserTokenId() async {
    if (_auth.currentUser == null) {
      throw Exception("Not logged in");
    }
    return _auth.currentUser!.getIdToken();
  }

  @override
  Future<void> registerWithEmailAndPassword(
      String email, String password, String passwordRepeat) async {
    if (password != passwordRepeat) {
      throw RegisterException("passwords-differ");
    }
    try {
      fb.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw RegisterException("weak-password");
      } else if (e.code == 'email-already-in-use') {
        throw RegisterException("email-already-in-use");
      }
    } catch (e) {
      logger.error(e);
    }
  }

  @override
  Future<bool> changePassword(
      String oldPassword, String newPassword, String passwordRepeat) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception(
          "Could not change password because the user is signed in anonymous.");
    } else {
      if (newPassword != passwordRepeat) {
        throw RegisterException("passwords-differ");
      }
      try {
        // Tell firebase to change the password.
        fb.AuthCredential credential = fb.EmailAuthProvider.credential(
            email: user.email!, password: oldPassword);
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        return true;
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          throw RegisterException("weak-password");
        } else if (e.code == 'invalid-credential' ||
            e.code == 'wrong-password') {
          throw LoginException('wrong-password');
        }
      } catch (e) {
        logger.error(e.toString());
      }
      return false;
    }
  }

  @override
  Future<fb.UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      fb.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw LoginException('user-not-found');
      } else if (e.code == 'wrong-password') {
        throw LoginException('wrong-password');
      } else {
        rethrow;
      }
    } catch (e) {
      logger.error('an error occured');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Fpr the logged in user, deletes all user-related data and the account itself from firebase
  @override
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      throw new Exception(
          "Could not delete the user because the user is signed in anonymous.");
    } else {
      try {
        // Reauthenticate. This is needed to delet the account in firebase
        fb.AuthCredential credential = fb.EmailAuthProvider.credential(
            email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);

        // First, delete all user related data
        FirebaseDatabase database = FirebaseDatabase.instance;
        DatabaseReference root = await FirebaseDatabase(
                databaseURL:
                    'https://awesome-poll-app-default-rtdb.europe-west1.firebasedatabase.app/')
            .ref();

        // delete user settings
        await root.child("users/" + uid).remove();

        // delete all of the users polls
        DatabaseEvent pollFetch = await root.child("poll-overview").once();
        Map<String, dynamic> obj = Map<String, dynamic>.from(
            pollFetch.snapshot.value as Map<Object?, Object?>);
        if (obj.containsKey(uid)) {
          obj = obj[uid];
          Map<String, dynamic> nodesToDelete = {};
          obj.forEach((key, value) async {
            nodesToDelete.addAll({"poll-details/" + key: null});
            nodesToDelete.addAll({"poll-results/" + key: null});
            nodesToDelete.addAll({"polls/" + key: null});
          });
          await root.update(nodesToDelete);
        }

        await root.child("poll-overview/" + uid).remove();

        // now delete the user
        await user.delete();
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
          throw LoginException('wrong-password');
        }
      } catch (e) {
        logger.error(e);
      }
    }
  }

  @override
  String get uid {
    if (!_loggedIn) {
      Future.error('user is not logged in');
    }
    return _auth.currentUser!.uid;
  }

  @override
  Future<String> hashedID(String pollID) async {
    if (!_loggedIn) {
      Future.error('user is not logged in');
    }
    String salt = await getSalt();
    var bytes = utf8.encode(_auth.currentUser!.uid + salt + pollID);
    var hashedID = sha256.convert(bytes);
    return hashedID.toString();
  }

  @override
  Future<void> dispose() async {
    await _authChanges?.cancel();
  }

  Future<void> setSharedPreferences() async {}

  Future<void> setSalt(String salt) async {
    EncryptedSharedPreferences encryptedSharedPreferences =
        EncryptedSharedPreferences();
    if (encryptedSharedPreferences
            .getString(_auth.currentUser!.uid)
            .toString() ==
        '') {
      encryptedSharedPreferences.setString(_auth.currentUser!.uid, salt);
    }
  }

  Future<String> getSalt() async {
    EncryptedSharedPreferences encryptedSharedPreferences =
        EncryptedSharedPreferences();
    if (encryptedSharedPreferences
            .getString(_auth.currentUser!.uid)
            .toString() ==
        '') {
      encryptedSharedPreferences.setString(
          _auth.currentUser!.uid, intialSalt.toString());
    }
    return encryptedSharedPreferences
        .getString(_auth.currentUser!.uid)
        .toString();
  }
}

//in-memory implementation of AuthService
@local
@LazySingleton(as: AuthService)
class LocalLogin implements AuthService {
  bool _loggedIn = false;

  LocalLogin() {
    logger.info('initializing local login');
  }

  @override
  bool isLoggedIn() {
    return _loggedIn;
  }

  @override
  Future<String> getUserTokenId() {
    return Future.value("");
  }

  @override
  Future<void> registerWithEmailAndPassword(
      String email, String password, String passwordRepeat) async {
    logger.info("User wants to register with email " +
        email +
        " and password " +
        password +
        " and repeated password " +
        passwordRepeat +
        ".");
  }

  @override
  Future<bool> changePassword(
      String oldPassword, String newPassword, String passwordRepeat) {
    return Future.value(true);
  }

  @override
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    if (email == "test@test.test" && password == "test@test.test") {
      _loggedIn = true;
    } else {
      return Future.error('invalid credentials');
    }
  }

  @override
  Stream<String?> get uidChanges {
    //TODO
    throw UnimplementedError();
  }

  @override
  Future<void> get initialized async {}

  @override
  Future<void> logout() async {
    _loggedIn = false;
  }

  @override
  Future<void> deleteAccount(String password) async {}

  @override
  String get uid {
    if (!_loggedIn) {
      Future.error('user is not logged in');
    }
    return 'test_user';
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<String> hashedID(String pollID) {
    return Future.value("NULL");
  }
}
