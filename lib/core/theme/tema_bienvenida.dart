import 'package:flutter/material.dart';
import 'colores_bienvenida.dart';
import 'typography.dart';

/// Tema claro de bienvenida
final ThemeData temaBienvenidaClaro = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: temaClaroBotonGradienteInicio,
    secondary: temaClaroBotonGradienteFin,
    onPrimary: temaClaroBotonGradienteContent,
    error: temaClaroTextoError,
    surface: Colors.white,
    onSurface: temaClaroTextoPrincipal,
    onSurfaceVariant: temaClaroTextoSecundario,
    tertiary: temaClaroTextoTerciario,
  ),
  textTheme: AppTypography.textTheme,
);

/// Tema oscuro de bienvenida
final ThemeData temaBienvenidaOscuro = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: temaOscuroBotonGradienteInicio,
    secondary: temaOscuroBotonGradienteFin,
    onPrimary: temaOscuroBotonGradienteContent,
    error: temaOscuroTextoError,
    surface: Colors.black,
    onSurface: temaOscuroTextoPrincipal,
    onSurfaceVariant: temaOscuroTextoSecundario,
    tertiary: temaOscuroTextoTerciario,
  ),
  textTheme: AppTypography.textTheme,
);
