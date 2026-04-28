import 'package:flutter/material.dart';

class DownloadSearch extends StatelessWidget {
 @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(title: Text('Download Page')),
      body: Page(),
    );
  }
}

class Page extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Column(
     children:[ Text("Placeholder"), TextFormField()]
    );
  }
}