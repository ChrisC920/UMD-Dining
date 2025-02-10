import 'package:flutter/material.dart';

class ProgressBarPage extends StatefulWidget {
  const ProgressBarPage({super.key});

  @override
  State<ProgressBarPage> createState() => _ProgressBarPageState();
}

class _ProgressBarPageState extends State<ProgressBarPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ElevatedButton(
          //   onPressed: () {},
          //   child: Container(
          //     color: Colors.red,
          //     height: 100,
          //     width: 100,
          //   ),
          // )
        ],
      ),
    );
  }
}
