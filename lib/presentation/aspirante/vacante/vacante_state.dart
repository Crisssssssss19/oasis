import 'package:oasis/domain/model/vacante_respuesta.dart';

/// Estado base para el flujo de vacantes.
/// Usamos sealed class para que el switch sea exhaustivo.
sealed class VacanteState {
  const VacanteState();
}

/// Estado inicial/cargando
class VacanteLoading extends VacanteState {
  const VacanteLoading();
}

/// Estado con datos cargados
class VacanteData extends VacanteState {
  final List<VacanteRespuesta> vacantes;
  final int currentIndex;

  const VacanteData(this.vacantes, {this.currentIndex = 0});

  VacanteData copyWith({List<VacanteRespuesta>? vacantes, int? currentIndex}) {
    return VacanteData(
      vacantes ?? this.vacantes,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

/// Estado de error
class VacanteError extends VacanteState {
  final String mensaje;

  const VacanteError(this.mensaje);
}
