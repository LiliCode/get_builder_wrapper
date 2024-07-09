import 'package:get/get.dart';

/// 页面的数据状态
enum DataState { init, loading, success, error }

/// 普通页面使用的控制器
class BaseGetxController extends GetxController {
  // 状态
  var _state = DataState.loading;
  // 获取数据的状态
  DataState get state => _state;

  // 错误状态文字
  String? _errorText;

  String? get errorText => _errorText;

  /// 刷新状态
  ///
  /// [s] 请求数据的状态
  void updateState(DataState s) {
    _state = s;
    update();
  }

  /// 刷新成功的状态
  void updateSuccess() {
    _errorText = null;
    updateState(DataState.success);
  }

  /// 刷新错误的状态
  ///
  /// [text] 可选参数，展示错误消息
  void updateError({String? text}) {
    _errorText = text;
    updateState(DataState.error);
  }

  /// 请求数据
  Future<void> request() async {}

  /// 重试
  Future<void> retry() async {
    print('点击了重试');
    updateState(DataState.loading);
    await request();
  }
}

/// 纯列表使用的控制器
/// [T] 泛型 T 就是数据源每条数据的类型
class BaseListController<T> extends BaseGetxController {
  // 分页
  int _pageCount = 0;
  int get pageIndex => _pageCount;

  // 数据源，请求回来的数据必须添加到这里面去
  final List<T> _dataSource = [];

  List<T> get dataSource => _dataSource;

  /// 设置分页初始值
  void setPageValue(int page) {
    _pageCount = page;
  }

  /// 刷新数据，可以作为下拉刷新
  Future<void> refreshData() async {
    setPageValue(1);
    await requestData(_pageCount);
  }

  /// 列表加载更多数据
  ///
  /// [bool] 使用 .isNotEmpty 返回列表不为空，用于判断是否有更多数据
  Future<bool> loadMoreData() async {
    _pageCount++;
    return await requestData(_pageCount);
  }

  /// 请求数据，子类只需要重写这个方法即可
  ///
  /// [page] 请求列表数据的分页
  /// [bool] 是否存在更多数据
  Future<bool> requestData(int page) async {
    return false;
  }

  @override
  Future<void> retry() async {
    updateState(DataState.loading);
    await refreshData();
  }
}
