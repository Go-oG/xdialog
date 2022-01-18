import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///一个自定义按钮 支持设置背景颜色和内容间隔
class CustomButton extends StatelessWidget {
  final EdgeInsetsGeometry contentPadding;
  final Widget text;
  final VoidCallback onPressed;
  final Color color;

  const CustomButton(
      {Key? key, this.color = Colors.transparent, required this.text, this.contentPadding = EdgeInsets.zero, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        color: color,
        child: Padding(padding: contentPadding, child: text),
      ),
    );
  }
}
