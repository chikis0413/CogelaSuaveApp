import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Paleta de colores personalizada
class AppColors {
  static const Color primary = Color(0xFFB3D1E6);
  static const Color secondary = Color(0xFFEAF3FA);
  static const Color accent = Color(0xFFF7F7F7);
  static const Color text = Color(0xFF222222);
  static const Color error = Color(0xFFE57373);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cogela Suave',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.secondary,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.text, fontFamily: 'Poppins'),
        ),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.text,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.accent,
          border: OutlineInputBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(AppColors.primary),
            foregroundColor: MaterialStatePropertyAll(AppColors.text),
            textStyle: MaterialStatePropertyAll(TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// Página de Login mejorada
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

  void _login() {
    // Simulación de autenticación
    setState(() {
      if (_emailController.text == "usuario" && _passwordController.text == "contraseña") {
        _error = null;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AccountPage()),
        );
      } else {
        _error = "Usuario o contraseña incorrectos.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Bienvenido a Cogela Suave",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tu espacio seguro para el bienestar mental",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Usuario",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text("Iniciar Sesión"),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Navegar a la página de registro
                  },
                  child: const Text("¿No tienes cuenta? Regístrate aquí"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Página de Cuenta con navegación entre pestañas
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Cuenta"),
      ),
      body: _selectedIndex == 0
          ? const ActivityRegistrationPage()
          : _selectedIndex == 1
              ? const CalendarPage()
              : const EmotionRegistrationPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Registrar Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'Registrar Emociones',
          ),
        ],
      ),
    );
  }
}

// Página para registrar actividades
class ActivityRegistrationPage extends StatelessWidget {
  const ActivityRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Lógica para registrar actividades
        },
        child: const Text("Registrar Actividad"),
      ),
    );
  }
}

// Página de calendario
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Aquí va el Calendario"),
    );
  }
}

// Página para registrar emociones
class EmotionRegistrationPage extends StatelessWidget {
  const EmotionRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Lógica para registrar emociones
        },
        child: const Text("Registrar Emoción"),
      ),
    );
  }
}
