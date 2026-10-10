import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginMethod { email, phone }

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  _LoginMethod _method = _LoginMethod.email;
  bool _loading = false;
  String? _verificationId;
  String _dialCode = '+92';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _signInOrSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showError('Enter email and password');
      return;
    }
    setState(() => _loading = true);
    try {
      try {
        await _auth.signInWithEmail(email, password);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          await _auth.signUpWithEmail(email, password);
        } else {
          rethrow;
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendOtp() async {
    final phone = '$_dialCode${_phoneController.text.trim()}';
    if (_phoneController.text.trim().isEmpty) {
      _showError('Enter your phone number');
      return;
    }
    setState(() => _loading = true);
    await _auth.startPhoneVerification(
      phoneNumber: phone,
      onCodeSent: (verificationId, _) {
        setState(() {
          _verificationId = verificationId;
          _loading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent to your phone')),
          );
        }
      },
      onFailed: (e) {
        setState(() => _loading = false);
        _showError(e.message ?? 'Phone verification failed');
      },
      onAutoVerify: (_) {},
      onAutoVerifyComplete: (_) {},
    );
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null || _otpController.text.trim().isEmpty) {
      _showError('Enter the OTP');
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.verifyOtp(_verificationId!, _otpController.text.trim());
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.chat, size: 64, color: Colors.white),
            const SizedBox(height: 12),
            const Text('WhatsApp Clone',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Sign in to start chatting',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            // Method toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _toggleChip('Email', _method == _LoginMethod.email, () {
                    setState(() => _method = _LoginMethod.email);
                  }),
                  const SizedBox(width: 10),
                  _toggleChip('Phone OTP', _method == _LoginMethod.phone, () {
                    setState(() => _method = _LoginMethod.phone);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: _loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppTheme.primary))
                    : _method == _LoginMethod.email
                        ? _emailForm()
                        : _phoneForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? AppTheme.primary : Colors.white,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _emailForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _input(_emailController, 'Email', Icons.email),
        const SizedBox(height: 14),
        _input(_passwordController, 'Password', Icons.lock,
            obscure: true),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: _signInOrSignUp,
            child: const Text('Login / Sign Up'),
          ),
        ),
        const SizedBox(height: 16),
        const Row(children: [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('OR',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(child: Divider()),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: Image.asset('assets/google_logo.png',
                width: 22, height: 22, errorBuilder: (_, __, ___) =>
                    const Icon(Icons.login, color: AppTheme.primary)),
            label: const Text('Continue with Google',
                style: TextStyle(color: AppTheme.primary)),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryLight),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: _signInWithGoogle,
          ),
        ),
      ],
    );
  }

  Widget _phoneForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('+92',
                  style: TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _input(_phoneController, '3XX XXXXXXX',
                  Icons.phone, keyboard: TextInputType.phone),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_verificationId != null) ...[
          _input(_otpController, '6-digit OTP', Icons.password,
              keyboard: TextInputType.number),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: _verifyOtp,
              child: const Text('Verify OTP'),
            ),
          ),
        ] else
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: _sendOtp,
              child: const Text('Send OTP'),
            ),
          ),
        const SizedBox(height: 16),
        const Text('After OTP verification you will set up your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _input(TextEditingController controller, String hint, IconData icon,
      {bool obscure = false, TextInputType? keyboard}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryLight),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }
}
