import 'package:dio/dio.dart';
import 'package:oasis/data/remote/dto/acceso_datos_dto.dart';
import 'package:oasis/data/remote/dto/api_respuesta.dart';
import 'package:oasis/data/remote/dto/registro_peticion_dto.dart';

class RegistroApi {
  final Dio _dio;

  RegistroApi(this._dio);

  Future<ApiRespuesta<AccesoDatosDto>> crearCuenta(RegistroPeticionDto dto) async {
    try {
      // final body = dto.toJson();
      // print("[TONGEO] Enviando body: $body");

      final response = await _dio.post(
        'user/register',
        data: dto.toJson(),
        // data: body,
        options: Options(validateStatus: (status) => true),
      );

      return ApiRespuesta.fromJson(
        response.data as Map<String, dynamic>,
        (json) => AccesoDatosDto.fromJson(json as Map<String, dynamic>),
      );
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
