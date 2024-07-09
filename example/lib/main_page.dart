import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_builder_wrapper_example/routes.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetBuilder Demo'),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Get.toNamed(RouteName.normal);
            },
            title: const Text('普通页面'),
          ),
          const Divider(indent: 16),
          ListTile(
            onTap: () {
              Get.toNamed(RouteName.list);
            },
            title: const Text('列表页面'),
          )
        ],
      ),
    );
  }
}
