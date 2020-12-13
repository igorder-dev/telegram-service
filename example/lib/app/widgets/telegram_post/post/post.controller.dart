import 'package:flutter/widgets.dart';
import 'package:id_mvc_app_framework/framework.dart';

class TelegramPostController extends MvcController {
  /// Returns maxWitdth basing on device orientation
  double get postMaxWidth => Get.mediaQuery.orientation == Orientation.portrait
      ? Get.width
      : Get.width * 0.8;
}
