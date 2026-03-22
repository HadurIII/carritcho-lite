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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Carrinhos'),
            const SizedBox(width: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  appVersion,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
