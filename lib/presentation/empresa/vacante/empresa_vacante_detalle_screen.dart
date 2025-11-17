import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:oasis/domain/model/vacante_respuesta.dart';
import 'package:oasis/core/theme/colores_bienvenida.dart';
import 'package:intl/intl.dart';

class EmpresaVacanteDetalleScreen extends StatelessWidget {
  final VacanteRespuesta vacante;

  const EmpresaVacanteDetalleScreen({
    super.key,
    required this.vacante,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Colores amarillos/naranjas de empresa
    final primaryColor = isDark 
        ? temaOscuroBotonGradienteAmarilloInicio 
        : temaClaroBotonGradienteAmarilloInicio;
    final secondaryColor = isDark 
        ? temaOscuroBotonGradienteAmarilloFin 
        : temaClaroBotonGradienteAmarilloFin;
    final onPrimaryColor = isDark 
        ? temaOscuroBotonGradienteAmarilloContent 
        : temaClaroBotonGradienteAmarilloContent;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header con imagen
            _buildHeader(context, primaryColor, secondaryColor),

            // Contenido principal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTituloSeccion(context, primaryColor),
                    const SizedBox(height: 24),
                    _buildSalarioSeccion(context, primaryColor, onPrimaryColor),
                    const SizedBox(height: 24),
                    _buildDetallesSeccion(context, primaryColor),
                    const SizedBox(height: 24),
                    _buildDescripcionSeccion(context),
                    const SizedBox(height: 24),
                    _buildPalabrasClaveSeccion(context, primaryColor, onPrimaryColor),
                    const SizedBox(height: 24),
                    _buildEstadisticasSeccion(context, primaryColor),
                    const SizedBox(height: 32),
                    _buildBotonesAccion(context, primaryColor, onPrimaryColor),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor, Color secondaryColor) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo
            CachedNetworkImage(
              imageUrl: vacante.imagenUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colorScheme.surfaceVariant,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: colorScheme.surfaceVariant,
                child: const Icon(Icons.image_not_supported, size: 64),
              ),
            ),
            // Overlay degradado con colores amarillos
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withValues(alpha: 0.3),
                    secondaryColor.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
            child: IconButton(
              icon: Icon(Icons.edit, color: primaryColor),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Editar vacante próximamente")),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTituloSeccion(BuildContext context, Color primaryColor) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: vacante.estado == "Abierta"
                  ? [primaryColor.withValues(alpha: 0.2), primaryColor.withValues(alpha: 0.1)]
                  : [colorScheme.error.withValues(alpha: 0.2), colorScheme.error.withValues(alpha: 0.1)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: vacante.estado == "Abierta" ? primaryColor : colorScheme.error,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                vacante.estado == "Abierta" ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: vacante.estado == "Abierta" ? primaryColor : colorScheme.error,
              ),
              const SizedBox(width: 6),
              Text(
                vacante.estado,
                style: textTheme.bodyMedium?.copyWith(
                  color: vacante.estado == "Abierta" ? primaryColor : colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Título
        Text(
          vacante.titulo,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // Empresa
        Row(
          children: [
            Icon(Icons.business, size: 20, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              vacante.empresa,
              style: textTheme.titleMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Fecha de publicación
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              "Publicada: ${DateFormat('dd MMM yyyy').format(vacante.fechaInicioLocal)}",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalarioSeccion(BuildContext context, Color primaryColor, Color onPrimaryColor) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.15),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                "Rango Salarial",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "${vacante.minSalario} - ${vacante.maxSalario}",
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetallesSeccion(BuildContext context, Color primaryColor) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final detalles = [
      {"icon": Icons.location_on, "label": "Ubicación", "value": vacante.ubicacion},
      {"icon": Icons.schedule, "label": "Jornada", "value": vacante.jornada},
      {"icon": Icons.work, "label": "Modalidad", "value": vacante.modalidad},
      {"icon": Icons.description, "label": "Tipo de Contrato", "value": vacante.tipoContrato},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Detalles del Puesto",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...detalles.map((detalle) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.15),
                          primaryColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      detalle["icon"] as IconData,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detalle["label"] as String,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          detalle["value"] as String,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildDescripcionSeccion(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final descripcion = "Esta vacante está buscando profesionales comprometidos "
        "y con ganas de crecer en un ambiente dinámico y colaborativo. "
        "Ofrecemos oportunidades de desarrollo profesional y un excelente "
        "ambiente laboral.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Descripción",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            descripcion,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPalabrasClaveSeccion(BuildContext context, Color primaryColor, Color onPrimaryColor) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (vacante.palabrasClave.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Habilidades Requeridas",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: vacante.palabrasClave.map((palabra) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                palabra,
                style: textTheme.bodyMedium?.copyWith(
                  color: onPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEstadisticasSeccion(BuildContext context, Color primaryColor) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final postulaciones = 10;
    final vistas = 156;
    final enProceso = 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Estadísticas",
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEstadistica(
                context,
                primaryColor,
                icon: Icons.people,
                value: postulaciones.toString(),
                label: "Postulaciones",
              ),
              Container(
                width: 1,
                height: 40,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              _buildEstadistica(
                context,
                primaryColor,
                icon: Icons.visibility,
                value: vistas.toString(),
                label: "Vistas",
              ),
              Container(
                width: 1,
                height: 40,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              _buildEstadistica(
                context,
                primaryColor,
                icon: Icons.hourglass_bottom,
                value: enProceso.toString(),
                label: "En proceso",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstadistica(
    BuildContext context,
    Color primaryColor, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBotonesAccion(BuildContext context, Color primaryColor, Color onPrimaryColor) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final gradientColors = isDark
        ? [temaOscuroBotonGradienteAmarilloInicio, temaOscuroBotonGradienteAmarilloFin]
        : [temaClaroBotonGradienteAmarilloInicio, temaClaroBotonGradienteAmarilloFin];

    return Column(
      children: [
        // Botón Ver Postulaciones con gradiente
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ver postulaciones próximamente")),
              );
            },
            icon: Icon(Icons.list, color: onPrimaryColor),
            label: Text(
              "Ver Postulaciones",
              style: TextStyle(color: onPrimaryColor),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botones secundarios
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: vacante.estado == "Abierta"
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Cerrar vacante próximamente")),
                        );
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Reabrir vacante próximamente")),
                        );
                      },
                icon: Icon(
                  vacante.estado == "Abierta" ? Icons.lock : Icons.lock_open,
                ),
                label: Text(vacante.estado == "Abierta" ? "Cerrar" : "Reabrir"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _mostrarDialogoEliminar(context);
                },
                icon: const Icon(Icons.delete),
                label: const Text("Eliminar"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _mostrarDialogoEliminar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Vacante"),
        content: const Text(
          "¿Estás seguro de que deseas eliminar esta vacante? "
          "Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Eliminar vacante próximamente")),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}