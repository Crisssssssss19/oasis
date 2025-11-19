import 'package:oasis/domain/model/acceso_sesion.dart';

class UserRoleHelper {
  /// Determina si el usuario es una empresa
  static bool esEmpresa(AccesoSesion session) {
    print('🔍 Checking if user is Empresa with roles: ${session.roles}');
    return session.roles.contains("Empresa");
  }

  /// Determina si el usuario es un aspirante
  static bool esAspirante(AccesoSesion session) {
    // Un aspirante no es empresa ni administrador
    final esEmpresa = session.roles.contains("Empresa");
    final esAdmin = session.roles.contains("Administrador");
    return !esEmpresa && !esAdmin;
  }

  /// Determina si el usuario es administrador
  static bool esAdministrador(AccesoSesion session) {
    return session.roles.contains("Administrador");
  }

  /// Obtiene la ruta de inicio según el tipo de usuario
  static String getRutaInicio(AccesoSesion session) {
    if (esAdministrador(session)) {
      return '/empresa/vacantes';
    } else if (esEmpresa(session)) {
      return '/empresa/vacantes';
    } else {
      return '/inicio';
    }
  }
}
