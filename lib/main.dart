import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dominio/pasaporte.dart';
import 'presentacion/pantalla_inicio.dart';

const _clavePasaporte = 'pasaporte_ids';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // La brújula y la cámara se comportan mejor con el teléfono en vertical.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  // Solo se guardan ids de lugares visitados, nunca coordenadas del usuario.
  final pasaporte = Pasaporte.desdeLista(prefs.getStringList(_clavePasaporte) ?? []);
  runApp(MaterialApp(
    title: 'Dolores AR',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
    home: PantallaInicio(
      pasaporte: pasaporte,
      alCambiarPasaporte: (p) => prefs.setStringList(_clavePasaporte, p.aLista()),
    ),
  ));
}
