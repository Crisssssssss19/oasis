import 'package:dio/dio.dart';
import 'package:oasis/data/remote/dto/api_respuesta.dart';
import 'package:oasis/data/remote/dto/vacante_datos_dto.dart';
import 'package:oasis/data/remote/dto/vacante_peticion_dto.dart';

class VacanteApi {
  final Dio _dio;

  VacanteApi(this._dio);

  Future<ApiRespuesta<List<VacanteDatosDto>>> obtenerVacantes(
    VacantePeticionDto dto,
  ) async {
    try {
      final response = await _dio.get(
        'vacancy/get-all',
        queryParameters: dto.toJson(),
        options: Options(extra: {"tokenRequerido": true}),
      );

      return ApiRespuesta.fromJson(
        response.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>)
            .map((e) => VacanteDatosDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiRespuesta.fromJson(
          e.response!.data as Map<String, dynamic>,
          (json) => (json as List<dynamic>)
              .map((e) => VacanteDatosDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
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
}
