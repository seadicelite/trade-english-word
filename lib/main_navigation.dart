import 'package:flutter/material.dart';
import 'package:boueki_eigo_word/screens/matching_test_screen.dart';
import 'package:boueki_eigo_word/screens/quiz_screen_jp.dart';
import 'package:boueki_eigo_word/screens/quiz_screen.dart';
import 'package:boueki_eigo_word/screens/flashcard_screen.dart';
import 'package:boueki_eigo_word/screens/word_list_screen.dart';

import 'overlay_splash.dart'; // ★ 必須

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 2;

  final List<Widget> _screens = [
    QuizJpScreen(),
    QuizScreen(),
    MatchingTestScreen(),
    FlashcardScreen(),
    WordListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverlaySplash(
        key: ValueKey(_currentIndex), // ★ これで毎回 Splash を再発火
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF101010),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '日→英'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: '英→日'),
          BottomNavigationBarItem(icon: Icon(Icons.pages), label: "試験対策"),
          BottomNavigationBarItem(icon: Icon(Icons.style), label: 'フラッシュ'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '一覧'),
        ],
      ),
    );
  }
}
