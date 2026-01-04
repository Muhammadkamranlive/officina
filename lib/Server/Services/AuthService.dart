import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/UserRepository.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepo = UserRepository();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<AppUser?> signInWithGoogle() async {
    // NEW API
    final GoogleSignInAccount googleUser =
        await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    final firebaseUser = userCredential.user!;

    final existingUser = await _userRepo.getByUid(firebaseUser.uid);

    if (existingUser != null) {
      return existingUser;
    }

    final newUser = AppUser(
      userId: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      role: UserRole.recruiter,
    );

    await _userRepo.add(newUser);
    return newUser;
  }
 

  Future<AppUser?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = AppUser(
      userId: credential.user!.uid,
      email: email,
      role: role,
    );
    await _userRepo.add(user);
    return user;
  }

  Future<AppUser?> signIn({
  required String email,
  required String password,
}) async {
  try {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      showCustomToast("Login failed. Please try again.");
      return null;
    }

    // Check user exists in your DB
    final appUser = await _userRepo.getByEmail(firebaseUser.email!);

    if (appUser == null) {
      showCustomToast("User not registered. Please sign up first.");
      return null;
    }

    return appUser;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      showCustomToast("User not found. Please sign up first.");
    } else if (e.code == 'wrong-password') {
      showCustomToast("Incorrect password.");
    } else if (e.code == 'invalid-email') {
      showCustomToast("Invalid email address.");
    } else {
      //showCustomToast("Login failed: ${e.message}");
    }
    return null;
  } catch (e) {
    showCustomToast("Something went wrong. Try again.");
    return null;
  }
}


  Future<void> signOut() async {
    await _auth.signOut();
  }

  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user != null) {
      // You may fetch full AppUser details from Firestore if needed
    }
    return null;
  }

 

  Future<void> sendOtp({
  required String phone,
  required Function(String verificationId) onCodeSent,
  required Function(String error) onError,
}) async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phone,
    timeout: const Duration(seconds: 60),
    verificationCompleted: (PhoneAuthCredential credential) async {
      // Auto-verification (Android only)
      await _auth.signInWithCredential(credential);
    },
    verificationFailed: (FirebaseAuthException e) {
      onError(e.message ?? "OTP verification failed");
    },
    codeSent: (String verificationId, int? resendToken) {
      onCodeSent(verificationId);
    },
    codeAutoRetrievalTimeout: (String verificationId) {},
  );
}
  

  Future<AppUser?> verifyOtp({
  required String verificationId,
  required String smsCode,
  required UserRole role,
}) async {
  try {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential =
        await _auth.signInWithCredential(credential);

    final firebaseUser = userCredential.user!;
    final uid   = firebaseUser.uid;
    final phone = firebaseUser.phoneNumber ?? '';

    // 🔍 Check if user already exists
    final existingUser = await _userRepo.getByUid(uid);
    if (existingUser != null) {
      return existingUser; // LOGIN
    }

    // 🆕 First time signup
    final newUser = AppUser(
      userId: uid,
      email: '', 
      phone: phone,
      role: role,
    );

    await _userRepo.add(newUser);
    return newUser;

  } catch (e) {
    showCustomToast("Invalid OTP");
    return null;
  }
}


  
}