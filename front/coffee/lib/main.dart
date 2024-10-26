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
  double sliderValue1 = 0.0;
  double sliderValue2 = 0.0;
  double sliderValue3 = 0.0;
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
        'value1': sliderValue1,
        'value2': sliderValue2,
        'value3': sliderValue3,
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
      appBar: AppBar(title: const Text('Slider with Send Button')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Slider 1: ${sliderValue1.toStringAsFixed(2)}'),
          Slider(
            value: sliderValue1,
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() {
                sliderValue1 = value;
              });
            },
          ),
          Text('Slider 2: ${sliderValue2.toStringAsFixed(2)}'),
          Slider(
            value: sliderValue2,
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() {
                sliderValue2 = value;
              });
            },
          ),
          Text('Slider 3: ${sliderValue3.toStringAsFixed(2)}'),
          Slider(
            value: sliderValue3,
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() {
                sliderValue3 = value;
              });
            },
          ),
          const SizedBox(height: 20),
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
            child: const Text('送信'),
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