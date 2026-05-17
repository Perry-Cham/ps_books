import 'package:flutter/material.dart';

class Google_Card extends StatelessWidget{
  final String name;
  final String email;
  const Google_Card({super.key, required this.name, required this.email});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:Colors.amber
      ),
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name),
        Text(email)
      ],
      ),
    );
  }
}