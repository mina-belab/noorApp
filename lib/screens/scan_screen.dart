// lib/screens/scan_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/ble_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_localizations.dart';
import '../utils/app_theme.dart';
import '../utils/ble_constants.dart';
import 'home_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissionsAndScan();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionsAndScan() async {
    final l10n = context.read<LocaleProvider>().l10n;

    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final allGranted = statuses.values.every((s) => s.isGranted);
    if (!allGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.permissionError),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (mounted) {
      await context.read<BleProvider>().startScan();
    }
  }

  Future<void> _connect(ScanResult result) async {
    final ble = context.read<BleProvider>();
    await ble.connectTo(result.device);

    if (!mounted) return;
    if (ble.status == BleStatus.connected) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ble   = context.watch<BleProvider>();
    final l10n  = context.watch<LocaleProvider>().l10n;
    final isScanning   = ble.status == BleStatus.scanning;
    final isConnecting = ble.status == BleStatus.connecting;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(l10n, isScanning),
              const SizedBox(height: 32),
              _buildScanButton(ble, l10n, isScanning, isConnecting),
              const SizedBox(height: 24),
              Expanded(child: _buildDeviceList(ble, l10n, isConnecting)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, bool isScanning) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.wifi_tethering, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.scanTitle,
              style: Theme.of(context).textTheme.titleLarge),
          Text(isScanning ? l10n.scanning : l10n.searchDevice,
              style: Theme.of(context).textTheme.bodyMedium),
        ]),
      ]),
      const SizedBox(height: 8),
      const Divider(),
    ]);
  }

  Widget _buildScanButton(BleProvider ble, AppLocalizations l10n,
      bool isScanning, bool isConnecting) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, child) {
          return Container(
            decoration: isScanning
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(
                      color: AppTheme.primary.withOpacity(
                          0.15 + _pulseCtrl.value * 0.25),
                      blurRadius: 20, spreadRadius: 2)])
                : null,
            child: child,
          );
        },
        child: ElevatedButton.icon(
          onPressed: isConnecting
              ? null
              : isScanning ? ble.stopScan : _requestPermissionsAndScan,
          icon: isScanning
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.search),
          label: Text(isScanning ? l10n.stopScan : l10n.startScan),
          style: ElevatedButton.styleFrom(
            backgroundColor: isScanning ? AppTheme.warning : AppTheme.primary),
        ),
      ),
    );
  }

  Widget _buildDeviceList(BleProvider ble, AppLocalizations l10n,
      bool isConnecting) {
    if (ble.scanResults.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_disabled,
              size: 64, color: AppTheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(l10n.noDevices,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ));
    }

    return ListView.separated(
      itemCount: ble.scanResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final result   = ble.scanResults[i];
        final name     = result.device.platformName;
        final isTarget = name == BleConstants.defaultDeviceName ||
            name.toLowerCase().contains('noor');

        return _DeviceTile(
          name: name,
          mac: result.device.remoteId.str,
          rssi: result.rssi,
          isTarget: isTarget,
          targetLabel: l10n.targetDevice,
          isConnecting: isConnecting,
          onTap: () => _connect(result),
        );
      },
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final String name, mac, targetLabel;
  final int rssi;
  final bool isTarget, isConnecting;
  final VoidCallback onTap;

  const _DeviceTile({required this.name, required this.mac, required this.rssi,
      required this.isTarget, required this.targetLabel,
      required this.isConnecting, required this.onTap});

  IconData get _rssiIcon {
    if (rssi >= -60) return Icons.signal_wifi_4_bar;
    if (rssi >= -75) return Icons.network_wifi_3_bar;
    if (rssi >= -85) return Icons.network_wifi_2_bar;
    return Icons.network_wifi_1_bar;
  }

  Color get _rssiColor {
    if (rssi >= -60) return AppTheme.success;
    if (rssi >= -75) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isTarget
            ? const BorderSide(color: AppTheme.primary, width: 1.5)
            : BorderSide(color: Colors.white.withOpacity(0.06))),
      child: InkWell(
        onTap: isConnecting ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: isTarget
                    ? AppTheme.primary.withOpacity(0.15)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.bluetooth,
                  color: isTarget ? AppTheme.primary : AppTheme.onSurface,
                  size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(name, style: TextStyle(
                    fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                    color: isTarget ? AppTheme.primary : AppTheme.onBackground)),
                  if (isTarget) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(targetLabel, style: const TextStyle(
                          fontSize: 10, color: AppTheme.primary,
                          fontFamily: 'Cairo')),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(mac, style: const TextStyle(fontSize: 11,
                    color: AppTheme.onSurface, fontFamily: 'Cairo')),
              ],
            )),
            Column(children: [
              Icon(_rssiIcon, color: _rssiColor, size: 20),
              Text('$rssi', style: TextStyle(fontSize: 11,
                  color: _rssiColor, fontFamily: 'Cairo')),
            ]),
          ]),
        ),
      ),
    );
  }
}
