import 'package:equatable/equatable.dart';

class RegistroPaso3State extends Equatable {
  final String nombres;
  final String apellidos;
  final String email;
  final String password;
  final String confirmPassword;
  final bool aceptaTerminos;
  final bool showPassword;
  final bool showConfirmPassword;
  final bool isSubmitting;

  const RegistroPaso3State({
    this.nombres = '',
    this.apellidos = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.aceptaTerminos = false,
    this.showPassword = false,
    this.showConfirmPassword = false,
    this.isSubmitting = false,
  });

  RegistroPaso3State copyWith({
    String? nombres,
    String? apellidos,
    String? email,
    String? password,
    String? confirmPassword,
    bool? aceptaTerminos,
    bool? showPassword,
    bool? showConfirmPassword,
    bool? isSubmitting,
  }) {
    return RegistroPaso3State(
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      aceptaTerminos: aceptaTerminos ?? this.aceptaTerminos,
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  /// ✅ Helper: todos los campos llenos + checkbox marcado
  bool get allFieldsFilled =>
      nombres.isNotEmpty &&
          apellidos.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          confirmPassword.isNotEmpty &&
          aceptaTerminos;

  @override
  List<Object?> get props => [
    nombres,
    apellidos,
    email,
    password,
    confirmPassword,
    aceptaTerminos,
    showPassword,
    showConfirmPassword,
    isSubmitting,
  ];
}