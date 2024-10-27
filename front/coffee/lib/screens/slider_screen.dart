import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'diagnosis_result.dart';

class SliderScreen extends StatefulWidget {
  const SliderScreen({super.key});

  @override
  SliderScreenState createState() => SliderScreenState();
}

class SliderScreenState extends State<SliderScreen> {
  bool isPro = false;
  bool isIce = true;
  int sliderValue1 = 50;
  int sliderValue2 = 50;
  int sliderValue3 = 50;

  // 選択されたカテゴリー
  var selectedCategory = <String>[];

  // カテゴリーのリスト
  final category = [
    'ブレンド',
    'ダークロースト',
  ];

  Future<void> sendValues(BuildContext context) async {
    final url = dotenv.env['API_URL'];
    if (url == null) {
      print('API_URL is not set in the environment variables');
      return;
    }

    // selectedCategoryにタグがあるかでフラグを設定
    bool selectedBrend = selectedCategory.contains('ブレンド');
    bool selectedDarkRoast = selectedCategory.contains('ダークロースト');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'isPro': isPro,
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
      appBar: AppBar(
        title: const Text('コーヒー診断'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 背景画像
          SizedBox.expand(
            child: Image.asset(
              isIce ? 'images/background_ice.png' : 'images/background_hot.png',
              fit: BoxFit.cover,
            ),
          ),
          // 背景の上に表示される内容
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                        side: isIce
                            ? const BorderSide(color: Colors.white, width: 3)
                            : null,
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
                        side: isIce
                            ? null
                            : const BorderSide(color: Colors.white, width: 3),
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

                // スライダーを中央揃えにするコンテナ
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      // テイストバランススライダー
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'テイストバランス',
                              style: TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.help_outline,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('テイストバランスについて'),
                                      content: const Text(
                                          '酸味、苦味、甘さがどれか一つ強すぎたりせず、全部がうまく混ざっているかどうかを見ます。\n\n"「弱い」：とがった味。マニア向け。\n\n"「強い」：まろやかな味。親しみやすい。'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('閉じる'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            width: 50, // 酸味テキストの幅を固定
                            child: Text(
                              '酸味',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
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
                          const SizedBox(
                            width: 50, // 苦味テキストの幅を固定
                            child: Text(
                              '苦味',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // ボディスライダー
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'ボディ（重厚感・質感）',
                              style: TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.help_outline,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('ボディについて'),
                                      content: const Text(
                                          'コーヒーの濃さを表しています。\n\n"「薄い」：水のように飲みやすい。\n\n"「濃い」：コーヒーの強い香りが楽しめます。'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('閉じる'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            width: 50, // ライトテキストの幅を固定
                            child: Text(
                              'ライト',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
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
                          const SizedBox(
                            width: 50, // フルテキストの幅を固定
                            child: Text(
                              'フル',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ローストスライダー
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'ロースト',
                              style: TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.help_outline,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('ローストについて'),
                                      content: const Text(
                                          'コーヒーの味を表しています。\n\n"「フルーティ」：フルーティで爽やか。\n\n"「苦味」：苦味が強く、コーヒー独特の味わい。'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('閉じる'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            width: 50, // 淺煎りテキストの幅を固定
                            child: Text(
                              '浅煎り',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
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
                          const SizedBox(
                            width: 50, // 深煎りテキストの幅を固定
                            child: Text(
                              '深煎り',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // こだわりチェックボックス
                // アイコンボタンの部分を修正
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedRotation(
                      turns: isPro ? 0.5 : 0.0, // 180度回転するためには0.5を指定します
                      duration:
                          const Duration(milliseconds: 300), // 回転のアニメーションの時間を設定
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_drop_down_circle, // 常に同じアイコンを使います
                          color: isPro
                              ? const Color.fromARGB(255, 201, 140, 61)
                              : Color.fromARGB(255, 201, 140, 61),
                        ),
                        onPressed: () {
                          setState(() {
                            isPro = !isPro; // ボタンが押されたときに状態を反転
                          });
                        },
                      ),
                    ),
                    const Text(
                      '詳細',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // カテゴリー選択（こだわる場合のみ表示）
                Visibility(
                  visible: isPro,
                  child: Wrap(
                    runSpacing: 16,
                    spacing: 16,
                    children: category.map((tag) {
                      final isSelected = selectedCategory.contains(tag);
                      return InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(32)),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(32)),
                            color: isSelected
                                ? Color.fromARGB(255, 201, 140, 61)
                                : Colors.white, // 選択されている場合は茶色背景白文字に変更
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors
                                      .black, // 選択されている場合は白文字、選択されていない場合は黒文字
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
        ],
      ),
    );
  }
}
