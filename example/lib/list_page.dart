import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_builder_wrapper/base_controller.dart';
import 'package:getx_builder_wrapper/custom_button.dart';
import 'package:getx_builder_wrapper/getx_widget.dart';

class NormalPage extends StatelessWidget {
  const NormalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('普通页面'),
      ),
      body: GetBuilderWidget<NormalController>(
        builder: (context, controller) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(
                () => Text(
                  'counter = ${controller.counter.value}',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              CustomElevatedButton(
                onPressed: () {
                  controller.counter.value++;
                },
                child: const Text(
                  '自增',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('列表页面'),
      ),
      body: GetBuilderListWidget<ListController>(
        enablePullUp: true,
        builder: (context, controller) => ListView.builder(
          itemCount: controller.dataSource.length,
          itemBuilder: (context, index) => ListTile(
            title: Text('这是一条测试数据: ${controller.dataSource[index]}'),
          ),
        ),
      ),
    );
  }
}

class NormalController extends BaseGetxController {
  final counter = 0.obs;

  @override
  void onReady() {
    super.onReady();

    // 在这里手动掉用一次
    request();
  }

  @override
  Future<void> request() async {
    await Future.delayed(const Duration(seconds: 1));
    counter.value = 2;
    updateSuccess();
    // updateError();
  }
}

class ListController extends BaseListController<int> {
  @override
  void onReady() {
    super.onReady();

    // 在这里手动掉用一次
    refreshData();
  }

  @override
  Future<bool> requestData(int page) async {
    await Future.delayed(const Duration(seconds: 1));
    if (page == 1) {
      dataSource.removeWhere((element) => true);
    }

    // 制作假数据
    final count = dataSource.length;
    for (int i = count; i < (count + 10); i++) {
      dataSource.add(i);
    }

    updateSuccess();

    return true;
  }
}
