import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommand.dart';

var trigger = 1.obs;
var trigger2 = 1.obs;
MvcCommand<MvcCommandSingleParam<String>, void> command =
    MvcCommand<MvcCommandSingleParam<String>, void>.async(
  func: func,
  params: MvcCommandSingleParam("World!!!"),
  triggers: [
    trigger,
    trigger2,
  ],
  useCallStack: true,
);
void main() {
  Worker w = ever<MvcCommandResult>(command, (c) {
    String handleResult = c.handleStatus(
      onReady: (commandResult) => "very muchready",
      onExecuting: (commandResult) => "very much executing",
      onCompleted: (commandResult) => "finally completed",
    );
    print("Command status: $handleResult");
  });
  print("${trigger++}");
  Future.delayed(3.seconds, () {
    print("${trigger2++}");
  });
  Future.delayed(2.seconds, () {
    command.execute(MvcCommandSingleParam("Piotr!!!"));
  });
  print("${trigger++}");
}

Future<void> func(MvcCommandSingleParam<String> param) async {
  await Future.delayed(2.seconds, () {
    print("Hello, ${param.value}!");
  });
}
