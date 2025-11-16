import 'dart:io';
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
    required List<String> palabrasClave,
    required File archivo,
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
      palabrasClave: palabrasClave,
      archivo: archivo,
    );
  }
}