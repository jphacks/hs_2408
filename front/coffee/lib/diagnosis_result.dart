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
      body: Center(
        child: coffeeResults.length >= 3
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('1位'),
                  // 一番上の画像
                  Image.network(
                    coffeeResults[0]["url"]!,
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 16), // 上下の間隔
                  // 二番目と三番目の画像を横に並べる
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2位
                      Column(
                        children: [
                          const Text('2位', textAlign: TextAlign.center),
                          const SizedBox(height: 8), // テキストと画像の間の間隔
                          Image.network(
                            coffeeResults[1]["url"]!,
                            width: 150,
                            height: 150,
                          ),
                        ],
                      ),
                      const SizedBox(width: 32), // 左右の間隔
                      // 3位
                      Column(
                        children: [
                          const Text('3位', textAlign: TextAlign.center),
                          const SizedBox(height: 8), // テキストと画像の間の間隔
                          Image.network(
                            coffeeResults[2]["url"]!,
                            width: 150,
                            height: 150,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            : const Text('画像が3枚必要です'),
      ),
    );
  }
}
