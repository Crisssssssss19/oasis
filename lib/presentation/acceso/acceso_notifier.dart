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
        final payload = decodeJwtPayload(result.token!);

        // 🔍 DEBUG: Ver qué contiene el payload
        print('🔍 JWT Payload: $payload');

        // Parsear userId y empresaId de forma robusta (pueden venir como int o String)
        int? parseInt(dynamic v) {
          if (v == null) return null;
          if (v is int) return v;
          if (v is String) {
            return int.tryParse(v);
          }
          if (v is double) return v.toInt();
          return null;
        }

        final userId = parseInt(payload?['userId']);
        final empresaId = parseInt(payload?['empresaId']);

        // Roles pueden venir como List<dynamic> o como String (json o single)
        List<String> parseRoles(dynamic r) {
          if (r == null) return [];
          if (r is List) return r.map((e) => e.toString()).toList();
          if (r is String) {
            // Intentar decodificar JSON si viene como '[]' o separar por comas
            try {
              final decoded = json.decode(r);
              if (decoded is List) return decoded.map((e) => e.toString()).toList();
            } catch (_) {}
            return r.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          }
          return [];
        }

        final roles = parseRoles(payload?['roles']);

        print('🔍 userId: $userId');
        print('🔍 empresaId: $empresaId');
        print('🔍 roles: $roles');

        await ref
            .read(sessionProvider.notifier)
            .saveSession(
              result.token!,
              result.profileImage != null
                  ? base64Encode(result.profileImage!)
                  : "",
              result.expiresAt ?? 0,
              userId: userId,
              empresaId: empresaId,
              roles: roles,
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
