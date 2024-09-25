import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';

class NodeWidget extends HookWidget {
  final Node node;
  const NodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    Color getContrastingTextColor(Color backgroundColor) {
      if (backgroundColor == Colors.transparent) {
        // Se for transparente, usa a cor baseada no tema
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
      }
      // Usa a fórmula de luminosidade relativa para determinar se o fundo é claro ou escuro
      final double luminance = backgroundColor.computeLuminance();
      return luminance > 0.5 ? Colors.black : Colors.white;
    }


    final textColor = getContrastingTextColor(node.color);
    final textController = useTextEditingController(text: node.text);
    final focusNode = useFocusNode();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: node.width,
        height: node.height,
        // width: sizeNotifier.value.width,
        // height: sizeNotifier.value.height,
        decoration: BoxDecoration(
          color: node.color,
          borderRadius: node.borderRadius,
          
        ),
        child: ValueListenableBuilder(
          valueListenable: nodesDataService.isEditing,
          builder: (context, isEditingValue, child) {
            return TextField(
              controller: textController,
              maxLines: null,
              enabled: isEditingValue && nodesDataService.firstSelectedNode.value == node, // Verifica se é o nó em edição,
              focusNode: focusNode,
              style: TextStyle(color: textColor), // Define a cor do texto dinamicamente
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            );
          }
        ),
      )
    );
  }
}
