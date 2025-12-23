import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../home/home_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _onVerify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    final otp = _otpController.text.trim();
    await context.read<AuthProvider>().verifyOtp(otp);

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    // Since verifyOtp doesn't return bool, check isLoggedIn instead
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
    
    if (isLoggedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _error = 'Invalid OTP. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = context.watch<AuthProvider>().phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter verification code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'We have sent a 6-digit code to +91 $phone.\nFor now, any 6-digit code will work in this prototype.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: '6-digit code',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the code';
                    }
                    if (value.trim().length != 6) {
                      return 'Code must be 6 digits';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                      return 'Digits only';
                    }
                    return null;
                  },
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _onVerify,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify & Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
