import 'package:flutter/material.dart';

class MzFadeInOut extends StatefulWidget {
  const MzFadeInOut({super.key});

  @override
  FadeInOutState createState() => FadeInOutState();
}

class FadeInOutState extends State<MzFadeInOut> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(seconds: 1),
          child: Container(
            width: 200.0,
            height: 200.0,
            color: Colors.green,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _visible = !_visible;
          });
        },
        child: const Icon(Icons.flip),
      ),
    );
  }
}
