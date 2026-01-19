/// State overlay widgets for loading, error, and empty states.
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'skeleton_loader.dart';

/// Unified state overlay for loading, error, and empty states.
class StateOverlay extends StatelessWidget {
  const StateOverlay({
    super.key,
    required this.state,
    required this.child,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
  });

  /// Current state.
  final OverlayState state;

  /// Content to show in success state.
  final Widget child;

  /// Custom loading widget builder.
  final Widget Function()? loadingBuilder;

  /// Custom error widget builder.
  final Widget Function(String? message, VoidCallback? onRetry)? errorBuilder;

  /// Custom empty state widget builder.
  final Widget Function()? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case OverlayState.loading:
        return loadingBuilder?.call() ?? const LoadingState();
      case OverlayState.error:
        return errorBuilder?.call(null, null) ?? const ErrorState();
      case OverlayState.empty:
        return emptyBuilder?.call() ?? const EmptyState();
      case OverlayState.success:
        return child;
    }
  }
}

/// Available overlay states.
enum OverlayState { loading, error, empty, success }

/// Loading state with spinning indicator or skeleton.
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message,
    this.useSkeleton = false,
    this.skeletonItemCount = 5,
  });

  final String? message;
  final bool useSkeleton;
  final int skeletonItemCount;

  @override
  Widget build(BuildContext context) {
    if (useSkeleton) {
      return SkeletonList(itemCount: skeletonItemCount);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state with retry action.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.onRetry,
    this.retryLabel,
  });

  final IconData? icon;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'Qualcosa è andato storto',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel ?? 'Riprova'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state placeholder.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.action,
    this.actionLabel,
    this.onAction,
  });

  final IconData? icon;
  final String? title;
  final String? message;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'Nessun elemento',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ] else if (onAction != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel ?? 'Aggiungi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Connection error state (special case of error).
class ConnectionErrorState extends StatelessWidget {
  const ConnectionErrorState({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.wifi_off_rounded,
      title: 'Nessuna connessione',
      message: 'Controlla la tua connessione internet e riprova.',
      onRetry: onRetry,
    );
  }
}

/// Server error state (special case of error).
class ServerErrorState extends StatelessWidget {
  const ServerErrorState({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.cloud_off_rounded,
      title: 'Errore del server',
      message: 'Si è verificato un problema. Riprova più tardi.',
      onRetry: onRetry,
    );
  }
}

/// Inline error banner (for partial errors).
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Riprova')),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 20),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

/// Success message banner.
class SuccessBanner extends StatelessWidget {
  const SuccessBanner({super.key, required this.message, this.onDismiss});

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSuccessContainer,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 20),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
