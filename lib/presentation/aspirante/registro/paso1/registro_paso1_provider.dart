import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/core/di/providers.dart';
import 'package:oasis/presentation/aspirante/registro/paso1/registro_paso1_notifier.dart';
import 'package:oasis/presentation/aspirante/registro/paso1/registro_paso1_state.dart';

final registroPaso1Provider =
    StateNotifierProvider.autoDispose<
      RegistroPaso1Notifier,
      RegistroPaso1State
    >((ref) {
      final pinCasoUso = ref.watch(solicitarPinUseCaseProvider);
      final notifier = RegistroPaso1Notifier(pinCasoUso);
      // notifier.reset();
      return notifier;
    });
