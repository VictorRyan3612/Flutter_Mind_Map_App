import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> fetchImageForText(String text) async {
  String accessKey = ''; // Substitua com sua chave da API
  String url = 'https://api.unsplash.com/photos/random?query=$text&client_id=$accessKey';

  var response;
  
  try {
    response = await http.get(Uri.parse(url));
  } catch (e) {
    print(e);
    return '';
  }

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    print(data);
    String imageUrl = data['urls']['regular']; // Obtendo URL da imagem
    print('Imagem relacionada a "$text": $imageUrl');
    return imageUrl;
  } else {
    print('Falha ao carregar imagem: ${response.statusCode}');
    return '';
  }
}

