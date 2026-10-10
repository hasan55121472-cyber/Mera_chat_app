import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../utils/theme.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final FirestoreService _fs = FirestoreService();
  late final String _me = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: StreamBuilder(
        stream: _fs.userStream(_me),
        builder: (context, snap) {
          final user = snap.data;
          if (user == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }
          return ListView(
            children: [
              const _SectionHeader('Last Seen'),
              RadioListTile<String>(
                value: 'everyone',
                groupValue: user.lastSeenPrivacy,
                activeColor: AppTheme.primaryLight,
                title: const Text('Everyone'),
                onChanged: (v) =>
                    _fs.updateUserFields(_me, {'lastSeenPrivacy': v}),
              ),
              RadioListTile<String>(
                value: 'nobody',
                groupValue: user.lastSeenPrivacy,
                activeColor: AppTheme.primaryLight,
                title: const Text('Nobody'),
                onChanged: (v) =>
                    _fs.updateUserFields(_me, {'lastSeenPrivacy': v}),
              ),
              const Divider(),
              const _SectionHeader('Profile Photo'),
              RadioListTile<String>(
                value: 'everyone',
                groupValue: user.photoPrivacy,
                activeColor: AppTheme.primaryLight,
                title: const Text('Everyone'),
                onChanged: (v) =>
                    _fs.updateUserFields(_me, {'photoPrivacy': v}),
              ),
              RadioListTile<String>(
                value: 'nobody',
                groupValue: user.photoPrivacy,
                activeColor: AppTheme.primaryLight,
                title: const Text('Nobody'),
                onChanged: (v) =>
                    _fs.updateUserFields(_me, {'photoPrivacy': v}),
              ),
              const Divider(),
              const _SectionHeader('Freeze Last Seen'),
              SwitchListTile(
                title: const Text('Freeze Last Seen'),
                subtitle: const Text(
                    'When ON, your last seen will not be updated'),
                value: user.freezeLastSeen,
                activeColor: AppTheme.primaryLight,
                onChanged: (val) => _fs.updateUserFields(
                    _me, {'freezeLastSeen': val}),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text,
          style: const TextStyle(
              color: AppTheme.primaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 13)),
    );
  }
}
