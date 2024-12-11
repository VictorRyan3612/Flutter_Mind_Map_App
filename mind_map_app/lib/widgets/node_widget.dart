import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mind_map_app/data/node.dart';
import 'package:mind_map_app/data/nodes_data_service.dart';

class NodeWidget extends HookWidget {
  final Node node;
  const NodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    Color getContrastingTextColor(Color backgroundColor) {
      if (backgroundColor == Colors.transparent) {
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
      }
      final double luminance = backgroundColor.computeLuminance();
      return luminance > 0.5 ? Colors.black : Colors.white;
    }

    final textColor = getContrastingTextColor(node.color);
    final textController = useTextEditingController(text: node.text);
    final focusNode = useFocusNode();
    final sizeNotifier = useState<Size>(Size(node.width, node.height));
    final isInitialized = useState<bool>(false);
    Timer? _debounce;

    void updateSize() {
      final textLength = textController.text.length;
final baseHeight = 50.0;
      // Calculando a largura e a altura do texto
      final textPainter = TextPainter(
        text: TextSpan(
          text: textController.text,
          style: TextStyle(fontSize: 16.0), // Ajuste o tamanho da fonte conforme necessário
        ),
        maxLines: null, // Para permitir múltiplas linhas
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(minWidth: 0, maxWidth: double.infinity);

      double newWidth = min(max(75.0, textPainter.width + 50), 400.0); // Adiciona algum padding
      double newHeight;
      // if(textController.text.endsWith('\n')){
      //   newHeight = min(max(baseHeight + (textLength > 30 ? ((textLength - 30) ~/ 10) * 10 : 0), textPainter.height + 20), 300.0); 
      // }
      // else{
        newHeight = baseHeight + (textLength > 30 ? ((textLength - 30) ~/ 10) * 10 : 0); 
      // }

      // Atualiza o tamanho se necessário
      if (newWidth != sizeNotifier.value.width || newHeight != sizeNotifier.value.height) {
        sizeNotifier.value = Size(newWidth, newHeight);
        node.width = newWidth;
        node.height = newHeight;
      }
    }

    useEffect(() {
      if (!isInitialized.value) {
        updateSize();
        isInitialized.value = true;
      }
      textController.addListener(updateSize);
      return () => textController.removeListener(updateSize);
    }, [textController]);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: sizeNotifier.value.width,
        height: sizeNotifier.value.height,
        decoration: BoxDecoration(
          color: node.color,
          borderRadius: node.borderRadius,
        ),
        child: ValueListenableBuilder(
          valueListenable: nodesDataService.isEditing,
          builder: (context, isEditingValue, child) {
            return Center(
              child: TextField(
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    node.text = value;
                  });
                },
                textAlign: TextAlign.center,
                controller: textController,
                maxLines: null,
                enabled: isEditingValue && nodesDataService.firstSelectedNode.value == node, // Verifica se é o nó em edição,
                focusNode: focusNode,
                style: TextStyle(color: textColor), // Define a cor do texto dinamicamente

                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
