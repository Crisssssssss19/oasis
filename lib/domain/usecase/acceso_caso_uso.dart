import 'package:oasis/domain/model/acceso_respuesta.dart';
import 'package:oasis/domain/repository/acceso_repositorio.dart';

class AccesoCasoUso {
  final AccesoRepositorio repository;

  const AccesoCasoUso(this.repository);

  Future<AccesoRespuesta> call(String email, String password) {
    return repository.login(email, password);
  }
}