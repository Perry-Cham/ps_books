import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'dart:io';

class FB2Paragraph {
  final String id;
  final Widget content;

  FB2Paragraph({required this.id, required this.content});
}

class FB2Reader extends StatelessWidget {
  const FB2Reader({super.key, required this.filePath});
  final String filePath;

  Future<List<FB2Paragraph>> _parseFB2() async {
    final file = File(filePath);
    final xmlString = await file.readAsString();
    final document = XmlDocument.parse(xmlString);
    final paragraphs = <FB2Paragraph>[];
    int paragraphCount = 0;

    // Find all <section> elements in the FB2 file
    final sections = document.findAllElements('section');

    for (var section in sections) {
      // For each section, find <p> tags
      // Note: we use findElements to only get direct children <p> of the section
      // or we can use findAllElements if we want all paragraphs nested within.
      // Usually FB2 structure has <p> directly under <section> or under <title> within <section>.
      final pTags = section.findAllElements('p');

      for (var p in pTags) {
        final textContent = p.innerText.trim();
        if (textContent.isEmpty) continue;

        final uniqueId = 'para_${paragraphCount++}_${DateTime.now().millisecondsSinceEpoch}';
        
        paragraphs.add(
          FB2Paragraph(
            id: uniqueId,
            content: KeyedSubtree(
              key: ValueKey(uniqueId),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  textContent,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return paragraphs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FB2 Reader'),
      ),
      body: FutureBuilder<List<FB2Paragraph>>(
        future: _parseFB2(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error parsing FB2: ${snapshot.error}'),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No paragraphs found in this FB2 file.'));
          }

          final paragraphs = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: paragraphs.map((p) => p.content).toList(),
            ),
          );
        },
      ),
    );
  }
}
