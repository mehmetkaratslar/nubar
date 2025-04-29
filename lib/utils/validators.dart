// lib/utils/validators.dart
// Form doğrulama fonksiyonları
// Uygulama genelinde form alanlarının doğrulanması için kullanılan yardımcı fonksiyonlar

// Boş alan doğrulama
String? validateRequired(String? value, {String? message}) {
  if (value == null || value.trim().isEmpty) {
    return message ?? 'Bu alan zorunludur';
  }
  return null;
}

// E-posta doğrulama
String? validateEmail(String? value, {String? message}) {
  if (value == null || value.trim().isEmpty) {
    return message ?? 'E-posta adresi zorunludur';
  }

  // E-posta formatı doğrulama (basit regex)
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return message ?? 'Geçerli bir e-posta adresi girin';
  }

  return null;
}

// Şifre doğrulama
String? validatePassword(String? value, {String? message, int minLength = 6}) {
  if (value == null || value.trim().isEmpty) {
    return message ?? 'Şifre zorunludur';
  }

  if (value.length < minLength) {
    return message ?? 'Şifre en az $minLength karakter olmalıdır';
  }

  return null;
}

// Şifre eşleşme doğrulama
String? validatePasswordMatch(String? value, String? passwordToMatch, {String? message}) {
  if (value == null || value.trim().isEmpty) {
    return message ?? 'Şifre (tekrar) zorunludur';
  }

  if (value != passwordToMatch) {
    return message ?? 'Şifreler eşleşmiyor';
  }

  return null;
}

// Kullanıcı adı doğrulama
String? validateUsername(String? value, {String? message, int minLength = 3}) {
  if (value == null || value.trim().isEmpty) {
    return message ?? 'Kullanıcı adı zorunludur';
  }

  if (value.length < minLength) {
    return message ?? 'Kullanıcı adı en az $minLength karakter olmalıdır';
  }

  // Geçersiz karakterleri kontrol et (sadece harf, rakam, nokta, alt çizgi ve tire)
  final validCharactersRegex = RegExp(r'^[a-zA-Z0-9._-]+$');
  if (!validCharactersRegex.hasMatch(value)) {
    return message ?? 'Kullanıcı adı sadece harf, rakam, nokta, alt çizgi ve tire içerebilir';
  }

  return null;
}

// URL doğrulama
String? validateUrl(String? value, {String? message, bool required = false}) {
  if (value == null || value.trim().isEmpty) {
    return required ? (message ?? 'URL zorunludur') : null;
  }

  // URL formatı doğrulama (basit regex)
  final urlRegex = RegExp(
      r'^(https?:\/\/)?' // http:// veya https://
      r'(?:(?:[a-zA-Z\u00a1-\uffff0-9]+-?)*[a-zA-Z\u00a1-\uffff0-9]+)' // alan adı
      r'(?:\.(?:[a-zA-Z\u00a1-\uffff0-9]+-?)*[a-zA-Z\u00a1-\uffff0-9]+)*' // alt alan adı
      r'(?:\.(?:[a-zA-Z\u00a1-\uffff]{2,}))' // üst seviye alan adı
      r'(?::\d{2,5})?' // port
      r'(?:\/[^\s]*)?$' // yol
  );

  if (!urlRegex.hasMatch(value)) {
    return message ?? 'Geçerli bir URL girin';
  }

  return null;
}

// Sayı doğrulama
String? validateNumber(String? value, {String? message, bool required = false}) {
  if (value == null || value.trim().isEmpty) {
    return required ? (message ?? 'Bu alan zorunludur') : null;
  }

  // Sayı formatı doğrulama
  if (double.tryParse(value) == null) {
    return message ?? 'Geçerli bir sayı girin';
  }

  return null;
}

// Minimum uzunluk doğrulama
String? validateMinLength(String? value, int minLength, {String? message, bool required = false}) {
  if (value == null || value.trim().isEmpty) {
    return required ? (message ?? 'Bu alan zorunludur') : null;
  }

  if (value.length < minLength) {
    return message ?? 'En az $minLength karakter olmalıdır';
  }

  return null;
}

// Maksimum uzunluk doğrulama
String? validateMaxLength(String? value, int maxLength, {String? message, bool required = false}) {
  if (value == null || value.trim().isEmpty) {
    return required ? (message ?? 'Bu alan zorunludur') : null;
  }

  if (value.length > maxLength) {
    return message ?? 'En fazla $maxLength karakter olmalıdır';
  }

  return null;
}

