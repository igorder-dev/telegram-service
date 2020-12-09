import 'package:get/get.dart';
import 'package:telegram_service_example/app/screens/entry_screen.dart';
import 'package:telegram_service_example/app/screens/feed_screen/feed_screen.view.dart';
import 'package:telegram_service_example/app/screens/login_screen/login_screen.view.dart';
import 'package:telegram_service_example/app/screens/logout_screen.dart';
import 'package:telegram_service_example/app/screens/main_screen/main_screen.view.dart';

class AppRoutes {
  static const INITIAL = AppRoutes.HOME;
  static const HOME = "/entry";
  static const LOGIN = "/login";
  static const LOGOUT = "/logout";
  static const MAIN = "/main";

  static final routes = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => EntryScreen(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginScreen(),
      maintainState: true,
      transition: Transition.zoom,
    ),
    GetPage(
      name: AppRoutes.LOGOUT,
      page: () => LogOutScreen(),
      transition: Transition.zoom,
    ),
/*     GetPage(
      name: AppRoutes.MAIN,
      page: () => FeedScreen(),
      transition: Transition.zoom,
    ), */
    GetPage(
      name: AppRoutes.MAIN,
      page: () => MainScreen(),
      transition: Transition.zoom,
    ),
  ];
}
