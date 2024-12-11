import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mind_map_app/data/node.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';

class EdgesPainter extends CustomPainter {
  final List<Edge> edges;
  final Offset Function(Offset) graphToLocalCoordinates; // Função de conversão de coordenadas

  EdgesPainter(this.edges, this.graphToLocalCoordinates);

  @override
  void paint(Canvas canvas, Size size) {
    for (Edge edge in edges){
      final Node sourceNode = nodesDataService.getFirstByType(Node, edge.idSource);
      final Node destinationNode = nodesDataService.getFirstByType(Node, edge.idDestination);

      // Convertendo as posições dos nós do gráfico para as coordenadas da tela
      final sourcePosition = graphToLocalCoordinates(sourceNode.position);
      final destinationPosition = graphToLocalCoordinates(destinationNode.position);

      // Pega as bordas dos nós para desenhar a linha, ajustando para as coordenadas da tela
      final startBorder = getBorderPosition(sourcePosition, destinationPosition, sourceNode.width, sourceNode.height);
      final endBorder = getBorderPosition(destinationPosition, sourcePosition, destinationNode.width, destinationNode.height);

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

  Offset getBorderPosition(Offset from, Offset to, double width, double height) {
    final center = Offset(from.dx + width / 1.65, from.dy + height / 1.5);
    final direction = (to - from).direction;

    final dx = (width / 2) * cos(direction);
    final dy = (height / 2) * sin(direction);

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
