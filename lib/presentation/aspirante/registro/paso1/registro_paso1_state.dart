import 'package:oasis/core/constants/country_prefixes.dart';
import 'package:oasis/domain/model/pin_respuesta.dart';

class RegistroPaso1State {
  final String prefijo;
  final String celular;
  final String? errorCelular;
  final String? errorPais;
  final bool cargando;

  final PinRespuesta? pinRespuesta;

  RegistroPaso1State({
    this.prefijo = defaultPrefix,
    this.celular = "",
    this.errorCelular,
    this.errorPais,
    this.cargando = false,
    this.pinRespuesta,
  });

  RegistroPaso1State copyWith({
    String? prefijo,
    String? celular,
    String? errorCelular,
    String? errorPais,
    bool? cargando,
    PinRespuesta? pinRespuesta,
  }) {
    return RegistroPaso1State(
      prefijo: prefijo ?? this.prefijo,
      celular: celular ?? this.celular,
      errorCelular: errorCelular,
      errorPais: errorPais,
      cargando: cargando ?? this.cargando,
      pinRespuesta: pinRespuesta ?? this.pinRespuesta,
    );
  }
}
