import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

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
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.user.nombre);
    _apellidoController = TextEditingController(text: widget.user.apellido);
    _carreraController = TextEditingController(text: widget.user.carrera);
    _descripcionController = TextEditingController(text: widget.user.descripcionPersonal);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _carreraController.dispose();
    _descripcionController.dispose();
    super.dispose();
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

      final result = await _apiService.updateUser(widget.user.id, userData);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
            tooltip: _isEditing ? 'Cancelar' : 'Editar',
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      _buildInfoRow('Usuario', widget.user.apodo, Icons.account_circle),
                      const Divider(),
                      _buildInfoRow('Email', widget.user.email, Icons.email),
                      const Divider(),
                      if (widget.user.fechaNacimiento != null)
                        _buildInfoRow('Fecha de Nacimiento', widget.user.fechaNacimiento!, Icons.cake),
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
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  filled: !_isEditing,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apellidoController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                  filled: !_isEditing,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _carreraController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'Carrera',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
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
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  filled: !_isEditing,
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
}
