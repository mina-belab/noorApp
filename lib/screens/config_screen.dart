// lib/screens/config_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/device_config.dart';
import '../providers/ble_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_localizations.dart';
import '../utils/app_theme.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _wifiSsid   = TextEditingController();
  final _wifiPass   = TextEditingController();
  final _gsmApn     = TextEditingController();
  final _gsmUser    = TextEditingController();
  final _gsmPass    = TextEditingController();
  final _simPin     = TextEditingController();
  final _mqttBroker = TextEditingController();
  final _mqttPort   = TextEditingController();
  final _mqttUser   = TextEditingController();
  final _mqttPass   = TextEditingController();
  final _bleName    = TextEditingController();
  final _utc        = TextEditingController();

  bool   _enableWifi   = false;
  bool   _enableGsm    = false;
  String _language     = 'ar';
  int    _volume       = 5;
  bool   _showWifiPass = false;
  bool   _showGsmPass  = false;
  bool   _showMqttPass = false;
  bool   _isSaving     = false;
  bool   _isLoading    = true;

  int    _secondsLeft  = 0;
  Timer? _localTimer;
  bool   _fieldsPopulated = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ble = context.read<BleProvider>();

      if (!ble.configModeActive) {
        Navigator.of(context).pop();
        return;
      }

      _secondsLeft = ble.configModeSecondsLeft;
      _startLocalTimer();

      if (ble.configStatus == ConfigLoadStatus.loaded && !_fieldsPopulated) {
        _populateFields(ble.config);
      } else {
        ble.requestConfig();
        ble.addListener(_waitForConfig);
      }
    });
  }

  void _waitForConfig() {
    if (!mounted) return;
    final ble = context.read<BleProvider>();

    if (!ble.configModeActive) {
      ble.removeListener(_waitForConfig);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    if (ble.configStatus == ConfigLoadStatus.loaded && !_fieldsPopulated) {
      ble.removeListener(_waitForConfig);
      _populateFields(ble.config);
    }
  }

  void _startLocalTimer() {
    _localTimer?.cancel();
    _localTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) { _localTimer?.cancel(); return; }
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _localTimer?.cancel();
        Navigator.of(context).pop();
      }
    });
  }

  void _populateFields(DeviceConfig cfg) {
    if (_fieldsPopulated) return;
    _fieldsPopulated = true;

    _wifiSsid.text   = cfg.wifiSsid;
    _wifiPass.text   = cfg.wifiPass;
    _gsmApn.text     = cfg.gsmAPN;
    _gsmUser.text    = cfg.gsmUser;
    _gsmPass.text    = cfg.gsmPass;
    _simPin.text     = cfg.simPin;
    _mqttBroker.text = cfg.mqttBroker;
    _mqttPort.text   = cfg.mqttPort.toString();
    _mqttUser.text   = cfg.mqttUsername;
    _mqttPass.text   = cfg.mqttPassword;
    _bleName.text    = cfg.bleName;
    _utc.text        = cfg.utc;

    if (mounted) {
      setState(() {
        _enableWifi = cfg.enableWIFI;
        _enableGsm  = cfg.enableGSM;
        _language   = cfg.language;
        _volume     = cfg.volume;
        _isLoading  = false;
      });
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final ble = context.read<BleProvider>();
    await ble.saveConfig(DeviceConfig(
      enableWIFI:   _enableWifi,
      wifiSsid:     _wifiSsid.text.trim(),
      wifiPass:     _wifiPass.text,
      enableGSM:    _enableGsm,
      gsmAPN:       _gsmApn.text.trim(),
      gsmUser:      _gsmUser.text.trim(),
      gsmPass:      _gsmPass.text,
      simPin:       _simPin.text.trim(),
      mqttBroker:   _mqttBroker.text.trim(),
      mqttPort:     int.tryParse(_mqttPort.text) ?? 1883,
      mqttUsername: _mqttUser.text.trim(),
      mqttPassword: _mqttPass.text,
      bleName:      _bleName.text.trim(),
      language:     _language,
      utc:          _utc.text.trim(),
      volume:       _volume,
    ));

    // Sync app UI language with the saved device language
    await context.read<LocaleProvider>().setLocale(_language);

    if (mounted) setState(() => _isSaving = false);
  }

  String get _countdown {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    try { context.read<BleProvider>().removeListener(_waitForConfig); } catch (_) {}
    _localTimer?.cancel();
    _tabCtrl.dispose();
    for (final c in [
      _wifiSsid, _wifiPass, _gsmApn, _gsmUser, _gsmPass, _simPin,
      _mqttBroker, _mqttPort, _mqttUser, _mqttPass, _bleName, _utc,
    ]) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.read<LocaleProvider>().l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.onSurface,
          labelStyle: const TextStyle(
              fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 12),
          tabs: [
            Tab(icon: const Icon(Icons.wifi, size: 20), text: l10n.tabWifi),
            Tab(icon: const Icon(Icons.sim_card, size: 20), text: l10n.tabGsm),
            Tab(icon: const Icon(Icons.cloud, size: 20), text: l10n.tabMqtt),
            Tab(icon: const Icon(Icons.devices, size: 20), text: l10n.tabDevice),
          ],
        ),
      ),
      body: _isLoading
          ? _LoadingView(l10n: l10n)
          : Column(children: [
              // Countdown bar
              Container(
                width: double.infinity,
                color: AppTheme.primary.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(l10n.configCountdown(_countdown),
                        style: const TextStyle(color: AppTheme.primary,
                            fontFamily: 'Cairo', fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _WifiTab(l10n: l10n, enabled: _enableWifi,
                        onToggle: (v) => setState(() => _enableWifi = v),
                        ssid: _wifiSsid, pass: _wifiPass,
                        showPass: _showWifiPass,
                        onTogglePass: () =>
                            setState(() => _showWifiPass = !_showWifiPass)),
                    _GsmTab(l10n: l10n, enabled: _enableGsm,
                        onToggle: (v) => setState(() => _enableGsm = v),
                        apn: _gsmApn, user: _gsmUser, pass: _gsmPass,
                        showPass: _showGsmPass,
                        onTogglePass: () =>
                            setState(() => _showGsmPass = !_showGsmPass),
                        simPin: _simPin),
                    _MqttTab(l10n: l10n, broker: _mqttBroker, port: _mqttPort,
                        user: _mqttUser, pass: _mqttPass,
                        showPass: _showMqttPass,
                        onTogglePass: () =>
                            setState(() => _showMqttPass = !_showMqttPass)),
                    _DeviceTab(l10n: l10n, bleName: _bleName, utc: _utc,
                        language: _language,
                        onLanguageChanged: (v) => setState(() => _language = v!),
                        volume: _volume,
                        onVolumeChanged: (v) => setState(() => _volume = v.round())),
                  ],
                ),
              ),

              // Save button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(top: BorderSide(
                      color: Colors.white.withOpacity(0.06))),
                ),
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? l10n.saving : l10n.save),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppTheme.success),
                ),
              ),
            ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  INFO NOTE — blue box with an info icon
