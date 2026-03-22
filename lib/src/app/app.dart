import 'package:flutter/material.dart';

class CarrinhoApp extends StatelessWidget {
  const CarrinhoApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrinhos',
      theme: ThemeData(primarySwatch: Colors.green),
      home: home,
    );
  }
}
