import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class PaginationControl extends StatefulWidget {
  /// Current page
  final int? current;

  /// Size of section
  final int section;

  /// Total number of pages
  final int total;

  /// Callback when value are changed.
  ///
  /// Values are changed on:
  /// - Number button tap;
  /// - Arrow control buttons tap;
  final void Function(int)? onChanged;

  final Axis axis;

  const PaginationControl({
    super.key,
    required this.current,
    required this.section,
    required this.total,
    this.onChanged,
    this.axis = Axis.horizontal,
  });

  @override
  State<PaginationControl> createState() => _PaginationControlState();
}

class _PaginationControlState extends State<PaginationControl> {
  late AxisDirection slideDirection = switch (widget.axis) {
    Axis.horizontal => AxisDirection.right,
    Axis.vertical => AxisDirection.down,
  };

  List generatePaginationNumbers() {
    int current = widget.current ?? 1;
    int section = widget.section.clamp(0, widget.total);
    if (section == 0) {
      return [];
    }

    int offset;
    if (section == 1) {
      offset = current;
    } else if (section % 2 == 0 || section == 3) {
      offset = current - 1;
    } else {
      offset = current - 2;
    }

    int maxOffset = widget.total - section + 1;
    if (maxOffset < 1) {
      maxOffset = 1;
    }

    offset = offset.clamp(1, maxOffset);
    return List.generate(
      section.clamp(0, widget.total),
      (i) => offset + i,
      growable: false,
    );
  }

  void _changePage(int value) {
    int nextPage = value.clamp(1, widget.total);
    if (nextPage != widget.current) {
      widget.onChanged?.call(nextPage);
    }
  }

  @override
  void didUpdateWidget(covariant PaginationControl oldWidget) {
    int lastPage = oldWidget.current ?? 1;
    int newPage = widget.current ?? 1;

    bool decreased = lastPage > newPage;
    bool increased = !decreased;

    slideDirection = switch (widget.axis) {
      Axis.horizontal when decreased => AxisDirection.left,
      Axis.horizontal when increased => AxisDirection.right,
      Axis.vertical when decreased => AxisDirection.up,
      Axis.vertical when increased => AxisDirection.down,
      // Flutter doesn't know that switch is exhaustively matched after first 4 cases.
      Axis.horizontal => AxisDirection.right,
      Axis.vertical => AxisDirection.down,
    };

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final int currentPage = widget.current ?? 1;
    final int firstPage = 1;
    final int previousPage = currentPage - 1;
    final int nextPage = currentPage + 1;
    final int lastPage = widget.total;

    final int quartersToTurn = switch (widget.axis) {
      Axis.horizontal => 0,
      Axis.vertical => 1,
    };

    var children = [
      IconButton.outlined(
        onPressed: () => _changePage(firstPage),
        icon: RotatedBox(
          quarterTurns: quartersToTurn,
          child: Icon(MdiIcons.pageFirst),
        ),
      ),
      IconButton.outlined(
        onPressed: () => _changePage(previousPage),
        icon: RotatedBox(
          quarterTurns: quartersToTurn,
          child: Icon(MdiIcons.arrowLeft),
        ),
      ),
      Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
      ...generatePaginationNumbers().map(
        (i) => _PaginationNumberButton(
          i,
          onPressed: (i) => _changePage(i),
          selected: i == currentPage,
          slideDirection: slideDirection,
        ),
      ),
      Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
      IconButton.outlined(
        onPressed: () => _changePage(nextPage),
        icon: RotatedBox(
          quarterTurns: quartersToTurn,
          child: Icon(MdiIcons.arrowRight),
        ),
      ),
      IconButton.outlined(
        onPressed: () => _changePage(lastPage),
        icon: RotatedBox(
          quarterTurns: quartersToTurn,
          child: Icon(MdiIcons.pageLast),
        ),
      ),
    ];

    return switch (widget.axis) {
      Axis.horizontal => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: children,
      ),
      Axis.vertical => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: children,
      ),
    };
  }
}

class _PaginationNumberButton extends StatelessWidget {
  final int number;
  final bool selected;
  final void Function(int value)? onPressed;
  final AxisDirection? slideDirection;

  const _PaginationNumberButton(
    this.number, {
    this.onPressed,
    this.selected = false,
    this.slideDirection,
  });

  @override
  Widget build(BuildContext context) {
    ButtonStyle tonalButtonStyle = FilledButton.tonal(
      onPressed: () {},
      child: null,
    ).defaultStyleOf(context);

    double radius = 12.0;
    if (selected) {
      radius = 4.0;
    }

    String text = number.toIconCodePoints();

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 7),
        minimumSize: Size(48, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ).copyWith(
        backgroundColor: selected ? tonalButtonStyle.backgroundColor : null,
        textStyle: selected ? tonalButtonStyle.textStyle : null,
      ),
      onPressed: onPressed != null ? () => onPressed!(number) : null,
      child: AnimatedSwitcher(
        transitionBuilder: (Widget child, Animation<double> animation) {
          final Offset begin = switch (slideDirection) {
            AxisDirection.right => Offset(-2.0, 0),
            AxisDirection.left => Offset(2, 0),
            AxisDirection.down => Offset(0, 2),
            AxisDirection.up => Offset(0, -2),
            null => Offset.zero,
          };

          final Animation<Offset> offset = Tween<Offset>(
            begin: begin,
            end: Offset(0, 0),
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              key: child.key,
              position: offset,
              child: child,
            ),
          );
        },
        duration: Durations.short2,
        reverseDuration: Durations.short2,
        child: Text(key: ValueKey(number), text),
      ),
    );
  }
}

extension IntegerExtensions on int {
  String toIconCodePoints() {
    String stringInt = toString();

    String text = "";
    for (int i = 0; i < stringInt.length; i++) {
      MdiIcons? icon = switch (stringInt[i]) {
        "-" => MdiIcons.minus,
        "0" => MdiIcons.numeric0,
        "1" => MdiIcons.numeric1,
        "2" => MdiIcons.numeric2,
        "3" => MdiIcons.numeric3,
        "4" => MdiIcons.numeric4,
        "5" => MdiIcons.numeric5,
        "6" => MdiIcons.numeric6,
        "7" => MdiIcons.numeric7,
        "8" => MdiIcons.numeric8,
        "9" => MdiIcons.numeric9,
        _ => null,
      };
      if (icon != null) {
        String char = String.fromCharCode(icon.codePoint);
        if (text.isNotEmpty) text += " ";
        text += char;
      }
    }
    return text;
  }
}
