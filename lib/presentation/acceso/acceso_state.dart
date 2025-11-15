class AccesoState {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool loading;
  final bool submitted;

  const AccesoState({
    this.email = "",
    this.password = "",
    this.emailError,
    this.passwordError,
    this.loading = false,
    this.submitted = false,
  });

  // Sentinel interno
  static const Object noChange = _noChange;

  AccesoState copyWith({
    String? email,
    String? password,
    Object? emailError = _noChange,
    Object? passwordError = _noChange,
    bool? loading,
    bool? submitted,
  }) {
    return AccesoState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError == _noChange
          ? this.emailError
          : emailError as String?,
      passwordError: passwordError == _noChange
          ? this.passwordError
          : passwordError as String?,
      loading: loading ?? this.loading,
      submitted: submitted ?? this.submitted,
    );
  }
}

const _noChange = Object();
