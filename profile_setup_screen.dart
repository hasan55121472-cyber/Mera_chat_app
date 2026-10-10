import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';
import '../utils/theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final AuthService _auth = AuthService();
  final StorageService _storage = StorageService();
  final _nameController = TextEditingController();
  final _aboutController =
      TextEditingController(text: 'Hey there! I am using WhatsApp Clone.');
  File? _pickedImage;
  String _photoUrl = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _nameController.text = user?.displayName ?? '';
    _photoUrl = user?.photoURL ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }
    setState(() => _saving = true);
    final user = _auth.currentUser!;
    String photoUrl = _photoUrl;
    if (_pickedImage != null) {
      photoUrl = await _storage.uploadProfilePhoto(user.uid, _pickedImage!);
    }
    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      photoUrl: photoUrl,
      about: _aboutController.text.trim(),
      lastSeen: DateTime.now(),
    );
    await _auth.saveUser(userModel);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text('Set Up Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: AppTheme.primaryLight,
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : (_photoUrl.isNotEmpty
                                  ? NetworkImage(_photoUrl) as ImageProvider
                                  : null),
                          child: _pickedImage == null && _photoUrl.isEmpty
                              ? const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 30)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Your name',
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
                          onPressed: _saving ? null : _saveProfile,
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Save & Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
