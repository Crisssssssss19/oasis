import 'package:oasis/domain/model/vacante_peticion.dart';
import 'package:oasis/domain/model/vacante_respuesta.dart';
import 'package:oasis/domain/repository/vacante_repository.dart';

class VacanteCasoUso {
  final VacanteRepositorio repository;

  const VacanteCasoUso(this.repository);

  Future<List<VacanteRespuesta>> call(VacantePeticion peticion) {
    return repository.obtenerVacantes(peticion);
  }
}
