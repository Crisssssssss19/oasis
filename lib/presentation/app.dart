import 'package:flutter/material.dart';
import 'package:oasis/core/theme/tema.dart';
import 'package:oasis/presentation/router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Swallow',
      theme: temaClaro,
      darkTheme: temaOscuro,
      themeMode: ThemeMode.system,
    );
  }
}
