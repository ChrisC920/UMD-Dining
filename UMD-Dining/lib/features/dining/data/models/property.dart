class Property {
  final int id;
  final String name;

  Property({required this.id, required this.name});

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      name: json['name'],
    );
  }
}
