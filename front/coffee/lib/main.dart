// main.dartの一部を修正
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'package:hs_2408/list_page.dart';
import 'package:hs_2408/diagnosis_result.dart';

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
        'isIce': isIce,
        'taste': sliderValue1,
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
    setState(() {
      imgurl = map["url"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('コーヒー診断')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ICE/HOTボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.ac_unit, color: Colors.white),
                label: const Text('ICE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isIce ? Colors.blue[900] : Colors.blue,
                  foregroundColor: Colors.white,
                  side:
                      isIce ? BorderSide(color: Colors.black, width: 3) : null,
                ),
                onPressed: () {
                  setState(() {
                    isIce = true;
                  });
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.local_fire_department,
                    color: Colors.white),
                label: const Text('HOT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isIce ? Colors.red : Colors.red[900],
                  foregroundColor: Colors.white,
                  side:
                      isIce ? null : BorderSide(color: Colors.black, width: 3),
                ),
                onPressed: () {
                  setState(() {
                    isIce = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 各スライダー
          Text('テイストバランス'),
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

          Text('ボディ'),
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

          Text('ロースト'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('淺煎り'),
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

          // 診断ボタン
          ElevatedButton(
            onPressed: () async {
              // await sendValues();
              // if (context.mounted) {
              //   showDialog<void>(
              //       context: context,
              //       builder: (_) {
              //         return AlertDialogSample(imgurl: imgurl);
              //       });
              // }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DiagnosisResult(),
                  ));
            },
            child: const Text('診断開始'),
          ),
          // ここでListPageウィジェットを使う
          const SizedBox(height: 20),
          //const ListPage(), // ListPageを追加
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
