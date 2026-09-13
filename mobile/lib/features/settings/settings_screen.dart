import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import '../../app/providers.dart';
import '../../domain/enums.dart';
import '../state/hsi_engine.dart';
import '../state/hsi_providers.dart';
import 'signal_check_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const path = '/settings';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final health = ref.watch(integrationHealthProvider).value;
    final ingestion =
        ref.watch(ingestionStatusProvider).value ?? health?.ingestion;
    final watch = ref.watch(watchDiagnosticProvider).value;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            SbSpace.gutter,
            SbSpace.xl,
            SbSpace.gutter,
            SbSpace.xxxl,
          ),
          children: [
            Text('Settings', style: context.text.headlineMedium),
            const SizedBox(height: SbSpace.xl),
            HairlineRow(
              title: const Text('Your watch'),
              subtitle: Text(
                watch == null
                    ? 'Checking…'
                    : watch.ready
                    ? 'Connected'
                    : watch.error ??
                          'Open Study Buddy on your watch and allow '
                              'heart rate',
              ),
              trailing: Icon(
                watch?.reachable == true
                    ? Icons.watch_outlined
                    : Icons.watch_off_outlined,
              ),
            ),
            HairlineRow(
              title: const Text('Check my setup'),
              subtitle: const Text(
                'Make sure your watch and measurements work',
              ),
              trailing: const Icon(Icons.arrow_forward_rounded),
              onTap: _openSignalCheck,
            ),
            HairlineRow(
              title: const Text('Measure with your watch'),
              subtitle: Text(_runtimeLabel(health)),
              trailing: Switch.adaptive(
                value:
                    health?.biosignalConsent ??
                    profile?.wearableConsent ??
                    false,
                onChanged: _submitting
                    ? null
                    : (value) => _saveConsent(measured: value),
              ),
            ),
            HairlineRow(
              title: const Text('Back up to Synheart'),
              subtitle: Text(_syncLabel(ingestion)),
              trailing: Switch.adaptive(
                value:
                    health?.cloudUploadConsent ??
                    profile?.cloudConsent ??
                    false,
                onChanged: _submitting
                    ? null
                    : (value) => _saveConsent(cloud: value),
              ),
            ),
            HairlineRow(
              title: const Text('Delete my data'),
              subtitle: const Text(
                'Removes subjects, PDFs, sessions, and measurements',
              ),
              trailing: const Icon(Icons.delete_outline_rounded),
              onTap: _confirmDelete,
            ),


            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              shape: const Border(),
              title: Text('Advanced', style: context.text.titleMedium),
              children: [
                HairlineRow.text(
                  label: 'Core runtime',
                  value: health?.runtimeAvailable == true
                      ? 'Ready'
                      : 'Unavailable',
                  subtitle: health?.runtimeVersion,
                ),
                HairlineRow.text(
                  label: 'Device authorization',
                  value: health?.deviceAuthReady == true ? 'Ready' : 'Pending',
                ),
                HairlineRow.text(
                  label: 'Cloud consent token',
                  value: health?.cloudTokenReady == true ? 'Ready' : 'Pending',
                ),
                HairlineRow.text(
                  label: 'Readings computed',
                  value: '${health?.hsiFrameCount ?? 0}',
                ),
                HairlineRow(
                  title: const Text('Retry backup'),
                  subtitle: Text(
                    '${ingestion?.queueLength ?? 0} readings waiting',
                  ),
                  trailing: const Icon(Icons.sync_rounded),
                  onTap: _retrySync,
                ),
                HairlineRow(
                  title: const Text('Copy diagnostics'),
                  subtitle: const Text('No credentials, notes, or identity'),
                  trailing: const Icon(Icons.copy_outlined),
                  onTap: _copyDiagnostics,
                ),
              ],
            ),

            const HairlineRow(
              title: Text('Version'),
              trailing: Text('1.0.0'),
              divider: false,
            ),
          ],
        ),
      ),
    );
  }

  String _runtimeLabel(IntegrationHealth? health) {
    if (health == null) return 'Checking…';
    if (!health.runtimeAvailable) {
      return health.error ?? 'Unavailable on this phone';
    }
    return health.biosignalConsent
        ? 'On — focus, energy, capacity, and stress'
        : 'Off';
  }

  String _syncLabel(IngestionSnapshot? value) {
    if (value == null) return 'Checking…';
    return switch (value.state) {
      SyncState.localOnly => 'Off — everything stays on this phone',
      SyncState.pending => '${value.queueLength} waiting to back up',
      SyncState.syncing => 'Backing up…',
      SyncState.synced =>
        value.lastUploadAt == null
            ? 'Waiting for the first backup'
            : 'Last backup ${SbFormat.relative(value.lastUploadAt!)}',
      SyncState.failed || SyncState.rejected => 'Backup did not go through',
      SyncState.offlineQueued => 'Will back up when online',
    };
  }

  Future<void> _saveConsent({bool? measured, bool? cloud}) async {
    final database = ref.read(databaseProvider);
    final gateway = ref.read(hsiEngineProvider);
    final profile = await database.getProfile();
    if (!mounted) return;
    if (profile == null) return;
    setState(() => _submitting = true);
    final measuredChoice = measured ?? profile.wearableConsent;
    final choice = StudyConsentChoice(
      measuredState: measuredChoice,
      cloudUpload: measuredChoice && (cloud ?? profile.cloudConsent),
    );
    final error = await gateway.setConsent(choice);
    final effective = await gateway.health();
    await database.saveProfile(
      nickname: profile.nickname,
      setupComplete: true,
      wearableConsent: effective.biosignalConsent,
      cloudConsent: effective.cloudUploadConsent,
    );
    if (mounted) {
      ref.invalidate(integrationHealthProvider);
      ref.invalidate(ingestionStatusProvider);
      setState(() => _submitting = false);
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  void _openSignalCheck() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SignalCheckScreen()));
  }

  Future<void> _retrySync() async {
    final gateway = ref.read(hsiEngineProvider);
    final result = await gateway.flushIngestion();
    if (!mounted) return;
    ref.invalidate(ingestionStatusProvider);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(_syncLabel(result))));
  }

  Future<void> _copyDiagnostics() async {
    await Clipboard.setData(
      ClipboardData(text: ref.read(hsiEngineProvider).sanitizedDiagnostics()),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sanitized diagnostics copied.')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final sourceStore = ref.read(sourceStoreProvider);
    final database = ref.read(databaseProvider);
    final gateway = ref.read(hsiEngineProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete local data?'),
        content: const Text(
          'This permanently removes your subjects, imported PDFs, sessions, local chat, and Synheart data from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await sourceStore.deleteAll();
    await database.deleteAllUserData();
    await gateway.wipeLocalData();
  }
}
