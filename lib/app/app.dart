import 'dart:math';

import 'package:expense/binding/home_binding.dart';
import 'package:expense/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    List<Color> randomColor = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.pink,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.grey,
      Colors.purpleAccent,
      Colors.deepPurple,
      Colors.deepOrange,
      Colors.pinkAccent,
      Colors.lightGreen,
      Colors.lightBlue,
      Colors.deepOrangeAccent,
      Colors.limeAccent,
      Colors.amberAccent,
      Colors.cyanAccent,
      Colors.indigoAccent,
      Colors.lime,
      Colors.amber,
      Colors.cyan,
      Colors.indigo
    ];

    Color getRandomColors() {
      final random = Random();
      return randomColor[random.nextInt(randomColor.length)];
    }

    return GetMaterialApp(
      title: 'IE Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: getRandomColors()),
        useMaterial3: true,
      ),
      initialBinding: HomeBinding(),
      home: HomePage(),
    );
  }
}
