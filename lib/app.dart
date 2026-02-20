import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_settings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/buy_screen.dart';
import 'screens/thank_you_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/addresses_screen.dart';
import 'screens/toc_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    return MaterialApp(
      title: 'Cloud District',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        CartScreen.routeName: (_) => const CartScreen(),
        BuyScreen.routeName: (_) => const BuyScreen(),
        ThankYouScreen.routeName: (_) => const ThankYouScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        ProfileEditScreen.routeName: (_) => const ProfileEditScreen(),
        AddressesScreen.routeName: (_) => const AddressesScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/toc') {
          return MaterialPageRoute(builder: (_) => const TocScreen());
        }
        return null;
      },
    );
  }
}
