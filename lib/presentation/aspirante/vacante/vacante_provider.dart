  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:oasis/core/di/providers.dart';
  import 'package:oasis/presentation/aspirante/vacante/vacante_notifier.dart';
  import 'package:oasis/presentation/aspirante/vacante/vacante_state.dart';

  final vacanteNotifierProvider =
      StateNotifierProvider<VacanteNotifier, VacanteState>((ref) {
        final casoUso = ref.watch(vacanteUseCaseProvider);
        return VacanteNotifier(casoUso);
      });
