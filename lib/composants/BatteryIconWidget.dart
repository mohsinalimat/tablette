import 'package:flutter/material.dart';

class BatteryIconWidget extends StatelessWidget {
  final int batteryLevel;

  BatteryIconWidget(this.batteryLevel);

  @override
  Widget build(BuildContext context) {
    IconData batteryIcon;

    if (batteryLevel > 90) {
      batteryIcon = Icons.battery_full;
    } else if (batteryLevel > 70 && batteryLevel <= 89) {
      batteryIcon = Icons.battery_4_bar;
    } else if (batteryLevel > 50 && batteryLevel <= 69) {
      batteryIcon = Icons.battery_3_bar;
    } else if (batteryLevel > 25 && batteryLevel <= 49) {
      batteryIcon = Icons.battery_2_bar;
    } else if (batteryLevel > 10 && batteryLevel <= 24) {
      batteryIcon = Icons.battery_1_bar;
    } else if (batteryLevel > 0 && batteryLevel <= 9) {
      batteryIcon = Icons.battery_0_bar;
    } else {
      batteryIcon = Icons.battery_unknown;
    }

    return Icon(
      batteryIcon,
      color: Colors.white,
      size: MediaQuery.of(context).size.height * 0.8 / 20,
    );
  }
}
