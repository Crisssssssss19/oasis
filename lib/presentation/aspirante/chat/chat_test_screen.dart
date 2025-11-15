import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:oasis/core/di/providers.dart";
import "package:oasis/presentation/aspirante/chat/chat_provider.dart";
import "package:oasis/presentation/aspirante/chat/chat_screen.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Pantalla de prueba para parametrizar el chat
/// Permite ingresar userId, empresaId, vacanteId y URL del backend
class ChatTestScreen extends ConsumerStatefulWidget {
  const ChatTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatTestScreen> createState() => _ChatTestScreenState();
}

class _ChatTestScreenState extends ConsumerState<ChatTestScreen> {
  late TextEditingController _userIdController;
  late TextEditingController _empresaIdController;
  late TextEditingController _vacanteIdController;
  late TextEditingController _backendUrlController;

  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController(text: "101");
    _empresaIdController = TextEditingController();
    _vacanteIdController = TextEditingController();
    _backendUrlController = TextEditingController(text: "http://localhost:3210");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cargar URL después de que el widget esté montado y tenga acceso a ref
    _cargarUrlGuardada();
  }

  /// Carga la URL guardada previamente, si existe
  Future<void> _cargarUrlGuardada() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final urlGuardada = prefs.getString("chat_backend_url");
      if (urlGuardada != null && urlGuardada.isNotEmpty) {
        _backendUrlController.text = urlGuardada;
        // Actualizar el provider con la URL guardada
        ref.read(chatBackendUrlProvider.notifier).state = urlGuardada;
      }
    } catch (e) {
      // Si hay error, usamos el valor por defecto
    }
  }

  /// Guarda la URL en SharedPreferences y actualiza el provider
  Future<void> _guardarUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final urlParaGuardar = _backendUrlController.text.trim();
      await prefs.setString("chat_backend_url", urlParaGuardar);
      
      // Actualizar el StateProvider para que los otros providers se recalculen
      ref.read(chatBackendUrlProvider.notifier).state = urlParaGuardar;
    } catch (e) {
      print("Error guardando URL: $e");
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _empresaIdController.dispose();
    _vacanteIdController.dispose();
    _backendUrlController.dispose();
    super.dispose();
  }

  /// Inicia carga de chats con los parámetros
  Future<void> _cargarChats() async {
    final userId = int.tryParse(_userIdController.text);
    final empresaId = _empresaIdController.text.isEmpty
        ? null
        : int.tryParse(_empresaIdController.text);
    final vacanteId = _vacanteIdController.text.isEmpty
        ? null
        : int.tryParse(_vacanteIdController.text);
    
    // Validar URL del backend
    final backendUrl = _backendUrlController.text.trim();
    if (backendUrl.isEmpty) {
      _mostrarError("Debes ingresar la URL del backend");
      return;
    }

    // Validar formato de URL
    final uri = Uri.tryParse(backendUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      _mostrarError("URL inválida. Debe ser del formato http://host:puerto");
      return;
    }

    if (userId == null || userId <= 0) {
      _mostrarError("userId debe ser un número válido mayor a 0");
      return;
    }

    setState(() => _cargando = true);

    try {
      // Guardar la URL antes de continuar
      await _guardarUrl();
      
      final notifier = ref.read(chatProvider.notifier);
      notifier.setUsuarioId(userId);
      
      // Establecer empresaId si se proporciona
      if (empresaId != null) {
        notifier.setEmpresaId(empresaId);
      }

      await notifier.cargarChats(
        empresaId: empresaId,
        vacanteId: vacanteId,
      );

      // Navegar a la pantalla principal del chat
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ChatScreen(),
          ),
        );
      }
    } catch (e) {
      _mostrarError("Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  /// Muestra un error al usuario
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🧪 Prueba de Chat"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              "Parámetros de Prueba",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ingresa los parámetros para probar el módulo de chat",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Campo: User ID
            _buildTextFormField(
              controller: _userIdController,
              label: "User ID",
              hint: "ID del usuario (requerido)",
              icon: Icons.person,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Campo: Empresa ID
            _buildTextFormField(
              controller: _empresaIdController,
              label: "Empresa ID",
              hint: "ID de la empresa (opcional)",
              icon: Icons.business,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Campo: Vacante ID
            _buildTextFormField(
              controller: _vacanteIdController,
              label: "Vacante ID",
              hint: "ID de la vacante (opcional)",
              icon: Icons.work,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Campo: Backend URL
            _buildTextFormField(
              controller: _backendUrlController,
              label: "Backend URL",
              hint: "http://localhost:3210",
              icon: Icons.link,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),

            // Información
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "💡 Notas:",
                    style: TextTheme.of(context).titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "• User ID es requerido\n"
                    "• Backend URL debe incluir protocolo y puerto\n"
                    "• Empresa ID y Vacante ID son opcionales\n"
                    "• Si dejas vacíos los opcionales, verás todos tus chats\n"
                    "• Si llenas Vacante ID, verás chats de esa vacante\n"
                    "• Si llenas Empresa ID, verás chats de esa empresa",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botón principal
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _cargando ? null : _cargarChats,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: _cargando
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Cargar Chats",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Botón de ejemplo
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _cargando
                    ? null
                    : () {
                        // Llenar con valores de ejemplo
                        _userIdController.text = "101";
                        _empresaIdController.text = "";
                        _vacanteIdController.text = "";
                        _backendUrlController.text = "http://localhost:3210";
                      },
                child: const Text("Usar valores por defecto"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para construir campos de texto personalizados
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: !_cargando,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
