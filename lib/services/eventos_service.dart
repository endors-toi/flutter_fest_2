import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http; // flutter pub add http
import 'package:flutter_fest/models/evento.dart';

class EventosService {
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<List<Evento>> getEventos() async {
    // implementación común de GET
    final response = await http.get(Uri.parse('$baseUrl/eventos'), headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Evento.fromJson(json)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Evento> createEvento(String nombre, String? descripcion, File? foto) async {
    // cuando se quiere crear un recurso que tiene un archivo,
    // se debe construir el request manualmente.
    // para esto se utiliza http.MultipartRequest()

    // iniciar objeto Request con sus headers
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/eventos'));
    request.headers.addAll({'Accept': 'application/json', 'Content-Type': 'application/json'});

    // agregar campos (se revisa si son nulos cuando los campos son opcionales)
    request.fields['nombre'] = nombre;
    if (descripcion != null) request.fields['descripcion'] = descripcion;

    // agregar archivo
    if (foto != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    }

    // enviar request y recibir respuesta
    final response = await http.Response.fromStream(await request.send());

    // manejar respuesta
    if (response.statusCode == 201) {
      return Evento.fromJson(jsonDecode(response.body));
    } else {
      // esto mostrará el mensaje de error directo desde la API a la pantalla gracias a FutureBuilder
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Evento> updateEvento(int id, String? nombre, String? descripcion, File? foto) async {
    // lo mismo que en create, con la excepción de que se debe elegir "POST" como método
    // y especificar "PUT" en la URL, similar a cómo se debía hacer en Desarrollo Web con Laravel
    
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/eventos/$id?_method=PUT'));
    request.headers.addAll({'Accept': 'application/json'});

    if (nombre != null) request.fields['nombre'] = nombre;
    if (descripcion != null) request.fields['descripcion'] = descripcion;

    if (foto != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    }

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) {
      return Evento.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> deleteEvento(int id) async {
    // implementación común de DELETE
    final response =
        await http.delete(Uri.parse('$baseUrl/eventos/$id'), headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 204) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}
