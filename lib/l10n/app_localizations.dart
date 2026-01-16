import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Home Screen
  String get homeTitle => _localizedValues[locale.languageCode]!['homeTitle']!;
  String get startReading => _localizedValues[locale.languageCode]!['startReading']!;
  String get continueReading => _localizedValues[locale.languageCode]!['continueReading']!;
  String get lastRead => _localizedValues[locale.languageCode]!['lastRead']!;
  String get page => _localizedValues[locale.languageCode]!['page']!;
  String get statistics => _localizedValues[locale.languageCode]!['statistics']!;
  String get totalPages => _localizedValues[locale.languageCode]!['totalPages']!;
  String get readPages => _localizedValues[locale.languageCode]!['readPages']!;
  String get remainingPages => _localizedValues[locale.languageCode]!['remainingPages']!;
  String get noHatimFound => _localizedValues[locale.languageCode]!['noHatimFound']!;
  String get createHatim => _localizedValues[locale.languageCode]!['createHatim']!;

  // Reading Screen
  String get readingTitle => _localizedValues[locale.languageCode]!['readingTitle']!;
  String get markAsRead => _localizedValues[locale.languageCode]!['markAsRead']!;
  String get fullScreenMode => _localizedValues[locale.languageCode]!['fullScreenMode']!;
  String get previous => _localizedValues[locale.languageCode]!['previous']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get fontSize => _localizedValues[locale.languageCode]!['fontSize']!;
  String get pageMarkedAsRead => _localizedValues[locale.languageCode]!['pageMarkedAsRead']!;
  String get markRemoved => _localizedValues[locale.languageCode]!['markRemoved']!;

  // Insights Screen
  String get insightsTitle => _localizedValues[locale.languageCode]!['insightsTitle']!;
  String get dailyStreak => _localizedValues[locale.languageCode]!['dailyStreak']!;
  String get days => _localizedValues[locale.languageCode]!['days']!;
  String get total => _localizedValues[locale.languageCode]!['total']!;
  String get thisMonth => _localizedValues[locale.languageCode]!['thisMonth']!;
  String get last30Days => _localizedValues[locale.languageCode]!['last30Days']!;

  // Settings Screen
  String get settingsTitle => _localizedValues[locale.languageCode]!['settingsTitle']!;
  String get hatimManagement => _localizedValues[locale.languageCode]!['hatimManagement']!;
  String get createNewHatim => _localizedValues[locale.languageCode]!['createNewHatim']!;
  String get hatimName => _localizedValues[locale.languageCode]!['hatimName']!;
  String get create => _localizedValues[locale.languageCode]!['create']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get completed => _localizedValues[locale.languageCode]!['completed']!;
  String get deleteHatim => _localizedValues[locale.languageCode]!['deleteHatim']!;
  String get deleteHatimConfirm => _localizedValues[locale.languageCode]!['deleteHatimConfirm']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get readingSettings => _localizedValues[locale.languageCode]!['readingSettings']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get dailyReminder => _localizedValues[locale.languageCode]!['dailyReminder']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get languageSelection => _localizedValues[locale.languageCode]!['languageSelection']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get turkish => _localizedValues[locale.languageCode]!['turkish']!;
  String get arabic => _localizedValues[locale.languageCode]!['arabic']!;

  // Authentication
  String get signInWithGoogle => _localizedValues[locale.languageCode]!['signInWithGoogle']!;
  String get signInAnonymously => _localizedValues[locale.languageCode]!['signInAnonymously']!;
  String get signOut => _localizedValues[locale.languageCode]!['signOut']!;
  String get signIn => _localizedValues[locale.languageCode]!['signIn']!;
  String get signUp => _localizedValues[locale.languageCode]!['signUp']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get displayName => _localizedValues[locale.languageCode]!['displayName']!;
  String get emailRequired => _localizedValues[locale.languageCode]!['emailRequired']!;
  String get emailInvalid => _localizedValues[locale.languageCode]!['emailInvalid']!;
  String get passwordRequired => _localizedValues[locale.languageCode]!['passwordRequired']!;
  String get passwordTooShort => _localizedValues[locale.languageCode]!['passwordTooShort']!;
  String get displayNameRequired => _localizedValues[locale.languageCode]!['displayNameRequired']!;
  String get dontHaveAccount => _localizedValues[locale.languageCode]!['dontHaveAccount']!;
  String get alreadyHaveAccount => _localizedValues[locale.languageCode]!['alreadyHaveAccount']!;
  String get sync => _localizedValues[locale.languageCode]!['sync']!;
  String get syncing => _localizedValues[locale.languageCode]!['syncing']!;
  String get syncComplete => _localizedValues[locale.languageCode]!['syncComplete']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get community => _localizedValues[locale.languageCode]!['community']!;
  String get communityHatim => _localizedValues[locale.languageCode]!['communityHatim']!;
  String get notSignedIn => _localizedValues[locale.languageCode]!['notSignedIn']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get finishJuz => _localizedValues[locale.languageCode]!['finishJuz']!;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'homeTitle': 'Hatim Tracker',
    'startReading': 'Start Reading',
    'continueReading': 'Continue Reading',
    'lastRead': 'Last Read',
    'page': 'Page',
      'statistics': 'Statistics',
      'totalPages': 'Total Pages',
      'readPages': 'Read Pages',
      'remainingPages': 'Remaining Pages',
      'noHatimFound': 'No Hatim found. Create one to start!',
      'createHatim': 'Create New Hatim',
      'readingTitle': 'Reading',
      'markAsRead': 'Mark as Read',
      'fullScreenMode': 'Full Screen Mode',
      'previous': 'Previous',
      'next': 'Next',
      'fontSize': 'Font Size',
      'pageMarkedAsRead': 'Page marked as read',
      'markRemoved': 'Mark removed',
      'insightsTitle': 'Insights',
      'dailyStreak': 'Daily Streak',
      'days': 'days',
      'total': 'Total',
      'thisMonth': 'This Month',
      'last30Days': 'Last 30 Days',
      'settingsTitle': 'Settings',
      'hatimManagement': 'Hatim Management',
      'createNewHatim': 'Create New Hatim',
      'hatimName': 'Hatim Name',
      'create': 'Create',
      'cancel': 'Cancel',
      'completed': 'completed',
      'deleteHatim': 'Delete Hatim',
      'deleteHatimConfirm': 'Are you sure you want to delete this hatim?',
      'delete': 'Delete',
      'readingSettings': 'Reading Settings',
      'notifications': 'Notifications',
      'dailyReminder': 'Daily Reminder',
      'language': 'Language',
      'languageSelection': 'Language Selection',
      'english': 'English',
      'turkish': 'Turkish',
      'arabic': 'Arabic',
      'signInWithGoogle': 'Sign in with Google',
      'signInAnonymously': 'Sign in Anonymously',
      'signOut': 'Sign Out',
      'signIn': 'Sign In',
      'signUp': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'displayName': 'Display Name',
      'emailRequired': 'Email is required',
      'emailInvalid': 'Invalid email format',
      'passwordRequired': 'Password is required',
      'passwordTooShort': 'Password must be at least 6 characters',
      'displayNameRequired': 'Display name is required',
      'dontHaveAccount': "Don't have an account? Sign Up",
      'alreadyHaveAccount': 'Already have an account? Sign In',
      'sync': 'Sync',
      'syncing': 'Syncing...',
      'syncComplete': 'Sync Complete',
      'profile': 'Profile',
      'community': 'Community',
      'communityHatim': 'Community Hatim',
      'notSignedIn': 'Not signed in',
      'loading': 'Loading...',
      'finishJuz': 'Finish Juz',
    },
    'tr': {
      'homeTitle': 'Hatim Takipçisi',
    'startReading': 'Okumaya Başla',
    'continueReading': 'Okumaya Devam Et',
    'lastRead': 'Son Okunan',
    'page': 'Sayfa',
      'statistics': 'İstatistikler',
      'totalPages': 'Toplam Sayfa',
      'readPages': 'Okunan Sayfa',
      'remainingPages': 'Kalan Sayfa',
      'noHatimFound': 'Hatim bulunamadı. Başlamak için bir tane oluşturun!',
      'createHatim': 'Yeni Hatim Oluştur',
      'readingTitle': 'Okuma',
      'markAsRead': 'Okundu Olarak İşaretle',
      'fullScreenMode': 'Tam Ekran Modu',
      'previous': 'Önceki',
      'next': 'Sonraki',
      'fontSize': 'Font Boyutu',
      'pageMarkedAsRead': 'Sayfa okundu olarak işaretlendi',
      'markRemoved': 'İşaret kaldırıldı',
      'insightsTitle': 'İstatistikler',
      'dailyStreak': 'Günlük Seri',
      'days': 'gün',
      'total': 'Toplam',
      'thisMonth': 'Bu Ay',
      'last30Days': 'Son 30 Gün',
      'settingsTitle': 'Ayarlar',
      'hatimManagement': 'Hatim Yönetimi',
      'createNewHatim': 'Yeni Hatim Oluştur',
      'hatimName': 'Hatim Adı',
      'create': 'Oluştur',
      'cancel': 'İptal',
      'completed': 'tamamlandı',
      'deleteHatim': 'Hatim Sil',
      'deleteHatimConfirm': 'Bu hatimi silmek istediğinize emin misiniz?',
      'delete': 'Sil',
      'readingSettings': 'Okuma Ayarları',
      'notifications': 'Bildirimler',
      'dailyReminder': 'Günlük Hatırlatıcı',
      'language': 'Dil',
      'languageSelection': 'Dil Seçimi',
      'english': 'İngilizce',
      'turkish': 'Türkçe',
      'arabic': 'Arapça',
      'signInWithGoogle': 'Google ile Giriş Yap',
      'signInAnonymously': 'Anonim Giriş Yap',
      'signOut': 'Çıkış Yap',
      'signIn': 'Giriş Yap',
      'signUp': 'Kayıt Ol',
      'email': 'E-posta',
      'password': 'Şifre',
      'displayName': 'Görünen Ad',
      'emailRequired': 'E-posta gereklidir',
      'emailInvalid': 'Geçersiz e-posta formatı',
      'passwordRequired': 'Şifre gereklidir',
      'passwordTooShort': 'Şifre en az 6 karakter olmalıdır',
      'displayNameRequired': 'Görünen ad gereklidir',
      'dontHaveAccount': 'Hesabınız yok mu? Kayıt Ol',
      'alreadyHaveAccount': 'Zaten hesabınız var mı? Giriş Yap',
      'sync': 'Senkronize Et',
      'syncing': 'Senkronize ediliyor...',
      'syncComplete': 'Senkronizasyon Tamamlandı',
      'profile': 'Profil',
      'community': 'Topluluk',
      'communityHatim': 'Topluluk Hatimi',
      'notSignedIn': 'Giriş yapılmadı',
      'loading': 'Yükleniyor...',
      'finishJuz': 'Cüzü Bitir',
    },
    'ar': {
      'homeTitle': 'متتبع الختم',
    'startReading': 'ابدأ القراءة',
    'continueReading': 'تابع القراءة',
    'lastRead': 'آخر قراءة',
    'page': 'صفحة',
      'statistics': 'الإحصائيات',
      'totalPages': 'إجمالي الصفحات',
      'readPages': 'الصفحات المقروءة',
      'remainingPages': 'الصفحات المتبقية',
      'noHatimFound': 'لم يتم العثور على ختم. أنشئ واحدًا للبدء!',
      'createHatim': 'إنشاء ختم جديد',
      'readingTitle': 'القراءة',
      'markAsRead': 'وضع علامة كمقروء',
      'fullScreenMode': 'وضع ملء الشاشة',
      'previous': 'السابق',
      'next': 'التالي',
      'fontSize': 'حجم الخط',
      'pageMarkedAsRead': 'تم وضع علامة على الصفحة كمقروءة',
      'markRemoved': 'تمت إزالة العلامة',
      'insightsTitle': 'الإحصائيات',
      'dailyStreak': 'السلسلة اليومية',
      'days': 'أيام',
      'total': 'الإجمالي',
      'thisMonth': 'هذا الشهر',
      'last30Days': 'آخر 30 يوم',
      'settingsTitle': 'الإعدادات',
      'hatimManagement': 'إدارة الختم',
      'createNewHatim': 'إنشاء ختم جديد',
      'hatimName': 'اسم الختم',
      'create': 'إنشاء',
      'cancel': 'إلغاء',
      'completed': 'مكتمل',
      'deleteHatim': 'حذف الختم',
      'deleteHatimConfirm': 'هل أنت متأكد من حذف هذا الختم؟',
      'delete': 'حذف',
      'readingSettings': 'إعدادات القراءة',
      'notifications': 'الإشعارات',
      'dailyReminder': 'تذكير يومي',
      'language': 'اللغة',
      'languageSelection': 'اختيار اللغة',
      'english': 'الإنجليزية',
      'turkish': 'التركية',
      'arabic': 'العربية',
      'signInWithGoogle': 'تسجيل الدخول باستخدام Google',
      'signInAnonymously': 'تسجيل الدخول كمجهول',
      'signOut': 'تسجيل الخروج',
      'signIn': 'تسجيل الدخول',
      'signUp': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'displayName': 'الاسم المعروض',
      'emailRequired': 'البريد الإلكتروني مطلوب',
      'emailInvalid': 'تنسيق البريد الإلكتروني غير صحيح',
      'passwordRequired': 'كلمة المرور مطلوبة',
      'passwordTooShort': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
      'displayNameRequired': 'الاسم المعروض مطلوب',
      'dontHaveAccount': 'ليس لديك حساب؟ إنشاء حساب',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟ تسجيل الدخول',
      'sync': 'مزامنة',
      'syncing': 'جاري المزامنة...',
      'syncComplete': 'اكتملت المزامنة',
      'profile': 'الملف الشخصي',
      'community': 'المجتمع',
      'communityHatim': 'ختم المجتمع',
      'notSignedIn': 'لم يتم تسجيل الدخول',
      'loading': 'جاري التحميل...',
      'finishJuz': 'إنهاء الجزء',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'tr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
