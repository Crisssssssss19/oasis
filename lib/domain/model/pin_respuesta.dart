class PinRespuesta {
  final bool exito;
  final String mensaje;
  final String? error;

  final int? idTelefonoPinTemporal;
  final String? valorPinTemporal;
  final String? fechaCreacionPinTemporal;
  final int? intentoPinTemporal;
  final int? totalIntentosPinTemporal;
  final int? minutosSuspensionPinTemporal;
  final bool? smsEnviado;

  const PinRespuesta({
    required this.exito,
    required this.mensaje,
    this.error,
    this.idTelefonoPinTemporal,
    this.valorPinTemporal,
    this.fechaCreacionPinTemporal,
    this.intentoPinTemporal,
    this.totalIntentosPinTemporal,
    this.minutosSuspensionPinTemporal,
    this.smsEnviado,
  });
}