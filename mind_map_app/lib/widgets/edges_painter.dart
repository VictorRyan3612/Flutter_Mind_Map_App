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

      // Calcular a distância entre os nós
      double distance = (startBorder - endBorder).distance;

      // Defina um fator que determina o quanto a curvatura deve aumentar com a distância
      double curvatureFactor = 0.15; // Ajuste esse valor conforme necessário

      if (edge.curvad) {
        // Aumentar o deslocamento da curva com base na distância
        final controlPoint1 = getControlPoint(startBorder, endBorder, distance * curvatureFactor); // Primeiro ponto de controle (acima)
        final controlPoint2 = getControlPoint(startBorder, endBorder, -distance * curvatureFactor); // Segundo ponto de controle (abaixo)

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
      if (edge.arrow) {
        drawArrowShape(canvas, endBorder, angle, paint);
      } else {
        
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
  void drawArrowShape(Canvas canvas, Offset position, double angle, Paint paint) {
    final arrowLength = 6.0; // Comprimento da seta
    final arrowWidth = 4.0;  // Largura da seta
    final arrowAngle = pi / 6; // Ângulo de abertura da seta

    // Calcular os pontos do triângulo
    final arrowP1 = Offset(
      position.dx - arrowLength * cos(angle - arrowAngle),
      position.dy - arrowLength * sin(angle - arrowAngle),
    );
    final arrowP2 = Offset(
      position.dx - arrowLength * cos(angle + arrowAngle),
      position.dy - arrowLength * sin(angle + arrowAngle),
    );

    // Desenhar o triângulo
    final path = Path()
      ..moveTo(position.dx, position.dy) // Ponto de origem da seta
      ..lineTo(arrowP1.dx, arrowP1.dy) // Ponto da primeira base
      ..lineTo(arrowP2.dx, arrowP2.dy) // Ponto da segunda base
      ..close(); // Fecha o triângulo

    // Preencher o triângulo
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;

  }
}
