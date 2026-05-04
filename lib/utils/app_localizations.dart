// lib/utils/app_localizations.dart
// Localization strings for Arabic, English, French, Turkish, and German

class AppLocalizations {
  final String locale;
  const AppLocalizations(this.locale);

  static const String defaultLocale = 'ar';

  // ── General ─────────────────────────────────────────────────
  String get appTitle => _t('جهاز نور', 'Noor Device', 'Appareil Noor', 'Noor Cihazı', 'Noor Gerät');
  String get settings => _t('الإعدادات', 'Settings', 'Paramètres', 'Ayarlar', 'Einstellungen');
  String get save => _t('حفظ الإعدادات', 'Save Settings', 'Enregistrer', 'Ayarları Kaydet', 'Einstellungen speichern');
  String get saving => _t('جاري الحفظ...', 'Saving...', 'Enregistrement...', 'Kaydediliyor...', 'Speichern...');
  String get send => _t('إرسال', 'Send', 'Envoyer', 'Gönder', 'Senden');
  String get cancel => _t('إلغاء', 'Cancel', 'Annuler', 'İptal', 'Abbrechen');
  String get reboot => _t('إعادة تشغيل', 'Reboot', 'Redémarrer', 'Yeniden Başlat', 'Neustart');
  String get rebootQ => _t(
      'هل تريد إعادة تشغيل الجهاز؟',
      'Do you want to reboot the device?',
      'Voulez-vous redémarrer l\'appareil?',
      'Cihazı yeniden başlatmak istiyor musunuz?',
      'Möchten Sie das Gerät neu starten?');
  String get rebootTitle => _t('إعادة التشغيل', 'Reboot Device', 'Redémarrage', 'Yeniden Başlatma', 'Neustart');

  // ── Scan Screen ──────────────────────────────────────────────
  String get scanTitle => _t('جهاز نور', 'Noor Device', 'Appareil Noor', 'Noor Cihazı', 'Noor Gerät');
  String get scanning => _t('جاري البحث...', 'Scanning...', 'Recherche...', 'Taranıyor...', 'Suche...');
  String get searchDevice =>
      _t('ابحث عن الجهاز', 'Search for device', 'Rechercher l\'appareil', 'Cihaz Ara', 'Gerät suchen');
  String get stopScan => _t('إيقاف البحث', 'Stop Scan', 'Arrêter', 'Taramayı Durdur', 'Suche stoppen');
  String get startScan =>
      _t('بحث عن الأجهزة', 'Scan for Devices', 'Rechercher', 'Cihazları Tara', 'Geräte suchen');
  String get noDevices => _t(
      'لا توجد أجهزة قريبة\nتأكد من تشغيل البلوتوث',
      'No nearby devices\nMake sure Bluetooth is on',
      'Aucun appareil trouvé\nVérifiez le Bluetooth',
      'Yakında cihaz yok\nBluetooth\'un açık olduğundan emin olun',
      'Keine Geräte in der Nähe\nStellen Sie sicher, dass Bluetooth eingeschaltet ist');
  String get targetDevice =>
      _t('الجهاز المستهدف', 'Target Device', 'Appareil cible', 'Hedef Cihaz', 'Zielgerät');
  String get permissionError => _t(
      'يرجى منح صلاحيات البلوتوث والموقع',
      'Please grant Bluetooth and Location permissions',
      'Veuillez accorder les permissions Bluetooth et localisation',
      'Lütfen Bluetooth ve Konum izinlerini verin',
      'Bitte erteilen Sie Bluetooth- und Standortberechtigungen');

