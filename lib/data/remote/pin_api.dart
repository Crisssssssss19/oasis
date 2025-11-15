import 'package:dio/dio.dart';
import 'package:oasis/data/remote/dto/api_respuesta.dart';
import 'package:oasis/data/remote/dto/pin_datos_dto.dart';
import 'package:oasis/data/remote/dto/pin_peticion_dto.dart';

class PinApi {
  final Dio _dio;

  PinApi(this._dio);

  Future<ApiRespuesta<PinDatosDto>> solicitarPin(PinPeticionDto dto) async {
    try {
      // final body = dto.toJson();
      // print("[TONGEO] Enviando body: $body");

      final response = await _dio.post(
        'user/pin',
        data: dto.toJson(),
        // data: body,
        options: Options(validateStatus: (status) => true),
      );

      return ApiRespuesta.fromJson(
        response.data as Map<String, dynamic>,
        (json) => PinDatosDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiRespuesta.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiRespuesta<PinDatosDto>(
        codigoEstado: e.response?.statusCode ?? -1,
        mensaje: e.message ?? 'Error desconocido',
        fechaHora: DateTime.now().toIso8601String(),
        datos: null,
        error: e.error?.toString(),
      );
    }
  }
}
