import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/core/di/providers.dart';
import 'package:oasis/presentation/acceso/acceso_notifier.dart';
import 'package:oasis/presentation/acceso/acceso_state.dart';

final accesoProvider =
    StateNotifierProvider.autoDispose<AccesoNotifier, AccesoState>((ref) {
      final loginUseCase = ref.watch(loginUseCaseProvider);
      return AccesoNotifier(loginUseCase, ref);
    });
