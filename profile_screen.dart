import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../utils/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _fs = FirestoreService();
  final StorageService _storage = StorageService();
  late final String _me = FirebaseAuth.instance.currentUser!.uid;

  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  String _photoUrl = '';
  File? _picked;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _aboutController = TextEditingController();
    _fs.getUser(_me).then((u) {
      if (u != null) {
        _nameController.text = u.name;
        _aboutController.text = u.about;
        setState(() => _photoUrl = u.photoUrl);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _picked = File(picked.path));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    String url = _photoUrl;
    if (_picked != null) {
      url = await _storage.uploadProfilePhoto(_me, _picked!);
    }
    await _fs.updateUserFields(_me, {
      'name': _nameController.text.trim(),
      'about': _aboutController.text.trim(),
      'photoUrl': url,
    });
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primaryLight,
                backgroundImage: _picked != null
                    ? FileImage(_picked!)
                    : (_photoUrl.isNotEmpty
                        ? NetworkImage(_photoUrl) as ImageProvider
                        : null),
                child: _picked == null && _photoUrl.isEmpty
                    ? const Icon(Icons.camera_alt,
                        color: Colors.white, size: 32)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person,
                    color: AppTheme.primaryLight),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _aboutController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'About',
                prefixIcon: const Icon(Icons.info_outline,
                    color: AppTheme.primaryLight),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
