import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../shared/loading_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanım şartlarını kabul etmelisiniz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authViewModel.registerWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    if (success && mounted) {
      // Başarılı kayıt, ana sayfaya yönlendir
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarılı, hoş geldiniz!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted) {
      // Hata mesajını göster (ViewModel'deki hata mesajı)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Kayıt başarısız'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _registerWithGoogle() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authViewModel.signInWithGoogle();

    if (success && mounted) {
      // Başarılı giriş, ana sayfaya yönlendir
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted) {
      // Hata mesajını göster (ViewModel'deki hata mesajı)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'Google ile kayıt başarısız'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        backgroundColor: Constants.bgColor,
        elevation: 0,
      ),
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
                      // Logo
                      Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                      ),
                      const SizedBox(height: 24),

                      // Başlık
                      const Text(
                        'Yeni Hesap Oluştur',
                        style: Constants.subheadingStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Alt başlık
                      const Text(
                        'Kürt kültürel mirasına erişim için hesap oluşturun',
                        style: Constants.captionStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Kayıt formu
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Ad alanı
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Ad Soyad',
                                hintText: 'Tam adınızı girin',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen adınızı girin';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

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

                            // Şifre onay alanı
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Şifre Onayı',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: _toggleConfirmPasswordVisibility,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: _obscureConfirmPassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen şifrenizi tekrar girin';
                                }
                                if (value != _passwordController.text) {
                                  return 'Şifreler eşleşmiyor';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Kullanım şartları onayı
                            Row(
                              children: [
                                Checkbox(
                                  value: _acceptTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptTerms = value ?? false;
                                    });
                                  },
                                  activeColor: Constants.primaryColor,
                                ),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      text: 'Kabul ediyorum ',
                                      style: TextStyle(color: Constants.textColor),
                                      children: [
                                        TextSpan(
                                          text: 'Kullanım Şartları',
                                          style: TextStyle(
                                            color: Constants.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' ve ',
                                        ),
                                        TextSpan(
                                          text: 'Gizlilik Politikası',
                                          style: TextStyle(
                                            color: Constants.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Kayıt butonu
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: authViewModel.isLoading ? null : _register,
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
                                  'Hesap Oluştur',
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

                            // Google ile kayıt butonu
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: authViewModel.isLoading ? null : _registerWithGoogle,
                                icon: Image.asset(
                                  'assets/images/google_logo.png',
                                  height: 24,
                                ),
                                label: const Text('Google ile Kayıt Ol'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Constants.darkGrey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Constants.defaultRadius),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Giriş sayfasına yönlendirme
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Zaten hesabınız var mı?',
                                  style: Constants.captionStyle,
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Giriş sayfasına geri dön
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Giriş Yap',
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