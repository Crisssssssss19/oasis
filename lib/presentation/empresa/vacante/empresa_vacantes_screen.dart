import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:oasis/core/di/providers.dart';
import 'package:oasis/core/ui/app_top_bar.dart';
import 'package:oasis/presentation/empresa/vacante/empresa_vacante_provider.dart';
import 'package:oasis/presentation/empresa/vacante/empresa_vacante_state.dart';

class EmpresaVacantesScreen extends ConsumerStatefulWidget {
  const EmpresaVacantesScreen({super.key});

  @override
  ConsumerState<EmpresaVacantesScreen> createState() =>
      _EmpresaVacantesScreenState();
}

class _EmpresaVacantesScreenState
    extends ConsumerState<EmpresaVacantesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(empresaVacanteProvider.notifier).cargarVacantes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(empresaVacanteProvider);
    final session = ref.watch(sessionProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppTopBar(
        title: "Mis Vacantes",
        notificacionesCount: 0,
        chatCount: null,
        onNotificacionesPressed: () => context.go('/notificaciones'),
        onChatPressed: null,
      ),
      body: switch (state) {
        EmpresaVacanteLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
        EmpresaVacanteError(:final mensaje) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    "Error al cargar vacantes",
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(empresaVacanteProvider.notifier)
                          .cargarVacantes();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reintentar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        EmpresaVacanteData(:final vacantes) => vacantes.isEmpty
            ? _buildEmptyState(context, colorScheme, textTheme)
            : RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(empresaVacanteProvider.notifier)
                      .cargarVacantes();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vacantes.length,
                  itemBuilder: (context, index) {
                    final vacante = vacantes[index];
                    return _VacanteCard(
                      titulo: vacante.titulo,
                      imagenUrl: vacante.imagenUrl,
                      estado: vacante.estado,
                      empresa: vacante.empresa,
                      salario:
                          "${vacante.minSalario} - ${vacante.maxSalario}",
                      ubicacion: vacante.ubicacion,
                      modalidad: vacante.modalidad,
                      onTap: () {
                        context.push(
                          '/empresa/vacante/${vacante.id}',
                          extra: vacante,
                        );
                      },
                    );
                  },
                ),
              ),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/empresa/crear-vacante'),
        icon: const Icon(Icons.add),
        label: const Text("Nueva vacante"),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavButton(
              context: context,
              icon: Icons.dashboard_outlined,
              label: "Inicio",
              isActive: false,
              onTap: () => context.go('/empresa/inicio'),
            ),
            _buildNavButton(
              context: context,
              icon: Icons.work_outline,
              label: "Vacantes",
              isActive: true,
              onTap: () {},
            ),
            _buildNavButton(
              context: context,
              icon: Icons.chat_bubble_outline,
              label: "Chats",
              isActive: false,
              onTap: () => context.go('/chat'),
            ),
            _buildNavButton(
              context: context,
              icon: Icons.person_outline,
              label: "Perfil",
              isActive: false,
              onTap: () => context.go('/perfil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: isActive
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                    )
                  : null,
              child: Icon(
                icon,
                color: isActive
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work_off_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No hay vacantes creadas",
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Comienza creando tu primera vacante\npara atraer a los mejores candidatos",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/empresa/crear-vacante'),
              icon: const Icon(Icons.add),
              label: const Text("Crear Primera Vacante"),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VacanteCard extends StatelessWidget {
  final String titulo;
  final String imagenUrl;
  final String estado;
  final String empresa;
  final String salario;
  final String ubicacion;
  final String modalidad;
  final VoidCallback onTap;

  const _VacanteCard({
    required this.titulo,
    required this.imagenUrl,
    required this.estado,
    required this.empresa,
    required this.salario,
    required this.ubicacion,
    required this.modalidad,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: imagenUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colorScheme.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colorScheme.surfaceVariant,
                  child:
                      const Icon(Icons.image_not_supported, size: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    empresa,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    salario,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: estado == "Abierta"
                              ? colorScheme.primary
                                  .withValues(alpha: 0.1)
                              : colorScheme.error
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: estado == "Abierta"
                                ? colorScheme.primary
                                : colorScheme.error,
                          ),
                        ),
                        child: Text(
                          estado,
                          style: textTheme.bodySmall?.copyWith(
                            color: estado == "Abierta"
                                ? colorScheme.primary
                                : colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ubicacion,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        modalidad == "Remoto"
                            ? Icons.home_work_outlined
                            : Icons.business_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        modalidad,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
