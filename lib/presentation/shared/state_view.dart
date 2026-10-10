import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failure.dart';

class StateView<T> extends ConsumerWidget {
  final AsyncValue<T> state;
  final Widget Function(T data) dataBuilder;
  final Widget Function()? emptyBuilder;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;

  const StateView({
    super.key,
    required this.state,
    required this.dataBuilder,
    this.emptyBuilder,
    this.onRetry,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return state.when(
      data: (data) {
        if (isEmpty != null && isEmpty!(data)) {
          return emptyBuilder != null
              ? emptyBuilder!()
              : const Center(child: Text('No hay datos disponibles.'));
        }
        return dataBuilder(data);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        String message = 'Ocurrió un error inesperado.';
        if (error is Failure) {
          message = error.message;
        } else if (error is Exception) {
          message = error.toString();
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Reintentar'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
