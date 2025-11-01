import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication service for SmartChef app
/// Handles email/password, Google, and phone authentication
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  // Configure GoogleSignIn with proper client ID
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of auth changes (for listening to login/logout)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with email and password
  /// Returns UserCredential on success, throws exception on error
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Convert Firebase errors to user-friendly messages
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Create new account with email and password
  /// Returns UserCredential on success, throws exception on error
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update the user's display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
        await userCredential.user?.reload();
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Convert Firebase errors to user-friendly messages
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Sign out current user
  /// Throws exception on error
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'Error signing out. Please try again.';
    }
  }

  /// Sign in with Google
  /// Returns UserCredential on success, throws exception on error
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔵 Starting Google Sign-In...');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('🔴 Google sign-in was cancelled by user');
        throw 'Google sign-in was cancelled';
      }

      print('🟢 Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('🔵 Google auth tokens obtained');

      // Check if we have the required tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('🔴 Failed to obtain Google authentication tokens');
        throw 'Failed to obtain Google authentication tokens';
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔵 Firebase credential created, signing in...');

      // Sign in to Firebase with the Google credential
      final result = await _firebaseAuth.signInWithCredential(credential);
      
      print('🟢 Firebase sign-in successful: ${result.user?.email}');
      
      return result;
    } on FirebaseAuthException catch (e) {
      print('🔴 Firebase Auth error: ${e.code} - ${e.message}');
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      print('🔴 Google Sign-In error: $e');
      if (e.toString().contains('cancelled')) {
        throw 'Google sign-in was cancelled';
      }
      throw 'Google sign-in failed: ${e.toString()}';
    }
  }

  /// Send phone verification code
  /// Returns verification ID for later use
  Future<String> sendPhoneVerification({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
  }) async {
    try {
      String verificationId = '';
      
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onVerificationFailed(_getAuthErrorMessage(e.code));
        },
        codeSent: (String verificationIdReceived, int? resendToken) {
          verificationId = verificationIdReceived;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationIdReceived) {
          verificationId = verificationIdReceived;
        },
        timeout: const Duration(seconds: 60),
      );
      
      return verificationId;
    } catch (e) {
      throw 'Phone verification failed. Please try again.';
    }
  }

  /// Verify phone number with SMS code
  /// Returns UserCredential on success, throws exception on error
  Future<UserCredential> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      throw 'Code verification failed. Please try again.';
    }
  }

  /// Send password reset email
  /// Throws exception on error
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Update user display name
  /// Can be used to store user's full name after signup
  Future<void> updateDisplayName(String displayName) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.reload();
    } catch (e) {
      throw 'Error updating profile. Please try again.';
    }
  }

  /// Convert Firebase Auth error codes to user-friendly messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This authentication method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'invalid-phone-number':
        return 'Please enter a valid phone number.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Verification session expired. Please try again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Get user email
  String? get userEmail => currentUser?.email;

  /// Get user display name
  String? get userDisplayName => currentUser?.displayName;

  /// Get user ID
  String? get userId => currentUser?.uid;
}