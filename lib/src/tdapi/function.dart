part of 'tdapi.dart';

// todo: considering setExtra method or like that...
abstract class TdFunction {
  static const CONSTRUCTOR = 'function';
  /// callback sign
  dynamic extra;
  Map<String, dynamic> toJson();
  String getConstructor() => CONSTRUCTOR;
}
