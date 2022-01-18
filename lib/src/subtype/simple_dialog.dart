import 'package:flutter/material.dart';

import '../../xdialog.dart';

class SimpleDialog extends BaseDialog {
  final String? content;
  TextStyle contentStyle;

  SimpleDialog(
      {this.content,
      this.contentStyle = const TextStyle(color: Color(0xFFBDBDBD), fontSize: 17),
      String? titleText,
      TextStyle? titleStyle,
      Widget? titleIcon,
      bool reverseTitleIcon = false,
      Gravity titleGravity = Gravity.center,
      String? promptText,
      TextStyle? promptStyle,
      bool promptInitValue = false,
      ValueChanged<bool>? promptCallback,
      String? positive,
      String? negative,
      Color positiveColor = const Color(0xFF1E88E5),
      Color negativeColor = Colors.grey,
      Widget? positiveWidget,
      Widget? negativeWidget,
      Gravity actionGravity = Gravity.center,
      bool reverseActionButton = false,
      RouteTransitionsBuilder? animation,
      Duration animationDuration = const Duration(milliseconds: 300),
      double cornerRadius = 8,
      bool autoCancel = true,
      bool breakCancel = true,
      bool outCanCancel = true,
      Color backgroundColor = Colors.white,
      Color maskColor = Colors.black54,
      Gravity gravity = Gravity.center})
      : super(
            titleText: titleText,
            titleStyle: titleStyle,
            titleIcon: titleIcon,
            reverseTitleIcon: reverseTitleIcon,
            titleGravity: titleGravity,
            promptText: promptText,
            promptStyle: promptStyle,
            promptInitValue: promptInitValue,
            promptCallback: promptCallback,
            positive: positive,
            negative: negative,
            positiveColor: positiveColor,
            negativeColor: positiveColor,
            positiveWidget: positiveWidget,
            negativeWidget: negativeWidget,
            actionGravity: actionGravity,
            reverseActionButton: reverseActionButton,
            animation: animation,
            animationDuration: animationDuration,
            cornerRadius: cornerRadius,
            autoCancel: autoCancel,
            breakCancel: breakCancel,
            outCanCancel: outCanCancel,
            backgroundColor: backgroundColor,
            maskColor: maskColor,
            gravity: gravity);

  @override
  Widget buildContentWidget(BuildContext context) {
    if (!StringUtil.isEmpty(content)) {
      return Text(content!, textAlign: TextAlign.start, textDirection: TextDirection.ltr, style: contentStyle);
    }
    return const SizedBox();
  }

}
