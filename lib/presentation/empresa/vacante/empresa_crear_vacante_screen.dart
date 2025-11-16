import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oasis/core/ui/barra_superior.dart';
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes seleccionar una imagen")),
      );
      return;
    }

    if (_ubicacionId == null ||
        _jornadaId == null ||
        _modalidadId == null ||
        _tipoContratoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final overlay = Overlay.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;

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
                      // Selector de imagen
                      _buildImageSelector(colorScheme, textTheme),
                      const SizedBox(height: 24),

                      // Título
                      TextFormField(
                        controller: _tituloController,
                        decoration: const InputDecoration(
                          labelText: "Título de la vacante *",
                          hintText: "Ej: Desarrollador Frontend",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campo requerido";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      TextFormField(
                        controller: _descripcionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: "Descripción *",
                          hintText: "Describe la vacante...",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campo requerido";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Salario mínimo y máximo
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minSalarioController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Salario mínimo *",
                                hintText: "3000000",
                                border: OutlineInputBorder(),
                              ),
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
                            child: TextFormField(
                              controller: _maxSalarioController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Salario máximo *",
                                hintText: "5000000",
                                border: OutlineInputBorder(),
                              ),
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
                      const SizedBox(height: 16),

                      // Ubicación
                      DropdownButtonFormField<int>(
                        value: _ubicacionId,
                        decoration: const InputDecoration(
                          labelText: "Ubicación *",
                          border: OutlineInputBorder(),
                        ),
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
                      DropdownButtonFormField<int>(
                        value: _jornadaId,
                        decoration: const InputDecoration(
                          labelText: "Jornada *",
                          border: OutlineInputBorder(),
                        ),
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
                      DropdownButtonFormField<int>(
                        value: _modalidadId,
                        decoration: const InputDecoration(
                          labelText: "Modalidad *",
                          border: OutlineInputBorder(),
                        ),
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
                      DropdownButtonFormField<int>(
                        value: _tipoContratoId,
                        decoration: const InputDecoration(
                          labelText: "Tipo de contrato *",
                          border: OutlineInputBorder(),
                        ),
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
                      const SizedBox(height: 16),

                      // Palabras clave
                      TextFormField(
                        controller: _palabrasClaveController,
                        decoration: const InputDecoration(
                          labelText: "Palabras clave",
                          hintText: "React, TypeScript, Frontend (separadas por comas)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón de crear
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            disabledBackgroundColor: colorScheme.surfaceVariant,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Crear Vacante"),
                        ),
                      ),
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

  Widget _buildImageSelector(ColorScheme colorScheme, TextTheme textTheme) {
    return GestureDetector(
      onTap: _seleccionarImagen,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline,
            width: 2,
          ),
        ),
        child: _imagenSeleccionada == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Toca para agregar imagen",
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _seleccionarImagen,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}