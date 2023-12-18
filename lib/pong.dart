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

  void checkBorders() {
    double diameter = 50;
    if(posY >= height - diameter - batHeight && vDir == Direction.down){
      if(posX >= (batPosition - diameter ) && posX <= (batPosition + batWidth + diameter)){
        vDir = Direction.up;
      }else{
        controller.stop();
        dispose();
      }
    }
    if (posX <= 0 && hDir == Direction.left) {
      hDir = Direction.right;
    }
    if (posX >= width - diameter && hDir == Direction.right) {
      hDir = Direction.left;
    }
    // if (posY >= height - 50 && vDir == Direction.down) {
    //   vDir = Direction.up;
    // }
    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
    }
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
        (hDir == Direction.right) ? posX += increment : posX -= increment;
        (vDir == Direction.down) ? posY += increment : posY -= increment;
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

  void safeSetState(Function function){
    if(mounted && controller.isAnimating){
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
