import 'package:animated_idle_shapes/animated_idle_shapes.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AnimatedIdleCirclesOptions circlesOptions = AnimatedIdleCirclesOptions();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Animated Idle Shapes Example",
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 400,
                  child: AnimatedIdleCirclesOptionsPanel(circlesOptions: circlesOptions),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 4)),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(border: Border.all()),
                    child: AnimatedIdleCirclesExample(circlesOptions: circlesOptions),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedIdleCirclesOptionsPanel extends StatelessWidget {
  final AnimatedIdleCirclesOptions circlesOptions;

  const AnimatedIdleCirclesOptionsPanel({super.key, required this.circlesOptions});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: circlesOptions,
      builder: (BuildContext context, Widget? child) {
        return Column(
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            Text("Color Picker", style: TextTheme.of(context).headlineSmall),
            Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            _ColorPicker(
              value: circlesOptions.color,
              onChanged: (Color? color) => circlesOptions.color = color,
            ),
            Divider(),
            Text("Shape", style: TextTheme.of(context).headlineSmall),
            Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            IntegerPicker(
              min: 0,
              label: "Radius",
              value: circlesOptions.radius.toInt(),
              onChanged: (value) {
                circlesOptions.radius = value.toDouble();
              },
            ),
            Divider(),
            Text("General", style: TextTheme.of(context).headlineSmall),
            Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            IntegerPicker(
              min: 0,
              label: "Count",
              value: circlesOptions.count,
              onChanged: (value) {
                circlesOptions.count = value;
              },
            ),
            IntegerPicker(
              min: 0,
              label: "Spacing",
              value: circlesOptions.spacing.toInt(),
              onChanged: (value) {
                circlesOptions.spacing = value.toDouble();
              },
            ),
          ],
        );
      },
    );
  }
}

class AnimatedIdleCirclesExample extends StatelessWidget {
  const AnimatedIdleCirclesExample({super.key, required this.circlesOptions});

  final AnimatedIdleCirclesOptions circlesOptions;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: circlesOptions,
      builder: (BuildContext context, Widget? child) {
        return AnimatedIdleCircles(
          color: circlesOptions.color,
          count: circlesOptions.count,
          spacing: circlesOptions.spacing,
          radius: circlesOptions.radius,
        );
      },
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.value, required this.onChanged});

  final Color? value;
  final Function(Color? color)? onChanged;

  @override
  Widget build(BuildContext context) {
    bool isColorSliderEnabled = onChanged != null && value != null;

    onRedComponentChanged(double r) => onChanged!(
      Color.from(red: r, green: value?.g ?? 0, blue: value?.b ?? 0, alpha: value?.a ?? 1),
    );

    onGreenComponentChanged(double g) => onChanged!(
      Color.from(red: value?.r ?? 0, green: g, blue: value?.b ?? 0, alpha: value?.a ?? 1),
    );

    onBlueComponentChanged(double b) => onChanged!(
      Color.from(red: value?.r ?? 0, green: value?.g ?? 0, blue: b, alpha: value?.a ?? 1),
    );

    onAlphaComponentChanged(double a) => onChanged!(
      Color.from(red: value?.r ?? 0, green: value?.g ?? 0, blue: value?.b ?? 0, alpha: a),
    );

    defaultValueSwitchCallback(bool defaultColor) {
      if (defaultColor) {
        onChanged!(null);
      } else {
        onChanged!(Color.from(alpha: 1, red: 0, green: 0, blue: 0));
      }
    }

    Widget sliderBuilder({
      required double? sliderValue,
      required String colorLabel,
      required Function(double value) onComponentChanged,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            SizedBox(width: 40, child: Text(colorLabel)),
            Expanded(
              child: Slider(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                value: sliderValue ?? 0,
                min: 0,
                max: 1,
                onChanged: isColorSliderEnabled ? onComponentChanged : null,
                label: "${colorLabel[0].toLowerCase()}: $sliderValue",
              ),
            ),
            SizedBox(width: 30, child: Text("${sliderValue?.toStringAsFixed(2)}")),
          ],
        ),
      );
    }

    return Column(
      children: [
        sliderBuilder(
          colorLabel: "Red",
          sliderValue: value?.r,
          onComponentChanged: onRedComponentChanged,
        ),
        sliderBuilder(
          colorLabel: "Green",
          sliderValue: value?.g,
          onComponentChanged: onGreenComponentChanged,
        ),
        sliderBuilder(
          colorLabel: "Blue",
          sliderValue: value?.b,
          onComponentChanged: onBlueComponentChanged,
        ),
        sliderBuilder(
          colorLabel: "Alpha",
          sliderValue: value?.a,
          onComponentChanged: onAlphaComponentChanged,
        ),

        SwitchListTile(
          title: Text("Default color"),
          value: value == null,
          onChanged: onChanged != null ? defaultValueSwitchCallback : null,
        ),
      ],
    );
  }
}

