import 'package:oasis/domain/model/pin_peticion.dart';
import 'package:oasis/domain/model/pin_respuesta.dart';

abstract class PinRepositorio {
  Future<PinRespuesta> solicitarPin(PinPeticion peticion);
}
