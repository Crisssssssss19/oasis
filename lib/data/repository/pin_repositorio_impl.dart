import 'package:dio/dio.dart';
import 'package:oasis/data/remote/dto/api_respuesta.dart';
import 'package:oasis/data/remote/dto/pin_datos_dto.dart';
import 'package:oasis/data/remote/dto/pin_peticion_dto.dart';
import 'package:oasis/data/remote/pin_api.dart';
import 'package:oasis/domain/model/pin_peticion.dart';
import 'package:oasis/domain/model/pin_respuesta.dart';
import 'package:oasis/domain/repository/pin_repositorio.dart';

class PinRepositorioImpl implements PinRepositorio {
  final PinApi api;

  PinRepositorioImpl(this.api);

  @override
  Future<PinRespuesta> solicitarPin(PinPeticion peticion) async {
    try {
      final ApiRespuesta<PinDatosDto> response = await api.solicitarPin(
        PinPeticionDto(telefonoAcceso: peticion.telefonoAcceso),
      );
      // print(">>> [TONGEO] codigoEstado: ${response.codigoEstado}");
      // print(">>> [TONGEO] mensaje: ${response.mensaje}");
      // print(">>> [TONGEO] error: ${response.error}");

      if (response.codigoEstado == 200 && response.datos != null) {
        final datos = response.datos!;
        return PinRespuesta(
          exito: true,
          mensaje: response.mensaje,
          idTelefonoPinTemporal: datos.idTelefonoPinTemporal,
          valorPinTemporal: datos.valorPinTemporal,
          fechaCreacionPinTemporal: datos.fechaCreacionPinTemporal,
          intentoPinTemporal: datos.intentoPinTemporal,
          totalIntentosPinTemporal: datos.totalIntentosPinTemporal,
          minutosSuspensionPinTemporal: datos.minutosSuspensionPinTemporal,
          smsEnviado: datos.smsEnviado,
        );
      } else {
        return PinRespuesta(
          exito: false,
          mensaje: response.mensaje,
          error: response.error,
        );
      }
    } on DioException catch (e) {
      return PinRespuesta(
        exito: false,
        mensaje: "Error HTTP ${e.response?.statusCode ?? ''}: ${e.message}",
      );
    } catch (e) {
      return PinRespuesta(exito: false, mensaje: "Error inesperado: $e");
    }
  }
}
