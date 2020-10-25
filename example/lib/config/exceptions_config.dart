import 'package:flutter/widgets.dart';
import 'package:id_mvc_app_framework/exceptions.dart';
import 'package:id_mvc_app_framework/framework.dart';

///Basic implementation of the class describing app level error handling using catcher
///Please see [main.dart] for example
class AppErrorConfig implements ExceptionsHandlingConfig {
  @override
  bool enableLogger = true;

  @override
  bool ensureInitialized = true;

  final CatcherOptions _options =
      CatcherOptions(SilentReportMode(), [ConsoleHandler(), ToastHandler()]);

  @override
  CatcherOptions get debugConfig => _options;

  @override
  GlobalKey<NavigatorState> get navigatorKey => Get.key;

  @override
  CatcherOptions get profileConfig => _options;

  @override
  CatcherOptions get releaseConfig => _options;
}
