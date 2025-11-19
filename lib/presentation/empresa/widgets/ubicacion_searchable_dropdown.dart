// lib/presentation/widgets/ubicacion_searchable_dropdown.dart
import 'package:flutter/material.dart';
import 'package:oasis/domain/model/ubicacion.dart';
import 'package:oasis/core/services/json_loader_service.dart';

class UbicacionSearchableDropdown extends StatefulWidget {
  final int? valorSeleccionado;
  final void Function(int?) onChanged;
  final Color primaryColor;
  final String? Function(int?)? validator;

  const UbicacionSearchableDropdown({
    super.key,
    required this.valorSeleccionado,
    required this.onChanged,
    required this.primaryColor,
    this.validator,
  });

  @override
  State<UbicacionSearchableDropdown> createState() =>
      _UbicacionSearchableDropdownState();
}

class _UbicacionSearchableDropdownState
    extends State<UbicacionSearchableDropdown> {
  final _searchController = TextEditingController();
  final _jsonLoader = JsonLoaderService();
  List<Ubicacion> _ubicaciones = [];
  List<Ubicacion> _ubicacionesFiltradas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarUbicaciones();
  }

  Future<void> _cargarUbicaciones() async {
    final ubicaciones = await _jsonLoader.cargarUbicaciones();
    setState(() {
      _ubicaciones = ubicaciones;
      _ubicacionesFiltradas = ubicaciones;
      _isLoading = false;
    });
  }

  void _filtrar(String query) {
    setState(() {
      _ubicacionesFiltradas = _jsonLoader.buscarUbicaciones(query, _ubicaciones);
    });
  }

  void _mostrarDialogo() async {
    // Resetear filtro antes de mostrar el diálogo
    setState(() {
      _ubicacionesFiltradas = _ubicaciones;
    });

    final seleccionada = await showDialog<Ubicacion>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 600),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Seleccionar Ubicación",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  
                  // Campo de búsqueda
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Buscar ubicación...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _ubicacionesFiltradas = _jsonLoader.buscarUbicaciones(value, _ubicaciones);
                        });
                        setDialogState(() {}); // Actualizar el diálogo
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Lista de ubicaciones
                  Expanded(
                    child: _ubicacionesFiltradas.isEmpty
                        ? const Center(child: Text("No se encontraron resultados"))
                        : ListView.builder(
                            itemCount: _ubicacionesFiltradas.length,
                            itemBuilder: (context, index) {
                              final ubicacion = _ubicacionesFiltradas[index];
                              return ListTile(
                                leading: Icon(Icons.location_on, color: widget.primaryColor),
                                title: Text(ubicacion.nombre),
                                onTap: () => Navigator.of(context).pop(ubicacion),
                              );
                            },
                          ),
                  ),
                  
                  // Botón cerrar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cerrar"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (seleccionada != null) {
      widget.onChanged(seleccionada.id);
    }
    _searchController.clear();
    setState(() {
      _ubicacionesFiltradas = _ubicaciones;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ubicacionActual = _ubicaciones.firstWhere(
      (u) => u.id == widget.valorSeleccionado,
      orElse: () => const Ubicacion(id: 0, nombre: ''),
    );

    if (_isLoading) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: widget.primaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: _mostrarDialogo,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Ubicación",
          prefixIcon: Icon(Icons.location_on, color: widget.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.primaryColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.primaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: widget.primaryColor.withOpacity(0.05),
          errorText: widget.validator?.call(widget.valorSeleccionado),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                ubicacionActual.id == 0
                    ? 'Seleccionar ubicación'
                    : ubicacionActual.nombre,
                style: TextStyle(
                  color: ubicacionActual.id == 0
                      ? Colors.grey
                      : widget.primaryColor,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: widget.primaryColor),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}