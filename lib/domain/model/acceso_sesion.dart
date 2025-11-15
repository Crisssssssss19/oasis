class AccesoSesion {
  final String? token;
  final String? imageBase64;
  final int? expiraEn;
  final int? userId;
  final int? empresaId;

  const AccesoSesion({
    this.token,
    this.imageBase64,
    this.expiraEn,
    this.userId,
    this.empresaId,
  });

  bool get isLoggedIn => token != null;

  bool get isExpired {
    if (expiraEn == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= expiraEn!;
  }

  AccesoSesion copyWith({
    String? token,
    String? imageBase64,
    int? expiraEn,
    int? userId,
    int? empresaId,
  }) {
    return AccesoSesion(
      token: token ?? this.token,
      imageBase64: imageBase64 ?? this.imageBase64,
      expiraEn: expiraEn ?? this.expiraEn,
      userId: userId ?? this.userId,
      empresaId: empresaId ?? this.empresaId,
    );
  }
}
