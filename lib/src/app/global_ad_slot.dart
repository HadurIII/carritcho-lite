import 'package:flutter/material.dart';

class GlobalAdSlot extends StatelessWidget {
  const GlobalAdSlot({
    super.key,
    this.child = const Text('ANUNCIOS'),
    this.height = 72,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.green.shade200,
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ),
    );
  }
}
