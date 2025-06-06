import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('Google Sign-In account result: ${googleUser?.email}');

      if (googleUser == null) {
        // User cancelled the sign-in
        print('User cancelled Google Sign-In');
        return null;
      }

      print('Getting Google authentication...');
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
        'Got Google auth tokens - Access token: ${googleAuth.accessToken != null}, ID token: ${googleAuth.idToken != null}',
      );

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Created Firebase credential');

      // Once signed in, return the UserCredential
      print('Signing in with Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);
      print('Firebase sign-in successful: ${userCredential.user?.email}');

      return userCredential;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      print('Error details: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  static bool isSignedIn() {
    return _auth.currentUser != null;
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
