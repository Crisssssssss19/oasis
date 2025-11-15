import 'dart:io';
import 'package:dio/dio.dart';
import 'package:oasis/data/remote/dto/api_respuesta.dart';
import 'package:oasis/data/remote/dto/vacante_datos_dto.dart';

class VacanteEmpresaApi {
  final Dio _dio;

  VacanteEmpresaApi(this._dio);

  /// Obtiene todas las vacantes (puede filtrar por empresa si el backend lo soporta)
  /// Por ahora usa el endpoint existente que ordena por fecha
  Future<ApiRespuesta<List<VacanteDatosDto>>> obtenerVacantes({
    String campoOrden = 'v.fecha_inicio_vacante',
    String orden = 'DESC',
  }) async {
    try {
      final response = await _dio.get(
        'vacancy/get-all',
        queryParameters: {
          'campoOrden': campoOrden,
          'orden': orden,
        },
        options: Options(
          extra: {"tokenRequerido": true},
          validateStatus: (status) => true,
        ),
      );

      return ApiRespuesta.fromJson(
        response.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>)
            .map((e) => VacanteDatosDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiRespuesta.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiRespuesta<List<VacanteDatosDto>>(
        codigoEstado: e.response?.statusCode ?? -1,
        mensaje: e.message ?? 'Error desconocido',
        fechaHora: DateTime.now().toIso8601String(),
        datos: null,
        error: e.error?.toString(),
      );
    }
  }

  /// Crea una nueva vacante usando el endpoint POST /vacancy/add
  /// Según tu VacanteCrearControlador, recibe @ModelAttribute VacanteDTOCrear
  Future<ApiRespuesta<VacanteDatosDto>> crearVacante({
    required String tituloVacante,
    required String descripcionVacante,
    required String minSalarioVacante,
    required String maxSalarioVacante,
    required int idUbicacion,
    required int idJornada,
    required int idModalidad,
    required int idTipoContrato,
    required String palabrasClave, // separadas por comas
    required File archivo,
  }) async {
    try {
      // Crear FormData exactamente como lo espera tu backend
      final formData = FormData.fromMap({
        'tituloVacante': tituloVacante,
        'descripcionVacante': descripcionVacante,
        'minSalarioVacante': minSalarioVacante,
        'maxSalarioVacante': maxSalarioVacante,
        'idUbicacion': idUbicacion,
        'idJornada': idJornada,
        'idModalidad': idModalidad,
        'idTipoContrato': idTipoContrato,
        'palabrasClave': palabrasClave,
        'archivo': await MultipartFile.fromFile(
          archivo.path,
          filename: archivo.path.split('/').last,
        ).catchError((_) async {
          // Fallback para Web: usar bytes en lugar de path
          final bytes = await archivo.readAsBytes();
          return MultipartFile.fromBytes(
            bytes,
            filename: archivo.path.split('/').last,
          );
        }),
      });

      final response = await _dio.post(
        'vacancy/add',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          extra: {"tokenRequerido": true},
          validateStatus: (status) => true,
        ),
      );

      return ApiRespuesta.fromJson(
        response.data as Map<String, dynamic>,
        (json) => VacanteDatosDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiRespuesta.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiRespuesta<VacanteDatosDto>(
        codigoEstado: e.response?.statusCode ?? -1,
        mensaje: e.message ?? 'Error desconocido',
        fechaHora: DateTime.now().toIso8601String(),
        datos: null,
        error: e.error?.toString(),
      );
    }
  }
}