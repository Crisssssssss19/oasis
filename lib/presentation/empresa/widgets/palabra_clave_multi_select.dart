// lib/presentation/widgets/palabra_clave_multi_select.dart
import 'package:flutter/material.dart';
import 'package:oasis/domain/model/palabra_clave.dart';
import 'package:oasis/core/services/json_loader_service.dart';

/// Widget para seleccionar múltiples palabras clave
/// ✅ Trabaja con IDs internamente, pero muestra nombres al usuario
class PalabraClaveMultiSelect extends StatefulWidget {
  final List<int> idsSeleccionados; // ✅ CAMBIO: Ahora recibe IDs
  final void Function(List<int>) onChanged; // ✅ CAMBIO: Ahora devuelve IDs
  final Color primaryColor;
  final Color onPrimaryColor;

  const PalabraClaveMultiSelect({
    super.key,
    required this.idsSeleccionados,
    required this.onChanged,
    required this.primaryColor,
    required this.onPrimaryColor,
  });

  @override
  State<PalabraClaveMultiSelect> createState() =>
      _PalabraClaveMultiSelectState();
}

class _PalabraClaveMultiSelectState extends State<PalabraClaveMultiSelect> {
  final _searchController = TextEditingController();
  final _jsonLoader = JsonLoaderService();
  List<PalabraClave> _palabrasClave = [];
  List<PalabraClave> _palabrasFiltradas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPalabrasClave();
  }

  Future<void> _cargarPalabrasClave() async {
    final palabras = await _jsonLoader.cargarPalabrasClave();
    setState(() {
      _palabrasClave = palabras;
      _palabrasFiltradas = palabras;
      _isLoading = false;
    });
  }

  void _filtrar(String query) {
    setState(() {
      _palabrasFiltradas = _jsonLoader.buscarPalabrasClave(query, _palabrasClave);
    });
  }

  void _agregarPalabra(PalabraClave palabra) {
    if (!widget.idsSeleccionados.contains(palabra.id)) { // ✅ CAMBIO: Comparar por ID
      widget.onChanged([...widget.idsSeleccionados, palabra.id]); // ✅ CAMBIO: Agregar ID
    }
  }

  void _eliminarPalabra(int palabraId) { // ✅ CAMBIO: Recibir ID
    widget.onChanged(
      widget.idsSeleccionados.where((id) => id != palabraId).toList(), // ✅ CAMBIO: Filtrar por ID
    );
  }

  void _mostrarDialogo() async {
    // Resetear filtro antes de mostrar el diálogo
    setState(() {
      _palabrasFiltradas = _palabrasClave;
    });

    await showDialog(
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
                      "Agregar Habilidades",
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
                        hintText: "Buscar habilidad...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _palabrasFiltradas = _jsonLoader.buscarPalabrasClave(value, _palabrasClave);
                        });
                        setDialogState(() {}); // Actualizar el diálogo
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Lista de palabras clave
                  Expanded(
                    child: _palabrasFiltradas.isEmpty
                        ? const Center(child: Text("No se encontraron resultados"))
                        : ListView.builder(
                            itemCount: _palabrasFiltradas.length,
                            itemBuilder: (context, index) {
                              final palabra = _palabrasFiltradas[index];
                              final yaSeleccionada = widget.idsSeleccionados.contains(palabra.id); // ✅ CAMBIO: Comparar por ID
                              return ListTile(
                                leading: Icon(
                                  yaSeleccionada ? Icons.check_circle : Icons.circle_outlined,
                                  color: yaSeleccionada ? widget.primaryColor : Colors.grey,
                                ),
                                title: Text(palabra.nombre),
                                onTap: () {
                                  _agregarPalabra(palabra);
                                  Navigator.of(context).pop();
                                },
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

    _searchController.clear();
    setState(() {
      _palabrasFiltradas = _palabrasClave;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botón para agregar palabras
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _mostrarDialogo,
          icon: Icon(Icons.add, color: widget.primaryColor),
          label: Text(
            "Agregar Habilidades",
            style: TextStyle(color: widget.primaryColor),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: widget.primaryColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: CircularProgressIndicator()),
          ),

        // Lista de palabras seleccionadas (mostrar nombres)
        if (widget.idsSeleccionados.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.idsSeleccionados.map((id) {
              // ✅ CAMBIO: Buscar el nombre correspondiente al ID
              final palabra = _palabrasClave.firstWhere(
                (p) => p.id == id,
                orElse: () => PalabraClave(id: id, nombre: 'ID: $id'),
              );
              
              return Chip(
                label: Text(
                  palabra.nombre, // ✅ CAMBIO: Mostrar nombre pero trabajar con ID
                  style: TextStyle(color: widget.onPrimaryColor),
                ),
                backgroundColor: widget.primaryColor,
                deleteIcon: Icon(
                  Icons.close,
                  size: 18,
                  color: widget.onPrimaryColor,
                ),
                onDeleted: () => _eliminarPalabra(id), // ✅ CAMBIO: Eliminar por ID
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}