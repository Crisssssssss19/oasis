Duration calcularTiempoRestante(String fechaCreacion, int minutosBloqueo) {
  try {
    var limpia = fechaCreacion.trim();

    final regex = RegExp(r'(\.\d{6})\d+');
    limpia = limpia.replaceAllMapped(regex, (m) => m[1]!);

    final inicio = DateTime.parse(limpia); // soporta Z y offsets
    final fin = inicio.add(Duration(minutes: minutosBloqueo));
    final ahora = DateTime.now().toUtc(); // comparar en UTC
    final restante = fin.toUtc().difference(ahora);

    // print(inicio);
    // print(fin);
    // print(ahora);
    // print(restante);

    return restante.isNegative ? Duration.zero : restante;
  } catch (e) {
    return Duration.zero;
  }
}
