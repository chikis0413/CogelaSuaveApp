import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'main.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String apellido = '';
  String apodo = '';
  String email = '';
  String contrasena = '';
  DateTime? fechaNacimiento;
  String carrera = '';
  String descripcion = '';
  String error = '';

  final RegExp nombreApellidoRegExp = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóú ]+$');

  Future<void> _register() async {
  final usuario = {
    'apodo': apodo,
    'contrasena': contrasena,
    'email': email,
    'nombre': nombre,
    'apellido': apellido,
    'fecha_nacimiento': fechaNacimiento != null
        ? fechaNacimiento!.toIso8601String().substring(0, 10)
        : '',
    'carrera': carrera,
    'descripcion_personal': descripcion,
  };
  try {
    var box = Hive.box('usuarios');
    await box.add(usuario); // <-- Aquí guardas el usuario
    Navigator.of(context).pushReplacementNamed('/home');
  } catch (e) {
    setState(() {
      error = 'Error al registrar: $e';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FA), // secondary-color
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Crear una cuenta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        error,
                        style: const TextStyle(
                          color: Color(0xFFE57373),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Nombre'),
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Apellido'),
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      return null;
                    },
                    onSaved: (value) => apodo = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Correo electrónico'),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      if (value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                    onSaved: (value) => contrasena = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                fechaNacimiento = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              fechaNacimiento == null
                                  ? 'Fecha de nacimiento'
                                  : '${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}',
                              style: TextStyle(
                                color: fechaNacimiento == null ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Carrera'),
                          onSaved: (value) => carrera = value ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Descripción personal',
                      hintText: 'Cuéntanos un poco sobre ti...',
                    ),
                    maxLines: 4,
                    onSaved: (value) => descripcion = value ?? '',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4a90e2),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false && fechaNacimiento != null) {
                          _formKey.currentState?.save();
                          setState(() {
                            error = '';
                          });
                          _register();
                        } else {
                          setState(() {
                            error = fechaNacimiento == null
                                ? 'Selecciona la fecha de nacimiento.'
                                : 'Por favor revisa los campos.';
                          });
                        }
                      },
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tienes una cuenta?'),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
                        },
                        child: const Text(
                          'Inicia sesión',
                          style: TextStyle(color: Color(0xFF4a90e2)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}