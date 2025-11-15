import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/core/di/providers.dart';
import 'registro_paso3_notifier.dart';
import 'registro_paso3_state.dart';

final registroPaso3Provider =
    StateNotifierProvider.autoDispose<
      RegistroPaso3Notifier,
      RegistroPaso3State
    >((ref) {
      final casoUso = ref.watch(registroUseCaseProvider);
      return RegistroPaso3Notifier(casoUso, ref);
    });
