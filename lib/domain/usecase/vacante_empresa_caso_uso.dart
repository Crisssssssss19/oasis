import 'package:oasis/domain/model/vacante_respuesta.dart';
import 'package:oasis/domain/repository/vacante_empresa_repository.dart';

/// UseCase para obtener todas las vacantes
class ObtenerVacantesEmpresaCasoUso {
  final VacanteEmpresaRepositorio repository;

  const ObtenerVacantesEmpresaCasoUso(this.repository);

  Future<List<VacanteRespuesta>> call() {
    return repository.obtenerVacantes();
  }
}

/// UseCase para crear una vacante
/// ✅ CAMBIO: Ahora trabaja con palabrasClaveIds en lugar de palabrasClave
class CrearVacanteCasoUso {
  final VacanteEmpresaRepositorio repository;

  const CrearVacanteCasoUso(this.repository);

  Future<VacanteRespuesta> call({
    required String titulo,
    required String descripcion,
    required String minSalario,
    required String maxSalario,
    required int ubicacionId,
    required int jornadaId,
    required int modalidadId,
    required int tipoContratoId,
    required List<int> palabrasClaveIds, // ✅ CAMBIO: Recibir IDs
    required dynamic archivo,
    required String fechaInicio,
    required String fechaFin,
    int? idUsuario,
    int? idEmpresa,
  }) {
    return repository.crearVacante(
      titulo: titulo,
      descripcion: descripcion,
      minSalario: minSalario,
      maxSalario: maxSalario,
      ubicacionId: ubicacionId,
      jornadaId: jornadaId,
      modalidadId: modalidadId,
      tipoContratoId: tipoContratoId,
      palabrasClaveIds: palabrasClaveIds, // ✅ CAMBIO: Pasar IDs
      archivo: archivo,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      idUsuario: idUsuario,
      idEmpresa: idEmpresa,
    );
  }
}