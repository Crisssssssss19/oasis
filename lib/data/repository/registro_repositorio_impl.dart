import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

import 'package:oasis/data/remote/dto/acceso_datos_dto.dart';
import 'package:oasis/data/remote/dto/api_respuesta.dart';
import 'package:oasis/data/remote/dto/registro_peticion_dto.dart';
import 'package:oasis/data/remote/registro_api.dart';
import 'package:oasis/domain/model/acceso_respuesta.dart';
import 'package:oasis/domain/model/registro_peticion.dart';
import 'package:oasis/domain/repository/registro_repositorio.dart';

class RegistroRepositorioImpl implements RegistroRepositorio {
  final RegistroApi api;

  RegistroRepositorioImpl(this.api);

  @override
  Future<AccesoRespuesta> registrarAspirante(RegistroPeticion peticion) async {
    try {
      final ApiRespuesta<AccesoDatosDto> response = await api.crearCuenta(
        RegistroPeticionDto(
          telefonoAcceso: peticion.telefonoAcceso,
          nombresUsuario: peticion.nombresUsuario,
          apellidosUsuario: peticion.apellidosUsuario,
          correoAcceso: peticion.correoAcceso,
          claveAcceso: peticion.claveAcceso,
        ),
      );
      // print(">>> [TONGEO] codigoEstado: ${response.codigoEstado}");
      // print(">>> [TONGEO] mensaje: ${response.mensaje}");
      // print(">>> [TONGEO] error: ${response.error}");

      if (response.codigoEstado == 200 && response.datos != null) {
        final datos = response.datos!;

        Uint8List? imageBytes;
        try {
          imageBytes = base64Decode(datos.fotoApp);
        } catch (_) {
          imageBytes = null;
        }

        return AccesoRespuesta(
          success: true,
          token: datos.tokenApp,
          profileImage: imageBytes,
          expiresAt: datos.expiraEn,
          message: response.mensaje,
        );
      } else {
        return AccesoRespuesta(success: false, message: response.mensaje);
      }
    } on DioException catch (e) {
      return AccesoRespuesta(
        success: false,
        message: "Error HTTP ${e.response?.statusCode ?? ''}: ${e.message}",
      );
    } catch (e) {
      return AccesoRespuesta(success: false, message: "Error inesperado: $e");
    }
  }
}
