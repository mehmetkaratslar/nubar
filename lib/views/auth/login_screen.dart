// Dosya: lib/views/auth/login_screen.dart
// Amaç: Kullanıcı giriş ekranını gösterir.
// Bağlantı: app.dart üzerinden çağrılır, AuthViewModel ile entegre çalışır.
// Not: SingleChildScrollView ile taşma sorunu çözüldü, Form ve doğrulama eklendi.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // Formun TextEditingController'larını tanımlıyoruz
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Animasyon için controller tanımlıyoruz
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animasyon controller'ını başlatıyoruz
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Biraz daha uzun süren animasyon
    );

    // Fade efekti için animasyon tanımlıyoruz
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );

    // Animasyonu başlatıyoruz
    _animationController.forward();
  }

  @override
  void dispose() {
    // Controller'ları dispose ediyoruz
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Giriş işlemini gerçekleştirir
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (authViewModel.errorMessage == null) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        if (mounted) {
          // Hata mesajını gösteriyoruz
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authViewModel.errorMessage!),
              backgroundColor: AppConstants.primaryRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  // Google ile giriş işlemini gerçekleştirir
  Future<void> _signInWithGoogle() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.signInWithGoogle();
    if (authViewModel.errorMessage == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      if (mounted) {
        // Hata mesajını gösteriyoruz
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage!),
            backgroundColor: AppConstants.primaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // Şifre sıfırlama işlemini gerçekleştirir
  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      // E-posta alanı boşsa hata mesajı gösteriyoruz
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidEmail),
          backgroundColor: AppConstants.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.resetPassword(_emailController.text.trim());
    if (authViewModel.errorMessage == null) {
      if (mounted) {
        // Başarı mesajını gösteriyoruz
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.resetPassword),
            backgroundColor: AppConstants.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      if (mounted) {
        // Hata mesajını gösteriyoruz
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage!),
            backgroundColor: AppConstants.primaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authViewModel = Provider.of<AuthViewModel>(context);
    final Size screenSize = MediaQuery.of(context).size;

    // Kürt bayrağının renklerini kullanıyoruz (kırmızı, beyaz, yeşil)
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Kürt bayrağının renklerini içeren gradient arka plan
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryRed.withOpacity(0.8), // Kırmızı rengi biraz yumuşatıyoruz
              Colors.white,
              AppConstants.primaryGreen.withOpacity(0.8), // Yeşil rengi biraz yumuşatıyoruz
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.2, 0.5, 0.8], // Gradient geçişlerini ayarlıyoruz
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // Ekran içeriğini kaydırılabilir yapıyoruz
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.08, // Ekran genişliğine göre yatay padding
              vertical: screenSize.height * 0.04, // Ekran yüksekliğine göre dikey padding
            ),
            child: FadeTransition(
              // Fade animasyonu ekliyoruz
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo bölümü
                    Container(
                      // Logo konteyneri
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        // Yuvarlak logo arka planı
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          // Logo için gölge efekti
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        // Logo içeriği
                        child: Text(
                          "NÛBAR",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryRed,
                            letterSpacing: 1.5,
                            shadows: [
                              // Metin için hafif gölge
                              Shadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30), // Boşluk ekliyoruz

                    // Başlık
                    Text(
                      l10n.login,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryRed,
                        shadows: [
                          // Metin için gölge efekti
                          Shadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 5,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30), // Boşluk ekliyoruz

                    // E-posta alanı
                    TextFormField(
                      controller: _emailController,
                      // Dekorasyon ayarlarını yapıyoruz
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        hintText: "name@example.com", // Örnek e-posta formatı
                        prefixIcon: Icon(Icons.email, color: AppConstants.primaryRed), // E-posta ikonu
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15), // Daha yuvarlak köşeler
                          borderSide: BorderSide(color: AppConstants.primaryRed),
                        ),
                        focusedBorder: OutlineInputBorder( // Odaklandığında kenarlık rengini değiştiriyoruz
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: AppConstants.primaryRed, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9), // Hafif transparan beyaz
                      ),
                      keyboardType: TextInputType.emailAddress, // E-posta klavyesi
                      // Doğrulama kurallarını ekliyoruz
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.requiredField;
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return l10n.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20), // Boşluk ekliyoruz

                    // Şifre alanı
                    TextFormField(
                      controller: _passwordController,
                      // Dekorasyon ayarlarını yapıyoruz
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        hintText: "••••••", // Şifre hint gösterimi
                        prefixIcon: Icon(Icons.lock, color: AppConstants.primaryRed), // Kilit ikonu
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15), // Daha yuvarlak köşeler
                          borderSide: BorderSide(color: AppConstants.primaryRed),
                        ),
                        focusedBorder: OutlineInputBorder( // Odaklandığında kenarlık rengini değiştiriyoruz
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: AppConstants.primaryRed, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9), // Hafif transparan beyaz
                      ),
                      obscureText: true, // Şifre gizleme
                      // Doğrulama kurallarını ekliyoruz
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.requiredField;
                        }
                        if (value.length < 6) {
                          return l10n.weakPassword;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10), // Boşluk ekliyoruz

                    // Şifremi unuttum bağlantısı - sağa yasladık
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _resetPassword,
                        // Şifremi unuttum butonu stili
                        style: TextButton.styleFrom(
                          foregroundColor: AppConstants.primaryRed,
                        ),
                        child: Text(
                          l10n.forgotPassword,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Boşluk ekliyoruz

                    // Giriş butonu
                    SizedBox(
                      // Buton için boyut belirliyoruz
                      width: double.infinity,
                      height: 55,
                      child: authViewModel.isLoading
                          ? Center(
                        // Yükleme göstergesi
                        child: CircularProgressIndicator(
                          color: AppConstants.primaryRed,
                          strokeWidth: 3,
                        ),
                      )
                          : ElevatedButton(
                        onPressed: _login,
                        // Buton stilini ayarlıyoruz
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 5, // Gölge miktarı
                          shadowColor: AppConstants.primaryGreen.withOpacity(0.5), // Gölge rengi
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Daha yuvarlak köşeler
                          ),
                        ),
                        child: Text(
                          l10n.login,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2, // Harfler arası boşluk
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Boşluk ekliyoruz

                    // Ayırıcı çizgi ve metin
                    Row(
                      // Ayırıcı satır oluşturuyoruz
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.withOpacity(0.5),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.ok,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.withOpacity(0.5),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20), // Boşluk ekliyoruz

                    // Google ile giriş butonu
                    SizedBox(
                      // Buton için boyut belirliyoruz
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        // Google buton stilini ayarlıyoruz
                        icon: const Icon(Icons.g_mobiledata, size: 30), // Google ikonu
                        label: Text(
                          l10n.loginWith('Google'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryRed,
                          foregroundColor: Colors.white,
                          elevation: 5, // Gölge miktarı
                          shadowColor: AppConstants.primaryRed.withOpacity(0.5), // Gölge rengi
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Daha yuvarlak köşeler
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30), // Boşluk ekliyoruz

                    // Kayıt ol bağlantısı
                    Row(
                      // Hesap oluşturma satırı
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${l10n.dontHaveAccount} ",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/register');
                          },
                          // Kayıt ol butonu stili
                          style: TextButton.styleFrom(
                            foregroundColor: AppConstants.primaryRed,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          child: Text(l10n.signup),
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