// ══════════════════════════════════════════════════════════════

class _InfoNote extends StatelessWidget {
  final String text;
  const _InfoNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline, color: AppTheme.primary, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text,
            style: const TextStyle(fontSize: 12, color: AppTheme.onSurface,
                fontFamily: 'Cairo', height: 1.5))),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TABS
// ══════════════════════════════════════════════════════════════

class _WifiTab extends StatelessWidget {
  final AppLocalizations l10n;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final TextEditingController ssid, pass;
  final bool showPass;
  final VoidCallback onTogglePass;
  const _WifiTab({required this.l10n, required this.enabled,
      required this.onToggle, required this.ssid, required this.pass,
      required this.showPass, required this.onTogglePass});

  @override
  Widget build(BuildContext context) => _TabScaffold(children: [
        _SectionToggle(label: l10n.enableWifi, value: enabled,
            onChanged: onToggle),
        const SizedBox(height: 16),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: enabled ? 1.0 : 0.4,
          child: Column(children: [
            _Field(controller: ssid, label: l10n.wifiSsid,
                icon: Icons.wifi, enabled: enabled),
            const SizedBox(height: 12),
            _PasswordField(controller: pass, label: l10n.wifiPass,
                showPassword: showPass, onToggle: onTogglePass,
                enabled: enabled),
          ]),
        ),
      ]);
}

class _GsmTab extends StatelessWidget {
  final AppLocalizations l10n;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final TextEditingController apn, user, pass, simPin;
  final bool showPass;
  final VoidCallback onTogglePass;
  const _GsmTab({required this.l10n, required this.enabled,
      required this.onToggle, required this.apn, required this.user,
      required this.pass, required this.showPass, required this.onTogglePass,
      required this.simPin});

  @override
  Widget build(BuildContext context) => _TabScaffold(children: [
        _SectionToggle(label: l10n.enableGsm, value: enabled,
            onChanged: onToggle),
        const SizedBox(height: 16),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: enabled ? 1.0 : 0.4,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // APN + user + pass
            _Field(controller: apn, label: l10n.gsmApn,
                icon: Icons.cell_tower, enabled: enabled),
            const SizedBox(height: 8),
            _Field(controller: user, label: l10n.gsmUser,
                icon: Icons.person_outline, enabled: enabled),
            const SizedBox(height: 8),
            _PasswordField(controller: pass, label: l10n.gsmPass,
                showPassword: showPass, onToggle: onTogglePass,
                enabled: enabled),

            // Note about APN / user / pass
            const SizedBox(height: 10),
            _InfoNote(text: l10n.gsmApnNote),

            const Divider(height: 28),

            // SIM PIN
            _Field(controller: simPin, label: l10n.simPin,
                icon: Icons.pin, enabled: enabled,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ]),

            // Note about SIM PIN
            const SizedBox(height: 10),
            _InfoNote(text: l10n.simPinNote),
          ]),
        ),
      ]);
}

