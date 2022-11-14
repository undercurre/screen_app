import 'package:flutter/material.dart';

class TemperatureCard extends StatefulWidget {
  final int minTemperature;
  final int maxTemperature;
  final int value;

  const TemperatureCard({
    super.key,
    this.value = 30,
    this.maxTemperature = 60,
    this.minTemperature = 10,
  });

  @override
  State<StatefulWidget> createState() => _TemperatureCardState();
}

class _TemperatureCardState extends State<TemperatureCard> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
