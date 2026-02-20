import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/toc_checkbox.dart';
import '../widgets/vape_shop_logo_image.dart';
import '../widgets/social_sign_in_buttons.dart';
import '../services/social_auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'toc_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _tocAccepted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_tocAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms and Conditions')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!_tocAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms and Conditions')),
      );
      return;
    }
    final result = await SocialAuthService.signInWithGoogle();
    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in was cancelled or failed')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithProvider(
      email: result.email,
      displayName: result.displayName,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    }
  }

  Future<void> _signInWithFacebook() async {
    if (!_tocAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms and Conditions')),
      );
      return;
    }
    final result = await SocialAuthService.signInWithFacebook();
    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facebook sign-in was cancelled or failed')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithProvider(
      email: result.email,
      displayName: result.displayName,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const Center(
                        child: VapeShopLogoImage(maxWidth: 220, maxHeight: 110),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _login,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Login'),
                        ),
                      ),
                      SocialSignInButtons(
                        onGooglePressed: _signInWithGoogle,
                        onFacebookPressed: _signInWithFacebook,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          RegisterScreen.routeName,
                        ),
                        child: const Text('Create an account / Register'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: TocCheckbox(
                  value: _tocAccepted,
                  onChanged: (v) => setState(() => _tocAccepted = v ?? false),
                  message: 'By logging in you agree to our',
                  onTocTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TocScreen()),
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
