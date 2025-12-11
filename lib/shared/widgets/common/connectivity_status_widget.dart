import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/connectivity_cubit.dart';

/// ConnectivityStatusWidget
/// Shows offline banner when device loses internet connection
/// Wraps your app content and displays a banner at top/bottom
class ConnectivityStatusWidget extends StatelessWidget {
  final Widget child;
  final bool showAtTop;
  final bool dismissible;
  final VoidCallback? onRetry;

  const ConnectivityStatusWidget({
    super.key,
    required this.child,
    this.showAtTop = true,
    this.dismissible = true,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        return Column(
          children: [
            if (showAtTop && state.showOfflineBanner)
              _OfflineBanner(
                dismissible: dismissible,
                onRetry: onRetry,
                onDismiss: () {
                  context.read<ConnectivityCubit>().dismissOfflineBanner();
                },
              ),
            Expanded(child: child),
            if (!showAtTop && state.showOfflineBanner)
              _OfflineBanner(
                dismissible: dismissible,
                onRetry: onRetry,
                onDismiss: () {
                  context.read<ConnectivityCubit>().dismissOfflineBanner();
                },
              ),
          ],
        );
      },
    );
  }
}

/// Offline Banner Widget
class _OfflineBanner extends StatelessWidget {
  final bool dismissible;
  final VoidCallback? onRetry;
  final VoidCallback onDismiss;

  const _OfflineBanner({
    required this.dismissible,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing16,
            vertical: DesignTokens.spacing12,
          ),
          child: Row(
            children: [
              const Icon(
                IconsaxPlusLinear.wifi_square,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: DesignTokens.spacing12),
              Expanded(
                child: Text(
                  'No internet connection',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Retry'),
                ),
              if (dismissible)
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated Offline Banner - Slides in/out smoothly
class AnimatedConnectivityBanner extends StatelessWidget {
  final Widget child;
  final Duration animationDuration;

  const AnimatedConnectivityBanner({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        return Column(
          children: [
            AnimatedContainer(
              duration: animationDuration,
              height: state.showOfflineBanner ? null : 0,
              child: AnimatedOpacity(
                duration: animationDuration,
                opacity: state.showOfflineBanner ? 1.0 : 0.0,
                child: _OfflineBanner(
                  dismissible: true,
                  onRetry: () {
                    context.read<ConnectivityCubit>().checkConnectivity();
                  },
                  onDismiss: () {
                    context.read<ConnectivityCubit>().dismissOfflineBanner();
                  },
                ),
              ),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

/// Connectivity Aware Builder
/// Build different widgets based on connectivity state
class ConnectivityAwareBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) onlineBuilder;
  final Widget Function(BuildContext context)? offlineBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  const ConnectivityAwareBuilder({
    super.key,
    required this.onlineBuilder,
    this.offlineBuilder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        if (!state.isInitialized) {
          return loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        if (!state.isConnected && offlineBuilder != null) {
          return offlineBuilder!(context);
        }

        return onlineBuilder(context);
      },
    );
  }
}

/// Simple Offline Indicator - Small dot indicator
class OfflineIndicator extends StatelessWidget {
  final double size;

  const OfflineIndicator({super.key, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        if (state.isConnected) return const SizedBox.shrink();

        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// Extension for easy connectivity check in widgets
extension ConnectivityContextExtension on BuildContext {
  bool get isOnline => read<ConnectivityCubit>().state.isConnected;
  bool get isOffline => !isOnline;
  ConnectivityState get connectivityState => read<ConnectivityCubit>().state;
}
