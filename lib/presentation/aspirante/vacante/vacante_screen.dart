import 'package:flutter/material.dart';
import 'package:oasis/core/theme/colores_extra.dart';
import 'package:oasis/presentation/aspirante/widget/inicio_keyword_bar.dart';
import 'package:oasis/presentation/aspirante/widget/inicio_vacante_bar.dart';
import 'package:oasis/presentation/aspirante/widget/labels_fila.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:oasis/domain/model/vacante_respuesta.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VacanteScreen extends StatelessWidget {
  final VacanteRespuesta vacante;
  final PageController pageController;
  final int totalPages;

  const VacanteScreen({
    super.key,
    required this.vacante,
    required this.pageController,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final extra = Theme.of(context).extension<ColoresExtra>()!;

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              // Imagen de fondo con cache
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: vacante.imagenUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),

              // Indicador de páginas
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: pageController,
                    count: totalPages,
                    effect: const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: Colors.white,
                      dotColor: Colors.white54,
                    ),
                  ),
                ),
              ),

              // Barra de acciones (favorito, compartir, expandir)
              Positioned(
                top: 16,
                right: 16,
                child: InicioVacanteBar(
                  onExpandirClick: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Expandir: ${vacante.titulo}")),
                    );
                  },
                  onFavoritoClick: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Favorito: ${vacante.titulo}")),
                    );
                  },
                  onCompartirClick: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Compartir: ${vacante.titulo}")),
                    );
                  },
                ),
              ),

              // Bloque inferior sobre la imagen (salario + keywords)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${vacante.minSalario} - ${vacante.maxSalario}",
                        style: textTheme.titleMedium?.copyWith(
                          color: extra.verdeIntenso,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InicioKeywordBar(palabrasClave: vacante.palabrasClave),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bloque inferior (título, empresa, etiquetas, postulaciones)
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 115),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vacante.titulo,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vacante.empresa,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LabelsFila(
                    label1: vacante.jornada,
                    label2: vacante.ubicacion,
                    label3: vacante.modalidad,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "10 postulaciones",
                    // "${vacante.postulaciones ?? 0} postulaciones",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
