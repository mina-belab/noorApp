// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/ble_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_theme.dart';
import 'config_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // No local volume at all — always show device value directly
  // Only use _pendingVolume while user is dragging the slider
  int? _pendingVolume; // null = show device value

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BleProvider>().getStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();
    final l10n = context.watch<LocaleProvider>().l10n;

    // Always use device volume unless user is actively dragging
    final displayVolume = _pendingVolume ?? ble.deviceVolume;

    // Navigate back to scan on disconnect
    if (ble.status == BleStatus.disconnected || ble.status == BleStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ScanScreen()),
          );
        }
      });
    }

    // Show snackbar messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || ble.lastMessage == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ble.lastMessage!,
              style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor:
              ble.lastMessageIsError ? AppTheme.error : AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      ble.clearMessage();
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          leading: const _ConnectionIndicator(),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refreshStatus,
              onPressed: () => ble.getStatus(),
            ),
            IconButton(
              icon: const Icon(Icons.bluetooth_disabled),
              tooltip: l10n.disconnect,
              onPressed: ble.disconnect,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.home, size: 18), text: l10n.appTitle),
              Tab(icon: const Icon(Icons.play_circle, size: 18), text: l10n.tabPlay),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // ── Tab 1: الرئيسية ──────────────────────────────
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  if (ble.configModeActive)
                    _ConfigModeBanner(ble: ble, l10n: l10n)
                  else
                    _NoConfigModeBanner(l10n: l10n),
                  const SizedBox(height: 16),
                  _VolumeCard(
                    l10n: l10n,
                    volume: displayVolume,
                    onChanged: (v) => setState(() => _pendingVolume = v.round()),
                    onSend: () async {
                      final vol = _pendingVolume ?? ble.deviceVolume;
                      await ble.sendVolume(vol);
                      setState(() => _pendingVolume = null);
                    },
                  ),
                  const SizedBox(height: 16),
                  _StatusCard(ble: ble, l10n: l10n),
                  const SizedBox(height: 16),
                  if (ble.infoFetched) _DeviceInfoCard(ble: ble, l10n: l10n),
                  if (ble.infoFetched) const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.settings,
                        label: l10n.settings,
                        enabled: ble.configModeActive,
                        tooltip: ble.configModeActive
                            ? l10n.openSettings
                            : l10n.requiresConfig,
                        color: AppTheme.primary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ConfigScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.restart_alt,
                        label: l10n.reboot,
                        enabled: true,
                        color: AppTheme.error,
                        onTap: () => _confirmReboot(context, ble, l10n),
                      ),
                    ),
                  ]),
                ]),
              ),
              // ── Tab 2: اختبار الصوت ──────────────────────────
              _PlayTestTab(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReboot(BuildContext ctx, BleProvider ble, l10n) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title:
            Text(l10n.rebootTitle, style: const TextStyle(fontFamily: 'Cairo')),
        content:
            Text(l10n.rebootQ, style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.reboot),
          ),
        ],
      ),
    );
    if (confirmed == true) await ble.reboot();
  }
}

// ══════════════════════════════════════════════════════════════
//  WIDGETS
// ══════════════════════════════════════════════════════════════

class _ConnectionIndicator extends StatelessWidget {
  const _ConnectionIndicator();
  @override
  Widget build(BuildContext context) {
    final connected =
        context.watch<BleProvider>().status == BleStatus.connected;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Stack(alignment: Alignment.center, children: [
        const Icon(Icons.bluetooth_connected, size: 22),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: connected ? AppTheme.success : AppTheme.error,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.surface, width: 1.5)),
          ),
        ),
      ]),
    );
  }
}

class _ConfigModeBanner extends StatelessWidget {
  final BleProvider ble;
  final dynamic l10n;
  const _ConfigModeBanner({required this.ble, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0097A7)]),
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        const Icon(Icons.settings_applications, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.configModeActive,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo')),
            Text('${l10n.configModeEndsIn} ${ble.configModeCountdown}',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12, fontFamily: 'Cairo')),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20)),
          child: Text(ble.configModeCountdown,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                  fontSize: 16)),
        ),
      ]),
    );
  }
}

class _NoConfigModeBanner extends StatelessWidget {
  final dynamic l10n;
  const _NoConfigModeBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Row(children: [
        Icon(Icons.info_outline,
            color: AppTheme.onSurface.withOpacity(0.6), size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Text(l10n.configModeHint,
                style: TextStyle(
                    color: AppTheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                    fontFamily: 'Cairo'))),
      ]),
    );
  }
}

