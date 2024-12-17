import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';
import 'package:mind_map_app/utils/functions_list_tiles.dart';
import 'package:mind_map_app/widgets/app_bar.dart';
import 'package:mind_map_app/widgets/chart_painter.dart';
import 'package:mind_map_app/widgets/edges_painter.dart';
import 'package:mind_map_app/widgets/node_widget.dart';


class GraphScreen extends HookWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    // Posições usando useState
    final chartOffset = useState(Offset(0, 0));
    final displayedCoordinates = useState(Offset(0, 0));
    var startPosition = useState(Offset(0,0));

     // Função para converter as coordenadas da tela em coordenadas relativas ao gráfico
    Offset localToGraphCoordinates(Offset localPosition) {
      return Offset(
        localPosition.dx - chartOffset.value.dx - (MediaQuery.of(context).size.width / 2),
        localPosition.dy - chartOffset.value.dy - (MediaQuery.of(context).size.height / 2),
      );
    }

    // Função para converter as coordenadas do gráfico para a tela
    Offset graphToLocalCoordinates(Offset graphPosition) {
      return Offset(
        graphPosition.dx + chartOffset.value.dx + (MediaQuery.of(context).size.width / 2),
        graphPosition.dy + chartOffset.value.dy + (MediaQuery.of(context).size.height / 2),
      );
    }
    return Scaffold(
      appBar: MyAppBar(title: 'mapa',modeMindMap: true),
      body: InteractiveViewer(
        child: ValueListenableBuilder<MindMap?>(
          valueListenable: nodesDataService.mindMap,
          builder: (context, mindMapValue, child) {
            final nodes = mindMapValue?.nodes ?? [];
            final edges = mindMapValue?.edges ?? [];

            return Stack(
              children: [
                GestureDetector(
                  onPanUpdate: (details) {
                    chartOffset.value = Offset(
                      chartOffset.value.dx + details.delta.dx,
                      chartOffset.value.dy + details.delta.dy,
                    );
                    nodesDataService.mindMap.notifyListeners();
                  },
                  onPanEnd: (details) {
                    Timer(const Duration(milliseconds: 500), () {
                      for (var element in nodes) {
                        print("${element.id}: ${element.position}");
                      }
                    });
                  },
                  onTapDown: (details) {
                    nodesDataService.isEditing.value = false;
                    nodesDataService.firstSelectedNode.value = null;
                    nodesDataService.secondSelectedNode.value = null;
                    nodesDataService.isSelecting.value = false;
      
                    displayedCoordinates.value = localToGraphCoordinates(details.localPosition);
                    print('Local: ${details.localPosition}');
                    print('Display: ${displayedCoordinates.value}');
                    
                  },
                  onDoubleTapDown: (details) {
                    if (nodesDataService.firstSelectedNode.value == null) {
                      nodesDataService.isSelecting.value = false;
                      nodesDataService.isEditing.value = false;
      
                      showContextMenu(context, positionOffset: details.localPosition, listTiles: functionListTileGraph(context, localToGraphCoordinates(details.localPosition)));
                    }
                  },
                  onSecondaryTapDown: (details) {
                    nodesDataService.isEditing.value = false;
                    nodesDataService.firstSelectedNode.value = null;
                    nodesDataService.isSelecting.value = false;
                    showContextMenu(context, positionOffset: details.localPosition, listTiles: functionListTileGraph(context, localToGraphCoordinates(details.localPosition)));
                  },
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: EdgesPainter(
                          edges.toList(),
                          graphToLocalCoordinates,
                        ),
                      ),
                      CustomPaint(
                        size: Size.infinite,
                        painter: ChartPainter(chartOffset.value),
                      ),
                      for (int i = 0; i < nodes.length; i++)
                        Positioned(
                          left: graphToLocalCoordinates(nodes[i].position).dx,
                          top: graphToLocalCoordinates(nodes[i].position).dy,
                          child: GestureDetector(
                            onDoubleTapDown: (details) {
                              nodesDataService.isEditing.value = true;
                              nodesDataService.firstSelectedNode.value = nodes[i];
                              nodesDataService.secondSelectedNode.value = null;
                              nodesDataService.isSelecting.value = false;
                            },
                            onTapDown: (details) {
                              if (nodesDataService.isSelecting.value == false) {
                                nodesDataService.firstSelectedNode.value = nodes[i];
                                nodesDataService.secondSelectedNode.value = null;
                                
                              } else {
                                nodesDataService.secondSelectedNode.value = nodes[i];
                                Edge edge = Edge(idSource: nodesDataService.firstSelectedNode.value!.id, idDestination: nodesDataService.secondSelectedNode.value!.id, color: nodesDataService.firstSelectedNode.value!.color);
                                
                                nodesDataService.addEdge(edge);
        
                                nodesDataService.mindMap.notifyListeners();
                              }
                              nodesDataService.isSelecting.value = false;
                              nodesDataService.secondSelectedNode.value = null;
                              nodesDataService.firstSelectedNode.value = null;
                            },
                            onSecondaryTapDown: (details) {
                              nodesDataService.firstSelectedNode.value = nodes[i];
                              showContextMenu(
                                context,
                                positionOffset: details.globalPosition,
                                listTiles: functionListTileNode(context, details.localPosition),
                              );
                            },
                            onPanStart: (details) {
                              startPosition.value = nodes[i].position;
                            },
                            onPanUpdate: (details) {
                              nodes[i].position = Offset(
                                startPosition.value.dx + details.localPosition.dx,
                                startPosition.value.dy + details.localPosition.dy,
                              );
                              nodesDataService.mindMap.notifyListeners();
                            },
                          
                            child: NodeWidget(node: nodes[i]),
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
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
