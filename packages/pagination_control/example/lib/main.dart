import 'package:flutter/material.dart';
import 'package:pagination_control/pagination_control.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final PaginationState paginationState = PaginationState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: PaginationControlOptions(paginationState: paginationState),
              ),
              Padding(padding: EdgeInsets.all(12.0), child: VerticalDivider()),
              Expanded(child: PaginationControlExample(paginationState: paginationState)),
            ],
          ),
        ),
      ),
    );
  }
}

class PaginationControlExample extends StatefulWidget {
  const PaginationControlExample({super.key, required this.paginationState});

  final PaginationState paginationState;

  @override
  State<PaginationControlExample> createState() => _PaginationControlExampleState();
}

class _PaginationControlExampleState extends State<PaginationControlExample> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.paginationState,
      builder: (BuildContext context, Widget? child) {
        var paginationState = widget.paginationState;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CurrentPageCard(
              current: paginationState.currentPage,
              total: paginationState.totalPages,
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 16)),
            PaginationControl(
              onChanged:
                  paginationState.enabled
                      ? (page) {
                        paginationState.currentPage = page;
                      }
                      : null,
              current: paginationState.currentPage,
              section: paginationState.sectionSize,
              total: paginationState.totalPages,
            ),
          ],
        );
      },
    );
  }
}

class _CurrentPageCard extends StatelessWidget {
  const _CurrentPageCard({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = TextTheme.of(context);

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedSize(
          curve: Curves.easeInOut,
          duration: Durations.short2,
          child: Column(
            children: [
              Text("$current/$total", style: textTheme.headlineLarge?.copyWith(fontSize: 54)),
              Text("Page", style: textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class PaginationControlOptions extends StatefulWidget {
  const PaginationControlOptions({super.key, required this.paginationState});

  final PaginationState paginationState;

  @override
  State<PaginationControlOptions> createState() => _PaginationControlOptionsState();
}

class _PaginationControlOptionsState extends State<PaginationControlOptions> {
  final TextEditingController currentPageFieldController = TextEditingController();
  final GlobalKey<FormFieldState> currentPageFieldKey = GlobalKey<FormFieldState>();

  final TextEditingController sectionSizeFieldController = TextEditingController();
  final GlobalKey<FormFieldState> sectionSizeFieldKey = GlobalKey<FormFieldState>();

  final TextEditingController totalPagesFieldController = TextEditingController();
  final GlobalKey<FormFieldState> totalPagesFieldKey = GlobalKey<FormFieldState>();

  bool enabled = true;

  void onPaginationStateNotify() {
    currentPageFieldController.text = widget.paginationState.currentPage.toString();
    sectionSizeFieldController.text = widget.paginationState.sectionSize.toString();
    totalPagesFieldController.text = widget.paginationState.totalPages.toString();
    enabled = widget.paginationState.enabled;
    setState(() {});
  }

  @override
  void initState() {
    widget.paginationState.addListener(onPaginationStateNotify);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        onPaginationStateNotify();
      }
    });
    super.initState();
  }

  String? Function(String?)? wholeNumberFieldValidator(field) {
    return (String? value) {
      bool isValid = int.tryParse(value ?? "") != null;
      return isValid ? null : "Total pages must be whole number";
    };
  }

  @override
  Widget build(BuildContext context) {
    final InputDecoration commonInputDecoration = InputDecoration(
      border: OutlineInputBorder(),
      helperText: ' ',
    );

    return SizedBox(
      width: 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          TextFormField(
            key: currentPageFieldKey,
            controller: currentPageFieldController,
            decoration: commonInputDecoration.copyWith(labelText: "Current Page"),
            onFieldSubmitted: (value) {
              bool isValid = currentPageFieldKey.currentState?.validate() == true;
              if (!isValid) return;
              int intValue = int.parse(value);
              widget.paginationState.currentPage = intValue;
            },
            validator: wholeNumberFieldValidator("Current Page"),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 4)),

          TextFormField(
            key: sectionSizeFieldKey,
            controller: sectionSizeFieldController,
            decoration: commonInputDecoration.copyWith(labelText: "Section Size"),
            onFieldSubmitted: (value) {
              bool isValid = sectionSizeFieldKey.currentState?.validate() == true;
              if (!isValid) return;
              int intValue = int.parse(value);
              widget.paginationState.sectionSize = intValue;
            },
            validator: wholeNumberFieldValidator("Section Size"),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 4)),
          TextFormField(
            key: totalPagesFieldKey,
            controller: totalPagesFieldController,
            decoration: commonInputDecoration.copyWith(labelText: "Total Pages"),
            onFieldSubmitted: (value) {
              bool isValid = totalPagesFieldKey.currentState?.validate() == true;
              if (!isValid) return;
              int intValue = int.parse(value);
              widget.paginationState.totalPages = intValue;
            },
            validator: wholeNumberFieldValidator("Total Pages"),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 4)),
          SwitchListTile(
            value: enabled,
            onChanged: (bool? value) {
              if (value != null) {
                widget.paginationState.enabled = value;
              }
            },
            title: Text("Enabled"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.paginationState.removeListener(onPaginationStateNotify);
    currentPageFieldController.dispose();
    totalPagesFieldController.dispose();
    sectionSizeFieldController.dispose();
    super.dispose();
  }
}

class PaginationState extends ChangeNotifier {
  PaginationState({
    int currentPage = 1,
    int totalPages = 10,
    int sectionSize = 3,
    bool enabled = true,
  }) : _currentPage = currentPage,
       _totalPages = totalPages,
       _sectionSize = sectionSize,
       _enabled = enabled;

  int _currentPage;
  int get currentPage => _currentPage;
  set currentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }

  int _totalPages;
  int get totalPages => _totalPages;
  set totalPages(int value) {
    if (_totalPages != value) {
      _totalPages = value;
      notifyListeners();
    }
  }

  int _sectionSize;
  int get sectionSize => _sectionSize;
  set sectionSize(int value) {
    if (_sectionSize != value) {
      _sectionSize = value;
      notifyListeners();
    }
  }

  bool _enabled;
  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled != value) {
      _enabled = value;
      notifyListeners();
    }
  }
}
