import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/domain/model/pin_peticion.dart';
import 'package:oasis/domain/usecase/pin_caso_uso.dart';
import 'registro_paso1_state.dart';

class RegistroPaso1Notifier extends StateNotifier<RegistroPaso1State> {
  final PinCasoUso pinCasoUso;

  RegistroPaso1Notifier(this.pinCasoUso) : super(RegistroPaso1State());

  void reset() {
    state = RegistroPaso1State();
  }

  void setPrefijo(String nuevo) {
    state = state.copyWith(prefijo: nuevo);
  }

  void setCelular(String value) {
    state = state.copyWith(celular: value);
  }

  Future<void> validarYEnviar() async {
    String? errorCelular;
    String? errorPais;

    if (state.celular.isEmpty) {
      errorCelular = "Número telefónico requerido";
    } else if (state.celular.length < 7 || state.celular.length > 11) {
      errorCelular = "Número de dígitos incorrecto";
    }

    if (state.prefijo != "+57") {
      errorPais = "País no disponible";
    }

    if (errorCelular != null || errorPais != null) {
      state = state.copyWith(errorCelular: errorCelular, errorPais: errorPais);
      return;
    }

    state = state.copyWith(errorCelular: null, errorPais: null, cargando: true);

    final respuesta = await pinCasoUso(
      PinPeticion(telefonoAcceso: state.celular),
    );

    state = state.copyWith(cargando: false, pinRespuesta: respuesta);
  }

  /// 👇 Nuevo método para reenviar código
  Future<void> reenviarCodigo() async {
    if (state.celular.isEmpty) return;

    state = state.copyWith(cargando: true);

    final respuesta = await pinCasoUso(
      PinPeticion(telefonoAcceso: state.celular),
    );

    state = state.copyWith(cargando: false, pinRespuesta: respuesta);
  }
}
