import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BalanceGameScreen(),
  ));
}

class BalanceGameScreen extends StatefulWidget {
  const BalanceGameScreen({super.key});

  @override
  State<BalanceGameScreen> createState() => _BalanceGameScreenState();
}

class _BalanceGameScreenState extends State<BalanceGameScreen> {
  double ballX = 100, ballY = 100;
  double targetX = 200, targetY = 400;

  final double ballSize = 50;
  final double targetSize = 60;
  double screenW = 0, screenH = 0;

  @override
  void initState() {
    super.initState();

    accelerometerEvents.listen((event) {
      setState(() {
        // Đã sửa hướng
        ballX -= event.x * 2;
        ballY += event.y * 2;

        // Giới hạn viền
        ballX = ballX.clamp(0, screenW - ballSize);
        ballY = ballY.clamp(0, screenH - ballSize);

        _checkWin();
      });
    });
  }

  void _randomTarget() {
    final rnd = Random();
    targetX = rnd.nextDouble() * (screenW - targetSize);
    targetY = rnd.nextDouble() * (screenH - targetSize);
  }

  void _checkWin() {
    final ballCX = ballX + ballSize / 2;
    final ballCY = ballY + ballSize / 2;
    final targetCX = targetX + targetSize / 2;
    final targetCY = targetY + targetSize / 2;

    final dist = sqrt(pow(ballCX - targetCX, 2) + pow(ballCY - targetCY, 2));
    if (dist < targetSize / 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Bạn đã thắng!')),
      );
      _randomTarget();
    }
  }

  @override
  Widget build(BuildContext context) {
    screenW = MediaQuery.of(context).size.width;
    screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: targetX,
            top: targetY,
            child: Container(
              width: targetSize,
              height: targetSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 4),
              ),
            ),
          ),
          Positioned(
            left: ballX,
            top: ballY,
            child: Container(
              width: ballSize,
              height: ballSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
