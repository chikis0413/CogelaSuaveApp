import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _carreraController;
  late TextEditingController _descripcionController;
  final _apiService = ApiService();
  
  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _apellidoController = TextEditingController();
    _carreraController = TextEditingController();
    _descripcionController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _carreraController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await _apiService.getUserById(widget.userId);

    if (result['success']) {
      setState(() {
        _user = result['user'];
        _nombreController.text = _user!.nombre ?? '';
        _apellidoController.text = _user!.apellido ?? '';
        _carreraController.text = _user!.carrera ?? '';
        _descripcionController.text = _user!.descripcionPersonal ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message'];
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final userData = {
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'carrera': _carreraController.text,
        'descripcion_personal': _descripcionController.text,
      };

      final result = await _apiService.updateUser(widget.userId, userData);

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
        _loadUserData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        automaticallyImplyLeading: false, // Elimina la flecha de atrás
        actions: [
          if (!_isEditing && !_isLoading && _user != null)
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
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          child: Icon(Icons.person, size: 60),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Usuario', _user?.apodo ?? '', Icons.account_circle),
                                const Divider(),
                                _buildInfoRow('Email', _user?.email ?? '', Icons.email),
                                if (_user?.fechaNacimiento != null) ...[
                                  const Divider(),
                                  _buildInfoRow('Fecha de Nacimiento', _user!.fechaNacimiento!, Icons.cake),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nombreController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person),
                            filled: !_isEditing,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _apellidoController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Apellido',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: !_isEditing,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _carreraController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Carrera',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.school),
                            filled: !_isEditing,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descripcionController,
                          enabled: _isEditing,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Descripción Personal',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.description),
                            filled: !_isEditing,
                          ),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = false;
                                      _loadUserData();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Guardar'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}