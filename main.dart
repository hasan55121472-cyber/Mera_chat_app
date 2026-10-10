import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/auth_service.dart';
import 'utils/theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  runApp(const WhatsAppCloneApp());
}

class WhatsAppCloneApp extends StatelessWidget {
  const WhatsAppCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
      },
    );
  }
}

/// Decides which screen to show based on auth state + Firestore profile.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _refreshLastSeen();
  }

  void _refreshLastSeen() {
    final user = _auth.currentUser;
    if (user != null) {
      _auth.saveUser(UserModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        phone: user.phoneNumber ?? '',
        photoUrl: user.photoURL ?? '',
        about: 'Hey there! I am using WhatsApp Clone.',
      ));
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          final data = doc.data()!;
          if (data['freezeLastSeen'] != true) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({'lastSeen': DateTime.now()}, SetOptions(merge: true));
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.authStateChanges,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        final user = snapshot.data!;
        // Check if profile is complete in Firestore.
        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> docSnap) {
            if (docSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary)),
              );
            }
            final exists = docSnap.hasData && docSnap.data!.exists;
            final data =
                exists ? docSnap.data!.data() as Map<String, dynamic>? : null;
            final hasProfile =
                exists && (data?['name'] as String?)?.isNotEmpty == true;
            if (!hasProfile) {
              return const ProfileSetupScreen();
            }
            return const HomeScreen();
          },
        );
      },
    );
  }
}
