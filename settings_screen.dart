import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/theme.dart';
import 'privacy_settings_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirestoreService _fs = FirestoreService();
  final AuthService _auth = AuthService();
  late final String _me = FirebaseAuth.instance.currentUser!.uid;
  bool _antiDelete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: StreamBuilder(
        stream: _fs.userStream(_me),
        builder: (context, snap) {
          final user = snap.data;
          _antiDelete = user?.antiDeleteEnabled ?? false;
          if (user == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }
          return ListView(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryLight,
                  backgroundImage: user.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: user.photoUrl.isEmpty
                      ? Text(user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?')
                      : null,
                ),
                title: Text(user.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(user.about),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.key, color: AppTheme.primaryLight),
                title: const Text('Privacy'),
                subtitle: const Text('Last seen, profile photo, freeze'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrivacySettingsScreen())),
              ),
              const Divider(),
              SwitchListTile(
                secondary: const Icon(Icons.shield, color: AppTheme.primaryLight),
                title: const Text('Anti-Delete Mode'),
                subtitle: const Text(
                    'Keep original text of messages others delete for everyone'),
                value: _antiDelete,
                activeColor: AppTheme.primaryLight,
                onChanged: (val) async {
                  await _fs.updateUserFields(_me, {
                    'antiDeleteEnabled': val,
                  });
                  setState(() => _antiDelete = val);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log out'),
                onTap: () async {
                  await _auth.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
