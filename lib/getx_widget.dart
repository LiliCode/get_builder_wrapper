import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_builder_wrapper/base_controller.dart';
import 'package:getx_builder_wrapper/custom_button.dart';
import 'package:getx_builder_wrapper/custom_refresh_header.dart';
import 'package:getx_builder_wrapper/getx_constant.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 结合了自动加载数据、网络错误、加载动画的一个 widget
class GetBuilderWidget<T extends BaseGetxController> extends StatefulWidget {
  final String? tag;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Color? loadingBackgroundColor; // 加载，背景色
  final Color? errorBackgroundColor; // 错误，背景色
  final VoidCallback? onInit; // init state 初始化
  final VoidCallback? onDispose; // dispose 的回调
  final Widget Function(BuildContext, T) builder;

  const GetBuilderWidget({
    super.key,
    required this.builder,
    this.tag,
    this.loadingWidget,
    this.errorWidget,
    this.loadingBackgroundColor,
    this.errorBackgroundColor,
    this.onInit,
    this.onDispose,
  });

  @override
  State<StatefulWidget> createState() => _GetBuilderWidgetState<T>();
}

class _GetBuilderWidgetState<T extends BaseGetxController>
    extends State<GetBuilderWidget<T>> {
  @override
  void initState() {
    super.initState();

    widget.onInit?.call();
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      tag: widget.tag,
      builder: (controller) {
        if (controller.state == DataState.loading) {
          return widget.loadingWidget ??
              LoadingWidget(color: widget.loadingBackgroundColor);
        } else if (controller.state == DataState.success) {
          return widget.builder(context, controller);
        } else if (controller.state == DataState.error) {
          return widget.errorWidget ??
              ErrorWidget(
                errorMsg: controller.errorText ?? GetxConstant.networkErrorText,
                color: widget.errorBackgroundColor,
                onRetry: () {
                  controller.retry();
                },
              );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// 给列表结合了自动加载数据、网络错误、加载动画的一个 widget
class GetBuilderListWidget<C extends BaseListController>
    extends StatefulWidget {
  final bool enablePullUp; // 开启上拉
  final bool enablePullDown; // 开启下拉
  final String? tag; // tag ，用来获取 controller
  final String? emptyDataText; // 空数据的文字
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final Widget? header; // 刷新视图
  final Widget? footer; // 加载视图
  final Color? loadingBackgroundColor; // 加载，背景色
  final Color? emptyBackgroundColor; // 空数据，背景色
  final Color? errorBackgroundColor; // 错误，背景色
  final VoidCallback? onInit; // init state 初始化
  final VoidCallback? onDispose; // dispose 的回调
  final VoidCallback? onRefresh; // 刷新的回调
  final VoidCallback? onLoading; // 加载更多的回调
  final Widget Function(BuildContext, C) builder;

  const GetBuilderListWidget({
    super.key,
    required this.builder,
    this.tag,
    this.emptyDataText,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.header,
    this.footer,
    this.loadingBackgroundColor,
    this.emptyBackgroundColor,
    this.errorBackgroundColor,
    this.onInit,
    this.onDispose,
    this.onRefresh,
    this.onLoading,
  });

  @override
  State<StatefulWidget> createState() => _GetBuilderListWidgetState<C>();
}

class _GetBuilderListWidgetState<C extends BaseListController>
    extends State<GetBuilderListWidget<C>> {
  // 刷新控制器
  final _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    widget.onInit?.call();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<C>(
      tag: widget.tag,
      builder: (controller) {
        if (controller.state == DataState.loading) {
          return widget.loadingWidget ??
              LoadingWidget(color: widget.loadingBackgroundColor);
        } else if (controller.state == DataState.success) {
          Widget buildContent() {
            // 空数据
            if (controller.dataSource.isEmpty) {
              return widget.emptyWidget ??
                  EmptyDataWidget(
                    label: widget.emptyDataText,
                    color: widget.emptyBackgroundColor,
                  );
            }

            return widget.builder(context, controller);
          }

          if (widget.enablePullDown == false && widget.enablePullUp == false) {
            // 空数据
            return buildContent();
          }

          // 成功，返回一个带刷新的组件
          return RefreshConfiguration(
            headerTriggerDistance: 50,
            child: SmartRefresher(
              controller: _refreshController,
              enablePullUp: widget.enablePullUp,
              enablePullDown: widget.enablePullDown,
              header: widget.header ?? const CustomClassicHeader(),
              footer: widget.footer ??
                  const ClassicFooter(
                    loadingIcon: CupertinoActivityIndicator(animating: true),
                  ),
              onRefresh: () async {
                await controller.refreshData();
                _refreshController.refreshCompleted();
                _refreshController.resetNoData();
                // 执行回调
                widget.onRefresh?.call();
              },
              onLoading: () async {
                final noMoreData = await controller.loadMoreData();
                if (noMoreData) {
                  _refreshController.loadComplete();
                } else {
                  _refreshController.loadNoData();
                }

                // 执行回调
                widget.onLoading?.call();
              },
              child: buildContent(),
            ),
          );
        } else if (controller.state == DataState.error) {
          return widget.errorWidget ??
              ErrorWidget(
                errorMsg: controller.errorText ?? GetxConstant.networkErrorText,
                color: widget.errorBackgroundColor,
                onRetry: () {
                  controller.retry();
                },
              );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// 加载动画
class LoadingWidget extends StatelessWidget {
  final String? label;
  final Color? color;
  final Color? textColor;

  const LoadingWidget({
    super.key,
    this.label,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: color ?? Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(
            animating: true,
          ),
          label != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    label!,
                    style: TextStyle(
                      color: textColor ?? Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

/// 错误提示
class ErrorWidget extends StatelessWidget {
  final String? errorMsg;
  final Color? color;
  final VoidCallback? onRetry;

  const ErrorWidget({super.key, this.errorMsg, this.color, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.white,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMsg ?? GetxConstant.errorText,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          CustomElevatedButton(
            onPressed: onRetry,
            size: const Size(60, 30),
            radius: 30,
            backgroundColor: Colors.red,
            child: const Text(
              GetxConstant.retryText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 空数据占位
class EmptyDataWidget extends StatelessWidget {
  final String? label;
  final Color? color;

  const EmptyDataWidget({super.key, this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
      ),
      child: Text(
        label ?? GetxConstant.emptyDataText,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
      ),
    );
  }
}
