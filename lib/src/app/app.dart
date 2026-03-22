import 'package:flutter/material.dart';

import 'package:carritcholite/src/app/global_ad_slot.dart';

class CarrinhoApp extends StatelessWidget {
  const CarrinhoApp({
    super.key,
    required this.home,
    this.appVersion = '1.0.0+1',
    this.floatingActionButton,
    this.adContent,
  });

  final Widget home;
  final String appVersion;
  final Widget? floatingActionButton;
  final Widget? adContent;

  @override
  Widget build(BuildContext context) {
    const adHeight = 72.0;

    return MaterialApp(
      title: 'Carrinhos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null)
              Padding(
                padding: const EdgeInsets.only(bottom: adHeight),
                child: child,
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: GlobalAdSlot(
                  height: adHeight,
                  child: adContent ?? const Text('ANUNCIOS'),
                ),
              ),
            ),
          ],
        );
      },
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
                  'v$appVersion',
                  style: const TextStyle(
                    color: Colors.black,
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
