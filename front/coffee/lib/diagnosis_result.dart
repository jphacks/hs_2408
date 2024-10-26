import 'package:flutter/material.dart';

class DiagnosisResult extends StatelessWidget {
  const DiagnosisResult({super.key}); 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('次の画面'),
      ),
      body: Center(
        child: const Text('これは次のページです'),
      ),
    );
  }
}
