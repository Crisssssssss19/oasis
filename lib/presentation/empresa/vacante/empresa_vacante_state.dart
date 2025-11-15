import 'package:oasis/domain/model/vacante_respuesta.dart';

/// Estados para el flujo de vacantes de empresa
sealed class EmpresaVacanteState {
  const EmpresaVacanteState();
}

/// Estado inicial/cargando
class EmpresaVacanteLoading extends EmpresaVacanteState {
  const EmpresaVacanteLoading();
}

/// Estado con vacantes cargadas
class EmpresaVacanteData extends EmpresaVacanteState {
  final List<VacanteRespuesta> vacantes;
  final int totalPostulaciones;

  const EmpresaVacanteData({
    required this.vacantes,
    this.totalPostulaciones = 0,
  });

  EmpresaVacanteData copyWith({
    List<VacanteRespuesta>? vacantes,
    int? totalPostulaciones,
  }) {
    return EmpresaVacanteData(
      vacantes: vacantes ?? this.vacantes,
      totalPostulaciones: totalPostulaciones ?? this.totalPostulaciones,
    );
  }
}

/// Estado de error
class EmpresaVacanteError extends EmpresaVacanteState {
  final String mensaje;

  const EmpresaVacanteError(this.mensaje);
}

/// Estado creando vacante
class EmpresaVacanteCreando extends EmpresaVacanteState {
  const EmpresaVacanteCreando();
}

/// Estado vacante creada exitosamente
class EmpresaVacanteCreada extends EmpresaVacanteState {
  final VacanteRespuesta vacante;

  const EmpresaVacanteCreada(this.vacante);
}