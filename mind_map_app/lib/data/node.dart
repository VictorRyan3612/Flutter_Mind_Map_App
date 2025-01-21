import 'package:flutter/material.dart';

class Node {
  int id;
  String text;
  String? image;
  Color color;
  Offset position;
  double width;
  double height;
  double borderRadiusValue; // Armazenando o valor do raio diretamente

  Node({
    this.id = 0,
    this.text = '',
    this.image,
    this.color = Colors.red,
    this.position = Offset.zero,
    double? width,
    double? height,
    double borderRadiusValue = 20, // Valor default para o raio
  })  : width = width ?? _calculateSize(text, true),
        height = height ?? _calculateSize(text, false),
        borderRadiusValue = borderRadiusValue,
        assert((width ?? 50) > 0, 'Width must be greater than zero'),
        assert((height ?? 20) > 0, 'Height must be greater than zero'),
        assert(id >= 0, 'Id must be greater than zero') {
    if (isBlackOrWhite(color)) {
      print("Warning: Using black or white color for Nodes is not recommended because background themes.");
    }
  }

  static bool isBlackOrWhite(Color color) {
    return color == Colors.black || color == Colors.white;
  }
  static double _calculateSize(String text, bool isWidth) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 16), // Tamanho da fonte desejado
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    if (isWidth) {
      return textPainter.width + 32; // Adiciona mais padding
      
    } else {
      return textPainter.height + 32; // Adiciona mais padding
      
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'image': image,
      'color': color.value,  // Serialize Color to int (color value)
      'position': {'dx': position.dx, 'dy': position.dy}, // Serialize position
      'width': width,
      'height': height,
      'borderRadius': borderRadiusValue, // Apenas o valor do raio
    };
  }

  // Converte de volta para um BorderRadius circular com o valor armazenado
  BorderRadiusGeometry get borderRadius => BorderRadius.circular(borderRadiusValue);

  static Node fromJson(Map<String, dynamic> json) {
    return Node(
      id: json['id'],
      image: json['image'],
      color: Color(json['color']),  // Deserialize Color from int
      height: json['height'],
      width: json['width'],
      text: json['text'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      borderRadiusValue: json['borderRadius'], // Apenas o valor do raio
    );
  }

  @override
  String toString() {
    return 'Node(id: $id, text: $text, color: $color, position: $position, width: $width, height: $height, borderRadius: $borderRadius)';
  }

}

