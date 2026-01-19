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
        title: const Text('Tracker App'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<TrackingCubit, TrackingState>(
        listener: (context, state) {
          if (state is TrackingConfigured && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
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
    // Initialize text controllers
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
          // Configuration Section
          _buildSectionHeader(context, '⚙️ Configuration'),
          const SizedBox(height: 8),
          _buildConfigCard(context, state),
          const SizedBox(height: 24),

          // Status Section
          _buildSectionHeader(context, '📍 Status'),
          const SizedBox(height: 8),
          _buildStatusCard(context, state),
          const SizedBox(height: 32),

          // Start Button
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Server URL
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                hintText: 'http://localhost:5000/api',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => cubit.updateServerUrl(value),
            ),
            const SizedBox(height: 16),

            // Confraternity Dropdown
            _buildConfraternityDropdown(context, state),
            const SizedBox(height: 16),

            // Secret
            TextField(
              controller: _secretController,
              decoration: const InputDecoration(
                labelText: 'Secret',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onChanged: (value) => cubit.updateConfig(secret: value),
            ),
            const SizedBox(height: 16),

            // Update Interval
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
              'No confraternities loaded',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
          IconButton(
            onPressed: () => cubit.fetchConfraternities(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh confraternities',
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
      value: selectedConfraternity,
      decoration: const InputDecoration(
        labelText: 'Confraternity',
        border: OutlineInputBorder(),
      ),
      items: state.confraternities.map((c) {
        return DropdownMenuItem(
          value: c,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _parseColor(c.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(c.name, overflow: TextOverflow.ellipsis)),
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
          'Update Interval: ${state.config.intervalSeconds} seconds',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: intervals.map((interval) {
            return ButtonSegment(value: interval, label: Text('${interval}s'));
          }).toList(),
          selected: {state.config.intervalSeconds},
          onSelectionChanged: (selected) {
            cubit.updateConfig(intervalSeconds: selected.first);
          },
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, TrackingConfigured state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('INACTIVE'),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Last: --'),
            const Text('Updates: 0 sent'),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, TrackingConfigured state) {
    final cubit = context.read<TrackingCubit>();
    final isConfigured = state.config.confraternityId.isNotEmpty;

    return SizedBox(
      height: 80,
      child: ElevatedButton(
        onPressed: isConfigured ? () => cubit.startTracking() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'START TRACKING',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildActiveView(BuildContext context, TrackingActive state) {
    final cubit = context.read<TrackingCubit>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tracking Info Card
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPulsingIndicator(),
                      const SizedBox(width: 8),
                      const Text(
                        'TRACKING ACTIVE',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Confraternity: ${state.config.confraternityName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Interval: ${state.config.intervalSeconds}s',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow(
                    'Last Position',
                    state.lastPosition != null
                        ? '${state.lastPosition!.latitude.toStringAsFixed(4)}, ${state.lastPosition!.longitude.toStringAsFixed(4)}'
                        : '--',
                  ),
                  const Divider(),
                  _buildStatRow(
                    'Last Update',
                    state.lastUpdateTime != null
                        ? _formatTime(state.lastUpdateTime!)
                        : '--',
                  ),
                  const Divider(),
                  _buildStatRow(
                    'Success',
                    '${state.successCount}',
                    valueColor: Colors.green,
                  ),
                  const Divider(),
                  _buildStatRow(
                    'Failed',
                    '${state.failureCount}',
                    valueColor: state.failureCount > 0
                        ? Colors.red
                        : Colors.grey,
                  ),
                  if (state.lastError != null) ...[
                    const Divider(),
                    Text(
                      state.lastError!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Spacer(),

          // Stop Button
          SizedBox(
            height: 80,
            child: ElevatedButton(
              onPressed: () => cubit.stopTracking(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'STOP TRACKING',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
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
          Text(label),
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
              ElevatedButton(
                onPressed: () => cubit.initialize(),
                child: const Text('Retry'),
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
