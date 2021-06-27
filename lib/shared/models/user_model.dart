import 'dart:convert';

class UserModel {
  final String name;
  final String? photoURL; // tem ? porque foto pode ser nula

  UserModel({required this.name, this.photoURL});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(name: map['name'], photoURL: map['photoURL']);
  }

  factory UserModel.fromJson(String json) =>
      UserModel.fromMap(jsonDecode(json));

  // Função que vai transformar nossa classe atual em um map
  Map<String, dynamic> toMap() => {
        "name": name,
        "photoURL": photoURL,
      };

  String toJson() => jsonEncode(toMap());
}
