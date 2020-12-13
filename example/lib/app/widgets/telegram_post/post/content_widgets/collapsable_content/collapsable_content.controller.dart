import 'package:flutter/widgets.dart';
import 'package:id_mvc_app_framework/framework.dart';

class CollapsablePostContentController extends MvcController {
  double get postMaxWidth => Get.mediaQuery.orientation == Orientation.portrait
      ? Get.width
      : Get.width * 0.8;

  bool _postTextCollapsed = true;
  bool get postTextCollapsed => _postTextCollapsed;
  set postTextCollapsed(bool value) {
    Get.log("postMaxWidth : $postMaxWidth");
    if (value == _postTextCollapsed) return;
    _postTextCollapsed = value;
    update();
  }

  void togglePostText() {
    postTextCollapsed = !postTextCollapsed;
  }
}
