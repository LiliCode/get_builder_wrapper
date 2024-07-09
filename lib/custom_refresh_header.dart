import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// 复制了 pull_to_refresh 组件的经典下拉刷新组件代码，修改了一些东西，加入了下拉震动反馈
///
// /// direction that icon should place to the text
// enum IconPosition { left, right, top, bottom }

// /// wrap child in outside,mostly use in add background color and padding
// typedef Widget OuterBuilder(Widget child);

///the most common indicator,combine with a text and a icon
///
/// See also:
///
/// [ClassicFooter]
class CustomClassicHeader extends RefreshIndicator {
  /// a builder for re wrap child,If you need to change the boxExtent or background,padding etc.you need outerBuilder to reWrap child
  /// example:
  /// ```dart
  /// outerBuilder:(child){
  ///    return Container(
  ///       color:Colors.red,
  ///       child:child
  ///    );
  /// }
  /// ````
  /// In this example,it will help to add backgroundColor in indicator
  final OuterBuilder? outerBuilder;
  final String? releaseText,
      idleText,
      refreshingText,
      completeText,
      failedText,
      canTwoLevelText;
  final Widget? releaseIcon,
      idleIcon,
      refreshingIcon,
      completeIcon,
      failedIcon,
      canTwoLevelIcon,
      twoLevelView;

  /// icon and text middle margin
  final double spacing;
  final IconPosition iconPos;

  final TextStyle textStyle;

  /// 开启线性马达震动反馈
  final bool? enableFeedback;

  const CustomClassicHeader({
    Key? key,
    RefreshStyle refreshStyle = RefreshStyle.Follow,
    double height = 50.0,
    Duration completeDuration = const Duration(milliseconds: 600),
    this.outerBuilder,
    this.textStyle = const TextStyle(color: Colors.grey),
    this.releaseText,
    this.refreshingText,
    this.canTwoLevelIcon,
    this.twoLevelView,
    this.canTwoLevelText,
    this.completeText,
    this.failedText,
    this.idleText,
    this.iconPos = IconPosition.left,
    this.spacing = 15.0,
    this.refreshingIcon = const CupertinoActivityIndicator(animating: true),
    this.failedIcon = const Icon(Icons.error, color: Colors.grey),
    this.completeIcon = const Icon(Icons.done, color: Colors.grey),
    this.idleIcon = const Icon(Icons.arrow_downward, color: Colors.grey),
    this.releaseIcon = const Icon(Icons.arrow_upward, color: Colors.grey),
    this.enableFeedback = true,
  }) : super(
          key: key,
          refreshStyle: refreshStyle,
          completeDuration: completeDuration,
          height: height,
        );

  @override
  State<CustomClassicHeader> createState() => _CustomClassicHeaderState();
}

class _CustomClassicHeaderState
    extends RefreshIndicatorState<CustomClassicHeader> {
  RefreshStatus? oldStatus;

  Widget _buildText(mode) {
    RefreshString strings =
        RefreshLocalizations.of(context)?.currentLocalization ??
            EnRefreshString();
    return Text(
        mode == RefreshStatus.canRefresh
            ? widget.releaseText ?? strings.canRefreshText!
            : mode == RefreshStatus.completed
                ? widget.completeText ?? strings.refreshCompleteText!
                : mode == RefreshStatus.failed
                    ? widget.failedText ?? strings.refreshFailedText!
                    : mode == RefreshStatus.refreshing
                        ? widget.refreshingText ?? strings.refreshingText!
                        : mode == RefreshStatus.idle
                            ? widget.idleText ?? strings.idleRefreshText!
                            : mode == RefreshStatus.canTwoLevel
                                ? widget.canTwoLevelText ??
                                    strings.canTwoLevelText!
                                : "",
        style: widget.textStyle);
  }

  Widget _buildIcon(mode) {
    Widget? icon = mode == RefreshStatus.canRefresh
        ? widget.releaseIcon
        : mode == RefreshStatus.idle
            ? widget.idleIcon
            : mode == RefreshStatus.completed
                ? widget.completeIcon
                : mode == RefreshStatus.failed
                    ? widget.failedIcon
                    : mode == RefreshStatus.canTwoLevel
                        ? widget.canTwoLevelIcon
                        : mode == RefreshStatus.canTwoLevel
                            ? widget.canTwoLevelIcon
                            : mode == RefreshStatus.refreshing
                                ? widget.refreshingIcon ??
                                    SizedBox(
                                      width: 25.0,
                                      height: 25.0,
                                      child: defaultTargetPlatform ==
                                              TargetPlatform.iOS
                                          ? const CupertinoActivityIndicator()
                                          : const CircularProgressIndicator(
                                              strokeWidth: 2.0),
                                    )
                                : widget.twoLevelView;
    return icon ?? Container();
  }

  @override
  bool needReverseAll() => false;

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    if (true == widget.enableFeedback &&
        (RefreshStatus.canRefresh == mode ||
            (RefreshStatus.canTwoLevel == mode &&
                RefreshStatus.canTwoLevel != oldStatus))) {
      // 线性马达震动反馈（中度）
      HapticFeedback.mediumImpact();
    }

    // 保存当前状态
    oldStatus = mode;

    Widget textWidget = _buildText(mode);
    Widget iconWidget = _buildIcon(mode);
    List<Widget> children = <Widget>[iconWidget, textWidget];
    final Widget container = Wrap(
      spacing: widget.spacing,
      textDirection: widget.iconPos == IconPosition.left
          ? TextDirection.ltr
          : TextDirection.rtl,
      direction: widget.iconPos == IconPosition.bottom ||
              widget.iconPos == IconPosition.top
          ? Axis.vertical
          : Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      verticalDirection: widget.iconPos == IconPosition.bottom
          ? VerticalDirection.up
          : VerticalDirection.down,
      alignment: WrapAlignment.center,
      children: children,
    );
    return widget.outerBuilder != null
        ? widget.outerBuilder!(container)
        : SizedBox(
            height: widget.height,
            child: Center(child: container),
          );
  }
}

