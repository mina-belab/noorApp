// lib/models/device_config.dart

class DeviceConfig {
  // WiFi
  bool enableWIFI;
  String wifiSsid;
  String wifiPass;

  // GSM
  bool enableGSM;
  String gsmAPN;
  String gsmUser;
  String gsmPass;
  String simPin;

  // MQTT
  String mqttBroker;
  int mqttPort;
  String mqttUsername;
  String mqttPassword;

  // الجهاز
  String bleName;
  String language;
  String utc;
  int volume;

  DeviceConfig({
    this.enableWIFI = false,
    this.wifiSsid = '',
    this.wifiPass = '',
    this.enableGSM = false,
    this.gsmAPN = '',
    this.gsmUser = '',
    this.gsmPass = '',
    this.simPin = '',
    this.mqttBroker = '',
    this.mqttPort = 1883,
    this.mqttUsername = '',
    this.mqttPassword = '',
    this.bleName = 'Noor',
    this.language = 'ar',
    this.utc = 'UTC+3',
    this.volume = 5,
  });

  /// دمج بيانات الأجزاء الثلاثة
  void applyPart(Map<String, dynamic> json) {
    final part = json['part'] as int?;

    if (part == 1) {
      enableWIFI = json['enableWIFI'] ?? enableWIFI;
      wifiSsid = json['wifi_ssid'] ?? wifiSsid;
      wifiPass = json['wifi_pass'] ?? wifiPass;
      enableGSM = json['enableGSM'] ?? enableGSM;
      gsmAPN = json['gsmAPN'] ?? gsmAPN;
      gsmUser = json['gsmUser'] ?? gsmUser;
      gsmPass = json['gsmPass'] ?? gsmPass;
      simPin = json['simPin'] ?? simPin;
    } else if (part == 2) {
      mqttBroker = json['mqttBroker'] ?? mqttBroker;
      mqttPort = json['mqttPort'] ?? mqttPort;
      mqttUsername = json['mqttUsername'] ?? mqttUsername;
      mqttPassword = json['mqttPassword'] ?? mqttPassword;
    } else if (part == 3) {
      bleName = json['ble_name'] ?? bleName;
      language = json['language'] ?? language;
      utc = json['utc'] ?? utc;
      volume = json['volume'] ?? volume;
    }
  }

  /// بناء JSON الكامل للإرسال
  Map<String, dynamic> toSetConfigJson() {
    final map = <String, dynamic>{
      'cmd': 'set_config',
      'enableWIFI': enableWIFI,
      'enableGSM': enableGSM,
      'mqttBroker': mqttBroker,
      'mqttPort': mqttPort,
      'ble_name': bleName,
      'language': language,
      'utc': utc,
      'volume': volume,
    };

    if (wifiSsid.isNotEmpty) map['wifi_ssid'] = wifiSsid;
    if (wifiPass.isNotEmpty) map['wifi_pass'] = wifiPass;
    if (gsmAPN.isNotEmpty) map['gsmAPN'] = gsmAPN;
    if (gsmUser.isNotEmpty) map['gsmUser'] = gsmUser;
    if (gsmPass.isNotEmpty) map['gsmPass'] = gsmPass;
    if (simPin.isNotEmpty) map['simPin'] = simPin;
    if (mqttUsername.isNotEmpty) map['mqttUsername'] = mqttUsername;
    if (mqttPassword.isNotEmpty) map['mqttPassword'] = mqttPassword;

    return map;
  }

  DeviceConfig copyWith({
    bool? enableWIFI,
    String? wifiSsid,
    String? wifiPass,
    bool? enableGSM,
    String? gsmAPN,
    String? gsmUser,
    String? gsmPass,
    String? simPin,
    String? mqttBroker,
    int? mqttPort,
    String? mqttUsername,
    String? mqttPassword,
    String? bleName,
    String? language,
    String? utc,
    int? volume,
  }) {
    return DeviceConfig(
      enableWIFI: enableWIFI ?? this.enableWIFI,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPass: wifiPass ?? this.wifiPass,
      enableGSM: enableGSM ?? this.enableGSM,
      gsmAPN: gsmAPN ?? this.gsmAPN,
      gsmUser: gsmUser ?? this.gsmUser,
      gsmPass: gsmPass ?? this.gsmPass,
      simPin: simPin ?? this.simPin,
      mqttBroker: mqttBroker ?? this.mqttBroker,
      mqttPort: mqttPort ?? this.mqttPort,
      mqttUsername: mqttUsername ?? this.mqttUsername,
      mqttPassword: mqttPassword ?? this.mqttPassword,
      bleName: bleName ?? this.bleName,
      language: language ?? this.language,
      utc: utc ?? this.utc,
      volume: volume ?? this.volume,
    );
  }
}
