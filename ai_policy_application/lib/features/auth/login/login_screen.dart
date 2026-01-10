import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/services/api_service.dart';
import '../../home/home_screen.dart';
import '../otp/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendEmailOTP() async {
  final email = _emailController.text.trim();

  if (email.isEmpty || !email.contains('@')) {
    _showError('Please enter a valid email');
    return;
  }

  setState(() => _isLoading = true);

  try {
    debugPrint('📤 Requesting OTP for: $email');
    
    final response = await _api.sendEmailOTP(email);
    
    debugPrint('📥 Response received: $response');
    
    setState(() => _isLoading = false);

    // ✅ Extract mock_otp for testing
    final mockOTP = response['mock_otp']?.toString();
    
    debugPrint('🔑 Mock OTP: $mockOTP');

    // Navigate to OTP screen
    if (mounted) {
      // ✅ Show success message with OTP (for development)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent! ${mockOTP != null ? "OTP: $mockOTP" : ""}'),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 5),
        ),
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPScreen(
            email: email,
            mockOTP: mockOTP,  // Pass OTP to screen
          ),
        ),
      );
    }
  } catch (e) {
    setState(() => _isLoading = false);
    
    debugPrint('❌ Error sending OTP: $e');
    
    _showError('Failed to send OTP: ${e.toString()}');
  }
}

void _showError(String message) {
  if (!mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 4),
    ),
  );
}


  Future<void> _signInWithGoogle() async {
  setState(() => _isLoading = true);

  try {
    // For Phase 1: Mock Google Sign-In
    // Phase 2: Use google_sign_in package
    
    final mockEmail = 'user@gmail.com';
    final mockName = 'Test User';
    final mockToken = 'mock_google_token_${DateTime.now().millisecondsSinceEpoch}';

    final response = await _api.googleSignIn(
      mockToken,
      mockEmail,
      mockName,
      null,
    );

    setState(() => _isLoading = false);

    // ✅ FIXED: Extract user data safely
    final userData = response['user'];
    final email = userData['email'] as String?;
    final name = userData['name'] as String?;
    final userId = userData['id'] as int?;
    final token = response['access_token'] as String?;

    if (email == null || name == null) {
      throw Exception('Invalid response from server');
    }

    // ✅ FIXED: Save user info with userId
    if (mounted) {
      await context.read<AuthProvider>().login(
        email: email,
        name: name,
        token: token,
        userId: userId,  // ✅ Added userId
      );
    }

    // Navigate to home
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signed in with Google! ✅'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  } catch (e) {
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryPurple,
                        AppTheme.secondaryBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.how_to_vote_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 28,
                    color: AppTheme.textLight,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppTheme.primaryPurple,
                      AppTheme.secondaryBlue,
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'PolicyAI',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                const Text(
                  'Your voice matters in shaping national policies',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textLight,
                  ),
                ),

                const SizedBox(height: 48),

                // Email Input
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryPurple,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Send OTP Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendEmailOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Send OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                const SizedBox(height: 32),

                // Google Sign-In Button
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: Image.asset(
                      'assets/google_logo.png', // Add Google logo
                      height: 24,
                      width: 24,
                      errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 32),
                    ),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Info Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'We\'ll send you a one-time password to verify your email',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
