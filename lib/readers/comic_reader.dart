import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:comic_reader/comic_reader.dart';

class ComicReaderPage extends StatelessWidget {
  final Uint8List fileBytes;
  final String filename;
  ComicReaderPage({super.key, required this.fileBytes, required this.filename});
  final ComicReaderParser parser = ComicReaderParser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comic Reader'),
        actions: [
          IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.close))
        ],
      ),
      body: FutureBuilder(
        future: parser.parse(fileBytes, filename),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return CircularProgressIndicator();
          }
          if(snapshot.data == null){
            return Text('No comicbook data');
          }
          return Center(
           child: ComicViewer(comic: snapshot.data!),
          );
        }
      ),
    );
  }
}

