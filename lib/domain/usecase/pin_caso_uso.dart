import 'package:oasis/domain/model/pin_peticion.dart';
import 'package:oasis/domain/model/pin_respuesta.dart';
import 'package:oasis/domain/repository/pin_repositorio.dart';

class PinCasoUso {
  final PinRepositorio repository;
  const PinCasoUso(this.repository);

  Future<PinRespuesta> call(PinPeticion peticion) {
    return repository.solicitarPin(peticion);
  }
}

