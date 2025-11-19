import 'package:oasis/domain/model/vacante_respuesta.dart';

/// ✅ CAMBIO: Interface actualizada para trabajar con IDs de palabras clave
abstract class VacanteEmpresaRepositorio {
  /// Obtiene todas las vacantes
  Future<List<VacanteRespuesta>> obtenerVacantes();

  /// Crea una nueva vacante
  Future<VacanteRespuesta> crearVacante({
    required String titulo,
    required String descripcion,
    required String minSalario,
    required String maxSalario,
    required int ubicacionId,
    required int jornadaId,
    required int modalidadId,
    required int tipoContratoId,
    required List<int> palabrasClaveIds, // ✅ CAMBIO: IDs en lugar de nombres
    required dynamic archivo,
    required String fechaInicio,
    required String fechaFin,
    int? idUsuario,
    int? idEmpresa,
  });
}