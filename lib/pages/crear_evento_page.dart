import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // flutter pub add image_picker
import 'package:flutter_fest/services/eventos_service.dart';

class CrearEventoPage extends StatefulWidget {
  final EventosService service;

  const CrearEventoPage({super.key, required this.service});

  @override
  State<CrearEventoPage> createState() => _CrearEventoPageState();
}

class _CrearEventoPageState extends State<CrearEventoPage> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String? _descripcion;
  File? _foto; // tipo File para almacenar la imagen

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
      _formKey.currentState!.save(); // EXTRA: este método ejecuta todos los "onSaved" de los campos del formulario
      try {
        await widget.service.createEvento(_nombre, _descripcion, _foto);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          // ^^^^^^ EXTRA: siempre que uno se refiere al "context" en un espacio asíncrono (async),
          // se debe verificar si el widget existe (está "mounted") para evitar errores de nula referencia.
          // Esto porque si se resuelve el "await" -después- de que el widget se destruye, el "context" ya no existe
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
        title: Text('Crear Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Este campo es requerido'
                    : null,
                onSaved: (value) => _nombre = value!,
                // EXTRA: onSaved es una manera alternativa de guardar los datos de un formulario.
                // en lugar de usar controllers, se crea este evento con una función que se ejecuta
                // cuando el formulario asociado es guardado.

                // en este FormField en específico,
                // cuando se hace _formKey.currentState!.save()
                // se asignará el "value" a la variable "_nombre"
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Descripción'),
                onSaved: (value) => _descripcion = value,
              ),
              SizedBox(height: 16),
              // si se ha seleccionado imagen,
              _foto != null
                  // se muestra.
                  ? Image.file(_foto!,
                      width: 100, height: 100, fit: BoxFit.cover)
                  // si no, un mensaje
                  : Text('No se ha seleccionado una imagen.'),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Seleccionar Imagen'),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _saveEvento,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