  // ── Home Screen ──────────────────────────────────────────────
  String get connected => _t('متصل', 'Connected', 'Connecté', 'Bağlı', 'Verbunden');
  String get disconnected => _t('منقطع', 'Disconnected', 'Déconnecté', 'Bağlantısız', 'Getrennt');
  String get connectionLost =>
      _t('انقطع الاتصال بالجهاز', 'Device disconnected', 'Connexion perdue', 'Cihaz bağlantısı kesildi', 'Geräteverbindung unterbrochen');
  String get volume => _t('مستوى الصوت', 'Volume', 'Volume', 'Ses Seviyesi', 'Lautstärke');
  String get deviceStatus =>
      _t('حالة الجهاز', 'Device Status', 'État de l\'appareil', 'Cihaz Durumu', 'Gerätestatus');
  String get refreshStatus =>
      _t('تحديث الحالة', 'Refresh Status', 'Actualiser', 'Durumu Yenile', 'Status aktualisieren');
  String get disconnect => _t('قطع الاتصال', 'Disconnect', 'Déconnecter', 'Bağlantıyı Kes', 'Trennen');
  String get configModeActive =>
      _t('وضع الإعداد نشط', 'Config Mode Active', 'Mode Config Actif', 'Yapılandırma Modu Aktif', 'Konfigurationsmodus aktiv');
  String get configModeEndsIn => _t('ينتهي خلال', 'Ends in', 'Se termine dans', 'Bitiş süresi', 'Endet in');
  String get configModeHint => _t(
        'فعّل وضع الإعداد بالضغط المطول على زر رفع الصوت في الجهاز',
        'Activate config mode by long-pressing the Volume Up button on the device',
        'Activez le mode config en appuyant longuement sur le bouton Volume+ de l\'appareil',
        'Cihazdaki Ses Artırma düğmesine uzun basarak yapılandırma modunu etkinleştirin',
        'Aktivieren Sie den Konfigurationsmodus durch langes Drücken der Lautstärke-Hoch-Taste am Gerät',
      );
  String get openSettings =>
      _t('فتح الإعدادات', 'Open Settings', 'Ouvrir les paramètres', 'Ayarları Aç', 'Einstellungen öffnen');
  String get requiresConfig =>
      _t('يتطلب وضع الإعداد', 'Requires config mode', 'Mode config requis', 'Yapılandırma modu gerekli', 'Konfigurationsmodus erforderlich');

  String get deviceInfo =>
      _t('معلومات الجهاز', 'Device Info', 'Infos appareil', 'Cihaz Bilgisi', 'Geräteinformationen');
  String get serial => _t('الرقم التسلسلي', 'Serial Number', 'Numéro de série', 'Seri Numarası', 'Seriennummer');
  String get serialCopied => _t('تم نسخ الرقم التسلسلي', 'Serial number copied', 'Numéro de série copié', 'Seri numarası kopyalandı', 'Seriennummer kopiert');
  String get tapToCopy => _t('اضغط للنسخ', 'Tap to copy', 'Appuyer pour copier', 'Kopyalamak için dokun', 'Zum Kopieren tippen');
  String get firmware => _t('إصدار البرنامج', 'Firmware', 'Firmware', 'Firmware', 'Firmware');
  String get loading => _t('جاري التحميل...', 'Loading...', 'Chargement...', 'Yükleniyor...', 'Laden...');

  // ── Tabs ─────────────────────────────────────────────────────
  String get tabWifi => 'WiFi';
  String get tabGsm => 'GSM';
  String get tabMqtt => 'MQTT';
  String get tabDevice => _t('الجهاز', 'Device', 'Appareil', 'Cihaz', 'Gerät');
  String get tabPlay => _t('اختبار الصوت', 'Audio Test', 'Test Audio', 'Ses Testi', 'Audiotest');

  // ── Play Test ────────────────────────────────────────────────
  String get playTestTitle => _t('اختبار تشغيل الملفات', 'File Play Test', 'Test de lecture', 'Dosya Oynatma Testi', 'Datei-Wiedergabetest');
  String get playFileNumber => _t('رقم الملف الصوتي', 'Audio File Number', 'Numéro de fichier audio', 'Ses Dosyası Numarası', 'Audiodateinummer');
  String get playBtn => _t('تشغيل', 'Play', 'Lire', 'Oynat', 'Abspielen');
  String get playCommand => _t('الأمر المُرسَل', 'Command to send', 'Commande envoyée', 'Gönderilecek komut', 'Zu sendender Befehl');

  // ── WiFi Tab ─────────────────────────────────────────────────
  String get enableWifi => _t('تفعيل WiFi', 'Enable WiFi', 'Activer WiFi', 'WiFi Etkinleştir', 'WiFi aktivieren');
  String get wifiSsid =>
      _t('اسم الشبكة (SSID)', 'Network Name (SSID)', 'Nom du réseau (SSID)', 'Ağ Adı (SSID)', 'Netzwerkname (SSID)');
  String get wifiPass =>
      _t('كلمة مرور WiFi', 'WiFi Password', 'Mot de passe WiFi', 'WiFi Şifresi', 'WiFi-Passwort');

  // ── GSM Tab ──────────────────────────────────────────────────
  String get enableGsm => _t('تفعيل GSM', 'Enable GSM', 'Activer GSM', 'GSM Etkinleştir', 'GSM aktivieren');
  String get gsmApn => 'APN';
  String get gsmUser =>
      _t('اسم المستخدم GSM', 'GSM Username', 'Nom d\'utilisateur GSM', 'GSM Kullanıcı Adı', 'GSM-Benutzername');
  String get gsmPass => _t('كلمة مرور GSM', 'GSM Password', 'Mot de passe GSM', 'GSM Şifresi', 'GSM-Passwort');
  String get simPin =>
      _t('رمز PIN للشريحة', 'SIM PIN Code', 'Code PIN de la SIM', 'SIM PIN Kodu', 'SIM-PIN-Code');

