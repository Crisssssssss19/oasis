import 'dart:convert';

Map<String, dynamic>? decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return null;

    String normalized = base64Url.normalize(parts[1]);
    final payloadBytes = base64Url.decode(normalized);

    final payloadString = utf8.decode(payloadBytes);
    return json.decode(payloadString) as Map<String, dynamic>;
  } catch (e) {
    return null;
  }
}
