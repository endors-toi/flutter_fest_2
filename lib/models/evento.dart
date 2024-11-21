class Evento {
  final int? id;
  final String nombre;
  final String? descripcion;
  final String? foto; // es un String ya que el modelo NO almacena el archivo, sólo la referencia a ésta (URL)

  Evento({
    this.id,
    required this.nombre,
    this.descripcion,
    this.foto,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'foto': foto,
    };
  }
}
