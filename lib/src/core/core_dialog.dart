import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../xdialog.dart';
import '../custom_button.dart';

///核心的Dialog,通过持有[BaseDialog]进行内容视图的更新和生命周期的回调
class CoreDialog<T extends BaseDialog> extends StatefulWidget {
  @protected
  final T dialog;

  const CoreDialog(this.dialog, {Key? key}) : super(key: key);

  @override
  State createState() {
    return _DialogState();
  }
}

//用于代理 子代相关的
class _DialogState extends State<CoreDialog> {
  late double _maxDialogWidth;
  late double _maxDialogHeight;

  @override
  void initState() {
    super.initState();
    widget.dialog.stateUpdateCallback = (value) {
      setState(value);
    };
    widget.dialog.initState();
  }

  @override
  void didUpdateWidget(CoreDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.dialog.didUpdateWidget(oldWidget);
  }

  @override
  void reassemble() {
    super.reassemble();
    widget.dialog.reassemble();
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.dialog.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    widget.dialog.stateUpdateCallback = null;
    widget.dialog.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.dialog.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    widget.dialog.context = context;
    _maxDialogWidth = widget.dialog.obtainDialogMaxWidth(context);
    _maxDialogHeight = widget.dialog.obtainDialogMaxHeight(context);
    Widget contentWidget = widget.dialog.buildContentWidget(context);
    AlignmentGeometry align = Alignment.center;
    if (widget.dialog.gravity == Gravity.top) {
      align = Alignment.topCenter;
    } else if (widget.dialog.gravity == Gravity.bottom) {
      align = Alignment.bottomCenter;
    }

    return WillPopScope(
      onWillPop: () async {
        return widget.dialog.breakCancel;
      },
      child: Align(
        alignment: align,
        child: Container(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(maxHeight: _maxDialogHeight, maxWidth: _maxDialogWidth, minWidth: _maxDialogWidth),
            //这里嵌套一个Material是因为某些子组件要求上级部件必须包含有Material 组件
            child: Material(
              type: MaterialType.card,
              color: widget.dialog.backgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.dialog.cornerRadius)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: _buildWidgetList(context, contentWidget),
              ),
            )),
      ),
    );
  }

  //构建整个dialog的控件列表
  List<Widget> _buildWidgetList(BuildContext context, Widget? contentWidget) {
    List<Widget> list = [];
    Widget? title = _buildTitle(context);
    if (title != null) {
      list.add(title);
    }

    //  构建ContentWidget并解决像素越界问题
    if (contentWidget != null) {
      EdgeInsetsGeometry? cp = widget.dialog.obtainContentPadding();
      cp ??= const EdgeInsets.only(left: leftMargin, right: rightMargin, top: titleWithContentMargin);
      list.add(Flexible(
          child: Padding(
            padding: cp,
            child: contentWidget,
          ),
          fit: FlexFit.loose));
    }

    //构建checkBoxPrompt
    Widget? promptWidget = _buildPrompt(context);
    if (promptWidget != null) {
      list.add(Padding(
          padding: const EdgeInsets.only(left: checkboxPromptMargin, right: rightMargin, top: contentWithCheckBoxMargin),
          child: promptWidget));
    }

    //构建底部ActionButton
    List<Widget>? actionButtonList = _buildActionWidget();
    if (actionButtonList != null && actionButtonList.isNotEmpty) {
      list.add(const Padding(padding: EdgeInsets.only(top: contentWithActionButtonMargin + minBottomMargin)));
      list.addAll(actionButtonList);
      list.add(const Padding(padding: EdgeInsets.only(bottom: minBottomMargin)));
    }

    return list;
  }

  //Title
  Widget? _buildTitle(BuildContext context) {
    if ((widget.dialog.titleText == null || widget.dialog.titleText!.isEmpty) && widget.dialog.titleIcon == null) {
      return null;
    }

    List<Widget> widgetList = [];
    if (widget.dialog.titleIcon != null) {
      widgetList.add(widget.dialog.titleIcon!);
    }

    bool empty = widget.dialog.titleText == null || widget.dialog.titleText!.isEmpty;
    if (!empty) {
      TextStyle? style = widget.dialog.titleStyle;
      style ??= const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w700);
      Text text = Text(widget.dialog.titleText!, style: style);
      widgetList.add(Expanded(child: text));
    }

    if (widgetList.length == 2) {
      if (widget.dialog.reverseTitleIcon) {
        Widget first = Expanded(child: widgetList.removeAt(1));
        Widget second = Padding(padding: const EdgeInsets.only(left: 16), child: widgetList.removeAt(0));
        widgetList.add(first);
        widgetList.add(second);
      } else {
        Widget second = Expanded(child: Padding(padding: const EdgeInsets.only(left: 16), child: widgetList.removeAt(1)));
        widgetList.add(second);
      }
    }

    MainAxisAlignment alignment;
    if (widget.dialog.titleGravity == Gravity.center) {
      alignment = MainAxisAlignment.center;
    } else if (widget.dialog.titleGravity == Gravity.end) {
      alignment = MainAxisAlignment.end;
    } else {
      alignment = MainAxisAlignment.start;
    }

    return Padding(
        padding: const EdgeInsets.only(top: titleTopMargin, left: leftMargin, right: rightMargin),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: alignment,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgetList,
        ));
  }

  //checkBoxPrompt
  Widget? _buildPrompt(BuildContext context) {
    if (widget.dialog.promptText == null || widget.dialog.promptText!.isEmpty) {
      return null;
    }

    List<Widget> widgetList = [];

    widgetList.add(StatefulBuilder(
      builder: (context, stateSetter) {
        return Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            autofocus: false,
            value: widget.dialog.promptInitValue,
            onChanged: (val) {
              bool check = val ?? false;
              widget.dialog.promptCallback?.call(check);
              setState(() {});
            });
      },
    ));

    TextStyle? style = widget.dialog.promptStyle;
    style ??= const TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.w500);
    widgetList.add(Text(
      widget.dialog.promptText!,
      style: style,
    ));

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgetList,
    );
  }

  //构建底部的ActionButton
  //需要注意当某个文字特别长后的处理
  List<Widget>? _buildActionWidget() {
    bool posIsNull = StringUtil.isEmpty(widget.dialog.positive);
    bool negIsNull = StringUtil.isEmpty(widget.dialog.negative);

    if (posIsNull && negIsNull && widget.dialog.positiveWidget == null && widget.dialog.negativeWidget == null) {
      return null;
    }

    List<Widget> widgetList = [];
    if (widget.dialog.positiveWidget != null) {
      widgetList.add(GestureDetector(
        child: AbsorbPointer(child: widget.dialog.positiveWidget),
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.of(context).pop(widget.dialog.operationResult(true));
        },
      ));
    } else {
      if (widget.dialog.positive != null && widget.dialog.positive!.isNotEmpty) {
        widgetList.add(CustomButton(
          contentPadding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
          onPressed: () {
            Navigator.of(context).pop(widget.dialog.operationResult(true));
          },
          text: Text(widget.dialog.positive!, style: TextStyle(fontSize: actionButtonTextSize, color: widget.dialog.positiveColor)),
        ));
      }
    }

    if (widget.dialog.negativeWidget != null) {
      widgetList.add(GestureDetector(
        child: AbsorbPointer(child: widget.dialog.negativeWidget),
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.of(context).pop(widget.dialog.operationResult(false));
        },
      ));
    } else {
      if (widget.dialog.negative != null && widget.dialog.negative!.isNotEmpty) {
        widgetList.add(CustomButton(
          contentPadding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
          onPressed: () {
            Navigator.of(context).pop(widget.dialog.operationResult(false));
          },
          text: Text(widget.dialog.negative!, style: TextStyle(fontSize: actionButtonTextSize, color: widget.dialog.positiveColor)),
        ));
      }
    }
    //TODO 需要处理文字异常

    EdgeInsetsGeometry buttonContentPadding = const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16);
    int posLength = posIsNull ? 0 : widget.dialog.positive!.length;
    int negLength = negIsNull ? 0 : widget.dialog.negative!.length;
    bool isTooLarge = ((negLength + posLength) * actionButtonTextSize + 80) > _maxDialogWidth * 0.8;
    bool reversButton = widget.dialog.reverseActionButton;
    if (isTooLarge) {
      if (!negIsNull && !posIsNull) {
        if (reversButton) {
          widgetList.add(Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildPositiveButton(buttonContentPadding),
            ),
          ));
          widgetList.add(const Padding(padding: EdgeInsets.only(top: 12, right: 8)));
          widgetList.add(Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildNegativeButton(buttonContentPadding),
            ),
          ));
        } else {
          widgetList.add(Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildNegativeButton(buttonContentPadding),
            ),
          ));
          widgetList.add(const Padding(padding: EdgeInsets.only(top: 12, right: 8)));
          widgetList.add(Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildPositiveButton(buttonContentPadding),
            ),
          ));
        }
      } else if (!negIsNull && posIsNull) {
        widgetList.add(Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildPositiveButton(buttonContentPadding),
          ),
        ));
      } else if (negIsNull && !posIsNull) {
        widgetList.add(Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildNegativeButton(buttonContentPadding),
          ),
        ));
      }
    } else {
      List<Widget> rowList = [];
      if (!negIsNull && !posIsNull) {
        if (reversButton) {
          rowList.add(_buildPositiveButton(buttonContentPadding));
          rowList.add(const Padding(padding: EdgeInsets.only(left: actionButtonHMargin)));
          rowList.add(_buildNegativeButton(buttonContentPadding));
        } else {
          rowList.add(_buildNegativeButton(buttonContentPadding));
          rowList.add(const Padding(padding: EdgeInsets.only(left: actionButtonHMargin)));
          rowList.add(_buildPositiveButton(buttonContentPadding));
        }
      } else if (!posIsNull && negIsNull) {
        rowList.add(_buildPositiveButton(buttonContentPadding));
      } else if (posIsNull && !negIsNull) {
        rowList.add(_buildNegativeButton(buttonContentPadding));
      }
      widgetList.add(Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: actionButtonHMargin),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: rowList,
          ),
        ),
      ));
    }
    return widgetList;
  }

  Widget _buildNegativeButton(EdgeInsetsGeometry buttonContentPadding) {
    return CustomButton(
      contentPadding: buttonContentPadding,
      color: Colors.transparent,
      text: Text(
        widget.dialog.negative ?? '',
        style: TextStyle(fontSize: actionButtonTextSize, color: widget.dialog.negativeColor),
      ),
      onPressed: () {
        dynamic operationResult = widget.dialog.operationResult(false);
        Navigator.of(context).pop(operationResult);
      },
    );
  }

  Widget _buildPositiveButton(EdgeInsetsGeometry buttonContentPadding) {
    return CustomButton(
      contentPadding: buttonContentPadding,
      onPressed: () {
        dynamic operationResult = widget.dialog.operationResult(true);
        Navigator.of(context).pop(operationResult);
      },
      text: Text(widget.dialog.positive ?? '', style: TextStyle(fontSize: actionButtonTextSize, color: widget.dialog.positiveColor)),
    );
  }
}

///用于感知[StatefulWidget]控件的生命周期
@protected
abstract class LiveCycleCallback {
  ///用于实现状态改变通知页面进行刷新，由[_CoreDialog]进行注入
  @protected
  ValueChanged<VoidCallback>? stateUpdateCallback;

  @protected
  late BuildContext context;

  //在构建前调用
  @protected
  @mustCallSuper
  void initState() {}

  @protected
  @mustCallSuper
  void didUpdateWidget(covariant Widget oldWidget) {}

  @protected
  @mustCallSuper
  void reassemble() {}

  @protected
  @mustCallSuper
  void deactivate() {}

  @protected
  @mustCallSuper
  void dispose() {}

  @protected
  @mustCallSuper
  void didChangeDependencies() {}

  ///构建中心内容Widget可以为空
  Widget buildContentWidget(BuildContext context);
}
