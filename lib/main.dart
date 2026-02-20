import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/user_profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => CartProvider(prefs)),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider(prefs)),
      ],
      child: Builder(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) =>
                  UserProfileProvider(prefs, context.read<AuthProvider>()),
            ),
          ],
          child: const App(),
        ),
      ),
    ),
  );
}
