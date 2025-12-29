import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ===============================================================
// Termモデル
// ===============================================================
class Term {
  final int id;
  final String termEn;
  final String termJp;

  Term({required this.id, required this.termEn, required this.termJp});

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json['id'],
      termEn: json['term_en'],
      termJp: json['term_jp'],
    );
  }
}

// ===============================================================
// Flashcard Screen（速度設定つき完全版）
// ===============================================================
class FlashcardScreen extends StatefulWidget {
  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  List<Term> terms = [];
  int currentIndex = 0;

  bool showFront = true;
  bool isAutoPlay = false;

  Timer? autoTimer;

  // ★ 自動再生の速度（double秒）
  double autoPlaySeconds = 1.0;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    loadJson();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );
  }

  // ===============================================================
  // JSON読み込み
  // ===============================================================
  Future<void> loadJson() async {
    String jsonString = await rootBundle.loadString('assets/trade_terms.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);

    setState(() {
      terms = jsonList.map((j) => Term.fromJson(j)).toList();
      terms.shuffle();
    });
  }

  @override
  void dispose() {
    autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ===============================================================
  // 自動再生（表→裏→次カード）
  // ===============================================================
  void startAutoPlay() {
    isAutoPlay = true;

    autoTimer?.cancel();
    autoTimer = Timer.periodic(
      Duration(milliseconds: (autoPlaySeconds * 1000).toInt()),
      (timer) {
        if (!mounted || terms.isEmpty) return;

        if (showFront) {
          flipCard();
        } else {
          nextCard();
        }
      },
    );

    setState(() {});
  }

  void stopAutoPlay() {
    autoTimer?.cancel();
    isAutoPlay = false;
    setState(() {});
  }

  // ===============================================================
  // カード反転
  // ===============================================================
  void flipCard() async {
    if (_controller.isAnimating) return;

    if (showFront) {
      await _controller.forward(from: 0);
      setState(() => showFront = false);
      _controller.value = 0;
    } else {
      await _controller.forward(from: 0);
      setState(() => showFront = true);
      _controller.value = 0;
    }
  }

  // ===============================================================
  // 次・前カード
  // ===============================================================
  void nextCard() {
    if (currentIndex < terms.length - 1) {
      setState(() {
        currentIndex++;
        showFront = true;
      });
    } else {
      stopAutoPlay();
    }
  }

  void prevCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        showFront = true;
      });
    }
  }

  // ===============================================================
  // ★ 設定ボトムシート（速度変更）
  // ===============================================================
  void openSettingSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "自動再生スピード",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),

              buildSpeedOption("1 秒", 1),
              buildSpeedOption("1.5 秒", 1.5),
              buildSpeedOption("2 秒", 2),
              buildSpeedOption("2.5 秒", 2.5),
              buildSpeedOption("3 秒", 3),
            ],
          ),
        );
      },
    );
  }

  Widget buildSpeedOption(String label, double seconds) {
    return ListTile(
      title: Text(label),
      trailing: autoPlaySeconds == seconds
          ? Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        Navigator.pop(context);
        setState(() => autoPlaySeconds = seconds);

        if (isAutoPlay) {
          startAutoPlay(); // 速度即時反映
        }
      },
    );
  }

  // ===============================================================
  // UI
  // ===============================================================
  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Flashcards")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final term = terms[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Flashcards"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isAutoPlay ? Icons.pause_circle_filled : Icons.play_circle_fill,
              size: 32,
            ),
            onPressed: () {
              if (isAutoPlay)
                stopAutoPlay();
              else
                startAutoPlay();
            },
          ),

          // ★ 設定アイコン
          IconButton(icon: Icon(Icons.settings), onPressed: openSettingSheet),
        ],
      ),

      body: GestureDetector(
        onTap: flipCard,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) nextCard();
          if (details.primaryVelocity! > 0) prevCard();
        },

        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * 3.14;
              final hideText = angle != 0 && angle != 3.14;
              final textToShow = showFront ? term.termEn : term.termJp;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),

                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 380,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 80),
                      opacity: hideText ? 0.0 : 1.0,
                      child: Text(
                        textToShow,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
