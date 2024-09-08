class Usuario {
  final String tipoUsuario;
  final int id;
  final String? name; 
  final String? email; 
  final String? cpf; 
  final String? profilePicture;
  final String? course;
  final String? university;

  Usuario({
    required this.tipoUsuario,
    required this.id,
    this.name, 
    this.email,
    this.cpf, 
    this.profilePicture,
    this.course,
    this.university,
  });

  // Método para converter um JSON da resposta da API em um objeto Usuario
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      tipoUsuario: _mapUserTypeIdToTipoUsuario(json['user_type_id']),
      id: json['id'],
      name: json['name'],
      email: json['email'],
      cpf: json['cpf'],
      profilePicture: json['profile_picture'],
      course: json['course'],
      university: json['faculty_id'] != null ? 'Faculdade de Id ${json['faculty_id']}' : null,
    );
  }

  static String _mapUserTypeIdToTipoUsuario(int userTypeId) {
    switch (userTypeId) {
      case 1:
        return 'admin';
      case 2:
        return 'driver';
      case 3:
        return 'student';
      default:
        return 'unknown';
    }
  }
}
