import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/core/di/providers.dart';
import 'package:oasis/presentation/empresa/vacante/empresa_vacante_state.dart';

class EmpresaVacanteNotifier extends StateNotifier<EmpresaVacanteState> {
  final Ref ref;

  EmpresaVacanteNotifier(this.ref) : super(const EmpresaVacanteLoading());

  /// Carga todas las vacantes
  Future<void> cargarVacantes() async {
    state = const EmpresaVacanteLoading();
    
    try {
      final useCase = ref.read(obtenerVacantesEmpresaUseCaseProvider);
      final vacantes = await useCase();

      state = EmpresaVacanteData(vacantes: vacantes);
    } catch (e) {
      state = EmpresaVacanteError("Error al cargar vacantes: $e");
    }
  }

  /// Crea una nueva vacante con imagen
  Future<void> crearVacante({
    required String titulo,
    required String descripcion,
    required String minSalario,
    required String maxSalario,
    required int ubicacionId,
    required int jornadaId,
    required int modalidadId,
    required int tipoContratoId,
    required List<String> palabrasClave,
    required File imagenArchivo,
  }) async {
    state = const EmpresaVacanteCreando();

    try {
      final useCase = ref.read(crearVacanteUseCaseProvider);
      final vacante = await useCase(
        titulo: titulo,
        descripcion: descripcion,
        minSalario: minSalario,
        maxSalario: maxSalario,
        ubicacionId: ubicacionId,
        jornadaId: jornadaId,
        modalidadId: modalidadId,
        tipoContratoId: tipoContratoId,
        palabrasClave: palabrasClave,
        archivo: imagenArchivo,
      );
      
      state = EmpresaVacanteCreada(vacante);
      
      // Recargar lista de vacantes
      await cargarVacantes();
    } catch (e) {
      state = EmpresaVacanteError("Error al crear vacante: $e");
    }
  }
}