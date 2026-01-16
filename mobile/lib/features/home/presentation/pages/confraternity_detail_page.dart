/// Confraternity detail page.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/repositories/home_repository.dart';
import '../cubit/home_cubit.dart';

/// Page showing detailed information about a confraternity.
class ConfraternityDetailPage extends StatelessWidget {
  const ConfraternityDetailPage({
    super.key,
    required this.args,
  });

  final ConfraternityDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(args.confraternityColor);

    return BlocProvider(
      create: (context) => HomeCubit(
        repository: context.read<HomeRepository>(),
      )..loadData(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Hero header with confraternity color
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: color,
              foregroundColor: _contrastColor(color),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  args.confraternityName,
                  style: TextStyle(
                    color: _contrastColor(color),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withAlpha(200),
                        color,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.church,
                      size: 80,
                      color: _contrastColor(color).withAlpha(100),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.status == HomeStatus.loading) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final confraternity = state.confraternities
                      .where((c) => c.id == args.confraternityId)
                      .firstOrNull;

                  if (confraternity == null) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Confraternita non trovata')),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Municipality
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.location_city),
                            title: const Text('Comune'),
                            subtitle: Text(confraternity.municipality),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // History section
                        Text(
                          'Storia',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          confraternity.history ?? 
                              'La storia di questa confraternita sarà disponibile a breve.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),

                        // Actions
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.tracking,
                              );
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('Vedi sulla mappa'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  Color _contrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
