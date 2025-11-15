import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oasis/domain/model/vacante_respuesta.dart';

Future<void> precacheVacanteImages(
  BuildContext context,
  List<VacanteRespuesta> vacantes,
) async {
  for (final vacante in vacantes) {
    final provider = CachedNetworkImageProvider(vacante.imagenUrl);
    precacheImage(provider, context);
  }
}