class _MqttTab extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController broker, port, user, pass;
  final bool showPass;
  final VoidCallback onTogglePass;
  const _MqttTab({required this.l10n, required this.broker, required this.port,
      required this.user, required this.pass,
      required this.showPass, required this.onTogglePass});

  @override
  Widget build(BuildContext context) => _TabScaffold(children: [
        _Field(controller: broker, label: l10n.mqttBroker,
            icon: Icons.cloud_queue),
        const SizedBox(height: 12),
        _Field(controller: port, label: l10n.mqttPort, icon: Icons.numbers,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        const SizedBox(height: 12),
        _Field(controller: user, label: l10n.mqttUser,
            icon: Icons.person_outline),
        const SizedBox(height: 12),
        _PasswordField(controller: pass, label: l10n.mqttPass,
            showPassword: showPass, onToggle: onTogglePass),
      ]);
}

class _DeviceTab extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController bleName, utc;
  final String language;
  final ValueChanged<String?> onLanguageChanged;
  final int volume;
  final ValueChanged<double> onVolumeChanged;
  const _DeviceTab({required this.l10n, required this.bleName,
      required this.utc, required this.language,
      required this.onLanguageChanged, required this.volume,
      required this.onVolumeChanged});

  @override
  Widget build(BuildContext context) => _TabScaffold(children: [
        _Field(controller: bleName, label: l10n.bleName,
            icon: Icons.bluetooth),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: language,
          decoration: InputDecoration(
            labelText: l10n.language,
            prefixIcon: const Icon(Icons.language, size: 20),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          dropdownColor: AppTheme.surfaceLight,
          items: [
            DropdownMenuItem(value: 'ar',
                child: Text(l10n.langAr,
                    style: const TextStyle(fontFamily: 'Cairo'))),
            DropdownMenuItem(value: 'en',
                child: Text(l10n.langEn,
                    style: const TextStyle(fontFamily: 'Cairo'))),
            DropdownMenuItem(value: 'fr',
                child: Text(l10n.langFr,
                    style: const TextStyle(fontFamily: 'Cairo'))),
            DropdownMenuItem(value: 'tr',
                child: Text(l10n.langTr,
                    style: const TextStyle(fontFamily: 'Cairo'))),
            DropdownMenuItem(value: 'de',
                child: Text(l10n.langDe,
                    style: const TextStyle(fontFamily: 'Cairo'))),
          ],
          onChanged: onLanguageChanged,
        ),
        const SizedBox(height: 12),
        _Field(controller: utc, label: l10n.utcOffset,
            icon: Icons.access_time),
        const SizedBox(height: 16),
        Row(children: [
          const Icon(Icons.volume_up, color: AppTheme.primary, size: 18),
          const SizedBox(width: 8),
          Text(l10n.volume, style: const TextStyle(
              fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Text('0', style: TextStyle(fontSize: 12,
              color: AppTheme.onSurface, fontFamily: 'Cairo')),
          Expanded(child: Slider(value: volume.toDouble(), min: 0, max: 21,
              divisions: 21, label: '$volume', onChanged: onVolumeChanged)),
          const Text('21', style: TextStyle(fontSize: 12,
              color: AppTheme.onSurface, fontFamily: 'Cairo')),
          const SizedBox(width: 8),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('$volume', style: const TextStyle(
                color: AppTheme.primary, fontWeight: FontWeight.w800,
                fontFamily: 'Cairo'))),
          ),
        ]),
      ]);
}

// ══════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ══════════════════════════════════════════════════════════════

class _TabScaffold extends StatelessWidget {
  final List<Widget> children;
  const _TabScaffold({required this.children});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: children));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _Field({required this.controller, required this.label,
      required this.icon, this.enabled = true,
      this.keyboardType, this.inputFormatters});
  @override
  Widget build(BuildContext context) => TextField(
      controller: controller, enabled: enabled,
      keyboardType: keyboardType, inputFormatters: inputFormatters,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(labelText: label,
          prefixIcon: Icon(icon, size: 20)));
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool showPassword;
  final VoidCallback onToggle;
  final bool enabled;
  const _PasswordField({required this.controller, required this.label,
      required this.showPassword, required this.onToggle, this.enabled = true});
  @override
  Widget build(BuildContext context) => TextField(
      controller: controller, enabled: enabled,
      obscureText: !showPassword, textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(showPassword
              ? Icons.visibility_off : Icons.visibility, size: 20),
          onPressed: onToggle)));
}

class _SectionToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SectionToggle({required this.label, required this.value,
      required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(
            fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
        Switch(value: value, onChanged: onChanged),
      ]));
}

class _LoadingView extends StatelessWidget {
  final AppLocalizations l10n;
  const _LoadingView({required this.l10n});
  @override
  Widget build(BuildContext context) => Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: AppTheme.primary),
        const SizedBox(height: 20),
        Text(l10n.loading, style: const TextStyle(
            color: AppTheme.onSurface, fontFamily: 'Cairo')),
      ]));
}
