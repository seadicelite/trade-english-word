import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ===============================
/// Term Model
/// ===============================
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

/// ===============================
/// Repository（JSON読み込み）
/// ===============================
class TermRepository {
  Future<List<Term>> loadTerms() async {
    final jsonString = await rootBundle.loadString('assets/trade_terms.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => Term.fromJson(item)).toList();
  }
}

/// ===============================
/// 表示モード
/// ===============================
enum WordViewMode { all, hideJp, hideEn }

/// ===============================
/// WordList Screen
/// ===============================
class WordListScreen extends StatefulWidget {
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  late Future<List<Term>> _termsFuture;
  WordViewMode mode = WordViewMode.all;

  @override
  void initState() {
    super.initState();
    _termsFuture = TermRepository().loadTerms();
  }

  int resetKey = 0;

  void changeMode(WordViewMode newMode) {
    setState(() {
      mode = newMode;
      resetKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Words"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.visibility),
            tooltip: "全表示",
            onPressed: () => changeMode(WordViewMode.all),
          ),
          IconButton(
            icon: Icon(Icons.visibility_off),
            tooltip: "日本語を隠す",
            onPressed: () => changeMode(WordViewMode.hideJp),
          ),
          IconButton(
            icon: Icon(Icons.visibility_off_outlined),
            tooltip: "英語を隠す",
            onPressed: () => changeMode(WordViewMode.hideEn),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _termsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final terms = snapshot.data as List<Term>;
          terms.shuffle();

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: terms.length,
            itemBuilder: (context, index) {
              return WordCard(
                term: terms[index],
                mode: mode,
                resetKey: resetKey,
              );
            },
          );
        },
      ),
    );
  }
}

/// 単語カード
/// ===============================
class WordCard extends StatefulWidget {
  final Term term;
  final WordViewMode mode;
  final int resetKey;

  WordCard({required this.term, required this.mode, required this.resetKey});

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool revealed = false;

  @override
  void didUpdateWidget(covariant WordCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.resetKey != widget.resetKey) {
      setState(() {
        revealed = false; // ← リセット！
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hideEn = widget.mode == WordViewMode.hideEn && !revealed;
    final hideJp = widget.mode == WordViewMode.hideJp && !revealed;

    return GestureDetector(
      onTap: () => setState(() => revealed = !revealed),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            /// 英語（左）
            Expanded(
              child: AnimatedOpacity(
                opacity: hideEn ? 0.0 : 1.0,
                duration: Duration(milliseconds: 300),
                child: Text(
                  widget.term.termEn,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: hideEn ? Colors.transparent : Colors.black,
                  ),
                ),
              ),
            ),

            /// 日本語（右）
            Expanded(
              child: AnimatedOpacity(
                opacity: hideJp ? 0.0 : 1.0,
                duration: Duration(milliseconds: 300),
                child: Text(
                  widget.term.termJp,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: hideJp ? Colors.transparent : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
