import 'dart:convert';
import 'package:boueki_eigo_word/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Term {
  final int id;
  final String termEn;
  final String termJp;

  Term({required this.id, required this.termEn, required this.termJp});

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json["id"],
      termEn: json["term_en"],
      termJp: json["term_jp"],
    );
  }
}

class MatchingTestScreen extends StatefulWidget {
  @override
  State<MatchingTestScreen> createState() => _MatchingTestScreenState();
}

class _MatchingTestScreenState extends State<MatchingTestScreen> {
  List<Term> allTerms = [];
  List<Term> questions = [];
  List<String> options = [];

  Map<int, String> userAnswers = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await loadTerms();
    generateTest();
  }

  Future<void> loadTerms() async {
    final jsonString = await rootBundle.loadString('assets/trade_terms.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    allTerms = jsonList.map((e) => Term.fromJson(e)).toList();
  }

  // ======================================================
  // ★ 5問作成 & 語群10個生成
  // ======================================================
  void generateTest() {
    questions = List<Term>.from(allTerms)..shuffle();
    questions = questions.take(5).toList();

    List<String> correct = questions.map((e) => e.termJp).toList();

    List<String> dummy =
        allTerms
            .map((e) => e.termJp)
            .where((jp) => !correct.contains(jp))
            .toList()
          ..shuffle();
    dummy = dummy.take(5).toList();

    options = [...correct, ...dummy]..shuffle();

    userAnswers.clear();
    loading = false;
    setState(() {});
  }

  // ======================================================
  // 採点
  // ======================================================
  void checkAnswers() {
    int score = 0;

    for (var q in questions) {
      if (userAnswers[q.id] == q.termJp) score++;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sc.card,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: sc.back,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // ======= スコアの丸バッジ =======
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 12),
                    padding: EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: score >= 3
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "$score / 5",
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: score >= 3
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          score >= 3 ? "Good Job!" : "Try Again!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: questions.length,
                      itemBuilder: (_, index) {
                        final q = questions[index];
                        final user = userAnswers[q.id];
                        final correct = q.termJp;
                        final isCorrect = user == correct;

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: sc.card,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: sc.back,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.termEn,
                                style: TextStyle(
                                  color: sc.text,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 8),

                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCorrect ? Icons.check : Icons.close,
                                          color: isCorrect
                                              ? Colors.green
                                              : Colors.red,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          user ?? "未回答",
                                          style: TextStyle(
                                            color: isCorrect
                                                ? Colors.green.shade900
                                                : Colors.red.shade900,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8),

                              Text(
                                "正解： $correct",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("ミニテスト", style: TextStyle(color: sc.text)),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("ミニテスト", style: TextStyle(color: sc.text)),
        actions: [
          IconButton(
            color: sc.icon,
            icon: Icon(Icons.arrow_forward), // ★ ←ここで次の5問
            tooltip: "次の5問",
            onPressed: () {
              generateTest();
            },
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];

          return Card(
            color: sc.card,
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.termEn,
                    style: TextStyle(
                      color: sc.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: DropdownButton<String>(
                      hint: Text("日本語を選択", style: TextStyle(color: sc.text)),
                      value: userAnswers[q.id],
                      items: options.map((jp) {
                        return DropdownMenuItem(value: jp, child: Text(jp));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          userAnswers[q.id] = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),

        child: ElevatedButton(
          style: TextButton.styleFrom(backgroundColor: sc.button),
          onPressed: checkAnswers,
          child: Text(
            "採点して結果を見る",
            style: TextStyle(fontSize: 18, color: sc.text),
          ),
        ),
      ),
    );
  }
}
