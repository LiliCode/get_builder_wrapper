import 'package:get/get.dart';
import 'package:getx_builder_wrapper_example/list_page.dart';
import 'package:getx_builder_wrapper_example/main_page.dart';

abstract class RouteName {
  static String initialRoute = '/';
  static String normal = '/normal';
  static String list = '/list';
}

abstract class RouteTable {
  static List<GetPage<dynamic>> routes = [
    GetPage(name: RouteName.initialRoute, page: () => const MainPage()),
    GetPage(
      name: RouteName.normal,
      page: () => const NormalPage(),
      binding: BindingsBuilder.put(() => NormalController()),
    ),
    GetPage(
      name: RouteName.list,
      page: () => const ListPage(),
      binding: BindingsBuilder.put(() => ListController()),
    ),
  ];
}
