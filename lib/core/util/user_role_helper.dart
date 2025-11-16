import 'package:oasis/domain/model/acceso_sesion.dart';

class UserRoleHelper {
  /// Determina si el usuario es una empresa
  static bool esEmpresa(AccesoSesion session) {
    print('🔍 Checking if user is Empresa with roles: ${session.roles}');
    return session.roles?.contains("Empresa") ?? false;
  }

  /// Determina si el usuario es un aspirante
  static bool esAspirante(AccesoSesion session) {
    return !(session.roles?.contains("Empresa") ?? false);
  }

  /// Obtiene la ruta de inicio según el tipo de usuario
  static String getRutaInicio(AccesoSesion session) {
    if (esEmpresa(session)) {
      return '/empresa/vacantes';
    } else {
      return '/inicio';
    }
  }
}
