class PinDatosDto {
  final int idTelefonoPinTemporal;
  final String valorPinTemporal;
  final String fechaCreacionPinTemporal;
  final int intentoPinTemporal;
  final int totalIntentosPinTemporal;
  final int minutosSuspensionPinTemporal;
  final bool smsEnviado;

  const PinDatosDto({
    required this.idTelefonoPinTemporal,
    required this.valorPinTemporal,
    required this.fechaCreacionPinTemporal,
    required this.intentoPinTemporal,
    required this.totalIntentosPinTemporal,
    required this.minutosSuspensionPinTemporal,
    required this.smsEnviado,
  });

  factory PinDatosDto.fromJson(Map<String, dynamic> json) {
    return PinDatosDto(
      idTelefonoPinTemporal: json['idTelefonoPinTemporal'] as int,
      valorPinTemporal: json['valorPinTemporal'] as String,
      fechaCreacionPinTemporal: json['fechaCreacionPinTemporal'] as String,
      intentoPinTemporal: json['intentoPinTemporal'] as int,
      totalIntentosPinTemporal: json['totalIntentosPinTemporal'] as int,
      minutosSuspensionPinTemporal: json['minutosSuspensionPinTemporal'] as int,
      smsEnviado: json['smsEnviado'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idTelefonoPinTemporal': idTelefonoPinTemporal,
      'valorPinTemporal': valorPinTemporal,
      'fechaCreacionPinTemporal': fechaCreacionPinTemporal,
      'intentoPinTemporal': intentoPinTemporal,
      'totalIntentosPinTemporal': totalIntentosPinTemporal,
      'minutosSuspensionPinTemporal': minutosSuspensionPinTemporal,
      'smsEnviado': smsEnviado,
    };
  }
}
