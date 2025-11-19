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
    required dynamic imagenArchivo,
    int? empresaIdOverride,
    int? usuarioIdOverride,
    required String fechaInicio,
    required String fechaFin,
  }) async {
    state = const EmpresaVacanteCreando();

    // Validación: la sesión debe pertenecer a una empresa (tener empresaId)
    final session = ref.read(sessionProvider);
    // Permitir override (admin eligiendo empresa). Si no hay override ni session, error.
    final empresaIdFinal = empresaIdOverride ?? session.empresaId;
    if (empresaIdFinal == null) {
      state = const EmpresaVacanteError(
          "Debes iniciar sesión con una cuenta de empresa o seleccionar una empresa para crear vacantes");
      return;
    }

    try {
      final useCase = ref.read(crearVacanteUseCaseProvider);
      // Obtener ids desde la sesión (si están disponibles)
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
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        idUsuario: usuarioIdOverride ?? session.userId,
        idEmpresa: empresaIdFinal,
      );
      
      state = EmpresaVacanteCreada(vacante);
      
      // Recargar lista de vacantes
      await cargarVacantes();
    } catch (e) {
      state = EmpresaVacanteError("Error al crear vacante: $e");
    }
  }
}