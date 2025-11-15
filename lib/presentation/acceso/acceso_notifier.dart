import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_validator/email_validator.dart';
import 'package:oasis/core/di/providers.dart';
import 'package:oasis/core/util/decode_jwt_payload.dart';
import 'package:oasis/domain/model/acceso_respuesta.dart';
import 'package:oasis/domain/usecase/acceso_caso_uso.dart';
import 'package:oasis/presentation/acceso/acceso_state.dart';

class AccesoNotifier extends StateNotifier<AccesoState> {
  final AccesoCasoUso accesoCasoUso;
  final Ref ref;

  AccesoNotifier(this.accesoCasoUso, this.ref) : super(const AccesoState());

  void setEmail(String value) {
    state = state.copyWith(
      email: value.trim(),
      emailError: state.submitted ? null : AccesoState.noChange,
    );
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value.trim(),
      passwordError: state.submitted ? null : AccesoState.noChange,
    );
  }

  void markSubmitted() {
    state = state.copyWith(submitted: true);
  }

  bool validarCampos() {
    markSubmitted();
    return _validarCamposInternal();
  }

  Future<AccesoRespuesta> login() async {
    state = state.copyWith(loading: true);

    final result = await accesoCasoUso(state.email, state.password);

    state = state.copyWith(loading: false);

    if (result.success && result.token != null) {
      // Decodificar el token JWT para extraer userId y empresaId
      final payload = decodeJwtPayload(result.token!);
      final userId = payload?["userId"] as int?;
      final empresaId = payload?["empresaId"] as int?;
      
      // Guardar sesión con userId y empresaId
      await ref.read(sessionProvider.notifier).saveSession(
        result.token!,
        result.profileImage != null ? base64Encode(result.profileImage!) : "",
        result.expiresAt ?? 0,
        userId: userId,
        empresaId: empresaId,
      );
    } else {
      state = state.copyWith(email: state.email, password: "");
    }

    return result;
  }

  bool _validarCamposInternal() {
    bool valid = true;
    String? emailError;
    String? passwordError;

    if (!EmailValidator.validate(state.email)) {
      emailError = "Correo inválido";
      valid = false;
    }

    if (state.password.length < 6) {
      passwordError = "Mínimo 6 caracteres";
      valid = false;
    }

    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
    );

    return valid;
  }
}