import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pong/ball.dart';
import 'package:pong/bat.dart';

enum Direction { up, down, left, right }

class Pong extends StatefulWidget {
  const Pong({super.key});

  @override
  State<Pong> createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  int score = 0;
  double randomX = 1;
  double randomY = 1;
  double increment = 10;
  Direction vDir = Direction.down;
  Direction hDir = Direction.right;
  double width = 0;
  double height = 0;
  double posX = 0;
  double posY = 0;
  double batWidth = 0;
  double batHeight = 0;
  double batPosition = 0;
  late Animation<double> animation;
  late AnimationController controller;

  double randomNumber() {
    //random between 0.5 and 1.5
    var random = Random();
    int num = random.nextInt(101);
    return (50 + num) / 100;
  }

  void checkBorders() {
    double diameter = 50;
    if (posX <= 0 && hDir == Direction.left) {
      hDir = Direction.right;
      randomX = randomNumber();
    }
    if (posX >= width - diameter && hDir == Direction.right) {
      hDir = Direction.left;
      randomX = randomNumber();
    }
    if (posY >= height - diameter - batHeight && vDir == Direction.down) {
      if (posX >= (batPosition - diameter) &&
          posX <= (batPosition + batWidth + diameter)) {
        vDir = Direction.up;
        randomY = randomNumber();
        safeSetState(() {
          score++;
        });
      } else {
        controller.stop();
        showMessage(context);
      }
    }
    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
      randomY = randomNumber();
    }
  }

  void showMessage(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Game overrrr"),
            content: const Text("Would you like to play again?"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    setState(() {
                      posX = 0;
                      posY = 0;
                      score = 0;
                    });
                    Navigator.of(context).pop();
                    controller.repeat();
                  },
                  child: const Text("Yes")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    dispose();
                  },
                  child: const Text("No"))
            ],
          );
        });
  }

  @override
  void initState() {
    posX = 0;
    posY = 0;

    controller = AnimationController(
        duration: const Duration(minutes: 10000), vsync: this);

    animation = Tween<double>(begin: 0, end: 100).animate(controller);

    animation.addListener(() {
      safeSetState(() {
        (hDir == Direction.right)
            ? posX += ((increment * randomX)).round()
            : posX -= ((increment * randomX)).round();
        (vDir == Direction.down)
            ? posY += ((increment * randomY)).round()
            : posY -= ((increment * randomY)).round();
      });
      checkBorders();
    });

    controller.forward();

    super.initState();
  }

  void moveBat(DragUpdateDetails update) {
    safeSetState(() {
      batPosition += update.delta.dx;
    });
  }

  void safeSetState(Function function) {
    if (mounted && controller.isAnimating) {
      setState(() {
        function();
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      batWidth = width / 5;
      batHeight = height / 20;
      return Stack(
        children: <Widget>[
          Positioned(top: 0, right: 24, child: Text("Score : $score")),
          Positioned(
            top: posY,
            left: posX,
            child: const Ball(),
          ),
          Positioned(
            bottom: 0,
            left: batPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: (DragUpdateDetails update) =>
                  moveBat(update),
              child: Bat(
                width: batWidth,
                height: batHeight,
              ),
            ),
          )
        ],
      );
    });
  }
}
