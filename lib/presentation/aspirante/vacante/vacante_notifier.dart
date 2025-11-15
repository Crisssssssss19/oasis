import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/domain/model/vacante_peticion.dart';
import 'package:oasis/domain/usecase/vacante_caso_uso.dart';
import 'vacante_state.dart';

class VacanteNotifier extends StateNotifier<VacanteState> {
  final VacanteCasoUso casoUso;

  VacanteNotifier(this.casoUso) : super(const VacanteLoading()) {
    _init();
  }

  /// Inicialización automática al crear el notifier
  Future<void> _init() async {
    await cargarVacantes();
  }

  /// Carga de vacantes desde el caso de uso
  Future<void> cargarVacantes() async {
    state = const VacanteLoading();
    try {
      final vacantes = await casoUso(
        const VacantePeticion(
          campoOrden: 'v.fecha_inicio_vacante',
          orden: 'ASC',
        ),
      );
      state = VacanteData(vacantes, currentIndex: 0);
    } catch (e) {
      state = VacanteError(e.toString());
    }
  }

  /// Permite actualizar el índice actual del PageView
  void setCurrentIndex(int index) {
    if (state case VacanteData(:final vacantes, :final currentIndex)) {
      if (index != currentIndex) {
        state = VacanteData(vacantes, currentIndex: index);
      }
    }
  }
}