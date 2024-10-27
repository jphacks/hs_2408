import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/slider_screen.dart'; // スライダースクリーンをインポート

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TopPage(), // トップページを表示
    );
  }
}

class TopPage extends StatelessWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景画像を設定
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/top_background.png'),
                fit: BoxFit.cover, // 画面に合わせて背景画像をリサイズ
              ),
            ),
          ),
          // コンテンツ（画像ボタン）
          Positioned(
            top: 190, // 必要に応じて調整、値を小さくすると上に移動します
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // 画像ボタンが押された時の処理（スライダースクリーンに遷移）
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SliderScreen()),
                );
              },
              child: Image.asset(
                'images/top_button.png', // ボタン画像を指定
                width: 250, // 必要に応じてボタンサイズを調整
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
