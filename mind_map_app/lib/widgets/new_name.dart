import 'package:flutter/material.dart';

class NewItemAlertDialog extends StatelessWidget {
  final TextEditingController nameController;
  final String title;
  final bool Function(String name) checkIfExists;
  final void Function(String name) onConfirm;
  
  const NewItemAlertDialog({
    super.key,
    required this.nameController,
    this.title = '',  // Título opcional, com valor default ''
    required this.checkIfExists,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title.isNotEmpty ? title : 'Novo Item'), // Usa o título ou 'Novo Item' se não for passado
      content: Form(
        child: TextField(
          controller: nameController,
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancelar'),
        ),
        TextButton(
          child: Text('Confirmar'),
          onPressed: () {
            var name = nameController.text;
            bool exists = checkIfExists(name);
            if (!exists) {
              onConfirm(name);
              Navigator.of(context).pop();
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Já existe um item com esse nome'),
                    actions: [
                      TextButton(
                        child: Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Mudar o nome'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Permite tentar novamente
                          showDialog(
                            context: context,
                            builder: (context) {
                              return NewItemAlertDialog(
                                nameController: nameController,
                                title: title,
                                checkIfExists: checkIfExists,
                                onConfirm: onConfirm,
                              );
                            },
                          );
                          Navigator.of(context).pop();
                        },
                        
                      ),
                    ],
                  );
                },
              );
              
            }
          },
          
        ),
      ],
      
    );
  }
}
