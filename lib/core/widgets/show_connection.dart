import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class ShowConnection extends StatelessWidget {
  ShowConnection({required this.status});
  final bool status;

  @override
  Widget build(BuildContext context) {
    Color color = status ? Colors.green : Colors.red;
    String label = status ? 'CONNECTED' : 'DISCONNECTED';
    IconData iconData = status ? Icons.wifi : Icons.wifi_off;

    return Row(
      children: [
        Icon(
          iconData,
          color: color,
          size: 24, // Adjust icon size as needed
        ),
        SizedBox(width: 5.0),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        )
      ],
    );
  }
}