/// 自定义的进入二楼的 header，加入震动反馈
class CustomTwoLevelHeader extends StatelessWidget {
  /// this  attr mostly put image or color
  final BoxDecoration? decoration;

  /// the content in TwoLevel,display in (twoLevelOpening,closing,TwoLeveling state)
  final Widget? twoLevelWidget;

  /// fromTop use with RefreshStyle.Behind,from bottom use with Follow Style
  final TwoLevelDisplayAlignment displayAlignment;
  // the following is the same with ClassicHeader
  final String? releaseText,
      idleText,
      refreshingText,
      completeText,
      failedText,
      canTwoLevelText;

  final Widget? releaseIcon,
      idleIcon,
      refreshingIcon,
      completeIcon,
      failedIcon,
      canTwoLevelIcon;

  /// icon and text middle margin
  final double spacing;
  final IconPosition iconPos;

  final TextStyle textStyle;

  final double height;
  final Duration completeDuration;

  const CustomTwoLevelHeader({
    super.key,
    this.height = 80.0,
    this.decoration,
    this.displayAlignment = TwoLevelDisplayAlignment.fromBottom,
    this.completeDuration = const Duration(milliseconds: 600),
    this.textStyle = const TextStyle(color: Color(0xff555555)),
    this.releaseText,
    this.refreshingText,
    this.canTwoLevelIcon,
    this.canTwoLevelText,
    this.completeText,
    this.failedText,
    this.idleText,
    this.iconPos = IconPosition.left,
    this.spacing = 15.0,
    this.refreshingIcon,
    this.failedIcon = const Icon(Icons.error, color: Colors.grey),
    this.completeIcon = const Icon(Icons.done, color: Colors.grey),
    this.idleIcon = const Icon(Icons.arrow_downward, color: Colors.grey),
    this.releaseIcon = const Icon(Icons.arrow_upward, color: Colors.grey),
    this.twoLevelWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CustomClassicHeader(
      refreshStyle: displayAlignment == TwoLevelDisplayAlignment.fromBottom
          ? RefreshStyle.Follow
          : RefreshStyle.Behind,
      height: height,
      refreshingIcon: refreshingIcon,
      refreshingText: refreshingText,
      releaseIcon: releaseIcon,
      releaseText: releaseText,
      completeDuration: completeDuration,
      canTwoLevelIcon: canTwoLevelIcon,
      canTwoLevelText: canTwoLevelText,
      failedIcon: failedIcon,
      failedText: failedText,
      idleIcon: idleIcon,
      idleText: idleText,
      completeIcon: completeIcon,
      completeText: completeText,
      spacing: spacing,
      textStyle: textStyle,
      iconPos: iconPos,
      outerBuilder: (child) {
        final RefreshStatus? mode =
            SmartRefresher.of(context)!.controller.headerStatus;
        final bool isTwoLevel = (mode == RefreshStatus.twoLevelClosing ||
            mode == RefreshStatus.twoLeveling ||
            mode == RefreshStatus.twoLevelOpening);
        if (displayAlignment == TwoLevelDisplayAlignment.fromBottom) {
          return Container(
            decoration: !isTwoLevel
                ? (decoration ?? const BoxDecoration(color: Colors.redAccent))
                : null,
            height: SmartRefresher.ofState(context)!.viewportExtent,
            alignment: isTwoLevel ? null : Alignment.bottomCenter,
            child: isTwoLevel
                ? twoLevelWidget
                : Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: child,
                  ),
          );
        } else {
          return Container(
            child: isTwoLevel
                ? twoLevelWidget
                : Container(
                    decoration: !isTwoLevel
                        ? (decoration ??
                            const BoxDecoration(color: Colors.redAccent))
                        : null,
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 15),
                    child: child,
                  ),
          );
        }
      },
    );
  }
}
