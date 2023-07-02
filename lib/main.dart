import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './accueil.dart';

void main() {
// Exécute l'application Flutter en enveloppant DemineurApp avec ProviderScope
  runApp(ProviderScope(child: DemineurApp()));
}

class DemineurApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
// Construit l'interface utilisateur de l'application
    return MaterialApp(
// Titre de l'application
      title: 'Démineur',
      theme: ThemeData(
// Thème de l'application avec la couleur principale définie comme bleu
        primarySwatch: Colors.blue,
      ),
// Page d'accueil de l'application
      home: const Accueil(),
    );
  }
}
