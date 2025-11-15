import 'package:oasis/domain/model/vacante_peticion.dart';
import 'package:oasis/domain/model/vacante_respuesta.dart';

abstract class VacanteRepositorio {
  Future<List<VacanteRespuesta>> obtenerVacantes(VacantePeticion peticion);
}
