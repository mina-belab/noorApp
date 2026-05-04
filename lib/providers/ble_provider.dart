// lib/providers/ble_provider.dart

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/device_config.dart';
import '../utils/ble_constants.dart';

enum BleStatus { idle, scanning, connecting, connected, disconnected }

enum ConfigLoadStatus { idle, loading, loaded, error }

class BleProvider extends ChangeNotifier {
  BleStatus _status = BleStatus.idle;
  BleStatus get status => _status;

  BluetoothDevice? _device;
  BluetoothDevice? get device => _device;

  List<ScanResult> _scanResults = [];
  List<ScanResult> get scanResults => _scanResults;

  BluetoothCharacteristic? _txChar;
  BluetoothCharacteristic? _rxChar;

  DeviceConfig _config = DeviceConfig();
  DeviceConfig get config => _config;

  ConfigLoadStatus _configStatus = ConfigLoadStatus.idle;
  ConfigLoadStatus get configStatus => _configStatus;

  Map<String, dynamic> _configPartsBuf = {};

  // ─── Config Mode ────────────────────────────────────────────
  bool _configModeActive = false;
  bool get configModeActive => _configModeActive;

  int _configModeSecondsLeft = 0;
  int get configModeSecondsLeft => _configModeSecondsLeft;

  Timer? _configModeTimer;
  Timer? _statusTimer;

// Device information (fetched once on connect)
  String _deviceSerial = '';
  String _deviceFwStr = '';
  int _deviceFwVersion = 0;
  bool _infoFetched = false;

  String get deviceSerial => _deviceSerial;
  String get deviceFwStr => _deviceFwStr;
  int get deviceFwVersion => _deviceFwVersion;
  bool get infoFetched => _infoFetched;

  // ─── حالة الجهاز ────────────────────────────────────────────
  bool _deviceWifi = false;
  bool get deviceWifi => _deviceWifi;

  bool _deviceGsm = false;
  bool get deviceGsm => _deviceGsm;

  int _deviceVolume = 0;
  int get deviceVolume => _deviceVolume;

  // ─── رسائل ──────────────────────────────────────────────────
  String? _lastMessage;
  bool _lastMessageIsError = false;
  String? get lastMessage => _lastMessage;
  bool get lastMessageIsError => _lastMessageIsError;

  String _rxBuffer = '';

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _notifySub;

  // ════════════════════════════════════════════════════════════
  //  SCAN
  // ════════════════════════════════════════════════════════════