class IntegerPicker extends StatefulWidget {
  const IntegerPicker({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.max,
    this.min,
  });

  final String label;
  final int value;
  final int? max;
  final int? min;
  final Function(int value)? onChanged;

  @override
  State<IntegerPicker> createState() => _IntegerPickerState();
}

class _IntegerPickerState extends State<IntegerPicker> {
  final TextEditingController textFormController = TextEditingController();

  @override
  void initState() {
    textFormController.value = TextEditingValue(text: widget.value.toString());
    super.initState();
  }

  @override
  void didUpdateWidget(covariant IntegerPicker oldWidget) {
    if (oldWidget.value != widget.value) {
      textFormController.value = TextEditingValue(text: widget.value.toString());
    }
    super.didUpdateWidget(oldWidget);
  }

  String? validateFieldValue(String? value) {
    if (value == null) return "Field value cannot be null";
    int? intValue = int.tryParse(value);
    if (intValue == null) return "Field value must be integer";
    if (widget.min != null && intValue < widget.min!) {
      return "Number must be bigger than or equal to ${widget.min!}";
    }
    if (widget.max != null && intValue > widget.max!) {
      return "Number must be smaller than or equal to ${widget.max!}";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget? buildCounter(
      BuildContext context, {
      required int currentLength,
      required bool isFocused,
      required int? maxLength,
    }) {
      return null;
    }

    bool increaseButtonEnabled =
        widget.onChanged != null && (widget.max == null || widget.value < widget.max!);

    bool decreaseButtonEnabled =
        widget.onChanged != null && (widget.min == null || widget.value > widget.min!);

    return Column(
      children: [
        Text(
          widget.label,
          style: TextTheme.of(
            context,
          ).labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 2)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: IconButton(
                onPressed: decreaseButtonEnabled ? () => widget.onChanged!(widget.value - 1) : null,
                icon: Icon(Icons.remove),
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 2)),

            SizedBox(
              width: 96,
              child: TextFormField(
                controller: textFormController,
                textAlign: TextAlign.center,
                maxLength: 5,
                buildCounter: buildCounter,
                validator: validateFieldValue,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.number,
                enabled: widget.onChanged != null,
                onFieldSubmitted:
                    widget.onChanged == null
                        ? null
                        : (String? value) {
                          if (value == null) return;
                          int? intValue = int.tryParse(value);
                          if (intValue == null) return;
                          if (widget.min != null && intValue < widget.min!) return;
                          if (widget.max != null && intValue > widget.max!) return;
                          widget.onChanged!(intValue);
                        },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  helperText: "",
                  hintText: "${widget.value}",
                  helperStyle: TextStyle(height: 1.2),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: IconButton(
                onPressed: increaseButtonEnabled ? () => widget.onChanged!(widget.value + 1) : null,
                icon: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AnimatedIdleCirclesOptions extends ChangeNotifier {
  AnimatedIdleCirclesOptions({Color? color, double radius = 20, int count = 3, double spacing = 5})
    : _color = color,
      _radius = radius,
      _count = count,
      _spacing = spacing;

  Color? _color;
  Color? get color => _color;
  set color(Color? value) {
    _color = value;
    notifyListeners();
  }

  double _radius;
  double get radius => _radius;
  set radius(double value) {
    _radius = value;
    notifyListeners();
  }

  int _count;
  int get count => _count;
  set count(int value) {
    _count = value;
    notifyListeners();
  }

  double _spacing;
  double get spacing => _spacing;
  set spacing(double value) {
    _spacing = value;
    notifyListeners();
  }
}
