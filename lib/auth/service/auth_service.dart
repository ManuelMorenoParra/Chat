import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '1008496453558-b53qjh6dbt9et1k862f2s86tb20ih6ct.apps.googleusercontent.com',
  );

  Future<User?> signInWithGoogle() async {
    try {
      print("LOGIN PRESSED");

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        print("LOGIN CANCELLED");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      print("LOGIN OK => ${userCredential.user?.email}");

      return userCredential.user;
    } catch (e) {
      print("LOGIN ERROR => $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
