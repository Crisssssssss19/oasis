import 'package:dio/dio.dart';

import 'package:oasis/data/remote/dto/api_respuesta.dart';
import 'package:oasis/data/remote/dto/vacante_datos_dto.dart';
import 'package:oasis/data/remote/vacante_api.dart';
import 'package:oasis/domain/model/vacante_peticion.dart';
import 'package:oasis/domain/model/vacante_respuesta.dart';
import 'package:oasis/domain/repository/vacante_repository.dart';
import 'package:oasis/mapper/vacante_mapper.dart';

class VacanteRepositorioImpl implements VacanteRepositorio {
  final VacanteApi api;

  VacanteRepositorioImpl(this.api);

  @override
  Future<List<VacanteRespuesta>> obtenerVacantes(
    VacantePeticion peticion,
  ) async {
    try {
      final ApiRespuesta<List<VacanteDatosDto>> response = await api
          .obtenerVacantes(peticion.toDto());

      return _procesarRespuesta(response);
    } on DioException catch (e) {
      throw Exception(
        "Error HTTP ${e.response?.statusCode ?? ''}: ${e.message}",
      );
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  // ***************************************************************************
  List<VacanteRespuesta> _procesarRespuesta(
    ApiRespuesta<List<VacanteDatosDto>> response,
  ) {
    switch (response.codigoEstado) {
      case 200:
        if (response.datos != null) {
          return response.datos!.map((dto) => dto.toDomain()).toList();
        } else {
          throw Exception('Respuesta 200 sin datos válidos');
        }

      case 204:
        return [];

      case 400:
        throw Exception(
          'Petición inválida: ${response.mensaje}'
          '${response.error != null ? " (${response.error})" : ""}',
        );

      case 401:
        throw Exception(
          'No autorizado: ${response.mensaje}'
          '${response.error != null ? " (${response.error})" : ""}',
        );

      case 500:
        throw Exception(
          'Error interno del servidor: ${response.mensaje}'
          '${response.error != null ? " (${response.error})" : ""}',
        );

      default:
        throw Exception(
          'Error inesperado [${response.codigoEstado}]: ${response.mensaje}'
          '${response.error != null ? " (${response.error})" : ""}',
        );
    }
  }
}
