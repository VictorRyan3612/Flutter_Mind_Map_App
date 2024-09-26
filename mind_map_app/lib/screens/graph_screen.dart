import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';
import 'package:mind_map_app/widgets/edges_painter.dart';
import 'package:mind_map_app/widgets/node_widget.dart';


class GraphScreen extends HookWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer? _debounce;

    List<ListTile> functionListTile(Offset position){
      List<ListTile> listtiles = [
        ListTile(
          title: Text("Criar Node"),
          onTap: () {
            nodesDataService.nodes.value.add(Node(color: Colors.red, position: position));
            nodesDataService.nodes.notifyListeners();
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text("Criar Edge"),
          onTap: () {
            nodesDataService.nodes.value.add(Node(id: 0, color: Colors.red, position: Offset(50, 50)));
            nodesDataService.nodes.value.add(Node(id: 1, color: Colors.blue, position: Offset(50, 500)));
            nodesDataService.nodes.value.add(Node(id: 2, color: Colors.yellow, position: Offset(100, 300)));
            nodesDataService.nodes.value.add(Node(id: 3, color: Colors.purple, position: Offset(400, 300)));
            nodesDataService.edges.value.add(Edge(idSource: 0, idDestination: 1, color: Colors.green));
            nodesDataService.edges.value.add(Edge(idSource: 2, idDestination: 3, color: nodesDataService.getFirstByType(Node, 2).color));
            nodesDataService.nodes.notifyListeners();
            nodesDataService.edges.notifyListeners();
            Navigator.pop(context);
          },
        )
      ];
      return listtiles;
    }
    // Posições usando useState
    final chartOffset = useState(Offset(0, 0));
    final displayedCoordinates = useState(Offset(0, 0));

    return InteractiveViewer(
      child: ValueListenableBuilder(
        valueListenable: nodesDataService.nodes,
        builder: (context, nodesValue, child) {
          return Stack(
            children: [
              GestureDetector(
                onPanUpdate: (details) {
                  chartOffset.value = Offset(
                    chartOffset.value.dx + details.delta.dx,
                    chartOffset.value.dy + details.delta.dy,
                  );

                    // Atualiza a posição de cada nó com base no deslocamento
                  for (var node in nodesValue) {
                    node.position = Offset(
                      node.position.dx + details.delta.dx,
                      node.position.dy + details.delta.dy,
                    );
                  }
                  // Notifica os listeners após atualizar as posições dos nós
                  nodesDataService.nodes.notifyListeners();
                },
                onTapDown: (details) {
                  nodesDataService.firstSelectedNode.value = null;
                  nodesDataService.secondSelectedNode.value = null;
          
                  displayedCoordinates.value = Offset(
                    (details.localPosition.dx - chartOffset.value.dx) -
                        (MediaQuery.of(context).size.width / 2),
                    (details.localPosition.dy - chartOffset.value.dy) -
                        (MediaQuery.of(context).size.height / 2),
                  );
                  
                },
                onDoubleTapDown: (details) {
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    if (nodesDataService.firstSelectedNode.value == null) {
                      showContextMenu(context, positionOffset: details.localPosition, listTiles: functionListTile(details.localPosition));
                    }
                  });
                },
                onSecondaryTapDown: (details) {
                  nodesDataService.firstSelectedNode.value = null;
                  showContextMenu(context, positionOffset: details.localPosition, listTiles: functionListTile(details.localPosition));
                },
                child: Stack(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: nodesDataService.edges,
                      builder: (context, edgesValue, child) {
                        return CustomPaint(
                          size: Size.infinite,
                          painter: EdgesPainter(
                            edgesValue.map((edge) {
                              // Recalcular a cor da aresta conforme o tema
                              if (edge.color == null) {
                                edge.color = Edge.determineEdgeColor(
                                  context, 
                                  nodesDataService.getFirstByType(Node, edge.idSource).color
                                );
                              }
                              return edge;
                            }).toList(),
                          ),
                        );
                      }
                    ),
                    CustomPaint(
                      size: Size(double.infinity, double.infinity),
                      painter: ChartPainter(chartOffset.value),
                    ),
                    for (int i = 0; i < nodesValue.length; i++)
                    Positioned(
                      left: nodesValue[i].position.dx,
                      top: nodesValue[i].position.dy,
                      child: GestureDetector(
                        onDoubleTapDown: (details) {
                          nodesDataService.isEditing.value = true;
                          nodesDataService.firstSelectedNode.value = nodesValue[i];
                        },
                        onTapDown: (details) {
                          nodesDataService.firstSelectedNode.value = nodesValue[i];
                          
                        },
                        onSecondaryTapDown: (details) {
                          nodesDataService.firstSelectedNode.value = nodesValue[i];
                        },
                        onPanUpdate: (details) {
                          nodesValue[i].position = Offset(
                            nodesValue[i].position.dx + details.delta.dx,
                            nodesValue[i].position.dy + details.delta.dy,
                          );
                          nodesDataService.nodes.notifyListeners();
                          
                        },
                        child: NodeWidget(
                          node: nodesValue[i],
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),
              
              Positioned(
                top: 16,
                left: 16,
                child: Text(
                  'Coordenadas: (${displayedCoordinates.value.dx.toStringAsFixed(1)}, ${displayedCoordinates.value.dy.toStringAsFixed(1)})',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}

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