  // GSM info notes
  String get gsmApnNote => _t(
        'قد تكون هذه الحقول فارغة أو مطلوبة حسب متطلبات شركة الاتصالات الخاصة بك. تواصل مع مزود الخدمة إذا لم تكن متأكداً.',
        'These fields may be left empty or filled depending on your mobile carrier requirements. Contact your service provider if unsure.',
        'Ces champs peuvent être vides ou remplis selon votre opérateur. Contactez votre fournisseur si vous n\'êtes pas sûr.',
        'Bu alanlar, mobil operatörünüzün gereksinimlerine bağlı olarak boş bırakılabilir veya doldurulabilir. Emin değilseniz servis sağlayıcınızla iletişime geçin.',
        'Diese Felder können je nach Anforderungen Ihres Mobilfunkanbieters leer gelassen oder ausgefüllt werden. Kontaktieren Sie Ihren Anbieter, falls Sie unsicher sind.',
      );
  String get simPinNote => _t(
        'أدخل رمز PIN فقط إذا كانت شريحة SIM محمية برمز. اتركه فارغاً إذا لم تكن الشريحة مقفلة.',
        'Enter the PIN only if your SIM card is PIN-protected. Leave empty if your SIM is not locked.',
        'Entrez le PIN uniquement si votre carte SIM est protégée. Laissez vide si la SIM n\'est pas verrouillée.',
        'PIN\'i yalnızca SIM kartınız PIN korumalıysa girin. SIM kilitli değilse boş bırakın.',
        'Geben Sie die PIN nur ein, wenn Ihre SIM-Karte PIN-geschützt ist. Lassen Sie das Feld leer, wenn Ihre SIM nicht gesperrt ist.',
      );

  // ── MQTT Tab ─────────────────────────────────────────────────
  String get mqttBroker => _t('MQTT Broker (IP أو Domain)',
      'MQTT Broker (IP or Domain)', 'MQTT Broker (IP ou domaine)', 'MQTT Broker (IP veya Domain)', 'MQTT Broker (IP oder Domain)');
  String get mqttPort => _t('المنفذ', 'Port', 'Port', 'Port', 'Port');
  String get mqttUser =>
      _t('اسم مستخدم MQTT', 'MQTT Username', 'Nom d\'utilisateur MQTT', 'MQTT Kullanıcı Adı', 'MQTT-Benutzername');
  String get mqttPass =>
      _t('كلمة مرور MQTT', 'MQTT Password', 'Mot de passe MQTT', 'MQTT Şifresi', 'MQTT-Passwort');

  // ── Device Tab ───────────────────────────────────────────────
  String get bleName =>
      _t('اسم الجهاز BLE', 'BLE Device Name', 'Nom BLE de l\'appareil', 'BLE Cihaz Adı', 'BLE-Gerätename');
  String get language => _t('اللغة', 'Language', 'Langue', 'Dil', 'Sprache');
  String get utcOffset => _t('التوقيت (مثال: UTC+3)', 'UTC Offset (e.g. UTC+3)',
      'Décalage UTC (ex: UTC+3)', 'UTC Farkı (örn: UTC+3)', 'UTC-Versatz (z.B. UTC+3)');

  // Language names (always in their own language)
  String get langAr => 'العربية';
  String get langEn => 'English';
  String get langFr => 'Français';
  String get langTr => 'Türkçe';
  String get langDe => 'Deutsch';

  // ── Config Mode countdown ────────────────────────────────────
  String get configMode => _t('وضع الإعداد', 'Config Mode', 'Mode Config', 'Yapılandırma Modu', 'Konfigurationsmodus');
  String configCountdown(String time) => _t(
        'وضع الإعداد — ينتهي خلال $time',
        'Config Mode — ends in $time',
        'Mode Config — se termine dans $time',
        'Yapılandırma Modu — bitiş süresi $time',
        'Konfigurationsmodus — endet in $time',
      );

  // ── Helper ───────────────────────────────────────────────────
  String _t(String ar, String en, String fr, String tr, String de) {
    switch (locale) {
      case 'en':
        return en;
      case 'fr':
        return fr;
      case 'tr':
        return tr;
      case 'de':
        return de;
      default:
        return ar;
    }
  }
}
