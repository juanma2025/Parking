import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failure.dart';
import 'empty_state.dart';
import 'error_state.dart';
import 'skeleton_card.dart';

class StateView<T> extends ConsumerWidget {
  final AsyncValue<T> state;
  final Widget Function(T data) dataBuilder;
  final Widget Function()? emptyBuilder;
  final Widget Function()? loadingBuilder;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;

  const StateView({
    super.key,
    required this.state,
    required this.dataBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.onRetry,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget content = state.when(
      data: (data) {
        if (isEmpty != null && isEmpty!(data)) {
          return emptyBuilder != null
              ? emptyBuilder!()
              : const EmptyState(
                  title: 'Sin datos aún',
                  message: 'No encontramos registros para mostrar en este momento.',
                );
        }
        return dataBuilder(data);
      },
      loading: () {
        if (loadingBuilder != null) return loadingBuilder!();
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: SkeletonCard(height: 140),
          ),
        );
      },
      error: (error, stack) {
        String message = 'No pudimos cargar la información. Intenta nuevamente.';
        if (error is Failure) {
          message = error.message;
        }

        return ErrorState(
          message: message,
          onRetry: onRetry,
        );
      },
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: content,
    );
  }
}
