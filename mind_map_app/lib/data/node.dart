import 'package:flutter/material.dart';

class Node {
  int id;
  String text;
  Color color;
  Offset position;
  double width;
  double height;
  BorderRadiusGeometry borderRadius;

  Node({
    this.id = 0,
    this.text = '',
    this.color = Colors.red,
    this.position = Offset.zero,
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
  })  : width = width ?? _calculateSize(text, true),
        height = height ?? _calculateSize(text, false),
        borderRadius = borderRadius ?? BorderRadius.circular(20),
        assert((width ?? 50) > 0, 'Width must be greater than zero'),
        assert((height ?? 20) > 0, 'Height must be greater than zero'),
        assert(id >= 0, 'Id must be greater than zero') 
    {
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
      'color': color,
      'position': {'dx': position.dx, 'dy': position.dy},
      'width': width,
      'height': height,
      'borderRadius': (borderRadius as BorderRadius).toString(),
    };
  }

  // Converte a instância para uma String legível
  @override
  String toString() {
    return 'Node(id: $id, text: $text, color: $color, position: $position, width: $width, height: $height, borderRadius: $borderRadius)';
  }

}

