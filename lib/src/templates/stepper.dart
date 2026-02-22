/// Template for the Stepper component source file.
const stepperTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladStepperTheme extends ThemeExtension<FladStepperTheme> {
  final Color activeColor;
  final Color inactiveColor;
  final Color completedColor;
  final Color connectorColor;
  final Color labelColor;
  final Color sublabelColor;
  final double radius;

  const FladStepperTheme({
    required this.activeColor,
    required this.inactiveColor,
    required this.completedColor,
    required this.connectorColor,
    required this.labelColor,
    required this.sublabelColor,
    required this.radius,
  });

  factory FladStepperTheme.fromScheme(ColorScheme scheme) {
    return FladStepperTheme(
      activeColor: scheme.primary,
      inactiveColor: scheme.outlineVariant,
      completedColor: scheme.primary,
      connectorColor: scheme.outlineVariant,
      labelColor: scheme.onSurface,
      sublabelColor: scheme.onSurfaceVariant,
      radius: 12,
    );
  }

  @override
  FladStepperTheme copyWith({
    Color? activeColor,
    Color? inactiveColor,
    Color? completedColor,
    Color? connectorColor,
    Color? labelColor,
    Color? sublabelColor,
    double? radius,
  }) {
    return FladStepperTheme(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      completedColor: completedColor ?? this.completedColor,
      connectorColor: connectorColor ?? this.connectorColor,
      labelColor: labelColor ?? this.labelColor,
      sublabelColor: sublabelColor ?? this.sublabelColor,
      radius: radius ?? this.radius,
    );
  }

  @override
  FladStepperTheme lerp(ThemeExtension<FladStepperTheme>? other, double t) {
    if (other is! FladStepperTheme) return this;
    return FladStepperTheme(
      activeColor: Color.lerp(activeColor, other.activeColor, t)!,
      inactiveColor: Color.lerp(inactiveColor, other.inactiveColor, t)!,
      completedColor: Color.lerp(completedColor, other.completedColor, t)!,
      connectorColor: Color.lerp(connectorColor, other.connectorColor, t)!,
      labelColor: Color.lerp(labelColor, other.labelColor, t)!,
      sublabelColor: Color.lerp(sublabelColor, other.sublabelColor, t)!,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

class FladStepperStep {
  final String title;
  final String? subtitle;
  final Widget content;

  const FladStepperStep({
    required this.title,
    this.subtitle,
    required this.content,
  });
}

enum FladStepperOrientation { horizontal, vertical }

class FladStepper extends StatefulWidget {
  final List<FladStepperStep> steps;
  final int initialStep;
  final ValueChanged<int>? onStepChanged;
  final FladStepperOrientation orientation;

  const FladStepper({
    super.key,
    required this.steps,
    this.initialStep = 0,
    this.onStepChanged,
    this.orientation = FladStepperOrientation.horizontal,
  });

  @override
  State<FladStepper> createState() => _FladStepperState();
}

class _FladStepperState extends State<FladStepper> {
  late int _currentStep;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, widget.steps.length - 1);
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.steps.length) return;
    setState(() => _currentStep = index);
    widget.onStepChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladStepperTheme>() ??
        FladStepperTheme.fromScheme(theme.colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.orientation == FladStepperOrientation.vertical
            ? _buildVerticalIndicator(theme, tokens)
            : _buildHorizontalIndicator(theme, tokens),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          child: KeyedSubtree(
            key: ValueKey(_currentStep),
            child: widget.steps[_currentStep].content,
          ),
        ),
        const SizedBox(height: 24),
        _buildNavigation(),
      ],
    );
  }

  Widget _buildHorizontalIndicator(ThemeData theme, FladStepperTheme tokens) {
    return Row(
      children: [
        for (int i = 0; i < widget.steps.length; i++) ...[
          _StepDot(
            index: i,
            step: widget.steps[i],
            isActive: i == _currentStep,
            isCompleted: i < _currentStep,
            tokens: tokens,
            theme: theme,
            onTap: () => _goTo(i),
          ),
          if (i < widget.steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: i < _currentStep
                    ? tokens.completedColor
                    : tokens.connectorColor,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildVerticalIndicator(ThemeData theme, FladStepperTheme tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.steps.length; i++) ...[
          _StepDot(
            index: i,
            step: widget.steps[i],
            isActive: i == _currentStep,
            isCompleted: i < _currentStep,
            tokens: tokens,
            theme: theme,
            onTap: () => _goTo(i),
          ),
          if (i < widget.steps.length - 1)
            Container(
              width: 2,
              height: 24,
              margin: const EdgeInsets.only(left: 15),
              color: i < _currentStep
                  ? tokens.completedColor
                  : tokens.connectorColor,
            ),
        ],
      ],
    );
  }

  Widget _buildNavigation() {
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == widget.steps.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: isFirst ? null : () => _goTo(_currentStep - 1),
          child: const Text('Back'),
        ),
        FilledButton(
          onPressed: isLast ? null : () => _goTo(_currentStep + 1),
          child: Text(isLast ? 'Finish' : 'Next'),
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final FladStepperStep step;
  final bool isActive;
  final bool isCompleted;
  final FladStepperTheme tokens;
  final ThemeData theme;
  final VoidCallback onTap;

  const _StepDot({
    required this.index,
    required this.step,
    required this.isActive,
    required this.isCompleted,
    required this.tokens,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isCompleted
        ? tokens.completedColor
        : isActive
            ? tokens.activeColor
            : tokens.inactiveColor;
    final fgColor =
        isActive || isCompleted ? theme.colorScheme.onPrimary : dotColor;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive || isCompleted ? dotColor : null,
              shape: BoxShape.circle,
              border: Border.all(color: dotColor, width: 2),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, size: 16, color: fgColor)
                  : Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: fgColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive ? tokens.activeColor : tokens.labelColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (step.subtitle != null)
            Text(
              step.subtitle!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: tokens.sublabelColor,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}
''';
