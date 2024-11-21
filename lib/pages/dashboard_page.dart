import 'package:flutter/material.dart';
import 'package:flutter_fest/models/evento.dart';
import 'package:flutter_fest/services/eventos_service.dart';
import 'crear_evento_page.dart';
import 'editar_evento_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final EventosService _service = EventosService();
  late Future<List<Evento>> _eventos;

  @override
  void initState() {
    super.initState();
    _loadEventos();
  }

  void _loadEventos() {
    setState(() {
      _eventos = _service.getEventos();
    });
  }

  void _navigateToCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CrearEventoPage(service: _service)),
    );
    _loadEventos();
  }

  void _navigateToEdit(Evento evento) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditarEventoPage(service: _service, evento: evento),
      ),
    );
    _loadEventos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToCreate,
          ),
        ],
      ),
      body: FutureBuilder<List<Evento>>(
        future: _eventos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No eventos found.'));
          } else {
            final eventos = snapshot.data!;
            return ListView.builder(
              itemCount: eventos.length,
              itemBuilder: (context, index) {
                final evento = eventos[index];
                return ListTile(
                  leading: evento.foto != null
                      // consumir imagen desde API
                      ? Image.network(evento.foto!,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.event),
                  title: Text(evento.nombre),
                  subtitle: Text(evento.descripcion ?? 'Sin descripción'),
                  onTap: () => _navigateToEdit(evento),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _service.deleteEvento(evento.id!);
                      _loadEventos();
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
