// lib/l10n/messages_all.dart
// Çoklu dil desteği için oluşturulan mesaj dosyası
// Bu dosya normalde Flutter gen-l10n komutu tarafından otomatik oluşturulur
// Şu an için temel fonksiyonlar manuel olarak eklenmiştir

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_ku.dart' deferred as messages_ku;
import 'messages_tr.dart' deferred as messages_tr;
import 'messages_en.dart' deferred as messages_en;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'ku': () => messages_ku.loadLibrary(),
  'tr': () => messages_tr.loadLibrary(),
  'en': () => messages_en.loadLibrary(),
};

MessageLookupByLibrary? _findExact(String localeName) {
  switch (localeName) {
    case 'ku':
      return messages_ku.messages;
    case 'tr':
      return messages_tr.messages;
    case 'en':
      return messages_en.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) async {
  await Intl.initializeInternationalization();
  var lib = _deferredLibraries[localeName];
  await (lib == null ? Future.value(false) : lib());
  initializeInternalMessageLookup(() => CompositeMessageLookup());
  MessageLookupByLibrary? messageLookup = _findExact(localeName);
  bool didInitialize = false;
  if (messageLookup != null) {
    messageLookup.addLocale(localeName, _findGeneratedMessagesFor);
    didInitialize = true;
  }
  return didInitialize;
}

MessageLookupByLibrary? _findGeneratedMessagesFor(String locale) {
  var actualLocale = Intl.verifiedLocale(locale, (locale) => _findExact(locale) != null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}

// Şimdilik basitleştirilmiş versiyonda minimal olarak implement etmek için
// Gerçek projede l10n kod üreteci tarafından oluşturulacak
class CompositeMessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'messages';

  @override
  String lookupMessage(
      String? messageName,
      int? locale,
      String? name,
      List<Object>? args,
      String? locale2,
      {MessageIfAbsent? ifAbsent}) {
    return '';
  }
}