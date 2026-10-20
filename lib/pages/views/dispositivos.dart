import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DispositivosTab extends StatelessWidget {
  final String tipo; // 'detectores' o 'valvulas'
  final String etiqueta; // 'Detector' o 'Válvula'
  final Color color;
  final String Function(Map data) textoEstado;
  final Widget Function(String id, String nombre) detalle;

  const DispositivosTab({
    super.key,
    required this.tipo,
    required this.etiqueta,
    required this.color,
    required this.textoEstado,
    required this.detalle,
  });

  // Lista de dispositivos del usuario actual
  DatabaseReference get _lista {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseDatabase.instance.ref('usuarios/$uid/$tipo');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          tipo == 'detectores' ? 'Sensores' : 'Válvulas',
          style: const TextStyle(fontSize: 22),
        ),
        TextButton.icon(
          onPressed: () => _agregar(context),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Agregar'),
        ),
        Expanded(
          child: StreamBuilder<DatabaseEvent>(
            stream: _lista.onValue,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final value = snapshot.data!.snapshot.value;
              if (value is! Map || value.isEmpty) {
                return const Center(
                  child: Text('Todavía no agregaste ningún dispositivo.'),
                );
              }
              final items = value.entries.toList();
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final id = items[i].key.toString();
                  final nombre = items[i].value.toString();
                  return _Tarjeta(
                    tipo: tipo,
                    etiqueta: etiqueta,
                    color: color,
                    id: id,
                    nombre: nombre,
                    textoEstado: textoEstado,
                    detalle: detalle,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _agregar(BuildContext context) async {
    final idController = TextEditingController();
    final nombreController = TextEditingController();
    String? error;
    bool cargando = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Agregar ${etiqueta.toLowerCase()}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'ID del dispositivo',
                ),
              ),
              TextField(
                controller: nombreController,
                maxLength: 20,
                decoration: InputDecoration(
                  labelText: 'Nombre (ej: Cocina)',
                  errorText: error,
                  errorMaxLines: 2,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: cargando ? null : () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: cargando
                  ? null
                  : () async {
                      final id = idController.text.trim();
                      final nombre = nombreController.text.trim();

                      if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(id)) {
                        setDialogState(() => error = 'Ingresa un ID válido.');
                        return;
                      }

                      setDialogState(() {
                        cargando = true;
                        error = null;
                      });

                      try {
                        final existe = await FirebaseDatabase.instance
                            .ref('$tipo/$id')
                            .get();
                        if (!existe.exists) {
                          setDialogState(() {
                            cargando = false;
                            error = 'No existe un dispositivo con ese ID.';
                          });
                          return;
                        }
                        await _lista
                            .child(id)
                            .set(nombre.isEmpty ? '$etiqueta $id' : nombre);
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setDialogState(() {
                          cargando = false;
                          error = 'No se pudo conectar. Revisa tu conexión.';
                        });
                      }
                    },
              child: cargando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Conectar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final String tipo, etiqueta, id, nombre;
  final Color color;
  final String Function(Map data) textoEstado;
  final Widget Function(String id, String nombre) detalle;

  const _Tarjeta({
    required this.tipo,
    required this.etiqueta,
    required this.color,
    required this.id,
    required this.nombre,
    required this.textoEstado,
    required this.detalle,
  });

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('$tipo/$id');

    return StreamBuilder<DatabaseEvent>(
      stream: ref.onValue,
      builder: (context, snapshot) {
        final data = snapshot.data?.snapshot.value;
        final estado = data is Map ? textoEstado(data) : 'Sin datos';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: color,
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              title: Text(
                '$etiqueta: $nombre',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Estado: $estado',
                style: const TextStyle(color: Colors.white),
              ),
              trailing: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_forward, color: Colors.black),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => detalle(id, nombre)),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------- Pantallas de detalle (al tocar la flecha) ----------

class DetalleDetector extends StatelessWidget {
  final String id, nombre;
  const DetalleDetector({super.key, required this.id, required this.nombre});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('detectores/$id');

    return Scaffold(
      appBar: AppBar(
        title: Text('Detector: $nombre'),
        backgroundColor: const Color(0xFFC61A2B),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          final data = snapshot.data?.snapshot.value;
          if (data is! Map) {
            return const Center(child: CircularProgressIndicator());
          }
          final gas = data['gas'] ?? 0;
          final estado = (data['estado'] ?? 'Desconocido').toString();

          Color c;
          switch (estado.toLowerCase()) {
            case 'limpio':
              c = Colors.green;
              break;
            case 'fuga':
              c = Colors.red;
              break;
            default:
              c = Colors.orange;
          }

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sensors, color: c, size: 80),
                const SizedBox(height: 16),
                Text(
                  estado,
                  style: TextStyle(
                    color: c,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Gas: $gas', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                Text('ID: $id'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DetalleValvula extends StatelessWidget {
  final String id, nombre;
  const DetalleValvula({super.key, required this.id, required this.nombre});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('valvulas/$id/abierta');

    return Scaffold(
      appBar: AppBar(
        title: Text('Válvula: $nombre'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final abierta = snapshot.data!.snapshot.value == true;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: SwitchListTile(
                secondary: Icon(
                  abierta ? Icons.lock_open : Icons.lock,
                  color: abierta ? Colors.green : Colors.red,
                  size: 40,
                ),
                title: Text(abierta ? 'Válvula abierta' : 'Válvula cerrada'),
                subtitle: Text('ID: $id'),
                value: abierta,
                onChanged: (value) => ref.set(value),
              ),
            ),
          );
        },
      ),
    );
  }
}