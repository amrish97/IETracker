import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final String? savedToken = await AuthService.getToken();
  runApp(MyApp(savedToken: savedToken));
}

class MyApp extends StatelessWidget {
  final String? savedToken;

  const MyApp({super.key, this.savedToken});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: MaterialApp(
        title: 'Expense & Income App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: savedToken != null && savedToken!.isNotEmpty
            ? HomeScreen(token: savedToken!)
            : const LoginScreen(),
      ),
    );
  }
}
