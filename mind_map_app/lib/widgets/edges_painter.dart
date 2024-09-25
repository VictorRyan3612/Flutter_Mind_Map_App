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
      if (edge.curvad) {
        final controlPoint1 = getControlPoint(startBorder, endBorder, -20); // Primeiro ponto de controle (acima)
        final controlPoint2 = getControlPoint(startBorder, endBorder, 20);  // Segundo ponto de controle (abaixo)

        final path = Path()
          ..moveTo(startBorder.dx, startBorder.dy)
          ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, endBorder.dx, endBorder.dy);

        canvas.drawPath(path, paint);
        
        // Calcular o ângulo da seta no final
        angle = atan2(endBorder.dy - startBorder.dy, endBorder.dx - startBorder.dx);
      }
      else {
        // Desenha linha reta entre os pontos de borda dos nós
        canvas.drawLine(startBorder, endBorder, paint);

        // Calcular o ângulo da seta na linha reta
        angle = atan2(endBorder.dy - startBorder.dy, endBorder.dx - startBorder.dx);
      }
    }
  }

  Offset getControlPoint(Offset start, Offset end, double offset) {
    return Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2 + offset, // Ajusta a altura do ponto de controle para criar a ondulação
    );
  }

  Offset getBorderPosition(Node from, Node to) {
    final center = Offset(from.position.dx + from.width /1.5, from.position.dy + from.height -1.5);
    final direction = (to.position - from.position).direction;

    final dx = (from.width / 2) * cos(direction);
    final dy = (from.height / 2) * sin(direction);

    return Offset(center.dx + dx, center.dy + dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;

  }
}
