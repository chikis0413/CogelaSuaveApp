import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String apellido = '';
  String email = '';
  String fechaNacimiento = '';
  String carrera = '';
  String descripcion = '';
  String message = '';

  final RegExp nombreApellidoRegExp = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FA), // secondary-color
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFFB3D1E6), // primary-color
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7), // accent-color
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: message.contains('Error')
                            ? const Color(0xFFE57373) // error-color
                            : const Color(0xFF222222), // text-color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                  ),
                  initialValue: nombre,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (!nombreApellidoRegExp.hasMatch(value)) {
                      return 'Solo letras y espacios';
                    }
                    return null;
                  },
                  onSaved: (value) => nombre = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                  ),
                  initialValue: apellido,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (!nombreApellidoRegExp.hasMatch(value)) {
                      return 'Solo letras y espacios';
                    }
                    return null;
                  },
                  onSaved: (value) => apellido = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  initialValue: email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                  onSaved: (value) => email = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Nacimiento',
                    hintText: 'YYYY-MM-DD',
                  ),
                  initialValue: fechaNacimiento,
                  onSaved: (value) => fechaNacimiento = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Carrera',
                  ),
                  initialValue: carrera,
                  onSaved: (value) => carrera = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Descripción Personal',
                  ),
                  initialValue: descripcion,
                  maxLines: 4,
                  onSaved: (value) => descripcion = value ?? '',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB3D1E6), // primary-color
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      setState(() {
                        message = 'Perfil actualizado exitosamente';
                      });
                      // Aquí puedes agregar la lógica para guardar los datos en tu backend
                    } else {
                      setState(() {
                        message = 'Error al actualizar el perfil';
                      });
                    }
                  },
                  child: const Text('Guardar Cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}