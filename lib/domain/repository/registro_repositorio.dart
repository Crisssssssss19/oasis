import 'package:oasis/domain/model/acceso_respuesta.dart';
import 'package:oasis/domain/model/registro_peticion.dart';

abstract class RegistroRepositorio {
  Future<AccesoRespuesta> registrarAspirante(RegistroPeticion peticion);
}
