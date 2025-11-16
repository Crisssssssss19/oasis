import 'package:oasis/domain/model/acceso_sesion.dart';

class UserRoleHelper {
  /// Determina si el usuario es una empresa
  static bool esEmpresa(AccesoSesion session) {
    // Si tiene empresaId, es empresa
    return session.empresaId != null && session.empresaId! > 0;
  }

  /// Determina si el usuario es un aspirante
  static bool esAspirante(AccesoSesion session) {
    // Si NO tiene empresaId (o es 0/null), es aspirante
    return session.empresaId == null || session.empresaId == 0;
  }

  /// Obtiene la ruta de inicio según el tipo de usuario
  static String getRutaInicio(AccesoSesion session) {
    if (esEmpresa(session)) {
      return '/empresa/vacantes';
    } else {
      return '/inicio'; // Ruta de aspirante
    }
  }
}