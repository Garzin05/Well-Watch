import 'package:flutter/material.dart';
import '../widgets/health_widgets.dart';

class CalendarBasePage extends StatefulWidget {
  final String title;
  final Widget dataDisplay;
  final Widget? actionButton;
  final bool showBackButton;
  final List<Widget>? actions;

  const CalendarBasePage({
    super.key,
    required this.title,
    required this.dataDisplay,
    this.actionButton,
    this.showBackButton = true,
    this.actions,
  });

  @override
  State<CalendarBasePage> createState() => _CalendarBasePageState();
}

class _CalendarBasePageState extends State<CalendarBasePage>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading:
            widget.showBackButton
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                )
                : null,
        title: Text(widget.title),
        actions:
            widget.actions ??
            [
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SaudeMonitorLogo(),
              ),
            ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CalendarGrid(
                initialMonth: _selectedDate,
                selectedDate: _selectedDate,
                onDaySelected: _onDaySelected,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(child: widget.dataDisplay),
                    const SizedBox(height: 16),
                    widget.actionButton ??
                        AnimatedActionButton(
                          text: 'OK',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
