import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String,dynamic>> fetch() async {
  final response = await http.get(Uri.parse("https://www.googleapis.com/books/v1/volumes?q=intitle:the+stand"));
  Map<String,dynamic> data = jsonDecode(response.body);
  return data['items'][0];
}

class BookData{

}