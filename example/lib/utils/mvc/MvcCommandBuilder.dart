import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';
import 'MvcCommand.dart';

class MvcCommandBuilder<T extends MvcCommand> extends StatelessWidget {
  final T command;
  final MvcCommandWidgetBuilder<T> onReady;
  final MvcCommandWidgetBuilder<T> onCompleted;
  final MvcCommandWidgetBuilder<T> onExecuting;
  final MvcCommandWidgetBuilder<T> onError;
  const MvcCommandBuilder({
    Key key,
    @required this.command,
    this.onReady,
    this.onCompleted,
    this.onExecuting,
    this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () =>
          command.result.handleStatus(
            onReady: (_) => onReady?.call(command),
            onCompleted: (_) => onCompleted?.call(command),
            onExecuting: (_) => onExecuting?.call(command),
            onError: (_) => onError?.call(command),
          ) ??
          Container(),
    );
  }
}

typedef Widget MvcCommandWidgetBuilder<T extends MvcCommand>(T command);
