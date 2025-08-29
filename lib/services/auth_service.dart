import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Update last login time
        await _updateLastLogin(userCredential.user!.uid);
        
        // Return user model
        return await getUserData(userCredential.user!.uid);
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Initialize Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Check if user already exists in Firestore
        UserModel? existingUser = await getUserData(userCredential.user!.uid);
        
        if (existingUser == null) {
          // Create new user in Firestore
          final newUser = UserModel.createNew(
            userCredential.user!.uid,
            userCredential.user!.email ?? '',
            userCredential.user!.displayName ?? 'User',
          );
          
          await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toJson());
          
          existingUser = newUser;
        }
        
        // Update last login time
        await _updateLastLogin(userCredential.user!.uid);
        
        return existingUser;
      }
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
    String email, 
    String password, 
    String displayName
  ) async {
    try {
      print('Starting registration for email: $email');
      
      // Validate input
      if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
        throw Exception('All fields are required');
      }
      
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }
      
      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        print('Firebase user created successfully: ${userCredential.user!.uid}');
        
        try {
          // Update display name
          await userCredential.user!.updateDisplayName(displayName);
          print('Display name updated successfully');
        } catch (e) {
          print('Warning: Could not update display name: $e');
          // Continue with registration even if display name update fails
        }
        
        // Create user document in Firestore
        final userModel = UserModel.createNew(
          userCredential.user!.uid,
          email,
          displayName,
        );
        
        print('Creating user document in Firestore...');
        await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toJson());
        
        print('User document created successfully in Firestore');
        
        // Update last login time
        await _updateLastLogin(userCredential.user!.uid);
        
        return userModel;
      } else {
        print('Error: userCredential.user is null');
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error during registration: ${e.code} - ${e.message}');
      String errorMessage;
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak. Please choose a stronger password.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account with this email already exists.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled. Please contact support.';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      print('General error during registration: $e');
      if (e is Exception) {
        rethrow; // Re-throw our custom exceptions
      }
      throw Exception('Registration failed. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update last login and check streak
  Future<void> _updateLastLogin(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final lastLoginAt = (userData['lastLoginAt'] as Timestamp).toDate();
        final now = DateTime.now();
        
        // Get streak data
        final streakData = StreakData.fromJson(userData['streak'] as Map<String, dynamic>);
        
        // Check if it's a new day (compared to last login)
        final isNewDay = lastLoginAt.day != now.day || 
                         lastLoginAt.month != now.month || 
                         lastLoginAt.year != now.year;
        
        // Check if it's consecutive day (yesterday)
        final isConsecutiveDay = now.difference(lastLoginAt).inDays == 1;
        
        // Update streak
        StreakData updatedStreak = streakData;
        
        if (isNewDay) {
          if (isConsecutiveDay) {
            // Consecutive day - increase streak
            final newCurrentStreak = streakData.currentStreak + 1;
            final newLongestStreak = newCurrentStreak > streakData.longestStreak 
                ? newCurrentStreak 
                : streakData.longestStreak;
            
            // Add today to streak dates
            final newStreakDates = List<DateTime>.from(streakData.streakDates)
              ..add(now);
            
            updatedStreak = streakData.copyWith(
              currentStreak: newCurrentStreak,
              longestStreak: newLongestStreak,
              lastLoginDate: now,
              streakDates: newStreakDates,
            );
          } else {
            // Not consecutive - reset streak
            updatedStreak = streakData.copyWith(
              currentStreak: 1,
              lastLoginDate: now,
              streakDates: [now],
            );
          }
        }
        
        // Update user document
        await _firestore.collection('users').doc(uid).update({
          'lastLoginAt': now,
          'streak': updatedStreak.toJson(),
        });
      }
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }
        
        // Update Firestore
        final updates = <String, dynamic>{};
        if (displayName != null) updates['displayName'] = displayName;
        if (photoUrl != null) updates['photoUrl'] = photoUrl;
        
        if (updates.isNotEmpty) {
          await _firestore.collection('users').doc(user.uid).update(updates);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}
