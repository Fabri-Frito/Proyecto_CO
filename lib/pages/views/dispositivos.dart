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

  /*|-----------------------------------------------|
  |                                               |
  |  Widget para mostrar la lista de dispositivos |
  |                                               |
  |-----------------------------------------------|*/
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          tipo == 'detectores' ? 'Sensores' : 'Válvulas',
          style: const TextStyle(fontSize: 22),
        ),

        Column(
          //Boton para agregar un nuevo dispositivo
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 16), // Espacio superior
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () => _agregar(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC61A2B),
                    fixedSize: const Size(40, 40), // Tamaño fijo del botón
                    shape: const CircleBorder(), // Mantiene tu diseño circular
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: StreamBuilder<DatabaseEvent>(
            // Escucha los cambios en la lista de dispositivos del usuario
            stream: _lista.onValue,
            builder: (context, snapshot) {
              // Muestra un indicador de carga mientras se obtienen los datos y se realiza una validadión de errores
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
                // Muestra la lista de dispositivos en tarjetas
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

  /*|--------------------------------------------|
  |                                            |
  |  Funcion para agregar un nuevo dispositivo |
  |                                            |
  |--------------------------------------------|
*/
  Future<void> _agregar(BuildContext context) async {
    final idController = TextEditingController();
    final nombreController = TextEditingController();
    String? error;
    bool cargando = false;

    await showDialog(
      //para pedir el id y nombre del dispositivo
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          // Diálogo para agregar un nuevo dispositivo
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
            // Botones de cancelar y conectar
            TextButton(
              onPressed: cargando ? null : () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              // Botón para conectar el dispositivo
              onPressed: cargando
                  ? null
                  : () async {
                      // Validación y conexión del dispositivo
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
                        if (ctx.mounted)
                          Navigator.pop(
                            ctx,
                          ); // Cierra el diálogo si la conexión fue exitosa
                      } catch (e) {
                        // Manejo de errores de conexión
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

/*|--------------------------------------------|
  |                                            |
  |  Widget para mostrar cada tarjeta de       |
  |  dispositivo en la lista                   |
  |                                            |
  |--------------------------------------------|*/
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

  /*|--------------------------------------------|
    |                                            |
           
    |                                            |
    |--------------------------------------------|                                            
  */
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

/*|----------------------------------------------------|
  |                                                    |
  |  Pantalla para mostrar el estado del detector y    |
  |            la cocentracion de gas                  |
  |                                                    |
  |----------------------------------------------------|
*/
class DetalleDetector extends StatelessWidget {
  final String id, nombre;
  const DetalleDetector({
    super.key,
    required this.id,
    required this.nombre,
  }); // Constructor para recibir el ID y nombre del detector

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref(
      'detectores/$id',
    ); // Referencia a los datos del detector

    return Scaffold(
      appBar: AppBar(
        title: Text('Detector: $nombre'),
        backgroundColor: const Color(0xFFC61A2B),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          // Muestra un indicador de carga mientras se obtienen los datos
          final data = snapshot.data?.snapshot.value;
          if (data is! Map) {
            // Si los datos no son un mapa, muestra un indicador de carga
            return const Center(child: CircularProgressIndicator());
          }

          final gas = data['gas'] ?? 0;
          final estado = (data['estado'] ?? 'Desconocido').toString();

          Color c;
          switch (estado.toLowerCase()) {
            // Cambia el color según el estado del detector
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

/*|----------------------------------------------------|
  |                                                    |
  |  Pantalla para poder abrir o cerrar la valvula     |
  |                                                    |
  |----------------------------------------------------|
*/
class DetalleValvula extends StatelessWidget {
  final String id, nombre;
  const DetalleValvula({
    super.key,
    required this.id,
    required this.nombre,
  }); // Constructor para recibir el ID y nombre de la válvula

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref(
      'valvulas/$id/abierta',
    ); // Referencia al estado de la válvula

    return Scaffold(
      appBar: AppBar(
        title: Text('Válvula: $nombre'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DatabaseEvent>(
        // Escucha los cambios en el estado de la válvula
        stream: ref.onValue,
        builder: (context, snapshot) {
          // Muestra un indicador de carga mientras se obtienen los datos
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final abierta =
              snapshot.data!.snapshot.value ==
              true; // Determina si la válvula está abierta o cerrada

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  abierta ? 'Válvula abierta' : 'Válvula cerrada',
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Muestra un diálogo de confirmación antes de cambiar el estado
                      final result = await showBasicDialog(context);
                      if (result == true) {
                        await ref.set(!abierta);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: abierta ? Colors.green : Colors.red,

                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(50),
                    ),
                    child: Icon(
                      abierta ? Icons.lock_open : Icons.lock,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text("ID: $id", style: const TextStyle(fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<bool?> showBasicDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmación'),
      content: const Text('¿Estás seguro de cambiar el estado de la válvula?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
}
