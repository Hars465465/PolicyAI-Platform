import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/splash/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/vote_provider.dart';
import 'providers/policy_provider.dart';  // Add this
import 'data/services/api_service.dart';  // Add this


class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize API service (NEW)
  await ApiService().init();

  // Initialize providers with storage
  final authProvider = AuthProvider();
  await authProvider.loadFromStorage();

  final voteProvider = VoteProvider();
  await voteProvider.loadFromStorage();

  final policyProvider = PolicyProvider();  // Add this

  runApp(MyApp(
    authProvider: authProvider,
    voteProvider: voteProvider,
    policyProvider: policyProvider,  // Add this
  ));
}


class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  final VoteProvider voteProvider;
  final PolicyProvider policyProvider;  // Add this

  const MyApp({
    super.key,
    required this.authProvider,
    required this.voteProvider,
    required this.policyProvider,  // Add this
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<VoteProvider>.value(value: voteProvider),
        ChangeNotifierProvider<PolicyProvider>.value(value: policyProvider),  // Add this
      ],
      child: MaterialApp(
        title: 'AI Policy Platform',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
