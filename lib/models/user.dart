class User {
  final int id;
  final String apodo;
  final String email;
  final String? nombre;
  final String? apellido;
  final String? fechaNacimiento;
  final String? carrera;
  final String? descripcionPersonal;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.apodo,
    required this.email,
    this.nombre,
    this.apellido,
    this.fechaNacimiento,
    this.carrera,
    this.descripcionPersonal,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      apodo: json['apodo'],
      email: json['email'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      fechaNacimiento: json['fecha_nacimiento'],
      carrera: json['carrera'],
      descripcionPersonal: json['descripcion_personal'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apodo': apodo,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'fecha_nacimiento': fechaNacimiento,
      'carrera': carrera,
      'descripcion_personal': descripcionPersonal,
    };
  }
}
