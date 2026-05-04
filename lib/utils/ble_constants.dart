// lib/utils/ble_constants.dart

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleConstants {
  // E104-BT07 UUIDs (من الـ datasheet)
  static final Guid serviceUuid =
      Guid('0000FFF0-0000-1000-8000-00805F9B34FB');
  static final Guid rxCharUuid = // Slave→App (notify) FFF1
      Guid('0000FFF1-0000-1000-8000-00805F9B34FB');
  static final Guid txCharUuid = // App→Slave (write)  FFF2
      Guid('0000FFF2-0000-1000-8000-00805F9B34FB');

  // MTU المحدد في المشروع
  static const int mtu = 240;

  // اسم الجهاز الافتراضي
  static const String defaultDeviceName = 'Noor';

  // مهلة الـ Config Mode (10 دقائق)
  static const int configModeTimeoutSeconds = 600;
}
