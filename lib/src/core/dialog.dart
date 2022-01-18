import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xdialog/src/core/result.dart';
import 'core_dialog.dart';

//顶层常量 Material Design设计
//https://material.io/components/dialogs/#full-screen-dialog

//整个Dialog的最大宽度
const double _dialogMaxWidth = 320;

//整个Dialog内容的左右边距
const double leftMargin = 24;
const double rightMargin = 24;
const double checkboxPromptMargin = 16;
const double titleTopMargin = 20; //title距顶部的间距
const double titleWithContentMargin = 20; //title和Content之间的间隔
const double listItemContentMargin = 32; //在ListDialog中 item中 checkBox和Text的间隔
const double contentWithActionButtonMargin = 20; //中间内容和ActionButton的间隔
const double contentWithCheckBoxMargin = 20; //中间内容和CheckBox的间隔
const double titleTextSize = 20; //title 字体大小
const double contentTextSize = 16; //中心内容 文字的大小
const double actionButtonTextSize = 16; //ActionButton 文字大小
const double actionButtonHeight = 36; //ActionButton按钮的高度
const double actionButtonHMargin = 8; //ActionButton之间水平间隔
const double actionButtonVMargin = 12; //ActionButton之间的竖直间隔
const double minBottomMargin = 8;

///用于Dialog中ActionButton的回调
typedef ActionListener = void Function(bool isPositiveClick, bool checkBoxIsSelect);

//用于控制其显示位置
enum Gravity { top, center, bottom ,start,end}

///基础的Dialog 其拥有StatefulWidget控件的生命周期
///同时也有对应setState函数和构建选项
///但其并不是[StatefulWidget]控件的子类，仅仅只是一个普通类
///另外 如果用户想实现自定义中心内容,可以继承该类并实现相关方法
abstract class BaseDialog extends LiveCycleCallback {
  final String? titleText; //标题文字
  final TextStyle? titleStyle;
  final Widget? titleIcon; //Title对应的Icon
  final Gravity titleGravity;// 只支持 start 、end、center
  final bool reverseTitleIcon;//是否倒序title和titleIcon 默认为icon在前(如果有icon的话)

  final String? positive; //确定按钮的文字
  final String? negative; //取消按钮的文字
  final Color negativeColor;
  final Color positiveColor;
  final Widget? positiveWidget;
  final Widget? negativeWidget;

  final bool reverseActionButton; //是否反转negativeButton和PositiveButton的按钮的顺序；默认为negative在前面
  final Gravity actionGravity;//只支持 end center;

  //复选框提示(在Content之下 actionButton按钮之上)
  final String? promptText;
  final TextStyle? promptStyle;
  final bool promptInitValue; //底部CheckBox的初始值
  final ValueChanged<bool>? promptCallback; //CheckBox选择框改变提示

  //Dialog动画构建者，可以更改该参数实现不同的动画效果
  final RouteTransitionsBuilder? animation;

  //dialog圆角
  final double cornerRadius;

  //Dialog在屏幕上的位置(永远都不为空)
  final Gravity gravity;

  //背景颜色
  final Color backgroundColor;

  //遮罩层颜色
  final Color maskColor;

  //是否自动退出
  final bool autoCancel;

  //按 返回键能否退出 true 能 false 不能
  final bool breakCancel;

  //能否点击外部退出
  final bool outCanCancel;

  //动画时间
  final Duration animationDuration;

  BaseDialog({
    this.titleText,
    this.titleStyle,
    this.titleIcon,
    this.reverseTitleIcon=false,
    this.titleGravity=Gravity.center,

    this.promptText,
    this.promptStyle,
    this.promptInitValue=false,
    this.promptCallback,

    this.positive,
    this.negative,
    this.positiveColor = const Color(0xFF1E88E5),
    this.negativeColor = Colors.grey,
    this.positiveWidget,
    this.negativeWidget,
    this.actionGravity=Gravity.center,
    this.reverseActionButton = false,

    this.animation,
    this.animationDuration = const Duration(milliseconds: 300),
    this.cornerRadius = 8,
    this.autoCancel = true,
    this.breakCancel = true,
    this.outCanCancel = true,

    this.backgroundColor = Colors.white,
    this.maskColor = Colors.black54,
    this.gravity = Gravity.center,
  });

  ///构建Dialog弹出动画
  static Widget buildDialogTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }

  //返回中间内容的间隔如果返回值为空则使用原始值
  EdgeInsetsGeometry? obtainContentPadding() {
    return null;
  }

  @mustCallSuper
  void setState([VoidCallback? fn]) {
    if (stateUpdateCallback == null) {
      print("尝试更新状态，但 StateUpdateCallback 为空");
      return;
    }
    if (fn != null) {
      stateUpdateCallback!.call(fn);
    } else {
      stateUpdateCallback!.call(() {});
    }
  }

  ///返回dialog的最大高度,该方法决定了Dialog整体的高度
  ///默认为（屏幕高度-状态栏高度）*0.8
  double obtainDialogMaxHeight(BuildContext context) {
    MediaQueryData data = MediaQuery.of(context);
    Size size = data.size;
    return (size.height - data.padding.top) * 0.8;
  }

  ///返回dialog的最大宽度 该方法决定了Dialog整体的宽度
  double obtainDialogMaxWidth(BuildContext context) {
    if (gravity == Gravity.bottom) {
      Size size = MediaQuery.of(context).size;
      return size.width;
    }
    return _dialogMaxWidth;
  }

  ///该方法返回中间内容的最大宽度，已经去除掉了水平padding的影响
  ///该方法决定的是Dialog中心内容的宽度
  double obtainContentMaxWidth(BuildContext context) {
    EdgeInsetsGeometry? padding = obtainContentPadding();
    padding ??= const EdgeInsets.only(left: leftMargin, right: rightMargin);
    return obtainDialogMaxWidth(context) - padding.horizontal;
  }

  ///子类通过复写该方法实现操作数据的传递
  ///该方法只会在 用户主动点击积极/消极按钮且autoCancel=true 时才会被调用
  ///参数 isPositionButton 标识用户点击的是哪个按钮，从而实现不同按钮返回不同的数据
  Result? operationResult(bool isPositiveButton) {
    return null;
  }

  //隐藏软键盘
  void dismissKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
