/// Modelo puro de un mensaje de chat
/// Representa un mensaje en el contexto de una postulación
class Mensaje {
  final int id;
  final int idPostulacion;
  final int idUsuarioResponde;
  final String texto;
  final DateTime fecha;
  /// 1 = no leído, 2 = leído
  final int estado;

  const Mensaje({
    required this.id,
    required this.idPostulacion,
    required this.idUsuarioResponde,
    required this.texto,
    required this.fecha,
    required this.estado,
  });

  /// Verifica si el mensaje está leído
  bool get esLeido => estado == 2;

  /// Verifica si el mensaje NO está leído
  bool get esNoLeido => estado == 1;

  /// Copia del modelo con campos opcionales
  Mensaje copyWith({
    int? id,
    int? idPostulacion,
    int? idUsuarioResponde,
    String? texto,
    DateTime? fecha,
    int? estado,
  }) {
    return Mensaje(
      id: id ?? this.id,
      idPostulacion: idPostulacion ?? this.idPostulacion,
      idUsuarioResponde: idUsuarioResponde ?? this.idUsuarioResponde,
      texto: texto ?? this.texto,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mensaje &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}


