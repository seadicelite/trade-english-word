import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int answerIndex;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json["id"],
      question: json["question"],
      options: List<String>.from(json["options"]),
      answerIndex: json["answer_index"],
    );
  }

  /// ★ 選択肢シャッフル（正解位置を再計算）
  QuizQuestion shuffled() {
    final correct = options[answerIndex];
    final newOptions = List<String>.from(options)..shuffle();
    final newCorrectIndex = newOptions.indexOf(correct);

    return QuizQuestion(
      id: id,
      question: question,
      options: newOptions,
      answerIndex: newCorrectIndex,
    );
  }
}

class QuizJpScreen extends StatefulWidget {
  @override
  State<QuizJpScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizJpScreen>
    with SingleTickerProviderStateMixin {
  List<QuizQuestion> questions = [];
  int current = 0;
  int? selected;
  bool answered = false;

  // ★ 正解演出用
  bool showCorrectCircle = false;
  late AnimationController _circleController;
  late Animation<double> _circleScale;

  @override
  void initState() {
    super.initState();
    loadQuiz();

    // ★ バウンドアニメーション設定
    _circleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _circleScale = CurvedAnimation(
      parent: _circleController,
      curve: Curves.elasticOut, // ← バウンド
    );
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  Future<void> loadQuiz() async {
    final jsonString = await rootBundle.loadString("assets/quiz_jp_to_en.json");
    final List<dynamic> data = jsonDecode(jsonString);

    final loaded = data.map((e) => QuizQuestion.fromJson(e)).toList()
      ..shuffle();
    final processed = loaded.map((q) => q.shuffled()).toList();

    setState(() => questions = processed);
  }

  void selectOption(int index) {
    if (answered) return;

    final isCorrect = index == questions[current].answerIndex;

    setState(() {
      selected = index;
      answered = true;

      if (isCorrect) {
        showCorrectCircle = true;
        _circleController.forward(from: 0); // ★ バウンド開始！
      }
    });

    // 丸フェードアウト
    if (isCorrect) {
      Future.delayed(Duration(milliseconds: 550), () {
        if (mounted) setState(() => showCorrectCircle = false);
      });
    }

    Future.delayed(Duration(seconds: 1), () {
      nextQuestion();
    });
  }

  void nextQuestion() {
    setState(() {
      if (current < questions.length - 1) {
        current++;
      }
      selected = null;
      answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = questions[current];

    return Scaffold(
      appBar: AppBar(
        title: Text("日→英 (${current + 1}/${questions.length})"),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          // =============================
          // メイン UI
          // =============================
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.question,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                ...List.generate(q.options.length, (i) {
                  final isCorrect = i == q.answerIndex;
                  final isSelected = selected == i;

                  Color color = Colors.white;
                  if (answered) {
                    if (isCorrect) color = Colors.green.withOpacity(0.7);
                    if (isSelected && !isCorrect)
                      color = Colors.red.withOpacity(0.7);
                  }

                  return GestureDetector(
                    onTap: () => selectOption(i),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: color,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(q.options[i], style: TextStyle(fontSize: 21)),
                    ),
                  );
                }),
              ],
            ),
          ),

          // =============================
          // ★ 正解演出（赤丸 + ◎）
          // =============================
          Center(
            child: AnimatedOpacity(
              opacity: showCorrectCircle ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: AnimatedBuilder(
                animation: _circleScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _circleScale.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "Great!",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(2, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
