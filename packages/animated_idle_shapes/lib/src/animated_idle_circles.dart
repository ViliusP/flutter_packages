import 'dart:math';

import 'package:flutter/material.dart';

/// A widget that displays a series of animated circles that move vertically
/// in an idle motion. The animation alternates the direction of movement
/// for each circle, creating a dynamic and visually appealing effect.
///
/// The widget allows customization of the number of circles, their radius,
/// and their color.
///
/// ## Parameters:
/// - [count]: The number of circles to display. Defaults to 5.
/// - [radius]: The radius of each circle. Defaults to 20.
/// - [color]: The color of the circles. If not provided, it defaults to the
///   primary color of the current theme with reduced opacity.
///
/// ## Behavior:
/// - Each circle moves vertically within a random range, alternating between
///   upward and downward directions.
/// - The animation duration and range of movement are randomized for each
///   circle to create a natural and varied motion.
/// - The animation uses an elastic curve for smooth transitions.
///
/// ## Example:
/// ```dart
/// AnimatedIdleCircles(
///   count: 7,
///   radius: 30,
///   color: Colors.blue,
/// )
/// ```
///
/// This will create 7 animated circles with a radius of 30 and a blue color.
class AnimatedIdleCircles extends StatefulWidget {
  final int count;
  final double spacing;
  final double radius;
  final Color? color;

  const AnimatedIdleCircles({
    super.key,
    this.color,
    this.radius = 20,
    this.count = 1,
    this.spacing = 0,
  });

  @override
  State<AnimatedIdleCircles> createState() => _AnimatedIdleCirclesState();
}

class _AnimatedIdleCirclesState extends State<AnimatedIdleCircles> {
  final Random _random = Random(5336);
  final List<double> _ranges = [];
  final List<VerticalDirection> _directions = [];
  final List<Duration> _durations = [];

  void resetShapeProperties() {
    _ranges.clear();
    _durations.clear();
    _directions.clear();
  }

  void generateShapeProperties() {
    var countIter = List.generate(widget.count, (i) => i);

    for (int _ in countIter) {
      _ranges.add(generateRange());
      _durations.add(generateDuration());
      _directions.add(
        _random.nextBool() ? VerticalDirection.up : VerticalDirection.down,
      );
    }
  }

  @override
  void initState() {
    generateShapeProperties();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        for (var i in List.generate(widget.count, (i) => i)) {
          flipDirection(i);
        }
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AnimatedIdleCircles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      resetShapeProperties();
      generateShapeProperties();
    }
  }

  double generateRange() {
    return widget.radius / 2 + (_random.nextDouble() * widget.radius * 3);
  }

  Duration generateDuration() {
    return Duration(milliseconds: 2000 + _random.nextInt(3000));
  }

  void flipDirection(int index) {
    _directions[index] = switch (_directions[index]) {
      VerticalDirection.up => VerticalDirection.down,
      VerticalDirection.down => VerticalDirection.up,
    };
  }

  @override
  Widget build(BuildContext context) {
    final Color color =
        widget.color ??
        Theme.of(context).colorScheme.primary.withAlpha(255 ~/ 1.5);

    double width = (widget.radius * widget.count);
    width += (widget.count - 1) * widget.spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        double verticalCenter = (constraints.maxHeight - widget.radius) / 2;
        double horizontalCenter = (constraints.maxWidth - width) / 2;
        return Stack(
          fit: StackFit.expand,
          children: List.generate(widget.count, (index) {
            double left = horizontalCenter;
            if (index != 0) left += (widget.radius + widget.spacing) * index;

            double top = verticalCenter;
            top += switch (_directions[index]) {
              VerticalDirection.up => -_ranges[index] / 2,
              VerticalDirection.down => _ranges[index] / 2,
            };

            return AnimatedPositioned(
              duration: _durations[index],
              top: top,
              left: left,
              curve: Curves.elasticInOut,
              onEnd: () {
                setState(() {
                  flipDirection(index);
                  _ranges[index] = generateRange();
                  _durations[index] = generateDuration();
                });
              },
              child: Container(
                width: widget.radius,
                height: widget.radius,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            );
          }),
        );
      },
    );
  }
}

class AnimatedIdleShape {}
