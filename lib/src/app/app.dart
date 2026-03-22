import 'package:flutter/material.dart';

class CarrinhoApp extends StatelessWidget {
  const CarrinhoApp({
    super.key,
    required this.home,
    this.appVersion = '1.0.0+1',
    this.floatingActionButton,
  });

  final Widget home;
  final String appVersion;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrinhos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: _AppShell(
        home: home,
        appVersion: appVersion,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell({
    required this.home,
    required this.appVersion,
    this.floatingActionButton,
  });

  final Widget home;
  final String appVersion;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: home,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        title: const Text('Carrinhos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  appVersion,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
