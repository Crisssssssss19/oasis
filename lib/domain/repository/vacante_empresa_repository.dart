import 'dart:io';
import 'package:oasis/domain/model/vacante_respuesta.dart';

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
    required List<String> palabrasClave,
    required File archivo,
  });
}