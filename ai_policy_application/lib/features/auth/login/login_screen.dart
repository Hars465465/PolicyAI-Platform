import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../otp/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    await context.read<AuthProvider>().loginWithPhone(phone);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OtpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Icon(
                Icons.how_to_vote_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Login with mobile number',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your phone number to participate in national policy decisions.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixText: '+91 ',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter phone number';
                        }
                        if (value.trim().length != 10) {
                          return 'Enter 10-digit number';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                          return 'Digits only';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: size.width,
                      child: ElevatedButton(
                        onPressed: _onContinue,
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  AppConstants.appTagline,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
