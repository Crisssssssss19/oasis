import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:oasis/data/remote/dto/api_respuesta.dart';
import 'package:oasis/data/remote/dto/vacante_datos_dto.dart';
import 'package:oasis/data/remote/vacante_empresa_api.dart';
import 'package:oasis/domain/model/vacante_respuesta.dart';
import 'package:oasis/domain/repository/vacante_empresa_repository.dart';
import 'package:oasis/mapper/vacante_mapper.dart';

class VacanteEmpresaRepositorioImpl implements VacanteEmpresaRepositorio {
  final VacanteEmpresaApi api;

  VacanteEmpresaRepositorioImpl(this.api);

  @override
  Future<List<VacanteRespuesta>> obtenerVacantes() async {
    try {
      final ApiRespuesta<List<VacanteDatosDto>> response =
          await api.obtenerVacantes();

      return _procesarRespuestaLista(response);
    } on DioException catch (e) {
      throw Exception(
        "Error HTTP ${e.response?.statusCode ?? ''}: ${e.message}",
      );
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  @override
  Future<VacanteRespuesta> crearVacante({
    required String titulo,
    required String descripcion,
    required String minSalario,
    required String maxSalario,
    required int ubicacionId,
    required int jornadaId,
    required int modalidadId,
    required int tipoContratoId,
    required List<String> palabrasClave,
    required File archivo,
  }) async {
    try {
      print('📦 [REPO] Preparando datos para crear vacante');
      
      // Por ahora, asumimos IDs fijos para las palabras clave
      // En producción, deberías obtener estos IDs del backend primero
      // basándote en las palabras clave ingresadas
      final List<int> idsPalabrasClave = List.generate(
        palabrasClave.length,
        (index) => index + 1, // IDs temporales
      );
      
      // Convertir a JSON string como espera el backend
      final idsPalabrasClaveTexto = jsonEncode(idsPalabrasClave);
      
      print('📦 [REPO] palabrasClave: $palabrasClave');
      print('📦 [REPO] idsPalabrasClaveTexto: $idsPalabrasClaveTexto');

      final ApiRespuesta<VacanteDatosDto> response = await api.crearVacante(
        tituloVacante: titulo,
        detalleVacante: descripcion,
        minSalarioVacante: minSalario,
        maxSalarioVacante: maxSalario,
        idUbicacion: ubicacionId,
        idJornada: jornadaId,
        idModalidad: modalidadId,
        idTipoContrato: tipoContratoId,
        idsPalabrasClaveTexto: idsPalabrasClaveTexto,
        archivo: archivo,
      );

      print('✅ [REPO] Respuesta procesada');
      return _procesarRespuestaUnica(response);
    } on DioException catch (e) {
      print('❌ [REPO] DioException: ${e.message}');
      throw Exception(
        "Error HTTP ${e.response?.statusCode ?? ''}: ${e.message}",
      );
    } catch (e) {
      print('❌ [REPO] Exception: $e');
      throw Exception("Error inesperado: $e");
    }
  }

  // ***************************************************************************
  // Métodos auxiliares para procesar respuestas
  // ***************************************************************************

  List<VacanteRespuesta> _procesarRespuestaLista(
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

  VacanteRespuesta _procesarRespuestaUnica(
    ApiRespuesta<VacanteDatosDto> response,
  ) {
    switch (response.codigoEstado) {
      case 200:
        if (response.datos != null) {
          return response.datos!.toDomain();
        } else {
          throw Exception('Respuesta 200 sin datos válidos');
        }

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