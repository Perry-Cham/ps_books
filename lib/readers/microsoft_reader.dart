import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:microsoft_viewer/microsoft_viewer.dart';

class MicrosoftReader extends StatelessWidget{
  const MicrosoftReader({super.key, required this.fileBytes});
 final Uint8List fileBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed:(){
            if(context.mounted){Navigator.of(context).pop();}
          }
        ),
        title: Text('Reader'),
      ),
      body:Center(
        child: SizedBox(height:1000, child: MicrosoftViewer(fileBytes, false, scale:3.0))
      )
    );

  }
}