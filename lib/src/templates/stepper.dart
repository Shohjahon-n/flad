/// Template for the Stepper component source file.
const stepperTemplate = '''
import 'package:flutter/material.dart';

enum FladStepperOrientation { horizontal, vertical }

enum FladStepStatus { completed, active, upcoming }

@immutable
class FladStepperTheme extends ThemeExtension<FladStepperTheme> {
  final Color completedColor;
  final Color activeColor;
  final Color upcomingColor;
  final Color completedTextColor;
  final Color activeTextColor;
  final Color upcomingTextColor;
  final Color connectorColor;
  final Color completedConnectorColor;
  final double indicatorSize;
  final double connectorThickness;

  const FladStepperTheme({
    required this.completedColor,
    required this.activeColor,
    required this.upcomingColor,
    required this.completedTextColor,
    required this.activeTextColor,
    required this.upcomingTextColor,
    required this.connectorColor,
    required this.completedConnectorColor,
    required this.indicatorSize,
    required this.connectorThickness,
  });

  factory FladStepperTheme.fromScheme(ColorScheme scheme) {
    return FladStepperTheme(
      completedColor: scheme.primary,
      activeColor: scheme.primary,
      upcomingColor: scheme.outlineVariant,
      completedTextColor: scheme.onPrimary,
      activeTextColor: scheme.onPrimary,
      upcomingTextColor: scheme.onSurfaceVariant,
      connectorColor: scheme.outlineVariant,
      completedConnectorColor: scheme.primary,
      indicatorSize: 32,
      connectorThickness: 2,
    );
  }

  @override
  FladStepperTheme copyWith({
    Color? completedColor,
    Color? activeColor,
    Color? upcomingColor,
    Color? completedTextColor,
    Color? activeTextColor,
    Color? upcomingTextColor,
    Color? connectorColor,
    Color? completedConnectorColor,
    double? indicatorSize,
    double? connectorThickness,
  }) {
    return FladStepperTheme(
      completedColor: completedColor ?? this.completedColor,
      activeColor: activeColor ?? this.activeColor,
      upcomingColor: upcomingColor ?? this.upcomingColor,
      completedTextColor: completedTextColor ?? this.completedTextColor,
      activeTextColor: activeTextColor ?? this.activeTextColor,
      upcomingTextColor: upcomingTextColor ?? this.upcomingTextColor,
      connectorColor: connectorColor ?? this.connectorColor,
      completedConnectorColor:
          completedConnectorColor ?? this.completedConnectorColor,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      connectorThickness: connectorThickness ?? this.connectorThickness,
    );
  }

  @override
  FladStepperTheme lerp(ThemeExtension<FladStepperTheme>? other, double t) {
    if (other is! FladStepperTheme) return this;
    return FladStepperTheme(
      completedColor: Color.lerp(completedColor, other.completedColor, t)!,
      activeColor: Color.lerp(activeColor, other.activeColor, t)!,
      upcomingColor: Color.lerp(upcomingColor, other.upcomingColor, t)!,
      completedTextColor:
          Color.lerp(completedTextColor, other.completedTextColor, t)!,
      activeTextColor:
          Color.lerp(activeTextColor, other.activeTextColor, t)!,
      upcomingTextColor:
          Color.lerp(upcomingTextColor, other.upcomingTextColor, t)!,
      connectorColor: Color.lerp(connectorColor, other.connectorColor, t)!,
      completedConnectorColor:
          Color.lerp(completedConnectorColor, other.completedConnectorColor, t)!,
      indicatorSize:
          indicatorSize + (other.indicatorSize - indicatorSize) * t,
      connectorThickness:
          connectorThickness + (other.connectorThickness - connectorThickness) * t,
    );
  }
}

class FladStepData {
  final String label;
  final String? subtitle;
  final IconData? icon;

  const FladStepData({
    required this.label,
    this.subtitle,
    this.icon,
  });
}

class FladStepper extends StatelessWidget {
  final List<FladStepData> steps;
  final int currentStep;
  final FladStepperOrientation orientation;
  final ValueChanged<int>? onStepTapped;

  const FladStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.orientation = FladStepperOrientation.horizontal,
    this.onStepTapped,
  });

  FladStepStatus _statusFor(int index) {
    if (index < currentStep) return FladStepStatus.completed;
    if (index == currentStep) return FladStepStatus.active;
    return FladStepStatus.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladStepperTheme>() ??
        FladStepperTheme.fromScheme(theme.colorScheme);

    if (orientation == FladStepperOrientation.vertical) {
      return _buildVertical(tokens);
    }
    return _buildHorizontal(tokens);
  }

  Widget _buildHorizontal(FladStepperTheme tokens) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final beforeIndex = i ~/ 2;
          final isCompleted = beforeIndex < currentStep;
          return Expanded(
            child: Container(
              height: tokens.connectorThickness,
              color: isCompleted
                  ? tokens.completedConnectorColor
                  : tokens.connectorColor,
            ),
          );
        }
        final index = i ~/ 2;
        return _FladStepIndicator(
          index: index,
          data: steps[index],
          status: _statusFor(index),
          tokens: tokens,
          onTap: onStepTapped != null ? () => onStepTapped!(index) : null,
          orientation: FladStepperOrientation.horizontal,
        );
      }),
    );
  }

  Widget _buildVertical(FladStepperTheme tokens) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final beforeIndex = i ~/ 2;
          final isCompleted = beforeIndex < currentStep;
          return Container(
            width: tokens.connectorThickness,
            height: 24,
            color: isCompleted
                ? tokens.completedConnectorColor
                : tokens.connectorColor,
          );
        }
        final index = i ~/ 2;
        return _FladStepIndicator(
          index: index,
          data: steps[index],
          status: _statusFor(index),
          tokens: tokens,
          onTap: onStepTapped != null ? () => onStepTapped!(index) : null,
          orientation: FladStepperOrientation.vertical,
        );
      }),
    );
  }
}

class _FladStepIndicator extends StatelessWidget {
  final int index;
  final FladStepData data;
  final FladStepStatus status;
  final FladStepperTheme tokens;
  final VoidCallback? onTap;
  final FladStepperOrientation orientation;

  const _FladStepIndicator({
    required this.index,
    required this.data,
    required this.status,
    required this.tokens,
    required this.orientation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case FladStepStatus.completed:
        bgColor = tokens.completedColor;
        textColor = tokens.completedTextColor;
        break;
      case FladStepStatus.active:
        bgColor = tokens.activeColor;
        textColor = tokens.activeTextColor;
        break;
      case FladStepStatus.upcoming:
        bgColor = tokens.upcomingColor;
        textColor = tokens.upcomingTextColor;
        break;
    }

    final indicator = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: tokens.indicatorSize,
        height: tokens.indicatorSize,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: status == FladStepStatus.completed
            ? Icon(
                data.icon ?? Icons.check,
                size: tokens.indicatorSize * 0.5,
                color: textColor,
              )
            : Text(
                '\${index + 1}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: tokens.indicatorSize * 0.4,
                ),
              ),
      ),
    );

    if (orientation == FladStepperOrientation.vertical) {
      return Row(
        children: [
          indicator,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: status == FladStepStatus.upcoming
                        ? tokens.upcomingTextColor
                        : tokens.activeColor,
                  ),
                ),
                if (data.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: tokens.upcomingTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(height: 6),
        Text(
          data.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: status == FladStepStatus.upcoming
                ? tokens.upcomingTextColor
                : tokens.activeColor,
          ),
          textAlign: TextAlign.center,
        ),
        if (data.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            data.subtitle!,
            style: TextStyle(
              fontSize: 10,
              color: tokens.upcomingTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
''';
