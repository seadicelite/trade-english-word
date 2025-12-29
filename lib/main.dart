import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ← JSON読み込みに必要
import 'package:boueki_eigo_word/main_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/colors.dart';

// ------------------------------------------------------
// ⭐ アプリ起動前に JSON を読み込む
// ------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // JSON 読み込み
  final jsonString = await rootBundle.loadString('assets/trade_terms.json');
  final List<dynamic> jsonList = json.decode(jsonString);

  // static 変数に格納
  TradeTermsData.terms = jsonList.map((e) => TradeTerm.fromJson(e)).toList();

  runApp(const TradeEnglishApp());
}

// ------------------------------------------------------
// ⭐ アプリ本体
// ------------------------------------------------------
class TradeEnglishApp extends StatelessWidget {
  const TradeEnglishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trade English App',

      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: sc.appbar,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: sc.text,
          ),
        ),
        textTheme: GoogleFonts.notoSansJpTextTheme().copyWith(
          bodyLarge: const TextStyle(fontWeight: FontWeight.bold),
          bodyMedium: const TextStyle(fontWeight: FontWeight.bold),
          bodySmall: const TextStyle(fontWeight: FontWeight.bold),
          titleLarge: const TextStyle(fontWeight: FontWeight.bold),
          titleMedium: const TextStyle(fontWeight: FontWeight.bold),
          titleSmall: const TextStyle(fontWeight: FontWeight.bold),
          labelLarge: const TextStyle(fontWeight: FontWeight.bold),
          labelMedium: const TextStyle(fontWeight: FontWeight.bold),
          labelSmall: const TextStyle(fontWeight: FontWeight.bold),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: const Color(0xFF202020),
      ),
      home: MainNavigation(),
    );
  }
}

// ------------------------------------------------------
// ⭐ TradeTerm モデル
// ------------------------------------------------------
class TradeTerm {
  final int id;
  final String termEn;
  final String termJp;

  TradeTerm({required this.id, required this.termEn, required this.termJp});

  factory TradeTerm.fromJson(Map<String, dynamic> json) {
    return TradeTerm(
      id: json['id'],
      termEn: json['term_en'],
      termJp: json['term_jp'],
    );
  }
}

// ------------------------------------------------------
// ⭐ JSONを読み込んだ結果を保持するクラス（どこでも使える）
// ------------------------------------------------------
class TradeTermsData {
  static List<TradeTerm> terms = [];
}

// ------------------------------------------------------
// ⭐ ランダム取得の便利関数（10問など）
// ------------------------------------------------------
List<TradeTerm> getRandomTerms(int count) {
  final list = List.of(TradeTermsData.terms);
  list.shuffle();
  return list.take(count).toList();
}
