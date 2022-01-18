import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xdialog/src/core/result.dart';
import 'core_dialog.dart';
import 'dialog.dart';

Future<Result?> showXDialog(BuildContext context, BaseDialog dialog) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
      final Widget pageChild = CoreDialog(dialog);
      return pageChild;
    },
    barrierDismissible: dialog.outCanCancel,
    barrierLabel: "",
    barrierColor: dialog.maskColor,
    transitionDuration: dialog.animationDuration,
    transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      if (dialog.animation == null) {
        return BaseDialog.buildDialogTransitions(context, animation, secondaryAnimation, child);
      } else {
        return dialog.animation!.call(context, animation, secondaryAnimation, child);
      }
    },
    useRootNavigator: true,
  );
}
