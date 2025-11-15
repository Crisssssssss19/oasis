import 'package:oasis/domain/model/acceso_respuesta.dart';
import 'package:oasis/domain/model/registro_peticion.dart';
import 'package:oasis/domain/repository/registro_repositorio.dart';

class RegistroCasoUso {
  final RegistroRepositorio repository;

  const RegistroCasoUso(this.repository);

  Future<AccesoRespuesta> call(RegistroPeticion peticion) {
    return repository.registrarAspirante(peticion);
  }
}
