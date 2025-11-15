import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/core/di/providers.dart';
import 'package:oasis/domain/model/acceso_respuesta.dart';
import 'package:oasis/domain/model/registro_peticion.dart';
import 'package:oasis/domain/usecase/registro_caso_uso.dart';
import 'registro_paso3_state.dart';

class RegistroPaso3Notifier extends StateNotifier<RegistroPaso3State> {
  final RegistroCasoUso casoUso;
  final Ref ref;

  RegistroPaso3Notifier(this.casoUso, this.ref)
    : super(const RegistroPaso3State());

  void updateNombres(String value) => state = state.copyWith(nombres: value);

  void updateApellidos(String value) =>
      state = state.copyWith(apellidos: value);

  void updateEmail(String value) => state = state.copyWith(email: value);

  void updatePassword(String value) => state = state.copyWith(password: value);

  void updateConfirmPassword(String value) =>
      state = state.copyWith(confirmPassword: value);

  void toggleShowPassword() =>
      state = state.copyWith(showPassword: !state.showPassword);

  void toggleShowConfirmPassword() =>
      state = state.copyWith(showConfirmPassword: !state.showConfirmPassword);

  void toggleAceptaTerminos(bool value) =>
      state = state.copyWith(aceptaTerminos: value);

  Future<AccesoRespuesta> submit(String telefono) async {
    if (!state.allFieldsFilled) {
      return const AccesoRespuesta(
        success: false,
        message: "Campos incompletos",
      );
    }

    state = state.copyWith(isSubmitting: true);

    final peticion = RegistroPeticion(
      telefonoAcceso: telefono,
      nombresUsuario: state.nombres,
      apellidosUsuario: state.apellidos,
      correoAcceso: state.email,
      claveAcceso: state.password,
    );

    final respuesta = await casoUso(peticion);

    if (respuesta.success && respuesta.token != null) {
      await ref
          .read(sessionProvider.notifier)
          .saveSession(
            respuesta.token!,
            respuesta.profileImage != null
                ? base64Encode(respuesta.profileImage!)
                : "",
            respuesta.expiresAt ?? 0,
          );
    }

    state = state.copyWith(isSubmitting: false);
    return respuesta;
  }
}