// Belirli bir değer aralığında doğrulama
String? validateRange(String? value, double min, double max, {String? message, bool required = false}) {
  if (value == null || value.trim().isEmpty) {
    return required ? (message ?? 'Bu alan zorunludur') : null;
  }

  final number = double.tryParse(value);
  if (number == null) {
    return message ?? 'Geçerli bir sayı girin';
  }

  if (number < min || number > max) {
    return message ?? '$min ile $max arasında bir değer girin';
  }

  return null;
}

// Telefon numarası doğrulama (basit)
String? validatePhone(String? value, {String? message, bool required = false}) {
  if (value == null || value.trim().isEmpty) {
    return required ? (message ?? 'Telefon numarası zorunludur') : null;
  }

  // Sadece rakam olup olmadığını kontrol et (ülkelere göre daha spesifik regex kullanılabilir)
  final validCharactersRegex = RegExp(r'^[0-9+ ()-]+$');
  if (!validCharactersRegex.hasMatch(value)) {
    return message ?? 'Geçerli bir telefon numarası girin';
  }

  // En az 10 karakter olup olmadığını kontrol et
  if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
    return message ?? 'Telefon numarası en az 10 hane olmalıdır';
  }

  return null;
}

// Dosya boyutu doğrulama
String? validateFileSize(int? fileSizeInBytes, int maxSizeInBytes, {String? message}) {
  if (fileSizeInBytes == null) {
    return null; // Dosya yoksa doğrulama yapma
  }

  if (fileSizeInBytes > maxSizeInBytes) {
    final maxSizeInMB = maxSizeInBytes / (1024 * 1024);
    return message ?? 'Dosya boyutu en fazla ${maxSizeInMB.toStringAsFixed(1)} MB olmalıdır';
  }

  return null;
}

// Dosya türü doğrulama
String? validateFileType(String? fileExtension, List<String> allowedExtensions, {String? message}) {
  if (fileExtension == null || fileExtension.isEmpty) {
    return null; // Dosya yoksa doğrulama yapma
  }

  // Uzantıyı küçük harfe çevir ve başındaki noktayı kaldır
  final normalizedExtension = fileExtension.toLowerCase().replaceAll(RegExp(r'^\.'), '');

  // İzin verilen uzantılar listesini küçük harfe çevir ve başındaki noktaları kaldır
  final normalizedAllowedExtensions = allowedExtensions.map(
          (ext) => ext.toLowerCase().replaceAll(RegExp(r'^\.'), '')
  ).toList();

  if (!normalizedAllowedExtensions.contains(normalizedExtension)) {
    return message ?? 'Desteklenen dosya türleri: ${allowedExtensions.join(', ')}';
  }

  return null;
}

// İçerik başlığı doğrulama
String? validateContentTitle(String? value, {String? message}) {
  if (value == null || value.trim().isEmpty) {
    return message ?? 'Başlık zorunludur';
  }

  if (value.length < 3) {
    return message ?? 'Başlık en az 3 karakter olmalıdır';
  }

  if (value.length > 100) {
    return message ?? 'Başlık en fazla 100 karakter olmalıdır';
  }

  return null;
}

// İçerik metni doğrulama
String? validateContentText(String? value, {String? message}) {
  if (value == null || value.trim().isEmpty) {
    return message ?? 'İçerik metni zorunludur';
  }

  if (value.length < 10) {
    return message ?? 'İçerik metni en az 10 karakter olmalıdır';
  }

  return null;
}

// Çoklu dil içeriği doğrulama
String? validateMultiLanguageContent(Map<String, String>? values, String requiredLanguage, {String? message}) {
  if (values == null || values.isEmpty) {
    return message ?? 'En az bir dilde içerik girilmelidir';
  }

  // Zorunlu dilde içerik var mı kontrol et
  if (!values.containsKey(requiredLanguage) || values[requiredLanguage]!.trim().isEmpty) {
    return message ?? '$requiredLanguage dilinde içerik zorunludur';
  }

  return null;
}

// Yorum metni doğrulama
String? validateCommentText(String? value, {String? message}) {
  if (value == null || value.trim().isEmpty) {
    return message ?? 'Yorum metni zorunludur';
  }

  if (value.length < 2) {
    return message ?? 'Yorum metni en az 2 karakter olmalıdır';
  }

  if (value.length > 500) {
    return message ?? 'Yorum metni en fazla 500 karakter olmalıdır';
  }

  return null;
}

// Şikayet açıklaması doğrulama
String? validateReportDescription(String? value, {String? message}) {
  if (value == null || value.trim().isEmpty) {
    return message ?? 'Şikayet açıklaması zorunludur';
  }

  if (value.length < 10) {
    return message ?? 'Şikayet açıklaması en az 10 karakter olmalıdır';
  }

  if (value.length > 300) {
    return message ?? 'Şikayet açıklaması en fazla 300 karakter olmalıdır';
  }

  return null;
}