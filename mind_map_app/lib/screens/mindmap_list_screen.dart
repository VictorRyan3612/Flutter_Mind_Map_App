import 'package:flutter/material.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';
import 'package:mind_map_app/widgets/app_bar.dart';

class MindMapListScreen extends StatelessWidget {
  const MindMapListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Lista de mapas', modeMindMap: false,),
      body: ValueListenableBuilder<List<MindMap>>(
      valueListenable: nodesDataService.listMindMap,
      builder: (context, listMindMap, _) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8, // Espaçamento horizontal
            runSpacing: 8, // Espaçamento vertical
            children: listMindMap.map((mindMap) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Cor neutra
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
                child: IntrinsicWidth( // Ajusta a largura conforme o conteúdo
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mindMap.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 14, 
                          color: Colors.grey[600]
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Criado: ${_formatDate(mindMap.createdAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        'Modificado: ${_formatDate(mindMap.modifiedAt)}',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Peso: ${mindMap.weight} bytes',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    ));
  }

  String _formatDate(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} "
          "${twoDigits(date.hour)}:${twoDigits(date.minute)}";
  }
}
