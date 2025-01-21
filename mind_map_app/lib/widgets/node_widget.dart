import 'dart:async';
import 'dart:io';
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
    final isInitialized = useState<bool>(false);
    Timer? _debounce;

    useEffect(() {
      if (!isInitialized.value) {
        isInitialized.value = true;
      }
      textController.addListener(() {});
      return () => textController.removeListener(() {});
    }, [textController]);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 50.0,
              minHeight: 50,
              maxWidth: 400.0,
              maxHeight: 400,
            ),
            decoration: BoxDecoration(
              color: node.color,
              borderRadius: node.borderRadius,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (node.image != null && node.image!.isNotEmpty)
                  Image.file(
                    File(node.image!),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                Flexible(
                  child: TextField(
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce =
                          Timer(const Duration(milliseconds: 500), () {
                        node.text = value;
                      });
                    },
                    textAlign: TextAlign.center,
                    controller: textController,
                    maxLines: null,
                    enabled: nodesDataService.isEditing.value &&
                        nodesDataService.firstSelectedNode.value == node,
                    focusNode: focusNode,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
