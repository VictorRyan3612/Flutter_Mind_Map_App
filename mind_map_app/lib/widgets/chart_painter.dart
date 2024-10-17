import 'package:flutter/material.dart';


class ChartPainter extends CustomPainter {
  final Offset chartOffset; // deslocamento do gráfico

  ChartPainter(this.chartOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4;

    // Desenhar o ponto na origem (0, 0) considerando o deslocamento do gráfico
    Offset adjustedPointPosition = Offset(size.width / 2 + chartOffset.dx, size.height / 2 + chartOffset.dy);

    // Desenhar o ponto no gráfico
    canvas.drawCircle(adjustedPointPosition, 10, paint);

    // Desenhar eixos do gráfico
    final axisPaint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 2;

    // Eixo X
    canvas.drawLine(
      Offset(0, size.height / 2) + chartOffset,
      Offset(size.width, size.height / 2) + chartOffset,
      axisPaint,
    );

    // Eixo Y
    canvas.drawLine(
      Offset(size.width / 2, 0) + chartOffset,
      Offset(size.width / 2, size.height) + chartOffset,
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
