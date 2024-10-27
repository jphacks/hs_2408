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

  Future<void> sendValues() async {
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

      if (!mounted) return; // ウィジェットがまだマウントされているか確認
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
                                      title:
                                          const Text('テイストバランス（Taste Balance）'),
                                      content: const Text(
                                        '  • 酸味 ⇔ 苦味\n'
                                        'コーヒーの味わいのバランスを、酸味と苦味の度合いで表します。\n\n'
                                        '酸味\n'
                                        '  • フルーティーな香りや、柑橘類のような爽やかな味わいが特徴。\n'
                                        '  • エチオピア産などの浅煎り豆でよく感じられます。\n\n'
                                        '苦味\n'
                                        '  • ダークチョコレートのような深い苦味を感じる味わい。\n'
                                        '  • 深煎りコーヒーやエスプレッソでよく味わえます。',
                                      ),
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
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 0, // バーを消す
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12.0, // 丸の大きさを指定
                                ),
                              ),
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
                                        '  • ライト ⇔ フル\n'
                                        'コーヒーを口に含んだときの「重さ」や「濃厚さ」を表します。\n\n'
                                        'ライト（Light Body）\n'
                                        '  • さっぱりとして軽い口当たり。\n'
                                        '  • 紅茶のような薄い質感で、飲みやすいタイプ。\n\n'
                                        'フル（Full Body）\n'
                                        '  • 口の中で感じるコクが強く、しっかりとした重厚感がある。\n'
                                        '  • クリーミーで、後味が長く残ることもあります。',
                                      ),
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
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 0, // バーを消す
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12.0, // 丸の大きさを指定
                                ),
                              ),
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
                                        '  • 朝煎り ⇔ 深煎り\n'
                                        'コーヒー豆の焙煎度を表します。ローストの度合いは、味や香り、酸味・苦味に影響を与えます。\n\n'
                                        '浅煎り（Light Roast）\n'
                                        '  • 明るい酸味とフルーティーな香りが特徴。\n'
                                        '  • ローラルやシトラス系の風味が感じられることが多い。\n\n'
                                        '深煎り（Dark Roast）\n'
                                        '  • 苦味が強く、重厚な風味が特徴。\n'
                                        '  • チョコレートやナッツのような香りが感じられることが多く、ミルクとの相性も良い。',
                                      ),
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
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 0, // バーを消す
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12.0, // 丸の大きさを指定
                                ),
                              ),
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
                    await sendValues();
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
