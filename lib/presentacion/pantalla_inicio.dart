import 'package:flutter/material.dart';

import '../datos/fuentes_reales.dart';
import '../datos/fuentes_simuladas.dart';
import '../dominio/catalogo.dart';
import '../dominio/geo.dart';
import '../dominio/pasaporte.dart';
import 'ar_viewmodel.dart';
import 'pantalla_ar.dart';
import 'pantalla_modelo3d.dart';

class PantallaInicio extends StatefulWidget {
  final Pasaporte pasaporte;
  final void Function(Pasaporte)? alCambiarPasaporte;

  const PantallaInicio({super.key, required this.pasaporte, this.alCambiarPasaporte});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  Future<void> _ir(Widget pantalla) async {
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => pantalla));
    widget.alCambiarPasaporte?.call(widget.pasaporte);
    if (mounted) setState(() {}); // refresca las palomitas del pasaporte
  }

  Future<void> _irReal() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Antes de empezar'),
        content: const Text('Mira a tu alrededor, cuida tu paso y no cruces la calle viendo el teléfono.\n\n'
            'Usaremos tu ubicación y la cámara solo mientras la app está abierta. '
            'Tu ubicación no sale del teléfono.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Entendido')),
        ],
      ),
    );
    if (ok != true) return;
    await _ir(PantallaAr(
      crearVm: () => ArViewModel(
        posicion: PosicionGps(),
        brujula: BrujulaReal(),
        lugares: catalogoDolores,
        pasaporte: widget.pasaporte,
      ),
    ));
  }

  Future<void> _irDemo() async {
    // Te "teletransporta" a la Plaza Principal para practicar en el salón.
    final brujula = BrujulaSimulada();
    await _ir(PantallaAr(
      crearVm: () => ArViewModel(
        posicion: PosicionSimulada(const Coordenada(21.15600, -100.93175)),
        brujula: brujula,
        lugares: catalogoDolores,
        pasaporte: widget.pasaporte,
      ),
      controlesDemo: DeslizadorRumbo(brujula: brujula),
    ));
    brujula.cerrar();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pasaporte;
    return Scaffold(
      appBar: AppBar(title: const Text('Dolores AR')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Descubre Dolores Hidalgo con realidad aumentada', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Apunta tu teléfono y mira qué lugares históricos te rodean.'),
        const SizedBox(height: 20),
        FilledButton.icon(
            onPressed: _irReal, icon: const Icon(Icons.explore), label: const Text('Explorar con GPS real')),
        const SizedBox(height: 10),
        OutlinedButton.icon(
            onPressed: _irDemo, icon: const Icon(Icons.school), label: const Text('Modo demo (salón de clases)')),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _ir(const PantallaModelo3D()),
          icon: const Icon(Icons.view_in_ar),
          label: const Text('Modelo 3D en tu espacio'),
        ),
        const SizedBox(height: 24),
        Text('Pasaporte: ${p.total} de ${catalogoDolores.length} sellos',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: p.progreso(catalogoDolores.length), minHeight: 8),
        const SizedBox(height: 8),
        for (final l in catalogoDolores)
          ListTile(
            leading: Text(l.emoji, style: const TextStyle(fontSize: 26)),
            title: Text(l.nombre),
            subtitle: Text(l.datoCurioso, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Icon(p.visitado(l.id) ? Icons.verified : Icons.circle_outlined,
                color: p.visitado(l.id) ? Colors.green : null),
          ),
      ]),
    );
  }
}

class DeslizadorRumbo extends StatefulWidget {
  final BrujulaSimulada brujula;

  const DeslizadorRumbo({super.key, required this.brujula});

  @override
  State<DeslizadorRumbo> createState() => _DeslizadorRumboState();
}

class _DeslizadorRumboState extends State<DeslizadorRumbo> {
  double _grados = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        const Text('Gira:', style: TextStyle(color: Colors.white)),
        Expanded(
          child: Slider(
            min: 0,
            max: 359,
            value: _grados,
            onChanged: (g) {
              setState(() => _grados = g);
              widget.brujula.girar(g);
            },
          ),
        ),
        Text('${_grados.round()}°', style: const TextStyle(color: Colors.white)),
      ]),
    );
  }
}
