import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

void main() async {
  await dotenv.load(fileName: ".env"); // dotenvを読み込みます
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // super.keyを追加

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: _SliderScreen(),
    );
  }
}

class _SliderScreen extends StatefulWidget {
  const _SliderScreen({super.key}); // super.keyを追加

  @override
  _SliderScreenState createState() => _SliderScreenState();
}

class _SliderScreenState extends State<_SliderScreen> {
  bool isIce = true;
  int sliderValue1 = 50;
  int sliderValue2 = 50;
  int sliderValue3 = 50;
  String imgurl = "https://www.kaldi.co.jp/ec/img/775/4515996013775_M_1m.jpg";

  Future<void> sendValues() async {
    final url = dotenv.env['API_URL']; // 環境変数からURLを取得
    if (url == null) {
      print('API_URL is not set in the environment variables');
      return;
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'acid': sliderValue1,
        'body': sliderValue2,
        'roast': sliderValue3,
      }),
    );

    if (response.statusCode == 200) {
      print('Values sent successfully');
    } else {
      print('Failed to send values');
    }
    Map<String, dynamic> map = jsonDecode(response.body);
    imgurl = map["url"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slider with Send Button2')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: const Icon(
              Icons.tag_faces,
              color: Colors.white,
            ),
            label: const Text('Button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // primaryをbackgroundColorに変更
              foregroundColor:
                  Colors.white, // これも変更が必要であれば、例えばforegroundColorに変更
            ),
            onPressed: () {},
          ),
          const SizedBox(height: 20),

          // テイストバランススライダー
          Text('テイストバランス: ${sliderValue1.toString()}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('酸味'),
              Expanded(
                child: Slider(
                  value: sliderValue1.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      sliderValue1 = value.toInt();
                    });
                  },
                ),
              ),
              const Text('苦味'),
            ],
          ),
          const SizedBox(height: 20),

          // ボディスライダー
          Text('ボディ: ${sliderValue2.toString()}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ライト'),
              Expanded(
                child: Slider(
                  value: sliderValue2.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      sliderValue2 = value.toInt();
                    });
                  },
                ),
              ),
              const Text('フル'),
            ],
          ),
          const SizedBox(height: 20),

          // ローストスライダー
          Text('ロースト: ${sliderValue3.toString()}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('浅煎り'),
              Expanded(
                child: Slider(
                  value: sliderValue3.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      sliderValue3 = value.toInt();
                    });
                  },
                ),
              ),
              const Text('深煎り'),
            ],
          ),
          const SizedBox(height: 20),

          // 送信ボタン
          ElevatedButton(
            onPressed: () async {
              await sendValues();
              if (context.mounted) {
                showDialog<void>(
                    context: context,
                    builder: (_) {
                      return AlertDialogSample(
                        imgurl: imgurl,
                      );
                    });
              }
            },
            child: const Text('診断開始'),
          ),
        ],
      ),
    );
  }
}

class AlertDialogSample extends StatelessWidget {
  final String? imgurl;
  const AlertDialogSample({super.key, this.imgurl});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('データを消してしまってもいいですか？'),
      content: const Text('こうかいしませんね？'),
      actions: <Widget>[
        Image.network(imgurl!),
        GestureDetector(
          child: const Text('いいえ'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        GestureDetector(
          child: const Text('はい'),
          onTap: () {},
        )
      ],
    );
  }
}
