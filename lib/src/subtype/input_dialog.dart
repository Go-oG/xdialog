import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xdialog/src/core/result.dart';

import '../../xdialog.dart';

class InputDialog extends BaseDialog {
  late final InputBorder border;
  final int? maxLength;
  final bool showMaxLengthTip; //是否显示输入字数
  final bool autoFocus;
  final String hintText;
  final TextStyle hintStyle;
  final TextStyle contentStyle;
  final Color borderColor;
  final InputType inputType;
  final EdgeInsetsGeometry textContentPadding;
  final ValueChanged<String>? onChanged;

  InputDialog(
      {this.contentStyle = const TextStyle(color: Color(0xFFBDBDBD), fontSize: 17),
      this.hintText = "",
      this.hintStyle = const TextStyle(color: Color(0xFF9E9E9E), fontSize: 17),
      this.maxLength,
      this.showMaxLengthTip = false,
      this.autoFocus = false,
      this.textContentPadding = const EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 8),
      this.borderColor = const Color(0xFFBDBDBD),
      this.inputType = InputType.text,
      this.onChanged,
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
            gravity: gravity) {
    border = UnderlineInputBorder(borderSide: BorderSide(color: borderColor));
  }

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Result? operationResult(bool isPositiveButton) {
   return Result(data: _controller.text);
  }

  @override
  Widget buildContentWidget(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 144),
      child: _buildTextWidget(),
    );
  }

  Widget _buildTextWidget() {
    List<TextInputFormatter> list = [];
    if (maxLength != null && !showMaxLengthTip) {
      list.add(LengthLimitingTextInputFormatter(maxLength));
    }
    if (inputType == InputType.phoneNumber) {
      list.add(FilteringTextInputFormatter.digitsOnly);
      list.add(FilteringTextInputFormatter.singleLineFormatter);

    } else if (inputType == InputType.email) {
      String regex = r'[a-zA-Z0-9@.]+';
      list.add(FilteringTextInputFormatter(RegExp(regex), allow: true));
      list.add(FilteringTextInputFormatter.singleLineFormatter);
    }

    InputDecoration inputDecoration = InputDecoration(
        contentPadding: textContentPadding,
        hintText: hintText,
        hintStyle: hintStyle,
        border: border,
        disabledBorder: border,
        focusedBorder: border,
        enabledBorder: border);

    int? maxLength2;
    int? maxLine2;
    if (maxLength != null) {
      maxLength2 = maxLength;
    } else {
      if (showMaxLengthTip) {
        maxLength2 = TextField.noMaxLength;
      }
    }

    if (inputType == InputType.password) {
      maxLine2 = 1;
    }

    return TextField(
        controller: _controller,
        style: contentStyle,
        maxLines: maxLine2,
        maxLength: maxLength2,
        autofocus: autoFocus,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
        textAlignVertical: TextAlignVertical.center,
        onChanged: onChanged,
        obscureText: inputType == InputType.password ? true : false,
        inputFormatters: list,
        decoration: inputDecoration);
  }
}

//文本框的输入类型
enum InputType {
  text,
  email,
  phoneNumber,
  password,
}
