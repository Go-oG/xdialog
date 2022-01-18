import 'package:flutter/material.dart';
import 'package:xdialog/src/core/result.dart';

import '../../xdialog.dart';

typedef ItemBuilder = String Function(int index);

class _ListItemBean {
  final String itemTitle;
  bool isCheck;

  _ListItemBean(this.itemTitle, {this.isCheck = false});
}

///带CheckBox的列表Dialog
///如果有选中的其返回值为: 被选中Item的索引 否则为空
class ListDialog extends BaseDialog {
  final List<_ListItemBean> _list = [];
  final int itemCount;
  final ItemBuilder? itemBuilder;
  final TextStyle itemStyle;
  final Color activeColor;
  final Color checkColor;
  final Color focusColor;

  //checkBox是圆形还是方形
  final bool isRadioButton;
  //是单选还是多选
  final bool singleSelect;

  ListDialog(this.itemCount, this.itemBuilder,
      {this.itemStyle = const TextStyle(color: Colors.black45, fontSize: 17),
      this.activeColor = Colors.grey,
      this.checkColor = Colors.white,
      this.focusColor = Colors.white,
      this.isRadioButton = false,
      this.singleSelect = false,
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
    if (itemBuilder != null && itemCount > 0) {
      for (int i = 0; i < itemCount; i++) {
        _list.add(_ListItemBean(itemBuilder!.call(i), isCheck: false));
      }
    }
  }

  @override
  Result? operationResult(bool isPositiveButton) {
    if (isPositiveButton) {
      if ( _list.isEmpty) {
        return null;
      }
      List<int> resultList = [];
      for (int i = 0; i < _list.length; i++) {
        if (_list[i].isCheck) {
          resultList.add(i);
        }
      }
      return Result(data: resultList);
    } else {
      return null;
    }
  }

  @override
  Widget buildContentWidget(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _list.length,
      padding: const EdgeInsets.only(top: 0, bottom: 8),
      itemBuilder: _buildItem,
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    Widget box;
    if (isRadioButton) {
      box = Radio<bool>(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          autofocus: false,
          groupValue: true,
          focusColor: focusColor,
          activeColor: activeColor,
          value: _list[index].isCheck,
          onChanged: (val) {
            _refreshData(val??false, index, false);
          });
    } else {
      box = Checkbox(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          autofocus: false,
          focusColor: focusColor,
          activeColor: activeColor,
          checkColor: checkColor,
          value: _list[index].isCheck,
          onChanged: (val) {
            _refreshData(val??false, index, true);
          });
    }

    return SizedBox(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          box,
          //避免越界
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: listItemContentMargin),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(_list[index].itemTitle, textAlign: TextAlign.center, maxLines: 1, style: itemStyle),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshData(bool val, int index, bool isCheckBox) {
    if (!isCheckBox) {
      val = !val;
    }
    if (singleSelect) {
      for (int i = 0; i < _list.length; i++) {
        if (i == index) {
          _list[i].isCheck = val;
        } else {
          _list[i].isCheck = false;
        }
      }
    } else {
      _list[index].isCheck = val;
    }
    setState();
  }
}
