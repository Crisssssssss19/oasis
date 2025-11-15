import 'dart:typed_data';

class AccesoRespuesta {
  final bool success;
  final String? token;
  final Uint8List? profileImage;
  final int? expiresAt;
  final String message;

  const AccesoRespuesta({
    required this.success,
    this.token,
    this.profileImage,
    this.expiresAt,
    required this.message,
  });
}