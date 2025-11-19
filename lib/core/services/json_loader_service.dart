// lib/core/services/json_loader_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:oasis/domain/model/ubicacion.dart';
import 'package:oasis/domain/model/palabra_clave.dart';

class JsonLoaderService {
  static JsonLoaderService? _instance;
  
  // Singleton
  factory JsonLoaderService() {
    _instance ??= JsonLoaderService._internal();
    return _instance!;
  }
  
  JsonLoaderService._internal();

  // Cache para evitar múltiples cargas
  List<Ubicacion>? _ubicacionesCache;
  List<PalabraClave>? _palabrasClaveCache;

  /// Carga las ubicaciones desde el archivo JSON
  /// Ruta esperada: assets/data/ubicaciones.json
  Future<List<Ubicacion>> cargarUbicaciones() async {
    if (_ubicacionesCache != null) {
      return _ubicacionesCache!;
    }

    try {
      final String jsonString = await rootBundle.loadString('./../../../assets/data/ubicaciones.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      _ubicacionesCache = jsonList
          .map((json) => Ubicacion.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ [JSON_LOADER] ${_ubicacionesCache!.length} ubicaciones cargadas');
      return _ubicacionesCache!;
    } catch (e) {
      print('❌ [JSON_LOADER] Error cargando ubicaciones: $e');
      return [];
    }
  }

  /// Carga las palabras clave desde el archivo JSON
  /// Ruta esperada: assets/data/palabras_clave.json
  Future<List<PalabraClave>> cargarPalabrasClave() async {
    if (_palabrasClaveCache != null) {
      return _palabrasClaveCache!;
    }

    try {
      final String jsonString = await rootBundle.loadString('./../../../assets/data/palabras_clave.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      _palabrasClaveCache = jsonList
          .map((json) => PalabraClave.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ [JSON_LOADER] ${_palabrasClaveCache!.length} palabras clave cargadas');
      return _palabrasClaveCache!;
    } catch (e) {
      print('❌ [JSON_LOADER] Error cargando palabras clave: $e');
      return [];
    }
  }

  /// Busca ubicaciones por nombre (case-insensitive)
  List<Ubicacion> buscarUbicaciones(String query, List<Ubicacion> ubicaciones) {
    if (query.isEmpty) return ubicaciones;
    
    final queryLower = query.toLowerCase();
    return ubicaciones
        .where((u) => u.nombre.toLowerCase().contains(queryLower))
        .toList();
  }

  /// Busca palabras clave por nombre (case-insensitive)
  List<PalabraClave> buscarPalabrasClave(String query, List<PalabraClave> palabras) {
    if (query.isEmpty) return palabras;
    
    final queryLower = query.toLowerCase();
    return palabras
        .where((p) => p.nombre.toLowerCase().contains(queryLower))
        .toList();
  }

  /// Limpia el cache (útil para testing o recargas)
  void clearCache() {
    _ubicacionesCache = null;
    _palabrasClaveCache = null;
  }
}