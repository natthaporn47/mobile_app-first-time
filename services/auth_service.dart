import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    // 1) เลือกบัญชี Google
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) {
      throw FirebaseAuthException(
        code: 'CANCELLED',
        message: 'User cancelled Google sign-in',
      );
    }

    // 2) เอา token
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    // 3) ทำ credential สำหรับ Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // 4) Sign in เข้า Firebase
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
