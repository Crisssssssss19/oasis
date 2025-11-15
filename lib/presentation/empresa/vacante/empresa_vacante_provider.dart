import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/presentation/empresa/vacante/empresa_vacante_notifier.dart';
import 'package:oasis/presentation/empresa/vacante/empresa_vacante_state.dart';

final empresaVacanteProvider =
    StateNotifierProvider.autoDispose<EmpresaVacanteNotifier, EmpresaVacanteState>((ref) {
  return EmpresaVacanteNotifier(ref);
});