  Future<void> startScan() async {
    if (_status == BleStatus.scanning) return;
    _scanResults = [];
    _setStatus(BleStatus.scanning);
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results
          .where((r) => r.device.platformName.isNotEmpty)
          .toList()
        ..sort((a, b) => b.rssi.compareTo(a.rssi));
      notifyListeners();
    });
    await Future.delayed(const Duration(seconds: 10));
    await stopScan();
  }

  Future<void> stopScan() async {
    await _scanSub?.cancel();
    _scanSub = null;
    await FlutterBluePlus.stopScan();
    if (_status == BleStatus.scanning) _setStatus(BleStatus.idle);
  }

  void _startStatusPolling() {
    _statusTimer?.cancel();
    //debugPrint('⚠️ _startStatusPolling started!');
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      //debugPrint('⚠️ polling tick');
      if (_status == BleStatus.connected) {
        await sendCommand('{"cmd":"get_status"}');
      }
    });
  }

  // ════════════════════════════════════════════════════════════
  //  CONNECT
  // ════════════════════════════════════════════════════════════

  Future<void> connectTo(BluetoothDevice device) async {
    try {
      _setStatus(BleStatus.connecting);
      //debugPrint('⚠️ connected — starting polling');
      _startStatusPolling();
      await stopScan();
      await device.connect(timeout: const Duration(seconds: 15));
      _device = device;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_device_id', device.remoteId.str);

      _connSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) _onDisconnected();
      });

      await device.requestMtu(BleConstants.mtu);
      await _discoverServices(device);
      _setStatus(BleStatus.connected);

      // ← انتظر حتى تستقر الـ BLE connection
      await Future.delayed(const Duration(milliseconds: 1500));
      await sendCommand('{"cmd":"get_status"}');
      await Future.delayed(const Duration(milliseconds: 200));
      await sendCommand('{"cmd":"get_information"}');

      // ← ابدأ الـ polling
      //_startStatusPolling();
    } catch (e) {
      _showMessage('فشل الاتصال: $e', isError: true);
      _setStatus(BleStatus.disconnected);
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    final services = await device.discoverServices();
    for (final service in services) {
      if (service.uuid == BleConstants.serviceUuid) {
        for (final char in service.characteristics) {
          if (char.uuid == BleConstants.txCharUuid) {
            _txChar = char;
          } else if (char.uuid == BleConstants.rxCharUuid) {
            _rxChar = char;
            await char.setNotifyValue(true);
            _notifySub = char.lastValueStream.listen(_onDataReceived);
          }
        }
        break;
      }
    }
  }

  void _onDisconnected() {
    _txChar = null;
    _rxChar = null;
    _notifySub?.cancel();
    _connSub?.cancel();
    _statusTimer?.cancel();
    _statusTimer = null;
    _rxBuffer = '';
    _configPartsBuf = {};
    _configModeTimer?.cancel();
    _configModeTimer = null;
    _configModeActive = false;
    _configModeSecondsLeft = 0;
    _infoFetched     = false;
_deviceSerial    = '';
_deviceFwStr     = '';
_deviceFwVersion = 0;
    _setStatus(BleStatus.disconnected);
    _showMessage('انقطع الاتصال بالجهاز', isError: true);
  }

  Future<void> disconnect() async {
    await _device?.disconnect();
    _device = null;
    _setStatus(BleStatus.idle);
  }

  // ════════════════════════════════════════════════════════════
  //  SEND
  // ════════════════════════════════════════════════════════════

  Future<bool> sendCommand(String jsonCmd) async {
    if (_txChar == null) {
      _showMessage('غير متصل بالجهاز', isError: true);
      return false;
    }
    try {
      final bytes = utf8.encode('$jsonCmd\n');
      const chunkSize = BleConstants.mtu - 3;
      for (var i = 0; i < bytes.length; i += chunkSize) {
        final end =
            (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        await _txChar!.write(bytes.sublist(i, end),
            withoutResponse: _txChar!.properties.writeWithoutResponse);
      }
      dev.log('TX: $jsonCmd');
      return true;
    } catch (e) {
      _showMessage('خطأ في الإرسال: $e', isError: true);
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  //  RECEIVE
  // ════════════════════════════════════════════════════════════

  void _onDataReceived(List<int> data) {
    if (data.isEmpty) return;
    _rxBuffer += utf8.decode(data, allowMalformed: true);
    while (_rxBuffer.contains('\n')) {
      final idx = _rxBuffer.indexOf('\n');
      final line = _rxBuffer.substring(0, idx).trim();
      _rxBuffer = _rxBuffer.substring(idx + 1);
      if (line.isNotEmpty) {
        dev.log('RX: $line');
        _handleMessage(line);
      }
    }
  }

  void _handleMessage(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final status = json['status'] as String?;
      switch (status) {
        case 'config':
          _handleConfigPart(json);
          break;
        case 'ok':
          _showMessage(json['msg'] ?? 'تم بنجاح');
          break;
        case 'error':
          // تجاهل رسالة config mode inactive — ليست خطأً حقيقياً
          final msg = json['msg'] as String? ?? '';
          if (!msg.contains('config mode inactive')) {
            _showMessage(msg, isError: true);
          }
          break;
        case 'config_mode':
          _handleConfigMode(json);
          break;
        case 'device_status':
          // debugPrint('⚠️ device_status received: $json');
          _deviceWifi = json['wifi'] ?? false;
          _deviceGsm = json['gsm'] ?? false;
          _deviceVolume = json['volume'] ?? 0;
          notifyListeners();
          break;
        case 'information':
          _deviceSerial = json['serial'] ?? '';
          _deviceFwStr = json['fw_str'] ?? '';
          _deviceFwVersion = json['fw_version'] ?? 0;
          _infoFetched = true;
          notifyListeners();
          break;
      }
    } catch (e) {
      dev.log('Parse error: $e');
    }
  }

  void _handleConfigPart(Map<String, dynamic> json) {
    final part = json['part'] as int?;
    if (part == null) return;

    _configPartsBuf.addAll(json);

    if (part == 3) {
      final cfg = DeviceConfig();
      cfg.applyPart({..._configPartsBuf, 'part': 1});
      cfg.applyPart({..._configPartsBuf, 'part': 2});
      cfg.applyPart({..._configPartsBuf, 'part': 3});
      _config = cfg;
      _configPartsBuf = {};
      _configStatus = ConfigLoadStatus.loaded;
      _deviceVolume = cfg.volume;
      notifyListeners();
    }
  }

  void _handleConfigMode(Map<String, dynamic> json) {
    final active = json['active'] as bool? ?? false;
    final timeout = json['timeout_s'] as int?;

    _configModeActive = active;

    if (active) {
      _configModeSecondsLeft = timeout ?? BleConstants.configModeTimeoutSeconds;
      _configModeTimer?.cancel();
      _configModeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_configModeSecondsLeft > 0) {
          _configModeSecondsLeft--;
          notifyListeners();
        } else {
          _configModeTimer?.cancel();
          _configModeTimer = null;
          _configModeActive = false;
          notifyListeners();
        }
      });
    } else {
      _configModeTimer?.cancel();
      _configModeTimer = null;
      _configModeSecondsLeft = 0;
    }

    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════
  //  COMMANDS
  // ════════════════════════════════════════════════════════════

  Future<void> requestConfig() async {
    _configStatus = ConfigLoadStatus.loading;
    _configPartsBuf = {};
    notifyListeners();
    final ok = await sendCommand('{"cmd":"get_config"}');
    if (!ok) {
      _configStatus = ConfigLoadStatus.error;
      notifyListeners();
    }
  }

  Future<void> saveConfig(DeviceConfig newConfig) async {
    _config = newConfig;
    _deviceVolume = newConfig.volume;
    await sendCommand(jsonEncode(newConfig.toSetConfigJson()));
  }

  Future<void> sendVolume(int volume) async {
    final cfg = _config.copyWith(volume: volume);
    await saveConfig(cfg);
  }

  Future<void> reboot() async {
    await sendCommand('{"cmd":"reboot"}');
  }

  Future<void> sendPlay(int fileNumber) async {
    await sendCommand('play=$fileNumber');
  }

  Future<void> getStatus() async {
    await sendCommand('{"cmd":"get_status"}');
  }

  // ════════════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════════════

  void _setStatus(BleStatus s) {
    _status = s;
    notifyListeners();
  }

  void _showMessage(String msg, {bool isError = false}) {
    _lastMessage = msg;
    _lastMessageIsError = isError;
    notifyListeners();
  }

  void clearMessage() {
    _lastMessage = null;
    notifyListeners();
  }

  String get configModeCountdown {
    final m = _configModeSecondsLeft ~/ 60;
    final s = _configModeSecondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _connSub?.cancel();
    _notifySub?.cancel();
    _configModeTimer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }
}
