import 'package:flutter/material.dart';

class DiagnosisResult extends StatelessWidget {
  final List<Map<String, String>> coffeeResults;

  const DiagnosisResult({super.key, required this.coffeeResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('診断結果'),
      ),
      body: ListView.builder(
        itemCount: coffeeResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(coffeeResults[index]["title"]!),
            leading: Image.network(coffeeResults[index]["url"]!),
          );
        },
      ),
    );
  }
}
