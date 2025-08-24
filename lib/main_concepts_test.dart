import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screen/concepts_home_screen.dart';

void main() {
  runApp(const ConceptsTestApp());
}

class ConceptsTestApp extends StatelessWidget {
  const ConceptsTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VyBzzZ Concepts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const ConceptsHomeScreen(),
    );
  }
}
