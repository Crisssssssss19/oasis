import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oasis/core/ui/barra_superior.dart';
import 'package:oasis/core/theme/colores_bienvenida.dart';
import 'package:oasis/presentation/empresa/vacante/empresa_vacante_provider.dart';
import 'package:oasis/presentation/empresa/vacante/empresa_vacante_state.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class EmpresaCrearVacanteScreen extends ConsumerStatefulWidget {
  const EmpresaCrearVacanteScreen({super.key});

  @override
  ConsumerState<EmpresaCrearVacanteScreen> createState() =>
      _EmpresaCrearVacanteScreenState();
}

class _EmpresaCrearVacanteScreenState
    extends ConsumerState<EmpresaCrearVacanteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _minSalarioController = TextEditingController();
  final _maxSalarioController = TextEditingController();
  final _palabrasClaveController = TextEditingController();

  File? _imagenSeleccionada;
  int? _ubicacionId;
  int? _jornadaId;
  int? _modalidadId;
  int? _tipoContratoId;

  bool _isSubmitting = false;

  // Listas de opciones (deberías obtenerlas del backend)
  final List<Map<String, dynamic>> _ubicaciones = [
    {"id": 1, "nombre": "Bogotá"},
    {"id": 2, "nombre": "Medellín"},
    {"id": 3, "nombre": "Cali"},
    {"id": 4, "nombre": "Barranquilla"},
    {"id": 5, "nombre": "Santa Marta"},
  ];

  final List<Map<String, dynamic>> _jornadas = [
    {"id": 1, "nombre": "Tiempo completo"},
    {"id": 2, "nombre": "Medio tiempo"},
    {"id": 3, "nombre": "Por horas"},
  ];

  final List<Map<String, dynamic>> _modalidades = [
    {"id": 1, "nombre": "Presencial"},
    {"id": 2, "nombre": "Remoto"},
    {"id": 3, "nombre": "Híbrido"},
  ];

  final List<Map<String, dynamic>> _tiposContrato = [
    {"id": 1, "nombre": "Indefinido"},
    {"id": 2, "nombre": "Fijo"},
    {"id": 3, "nombre": "Por obra o labor"},
    {"id": 4, "nombre": "Prestación de servicios"},
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _minSalarioController.dispose();
    _maxSalarioController.dispose();
    _palabrasClaveController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imagenSeleccionada = File(image.path);
      });
    }
  }

  void _eliminarImagen() {
    setState(() {
      _imagenSeleccionada = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ubicacionId == null ||
        _jornadaId == null ||
        _modalidadId == null ||
        _tipoContratoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos requeridos")),
      );
      return;
    }

    if (_imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debes seleccionar una imagen para la vacante"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Convertir lista de palabras clave a JSON string que espera el backend
    final palabrasClave = _palabrasClaveController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    await ref.read(empresaVacanteProvider.notifier).crearVacante(
          titulo: _tituloController.text,
          descripcion: _descripcionController.text,
          minSalario: _minSalarioController.text,
          maxSalario: _maxSalarioController.text,
          ubicacionId: _ubicacionId!,
          jornadaId: _jornadaId!,
          modalidadId: _modalidadId!,
          tipoContratoId: _tipoContratoId!,
          palabrasClave: palabrasClave,
          imagenArchivo: _imagenSeleccionada!,
        );

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final overlay = Overlay.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;

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

    ref.listen<EmpresaVacanteState>(empresaVacanteProvider, (prev, next) {
      if (next is EmpresaVacanteCreada) {
        showTopSnackBar(
          overlay,
          const CustomSnackBar.success(
            message: "Vacante creada exitosamente",
          ),
          displayDuration: const Duration(seconds: 2),
          padding: EdgeInsets.only(
            top: statusBarHeight,
            left: 16,
            right: 16,
          ),
        );
        context.pop();
      } else if (next is EmpresaVacanteError) {
        showTopSnackBar(
          overlay,
          CustomSnackBar.error(message: next.mensaje),
          displayDuration: const Duration(seconds: 3),
          padding: EdgeInsets.only(
            top: statusBarHeight,
            left: 16,
            right: 16,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            BarraSuperior(
              onBack: () => context.pop(),
              title: "Nueva Vacante",
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con gradiente
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withValues(alpha: 0.15),
                              secondaryColor.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryColor, width: 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.work_outline,
                                color: onPrimaryColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Crear Nueva Vacante",
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Completa la información para publicar tu oferta",
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Selector de imagen (OBLIGATORIO)
                      _buildImageSelector(primaryColor, secondaryColor, textTheme),
                      const SizedBox(height: 24),

                      // Sección: Información Básica
                      _buildSeccionHeader("Información Básica", primaryColor, textTheme),
                      const SizedBox(height: 12),

                      // Título
                      _buildTextField(
                        controller: _tituloController,
                        label: "Título de la vacante",
                        hint: "Ej: Desarrollador Frontend",
                        icon: Icons.title,
                        primaryColor: primaryColor,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campo requerido";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      _buildTextField(
                        controller: _descripcionController,
                        label: "Descripción",
                        hint: "Describe las responsabilidades y requisitos...",
                        icon: Icons.description,
                        primaryColor: primaryColor,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campo requerido";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Sección: Compensación
                      _buildSeccionHeader("Compensación", primaryColor, textTheme),
                      const SizedBox(height: 12),

                      // Salario mínimo y máximo
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _minSalarioController,
                              label: "Salario mínimo",
                              hint: "3000000",
                              icon: Icons.attach_money,
                              primaryColor: primaryColor,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Requerido";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _maxSalarioController,
                              label: "Salario máximo",
                              hint: "5000000",
                              icon: Icons.attach_money,
                              primaryColor: primaryColor,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Requerido";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sección: Detalles del Puesto
                      _buildSeccionHeader("Detalles del Puesto", primaryColor, textTheme),
                      const SizedBox(height: 12),

                      // Ubicación
                      _buildDropdown<int>(
                        value: _ubicacionId,
                        label: "Ubicación",
                        icon: Icons.location_on,
                        primaryColor: primaryColor,
                        items: _ubicaciones.map((ubicacion) {
                          return DropdownMenuItem<int>(
                            value: ubicacion['id'] as int,
                            child: Text(ubicacion['nombre'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _ubicacionId = value);
                        },
                        validator: (value) {
                          if (value == null) return "Selecciona una ubicación";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Jornada
                      _buildDropdown<int>(
                        value: _jornadaId,
                        label: "Jornada",
                        icon: Icons.schedule,
                        primaryColor: primaryColor,
                        items: _jornadas.map((jornada) {
                          return DropdownMenuItem<int>(
                            value: jornada['id'] as int,
                            child: Text(jornada['nombre'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _jornadaId = value);
                        },
                        validator: (value) {
                          if (value == null) return "Selecciona una jornada";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Modalidad
                      _buildDropdown<int>(
                        value: _modalidadId,
                        label: "Modalidad",
                        icon: Icons.work,
                        primaryColor: primaryColor,
                        items: _modalidades.map((modalidad) {
                          return DropdownMenuItem<int>(
                            value: modalidad['id'] as int,
                            child: Text(modalidad['nombre'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _modalidadId = value);
                        },
                        validator: (value) {
                          if (value == null) return "Selecciona una modalidad";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tipo de contrato
                      _buildDropdown<int>(
                        value: _tipoContratoId,
                        label: "Tipo de contrato",
                        icon: Icons.assignment,
                        primaryColor: primaryColor,
                        items: _tiposContrato.map((tipo) {
                          return DropdownMenuItem<int>(
                            value: tipo['id'] as int,
                            child: Text(tipo['nombre'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _tipoContratoId = value);
                        },
                        validator: (value) {
                          if (value == null) return "Selecciona un tipo";
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Sección: Habilidades
                      _buildSeccionHeader("Habilidades Requeridas", primaryColor, textTheme),
                      const SizedBox(height: 12),

                      // Palabras clave
                      _buildTextField(
                        controller: _palabrasClaveController,
                        label: "Palabras clave (opcional)",
                        hint: "React, TypeScript, Frontend (separadas por comas)",
                        icon: Icons.label,
                        primaryColor: primaryColor,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 32),

                      // Botón de crear con gradiente
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: onPrimaryColor,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline, color: onPrimaryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Crear Vacante",
                                      style: TextStyle(
                                        color: onPrimaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionHeader(String titulo, Color primaryColor, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withValues(alpha: 0.5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          titulo,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: primaryColor.withValues(alpha: 0.05),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required Color primaryColor,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: primaryColor.withValues(alpha: 0.05),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildImageSelector(Color primaryColor, Color secondaryColor, TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.image, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              "Imagen de la vacante",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: Text(
                "Requerida",
                style: textTheme.bodySmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _seleccionarImagen,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: _imagenSeleccionada == null
                  ? LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.1),
                        secondaryColor.withValues(alpha: 0.05),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor,
                width: 2,
                style: _imagenSeleccionada == null ? BorderStyle.solid : BorderStyle.none,
              ),
            ),
            child: _imagenSeleccionada == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Toca para agregar imagen",
                        style: textTheme.bodyLarge?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Imagen requerida para crear la vacante",
                        style: textTheme.bodySmall?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _imagenSeleccionada!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.black87,
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                onPressed: _seleccionarImagen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: Colors.red,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                                onPressed: _eliminarImagen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}