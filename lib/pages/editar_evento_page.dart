import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_fest/models/evento.dart';
import 'package:flutter_fest/services/eventos_service.dart';

class EditarEventoPage extends StatefulWidget {
  final EventosService service;
  final Evento evento;

  const EditarEventoPage(
      {super.key, required this.service, required this.evento});

  @override
  State<EditarEventoPage> createState() => _EditarEventoPageState();
}

class _EditarEventoPageState extends State<EditarEventoPage> {
  final _formKey = GlobalKey<FormState>();
  late String? _nombre;
  late String? _descripcion;
  File? _foto; // tipo File para almacenar la imagen -seleccionada-

  @override
  void initState() {
    super.initState();
    _nombre = widget.evento.nombre;
    _descripcion = widget.evento.descripcion;
    // al cargar datos anteriores (como se debe hacer en un form de edición),
    // no es necesario inicializar _foto ya que se accede a la imagen existente via URL
  }

  // método para abrir y usar el selector de imágenes
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    // si se elige imagen, se coloca en _foto y se redibuja el widget
    if (pickedFile != null) {
      setState(() {
        _foto = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveEvento() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await widget.service.updateEvento(
          widget.evento.id!,
          _nombre,
          _descripcion,
          _foto,
        );
        if (mounted) Navigator.pop(context);
        // ^^^^^^^^ EXTRA: siempre que uno se refiere al "context" en un espacio asíncrono (async),
        // se debe verificar si el widget existe (está "mounted") para evitar errores de nula referencia.
        // Esto porque si se resuelve el "await" -después- de que el widget se destruye, el "context" ya no existe
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _nombre,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Este campo es requerido'
                    : null,
                onSaved: (value) => _nombre = value,
              ),
              TextFormField(
                initialValue: _descripcion,
                decoration: InputDecoration(labelText: 'Descripción'),
                onSaved: (value) => _descripcion = value,
              ),
              SizedBox(height: 16),
              // mostrar imagen seleccionada
              _foto != null
                  // si se ha seleccionado una imagen, mostrarla
                  ? Image.file(_foto!,
                      width: 100, height: 100, fit: BoxFit.cover)
                  // si no se ha seleccionado una imagen, mostrar la anterior
                  : (widget.evento.foto != null
                      ? Image.network(widget.evento.foto!,
                          width: 100, height: 100, fit: BoxFit.cover)
                      // si el evento no tenía imagen, mostrar un mensaje
                      : Text('No se ha seleccionado una imagen.')),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Seleccionar Imagen'),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _saveEvento,
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
