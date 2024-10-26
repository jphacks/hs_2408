import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'diagnosis_result.dart'; // 診断結果画面をインポート

class SliderScreen extends StatefulWidget {
  const SliderScreen({super.key});

  @override
  SliderScreenState createState() => SliderScreenState();
}

class SliderScreenState extends State<SliderScreen> {
  bool isBeginner = false;
  bool isIce = true;
  int sliderValue1 = 50;
  int sliderValue2 = 50;
  int sliderValue3 = 50;

  // 選択されたカテゴリー
  var selectedCategory = <String>[];

  // カテゴリーのリスト
  final category = [
    'brend',
    'darkRoast',
  ];

  Future<void> sendValues(BuildContext context) async {
    final url = dotenv.env['API_URL'];
    if (url == null) {
      print('API_URL is not set in the environment variables');
      return;
    }

    // selectedCategoryにタグがあるかでフラグを設定
    bool selectedBrend = selectedCategory.contains('brend');
    bool selectedDarkRoast = selectedCategory.contains('darkRoast');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'isBeginner': isBeginner,
        'isIce': isIce,
        'taste': sliderValue1,
        'body': sliderValue2,
        'roast': sliderValue3,
        'pro': {
          'brend': selectedBrend,
          'darkRoast': selectedDarkRoast,
        },
      }),
    );

    if (response.statusCode == 200) {
      final resultData = jsonDecode(response.body);
      List<dynamic> x = resultData["imgs"];
      List<Map<String, String>> coffeeResults =
          x.map((item) => Map<String, String>.from(item)).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnosisResult(coffeeResults: coffeeResults),
        ),
      );
    } else {
      print('Failed to send values');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('コーヒー診断')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

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
                    side: isIce ? const BorderSide(color: Colors.black, width: 3) : null,
                  ),
                  onPressed: () {
                    setState(() {
                      isIce = true;
                    });
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.local_fire_department, color: Colors.white),
                  label: const Text('HOT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isIce ? Colors.red : Colors.red[900],
                    foregroundColor: Colors.white,
                    side: isIce ? null : const BorderSide(color: Colors.black, width: 3),
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

            // テイストバランススライダー
            const Text('テイストバランス'),
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
            const Text('ボディ'),
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
            const Text('ロースト'),
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

            // こだわりチェックボックス
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('こだわりますか'),
                Checkbox(
                  value: isBeginner,
                  onChanged: (value) {
                    setState(() {
                      isBeginner = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // カテゴリー選択（こだわる場合のみ表示）
            Visibility(
              visible: isBeginner,
              child: Wrap(
                runSpacing: 16,
                spacing: 16,
                children: category.map((tag) {
                  final isSelected = selectedCategory.contains(tag);
                  return InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedCategory.remove(tag); // 選択されている場合は削除
                        } else {
                          selectedCategory.add(tag); // 選択されていない場合は追加
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(32)),
                        border: Border.all(
                          width: 2,
                          color: Colors.pink,
                        ),
                        color: isSelected ? Colors.pink : null,
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.pink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // 診断開始ボタン
            ElevatedButton(
              onPressed: () async {
                await sendValues(context);
              },
              child: const Text('診断開始'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
