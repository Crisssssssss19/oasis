import 'package:oasis/domain/model/acceso_respuesta.dart';

abstract class AccesoRepositorio {
  Future<AccesoRespuesta> login(String email, String password);
}