import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../shared/loading_indicator.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authViewModel.signInWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      // Başarılı giriş, ana sayfaya yönlendir
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted) {
      // Hata mesajını göster (ViewModel'deki hata mesajı)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Giriş başarısız'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authViewModel.signInWithGoogle();

    if (success && mounted) {
      // Başarılı giriş, ana sayfaya yönlendir
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted) {
      // Hata mesajını göster (ViewModel'deki hata mesajı)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Google ile giriş başarısız'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(Constants.defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 64),

                      // Logo
                      Image.asset(
                        'assets/images/logo.png',
                        height: 120,
                      ),
                      const SizedBox(height: 32),

                      // Başlık
                      const Text(
                        'Nûbar\'a Hoş Geldiniz',
                        style: Constants.headingStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Alt başlık
                      const Text(
                        'Kürt kültürüne erişim için giriş yapın',
                        style: Constants.captionStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Giriş formu
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // E-posta alanı
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'E-posta',
                                hintText: 'ornek@mail.com',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen e-posta adresinizi girin';
                                }
                                if (!value.contains('@') || !value.contains('.')) {
                                  return 'Geçerli bir e-posta adresi girin';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Şifre alanı
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Şifre',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen şifrenizi girin';
                                }
                                if (value.length < 6) {
                                  return 'Şifre en az 6 karakter olmalıdır';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Beni hatırla ve Şifremi unuttum
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: Constants.primaryColor,
                                    ),
                                    const Text('Beni hatırla'),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Şifre sıfırlama sayfasına yönlendir
                                    // TODO: Implement password reset screen
                                  },
                                  child: const Text(
                                    'Şifremi unuttum',
                                    style: TextStyle(
                                      color: Constants.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Giriş butonu
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: authViewModel.isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Constants.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Constants.defaultRadius),
                                  ),
                                ),
                                child: authViewModel.isLoading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // veya çizgisi
                            const Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Constants.subtextColor,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    'veya',
                                    style: Constants.captionStyle,
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Constants.subtextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Google ile giriş butonu
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: authViewModel.isLoading ? null : _loginWithGoogle,
                                icon: Image.asset(
                                  'assets/images/google_logo.png',
                                  height: 24,
                                ),
                                label: const Text('Google ile Giriş Yap'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Constants.darkGrey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Constants.defaultRadius),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Kayıt ol yönlendirmesi
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Hesabınız yok mu?',
                                  style: Constants.captionStyle,
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Kayıt sayfasına yönlendir
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Kayıt Ol',
                                    style: TextStyle(
                                      color: Constants.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tam ekran yükleniyor göstergesi
              if (authViewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: LoadingIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}