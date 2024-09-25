import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';

class EdgesPainter extends CustomPainter {
  final List<Edge> edges;

  EdgesPainter(this.edges);

  
  @override
  void paint(Canvas canvas, Size size) {
    for (Edge edge in edges){
      final Node sourceNode = nodesDataService.getFirstByType(Node, edge.idSource);
      final Node destinationNode = nodesDataService.getFirstByType(Node, edge.idDestination);


      // Pega as bordas dos nós para desenhar a linha
      final startBorder = getBorderPosition(sourceNode, destinationNode);
      final endBorder = getBorderPosition(destinationNode, sourceNode);

      final paint = Paint()
        ..color = edge.color
        ..strokeWidth = edge.size
        ..style = PaintingStyle.stroke;
        
      double angle;
    }
  }
  
  Offset getBorderPosition(Node from, Node to) {
    final center = Offset(from.position.dx + from.width / 2, from.position.dy + from.height / 2);
    final direction = (to.position - from.position).direction;

    final dx = (from.width / 2 + 10) * cos(direction);
    final dy = (from.height / 2 + 15) * sin(direction);

    return Offset(center.dx + dx, center.dy + dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;

  }
}
