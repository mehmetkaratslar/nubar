// lib/views/auth/register_screen.dart
// Kayıt olma ekranı
// Kullanıcının yeni hesap oluşturmasını sağlar

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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form anahtarı - Form doğrulama için
  final _formKey = GlobalKey<FormState>();

  // Text controller'lar - Form değerlerini almak için
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Şifre görünürlüğü
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Yükleniyor durumu
  bool _isLoading = false;

  @override
  void dispose() {
    // Controller'ları temizle
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Kayıt olma işlemi
  Future<void> _register() async {
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
      // AuthViewModel üzerinden kayıt işlemi
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
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

  // Google ile kayıt olma
  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // AuthViewModel üzerinden Google ile giriş işlemi
      // Not: Google ile kayıt, aslında Google ile giriş ile aynı - kayıt otomatik oluşur
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

                    // Kullanıcı adı giriş alanı
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.name,
                      validator: (value) => validateUsername(value),
                      decoration: InputDecoration(
                        labelText: S.of(context).username,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

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
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

                    // Şifre tekrar giriş alanı
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      validator: (value) => validatePasswordMatch(value, _passwordController.text),
                      decoration: InputDecoration(
                        labelText: S.of(context).confirmPassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _register(),
                    ),

                    const SizedBox(height: 24),

                    // Kayıt ol butonu
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(S.of(context).signup),
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

                    // Google ile kayıt ol butonu
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signUpWithGoogle,
                      icon: Image.asset(
                        'assets/images/google_logo.png',
                        height: 24,
                      ),
                      label: Text(
                        S.of(context).signupWith('Google'),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Giriş yap bağlantısı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.of(context).alreadyHaveAccount,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () {
                            // Giriş ekranına yönlendir
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                          child: Text(S.of(context).login),
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