class _VolumeCard extends StatelessWidget {
  final dynamic l10n;
  final int volume;
  final ValueChanged<double> onChanged;
  final VoidCallback onSend;
  const _VolumeCard(
      {required this.l10n,
      required this.volume,
      required this.onChanged,
      required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.volume_up, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(l10n.volume,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('$volume',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                      fontSize: 16)),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Text('0',
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.onSurface,
                    fontFamily: 'Cairo')),
            Expanded(
                child: Slider(
                    value: volume.toDouble(),
                    min: 0,
                    max: 21,
                    divisions: 21,
                    onChanged: onChanged)),
            const Text('21',
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.onSurface,
                    fontFamily: 'Cairo')),
          ]),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSend,
              icon: const Icon(Icons.send, size: 16),
              label: Text(l10n.send),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final BleProvider ble;
  final dynamic l10n;
  const _StatusCard({required this.ble, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.monitor_heart, color: AppTheme.accent, size: 20),
            const SizedBox(width: 8),
            Text(l10n.deviceStatus,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ]),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(children: [
              Expanded(
                  child: _StatusItem(
                label: 'WiFi',
                value: ble.deviceWifi ? l10n.connected : l10n.disconnected,
                color: ble.deviceWifi ? AppTheme.success : AppTheme.onSurface,
                icon: ble.deviceWifi ? Icons.wifi : Icons.wifi_off,
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: _StatusItem(
                label: 'GSM',
                value: ble.deviceGsm ? l10n.connected : l10n.disconnected,
                color: ble.deviceGsm ? AppTheme.success : AppTheme.onSurface,
                icon: ble.deviceGsm
                    ? Icons.signal_cellular_alt
                    : Icons.signal_cellular_off,
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: _StatusItem(
                label: 'BLE',
                value: l10n.connected,
                color: AppTheme.success,
                icon: Icons.bluetooth_connected,
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatusItem(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
          color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.onSurface, fontFamily: 'Cairo')),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo')),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DEVICE INFO CARD
// ══════════════════════════════════════════════════════════════

class _DeviceInfoCard extends StatelessWidget {
  final BleProvider ble;
  final dynamic l10n;
  const _DeviceInfoCard({required this.ble, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.info_outline, color: AppTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(l10n.deviceInfo,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
            ]),
            const SizedBox(height: 12),
            // Serial number — tap to copy
            _InfoRow(
              label: l10n.serial,
              value: ble.deviceSerial,
              icon: Icons.tag,
              mono: true,
              copyable: true,
            ),
            const SizedBox(height: 8),
            // Firmware version
            _InfoRow(
              label: l10n.firmware,
              value: 'v${ble.deviceFwStr}',
              icon: Icons.memory,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool mono;
  final bool copyable;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.mono = false,
    this.copyable = false,
  });

  Future<void> _copyToClipboard(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.read<LocaleProvider>().l10n;

    await Clipboard.setData(ClipboardData(text: value));

    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.serialCopied,
            style: const TextStyle(fontFamily: 'Cairo')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LocaleProvider>().l10n;

    final row = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: copyable
            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.2))
            : null,
      ),
      child: Row(children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.onSurface,
                      fontFamily: 'Cairo')),
              const SizedBox(height: 2),
              Text(value,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.onBackground,
                      fontWeight: FontWeight.w700,
                      fontFamily: mono ? 'monospace' : 'Cairo',
                      letterSpacing: mono ? 1.2 : 0)),
            ],
          ),
        ),
        if (copyable)
          Icon(Icons.copy, size: 16, color: AppTheme.primary.withOpacity(0.7)),
      ]),
    );

    if (!copyable) return row;

    return Tooltip(
      message: l10n.tapToCopy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _copyToClipboard(context),
        child: row,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PLAY TEST TAB
// ══════════════════════════════════════════════════════════════

class _PlayTestTab extends StatefulWidget {
  final dynamic l10n;
  const _PlayTestTab({required this.l10n});

  @override
  State<_PlayTestTab> createState() => _PlayTestTabState();
}

class _PlayTestTabState extends State<_PlayTestTab> {
  int _fileNumber = 0;
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();
    final l10n = widget.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.play_circle, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(l10n.playTestTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
              ]),
              const SizedBox(height: 24),

              // File number selector
              Text(l10n.playFileNumber,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.onSurface,
                      fontFamily: 'Cairo')),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: AppTheme.primary, size: 32),
                  onPressed: _fileNumber > 0
                      ? () => setState(() => _fileNumber--)
                      : null,
                ),
                Container(
                  width: 80,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('$_fileNumber',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          fontFamily: 'Cairo')),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppTheme.primary, size: 32),
                  onPressed: () => setState(() => _fileNumber++),
                ),
              ]),
              const SizedBox(height: 12),

              // Command preview
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('play=$_fileNumber',
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          letterSpacing: 1.2,
                          color: AppTheme.accent)),
                ),
              ),
              const SizedBox(height: 24),

              // Play button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sending
                      ? null
                      : () async {
                          setState(() => _sending = true);
                          await ble.sendPlay(_fileNumber);
                          if (mounted) setState(() => _sending = false);
                        },
                  icon: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.play_arrow, size: 20),
                  label: Text(l10n.playBtn,
                      style: const TextStyle(fontFamily: 'Cairo')),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.enabled,
      required this.color,
      required this.onTap,
      this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? label,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: enabled ? 1.0 : 0.4,
        child: ElevatedButton.icon(
          onPressed: enabled ? onTap : null,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
              backgroundColor: color,
              disabledBackgroundColor: color.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 48)),
        ),
      ),
    );
  }
}
