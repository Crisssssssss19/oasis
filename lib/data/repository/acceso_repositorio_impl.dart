import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

import 'package:oasis/data/remote/acceso_api.dart';
import 'package:oasis/data/remote/dto/acceso_datos_dto.dart';
import 'package:oasis/data/remote/dto/api_respuesta.dart';
import 'package:oasis/domain/model/acceso_respuesta.dart';
import 'package:oasis/domain/repository/acceso_repositorio.dart';

class AccesoRepositorioImpl implements AccesoRepositorio {
  final AccesoApi api;

  AccesoRepositorioImpl(this.api);

  @override
  Future<AccesoRespuesta> login(String email, String password) async {
    try {
      final ApiRespuesta<AccesoDatosDto> response = await api.login(email, password);

      if (response.codigoEstado == 200 && response.datos != null) {
        final datos = response.datos!;

        // Decodificar imagen base64 a bytes (para uso inmediato en memoria)
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
        return AccesoRespuesta(
          success: false,
          message: response.error != null && response.error!.isNotEmpty
              ? "${response.mensaje} (${response.error})"
              : response.mensaje,
        );
      }
    } on DioException catch (e) {
      return AccesoRespuesta(
        success: false,
        message: "Error HTTP ${e.response?.statusCode ?? ''}: ${e.message}",
      );
    } catch (e) {
      return AccesoRespuesta(
        success: false,
        message: "Error inesperado: $e",
      );
    }
  }
}