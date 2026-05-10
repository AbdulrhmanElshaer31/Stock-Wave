import 'package:flutter/material.dart';
import 'package:stock_wave/screens/home.dart';
import 'package:stock_wave/screens/analysis.dart';
import 'package:stock_wave/screens/market.dart';
import 'package:stock_wave/screens/news.dart';
import 'package:stock_wave/screens/search.dart';
import 'package:stock_wave/screens/watchlist.dart';

void main() {
  runApp(const StockWaveApp());
}

class StockWaveApp extends StatefulWidget {
  const StockWaveApp({super.key});
  @override
  State<StockWaveApp> createState() => StockWave();
}

class StockWave extends State<StockWaveApp> {
  int currentIndex = 0;
  final List<Widget> screens = [
    const Home(),
    const Market(),
    const News(),
    const Search(),
    const Analysis(),
    const Watchlist(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      home: Scaffold(
        body: screens[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0B0B0B),
          selectedItemColor: Color(0xfffcba03),
          unselectedItemColor: Colors.grey,
          iconSize: 24,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: [
            BottomNavigationBarItem(
              label: "Home",
              icon: const Icon(Icons.home_rounded),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfffcba03).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.home_rounded, color: Color(0xfffcba03)),
              ),
            ),
            BottomNavigationBarItem(
              label: "Market",
              icon: const Icon(Icons.show_chart),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfffcba03).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.show_chart, color: Color(0xfffcba03)),
              ),
            ),
            BottomNavigationBarItem(
              label: "Search",
              icon: const Icon(Icons.search),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfffcba03).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.search, color: Color(0xfffcba03)),
              ),
            ),
            BottomNavigationBarItem(
              label: "News",
              icon: const Icon(Icons.article_outlined),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfffcba03).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: Color(0xfffcba03),
                ),
              ),
            ),
            BottomNavigationBarItem(
              label: "Analysis",
              icon: const Icon(Icons.leaderboard_outlined),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfffcba03).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.leaderboard_outlined,
                  color: Color(0xfffcba03),
                ),
              ),
            ),
            BottomNavigationBarItem(
              label: "Watchlist",
              icon: const Icon(Icons.star_outline_rounded),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfffcba03).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.star_rounded, color: Color(0xfffcba03)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
