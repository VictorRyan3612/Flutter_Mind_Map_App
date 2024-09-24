import 'package:flutter/material.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';

class EdgesPainter extends CustomPainter {
  final List<Edge> edges;

  EdgesPainter(this.edges);

  
  @override
  void paint(Canvas canvas, Size size) {
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;

  }
}
