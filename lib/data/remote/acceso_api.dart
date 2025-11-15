import 'package:dio/dio.dart';
import 'package:oasis/data/remote/dto/acceso_datos_dto.dart';
import 'package:oasis/data/remote/dto/api_respuesta.dart';

class AccesoApi {
  final Dio _dio;

  AccesoApi(this._dio);

  Future<ApiRespuesta<AccesoDatosDto>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'auth/login',
        data: {
          'correoAcceso': email,
          'claveAcceso': password,
        },
        options: Options(validateStatus: (status) => true),
      );

      if (response.statusCode == 200) {
        return ApiRespuesta.fromJson(
          response.data as Map<String, dynamic>,
              (json) => AccesoDatosDto.fromJson(json as Map<String, dynamic>),
        );
      } else {
        return ApiRespuesta.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiRespuesta.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiRespuesta<AccesoDatosDto>(
        codigoEstado: e.response?.statusCode ?? -1,
        mensaje: e.message ?? 'Error desconocido',
        fechaHora: DateTime.now().toIso8601String(),
        datos: null,
        error: e.error?.toString(),
      );
    }
  }
}