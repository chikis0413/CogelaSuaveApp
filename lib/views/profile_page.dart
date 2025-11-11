import 'package:flutter/material.dart';
import 'package:cogela_suave/db_helper.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _apodoController = TextEditingController();
  final _carreraController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  String email = '';
  DateTime? fechaNacimiento;
  bool _isLoading = true;
  bool _isEditing = false;
  String _error = '';
  String _successMessage = '';

  final RegExp nombreApellidoRegExp = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóú ]+$');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _apodoController.dispose();
    _carreraController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final db = await DBHelper.db;
      final result = await db.query(
        'usuarios',
        where: 'id = ?',
        whereArgs: [widget.userId],
      );

      if (result.isNotEmpty) {
        final userData = result.first;
        setState(() {
          _nombreController.text = userData['nombre'] as String? ?? '';
          _apellidoController.text = userData['apellido'] as String? ?? '';
          _apodoController.text = userData['apodo'] as String? ?? '';
          _carreraController.text = userData['carrera'] as String? ?? '';
          _descripcionController.text = userData['descripcion_personal'] as String? ?? '';
          email = userData['email'] as String? ?? '';
          
          if (userData['fecha_nacimiento'] != null && userData['fecha_nacimiento'] != '') {
            try {
              fechaNacimiento = DateTime.parse(userData['fecha_nacimiento'] as String);
            } catch (e) {
              fechaNacimiento = null;
            }
          }
        });
      } else {
        setState(() {
          _error = 'Usuario no encontrado';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los datos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _error = '';
        _successMessage = '';
      });

      final db = await DBHelper.db;
      await db.update(
        'usuarios',
        {
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'apodo': _apodoController.text.trim(),
          'carrera': _carreraController.text.trim(),
          'descripcion_personal': _descripcionController.text.trim(),
        },
        where: 'id = ?',
        whereArgs: [widget.userId],
      );

      setState(() {
        _isEditing = false;
        _successMessage = 'Perfil actualizado correctamente';
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _successMessage = '';
          });
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Error al actualizar el perfil: $e';
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _error = '';
      _successMessage = '';
    });
    _loadUserData();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _isEditing ? const Color(0xFF1A73E8) : Colors.grey[600],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: maxLines > 1 ? 16 : 16,
        ),
      ),
      enabled: _isEditing,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A73E8),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isEditing && !_isLoading)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                    _error = '';
                    _successMessage = '';
                  });
                },
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const CircularProgressIndicator(
                      color: Color(0xFF1A73E8),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Cargando perfil...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con avatar
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 32),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1A73E8),
                            Color(0xFF4285F4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A73E8).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isEditing ? 'Editando Perfil' : 'Mi Información Personal',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isEditing 
                                ? 'Actualiza tu información personal' 
                                : 'Consulta y modifica tus datos',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Contenedor principal con el formulario
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mensajes de error y éxito
                          if (_error.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA4335).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFEA4335).withOpacity(0.3),
                                  ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEA4335).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.error_outline,
                                      color: Color(0xFFEA4335),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _error,
                                      style: const TextStyle(
                                        color: Color(0xFFEA4335),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (_successMessage.isNotEmpty)
                            Container(