import 'package:flutter/material.dart';
import 'package:toldya/helper/theme.dart';

/// Reusable settings card container (dark neon / grouped layout).
class CustomSettingsCard extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final TextStyle? titleTextStyle;
  final List<Widget> children;

  final EdgeInsetsGeometry padding;
  final double verticalGap;
  final bool addTopDivider;

  const CustomSettingsCard({
    super.key,
    this.title,
    this.titleWidget,
    this.titleTextStyle,
    required this.children,
    this.padding = const EdgeInsets.all(MockupDesign.cardPadding),
    this.verticalGap = 12,
    this.addTopDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTitleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: MockupDesign.textPrimary,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MockupDesign.card,
        borderRadius: BorderRadius.circular(MockupDesign.cardRadius),
        border: Border.all(color: MockupDesign.cardBorder),
        boxShadow: MockupDesign.cardShadow,
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (addTopDivider) const Divider(height: 0),
          if (titleWidget != null || title != null) ...[
            if (titleWidget != null)
              titleWidget!
            else
              Text(
                title ?? '',
                style: titleTextStyle ?? defaultTitleStyle,
              ),
            SizedBox(height: verticalGap),
          ],
          ..._withGaps(children, verticalGap),
        ],
      ),
    );
  }

  List<Widget> _withGaps(List<Widget> widgets, double gap) {
    if (widgets.isEmpty) return const <Widget>[];
    if (gap <= 0) return widgets;
    final out = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      out.add(widgets[i]);
      if (i != widgets.length - 1) out.add(SizedBox(height: gap));
    }
    return out;
  }
}

