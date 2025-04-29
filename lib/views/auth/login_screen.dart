// lib/views/auth/login_screen.dart
// Giriş yapma ekranı
// Kullanıcının e-posta ve şifre ile giriş yapmasını sağlar

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ViewModels
import '../../viewmodels/auth_viewmodel.dart';

// Utils
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/extensions.dart';

// Çoklu dil desteği
import '../../generated/l10n.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form anahtarı - Form doğrulama için
  final _formKey = GlobalKey<FormState>();

  // Text controller'lar - Form değerlerini almak için
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Şifre görünürlüğü
  bool _obscurePassword = true;

  // Yükleniyor durumu
  bool _isLoading = false;

  @override
  void dispose() {
    // Controller'ları temizle
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // E-posta ve şifre ile giriş yapma
  Future<void> _login() async {
    // Klavyeyi kapat
    context.hideKeyboard();

    // Form doğrulama
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // AuthViewModel üzerinden giriş işlemi
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Ana sayfaya yönlendir
      Navigator.of(context).pushReplacementNamed('/home');

    } catch (e) {
      // Hata mesajı göster
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Google ile giriş yapma
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // AuthViewModel üzerinden Google ile giriş işlemi
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.signInWithGoogle();

      if (!mounted) return;

      // Ana sayfaya yönlendir
      Navigator.of(context).pushReplacementNamed('/home');

    } catch (e) {
      // Hata mesajı göster
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo ve başlık
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 80,
                            height: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nûbar',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            S.of(context).appDescription,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // E-posta giriş alanı
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => validateEmail(value),
                      decoration: InputDecoration(
                        labelText: S.of(context).email,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

                    // Şifre giriş alanı
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: (value) => validatePassword(value),
                      decoration: InputDecoration(
                        labelText: S.of(context).password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                    ),

                    const SizedBox(height: 8),

                    // Şifremi unuttum bağlantısı
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Şifre sıfırlama ekranına yönlendir
                          // TODO: Şifre sıfırlama ekranını ekle
                        },
                        child: Text(S.of(context).forgotPassword),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Giriş yap butonu
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(S.of(context).login),
                    ),

                    const SizedBox(height: 16),

                    // Veya ayırıcı
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            S.of(context).or,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Google ile giriş yap butonu
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: Image.asset(
                        'assets/images/google_logo.png',
                        height: 24,
                      ),
                      label: Text(
                        S.of(context).loginWith.replaceAll('{provider}', 'Google'),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Kayıt ol bağlantısı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.of(context).dontHaveAccount,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () {
                            // Kayıt olma ekranına yönlendir
                            Navigator.of(context).pushNamed('/register');
                          },
                          child: Text(S.of(context).signup),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}