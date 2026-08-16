import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/tracking_cubit.dart';
import '../cubit/tracking_state.dart';
import '../../domain/entities/confraternity.dart';

/// Home page with configuration and tracking controls.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _serverUrlController = TextEditingController();
  final _secretController = TextEditingController();

  @override
  void dispose() {
    _serverUrlController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passio Tracker'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<TrackingCubit, TrackingState>(
        listener: (context, state) {
          if (state is TrackingConfigured && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            TrackingInitial() => const Center(
              child: CircularProgressIndicator(),
            ),
            TrackingConfigured() => _buildConfiguredView(context, state),
            TrackingActive() => _buildActiveView(context, state),
            TrackingError() => _buildErrorView(context, state),
          };
        },
      ),
    );
  }

  Widget _buildConfiguredView(BuildContext context, TrackingConfigured state) {
    if (_serverUrlController.text.isEmpty) {
      _serverUrlController.text = state.config.serverUrl;
    }
    if (_secretController.text.isEmpty) {
      _secretController.text = state.config.secret;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(context, '⚙️ Configurazione Confraternita'),
          const SizedBox(height: 8),
          _buildConfigCard(context, state),
          const SizedBox(height: 16),

          _buildSectionHeader(context, '📡 Verifica & Stato'),
          const SizedBox(height: 8),
          _buildConnectionTestCard(context, state),
          const SizedBox(height: 24),

          _buildStartButton(context, state),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildConfigCard(BuildContext context, TrackingConfigured state) {
    final cubit = context.read<TrackingCubit>();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Server API',
                hintText: 'http://192.168.1.X:5000/api',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.dns_rounded),
              ),
              onSubmitted: (value) => cubit.updateServerUrl(value),
            ),
            const SizedBox(height: 16),

            _buildConfraternityDropdown(context, state),
            const SizedBox(height: 16),

            TextField(
              controller: _secretController,
              decoration: const InputDecoration(
                labelText: 'Secret Capofila',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key_rounded),
              ),
              obscureText: true,
              onChanged: (value) => cubit.updateConfig(secret: value),
            ),
            const SizedBox(height: 16),

            _buildIntervalSelector(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildConfraternityDropdown(
    BuildContext context,
    TrackingConfigured state,
  ) {
    final cubit = context.read<TrackingCubit>();

    if (state.confraternities.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Nessuna confraternita caricata',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => cubit.fetchConfraternities(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Ricarica elenco',
          ),
        ],
      );
    }

    Confraternity? selectedConfraternity;
    if (state.config.confraternityId.isNotEmpty) {
      selectedConfraternity = state.confraternities.firstWhere(
        (c) => c.id == state.config.confraternityId,
        orElse: () => state.confraternities.first,
      );
    }

    return DropdownButtonFormField<Confraternity>(
      initialValue: selectedConfraternity,
      decoration: const InputDecoration(
        labelText: 'Seleziona Confraternita',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.church_rounded),
      ),
      items: state.confraternities.map((c) {
        return DropdownMenuItem(
          value: c,
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _parseColor(c.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                c.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (confraternity) {
        if (confraternity != null) {
          cubit.updateConfig(
            confraternityId: confraternity.id,
            confraternityName: confraternity.name,
          );
        }
      },
    );
  }

  Widget _buildIntervalSelector(
    BuildContext context,
    TrackingConfigured state,
  ) {
    final cubit = context.read<TrackingCubit>();
    final intervals = [10, 30, 60];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intervallo invio: ogni ${state.config.intervalSeconds} secondi',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: intervals.map((interval) {
            return ButtonSegment(
              value: interval,
              label: Text('${interval}s'),
            );
          }).toList(),
          selected: {state.config.intervalSeconds},
          onSelectionChanged: (selected) {
            cubit.updateConfig(intervalSeconds: selected.first);
          },
        ),
      ],
    );
  }

  Widget _buildConnectionTestCard(BuildContext context, TrackingConfigured state) {
    final cubit = context.read<TrackingCubit>();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Server',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.connectionStatusMessage ??
                            'Verifica la connessione prima di iniziare il corteo',
                        style: TextStyle(
                          fontSize: 12,
                          color: state.isConnectionOk == true
                              ? Colors.green.shade800
                              : state.isConnectionOk == false
                                  ? Colors.red.shade800
                                  : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: state.isTestingConnection
                      ? null
                      : () => cubit.testConnection(),
                  icon: state.isTestingConnection
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_find_rounded),
                  label: const Text('Test'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, TrackingConfigured state) {
    final cubit = context.read<TrackingCubit>();
    final isConfigured = state.config.confraternityId.isNotEmpty;

    return SizedBox(
      height: 64,
      child: FilledButton.icon(
        onPressed: isConfigured ? () => cubit.startTracking() : null,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.play_arrow_rounded, size: 30),
        label: const Text(
          'AVVIA TRACCIAMENTO',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildActiveView(BuildContext context, TrackingActive state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tracking Banner
          Card(
            color: Colors.green.shade50,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPulsingIndicator(),
                      const SizedBox(width: 8),
                      Text(
                        'TRACCIAMENTO ATTIVO',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.config.confraternityName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Invio ogni ${state.config.intervalSeconds} secondi',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Background Service notification reminder
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.notification_important_rounded, color: Colors.blue.shade800),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tracciamento attivo in background. Puoi chiudere l\'app o bloccare lo schermo.',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow(
                    'Ultima Posizione',
                    state.lastPosition != null
                        ? '${state.lastPosition!.latitude.toStringAsFixed(5)}, ${state.lastPosition!.longitude.toStringAsFixed(5)}'
                        : 'In attesa segnale GPS...',
                  ),
                  const Divider(),
                  _buildStatRow(
                    'Precisione GPS',
                    state.lastPosition != null
                        ? '±${state.lastPosition!.accuracy.toStringAsFixed(1)} m'
                        : '--',
                    valueColor: (state.lastPosition?.accuracy ?? 100) < 15
                        ? Colors.green.shade700
                        : Colors.orange.shade800,
                  ),
                  const Divider(),
                  _buildStatRow(
                    'Ultimo Invio',
                    state.lastUpdateTime != null
                        ? _formatTime(state.lastUpdateTime!)
                        : '--',
                  ),
                  const Divider(),
                  _buildStatRow(
                    'Posizioni Inviate',
                    '${state.successCount}',
                    valueColor: Colors.green.shade700,
                  ),
                  const Divider(),
                  _buildStatRow(
                    'Errori Rete',
                    '${state.failureCount}',
                    valueColor: state.failureCount > 0 ? Colors.red : Colors.grey,
                  ),
                  if (state.queuedCount > 0) ...[
                    const Divider(),
                    _buildStatRow(
                      'In coda offline',
                      '${state.queuedCount}',
                      valueColor: Colors.orange.shade800,
                    ),
                  ],
                  if (state.lastError != null) ...[
                    const Divider(),
                    Text(
                      state.lastError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Stop Button
          SizedBox(
            height: 64,
            child: FilledButton.icon(
              onPressed: () => _confirmStopTracking(context),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.stop_rounded, size: 28),
              label: const Text(
                'STOP TRACCIAMENTO',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmStopTracking(BuildContext context) {
    final cubit = context.read<TrackingCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Terminare il tracciamento?'),
        content: const Text(
          'Vuoi davvero interrompere l\'invio della posizione GPS per questa processione?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogCtx);
              cubit.stopTracking();
            },
            child: const Text('Ferma Tracciamento'),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withAlpha(120),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, TrackingError state) {
    final cubit = context.read<TrackingCubit>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            if (state.canRetry)
              ElevatedButton.icon(
                onPressed: () => cubit.initialize(),
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}
