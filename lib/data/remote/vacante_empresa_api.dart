import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:oasis/data/remote/dto/api_respuesta.dart';
import 'package:oasis/data/remote/dto/vacante_datos_dto.dart';

class VacanteEmpresaApi {
  final Dio _dio;

  VacanteEmpresaApi(this._dio);

  /// Obtiene todas las vacantes (puede filtrar por empresa si el backend lo soporta)
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
  /// Coincide exactamente con VacanteDTOCrear del backend
  Future<ApiRespuesta<VacanteDatosDto>> crearVacante({
    required String tituloVacante,
    required String detalleVacante,
    required String minSalarioVacante,
    required String maxSalarioVacante,
    required int idUbicacion,
    required int idJornada,
    required int idModalidad,
    required int idTipoContrato,
    required String idsPalabrasClaveTexto, // JSON string con array de IDs
    required String fechaInicio,
    required String fechaFin,
    int? idUsuario,
    int? idEmpresa,
    required dynamic archivo,
  }) async {
    try {
      print('🔧 [API] Creando vacante con:');
      print('  - tituloVacante: $tituloVacante');
      print('  - idsPalabrasClaveTexto: $idsPalabrasClaveTexto');
      print('  - archivo: ${archivo is XFile ? archivo.name : archivo.path}');

      // Crear MultipartFile dependiendo de la plataforma
      MultipartFile multipartFile;
      if (kIsWeb) {
        // En web `archivo` suele ser XFile
        Uint8List bytes;
        String filename = 'upload.bin';
        if (archivo is XFile) {
          bytes = await archivo.readAsBytes();
          filename = archivo.name;
        } else {
          try {
            bytes = await archivo.readAsBytes();
          } catch (e) {
            throw Exception('No se pudo leer el archivo en web: $e');
          }
        }

        // Inferir mime type por extensión simple
        String ext = '';
        final idx = filename.lastIndexOf('.');
        if (idx != -1 && idx < filename.length - 1) ext = filename.substring(idx + 1).toLowerCase();
        String mimeMain = 'application';
        String mimeSub = 'octet-stream';
        if (ext == 'jpg' || ext == 'jpeg') {
          mimeMain = 'image';
          mimeSub = 'jpeg';
        } else if (ext == 'png') {
          mimeMain = 'image';
          mimeSub = 'png';
        } else if (ext == 'gif') {
          mimeMain = 'image';
          mimeSub = 'gif';
        } else if (ext == 'webp') {
          mimeMain = 'image';
          mimeSub = 'webp';
        }

        // Si no pudimos inferir por extensión, intentar por magic bytes (más fiable)
        if (mimeMain == 'application' && mimeSub == 'octet-stream') {
          if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
            mimeMain = 'image';
            mimeSub = 'jpeg';
            if (!filename.contains('.')) filename = '$filename.jpg';
          } else if (bytes.length >= 4 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
            mimeMain = 'image';
            mimeSub = 'png';
            if (!filename.contains('.')) filename = '$filename.png';
          } else if (bytes.length >= 3 && bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
            mimeMain = 'image';
            mimeSub = 'gif';
            if (!filename.contains('.')) filename = '$filename.gif';
          } else {
            // Fallback conservador: intentar enviar como jpeg
            mimeMain = 'image';
            mimeSub = 'jpeg';
            if (!filename.contains('.')) filename = '$filename.jpg';
          }
        }

        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: MediaType(mimeMain, mimeSub),
        );
      } else {
        try {
          // Intenta usar fromFile (Android/iOS)
          multipartFile = await MultipartFile.fromFile(
            archivo.path,
            filename: archivo.path.split('/').last,
          );
        } catch (e) {
          // Fallback para otros entornos: usar bytes
          final bytes = await archivo.readAsBytes();
          multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: archivo.path.split('/').last,
          );
        }
      }

      // Crear FormData exactamente como lo espera el backend
      final formData = FormData.fromMap({
        'tituloVacante': tituloVacante,
        'detalleVacante': detalleVacante,
        'minSalarioVacante': minSalarioVacante,
        'maxSalarioVacante': maxSalarioVacante,
        'idUbicacion': idUbicacion,
        'idJornada': idJornada,
        'idModalidad': idModalidad,
        'idTipoContrato': idTipoContrato,
        'idsPalabrasClaveTexto': idsPalabrasClaveTexto,
        if (idUsuario != null) 'idUsuario': idUsuario,
        if (idEmpresa != null) 'idEmpresa': idEmpresa,
        // Fechas (incluir variantes por compatibilidad con backend)
        'fechainicioVacante': fechaInicio,
        'fechaInicioVacante': fechaInicio,
        'fechaFinVacante': fechaFin,
        // Estado por defecto (1 = activo)
        'estadoVacante': 1,
        'archivo': multipartFile,
      });

      print('🚀 [API] Enviando FormData al endpoint /vacancy/add');

      final response = await _dio.post(
        'vacancy/add',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          extra: {"tokenRequerido": true},
          validateStatus: (status) => true,
        ),
      );

      print('✅ [API] Respuesta recibida: statusCode=${response.statusCode}');
      
      if (response.statusCode == 200) {
        return ApiRespuesta.fromJson(
          response.data as Map<String, dynamic>,
          (json) => VacanteDatosDto.fromJson(json as Map<String, dynamic>),
        );
      } else {
        print('❌ [API] Error en respuesta: ${response.data}');
        return ApiRespuesta.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      print('❌ [API] DioException: ${e.message}');
      print('❌ [API] Response: ${e.response?.data}');
      
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
    } catch (e) {
      print('❌ [API] Exception general: $e');
      return ApiRespuesta<VacanteDatosDto>(
        codigoEstado: -1,
        mensaje: 'Error inesperado: $e',
        fechaHora: DateTime.now().toIso8601String(),
        datos: null,
        error: e.toString(),
      );
    }
  }
}