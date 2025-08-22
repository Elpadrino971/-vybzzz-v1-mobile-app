import 'package:flutter/material.dart';

void main() {
  runApp(const VyBzzZSimpleApp());
}

class VyBzzZSimpleApp extends StatelessWidget {
  const VyBzzZSimpleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VyBzzZ Web',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VyBzzZHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VyBzzZHomePage extends StatefulWidget {
  const VyBzzZHomePage({Key? key}) : super(key: key);

  @override
  State<VyBzzZHomePage> createState() => _VyBzzZHomePageState();
}

class _VyBzzZHomePageState extends State<VyBzzZHomePage> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('VyBzzZ Web'),
          backgroundColor: _isDarkMode ? Colors.black : Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isDarkMode 
                ? [Colors.red.shade900, Colors.black]
                : [Colors.blue.shade300, Colors.purple.shade300],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flutter_dash,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 24),
                Text(
                  'VyBzzZ Web',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Application web déployée avec succès !',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Text(
                  '🎉 Félicitations ! Votre app est en ligne ! 🚀',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
