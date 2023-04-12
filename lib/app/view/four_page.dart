

import 'package:flutter/material.dart';

class FourWayPageView extends StatefulWidget {
  @override
  _FourWayPageViewState createState() => _FourWayPageViewState();
}

class _FourWayPageViewState extends State<FourWayPageView> {
  final PageController _horizontalController = PageController(initialPage: 1);
  final PageController _verticalController = PageController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  Widget _buildPage(int horizontalIndex, int verticalIndex) {
    // 각 인덱스에 따라 다른 위젯을 반환하려면 이 로직을 변경하세요.
    Color backgroundColor = Colors.primaries[(horizontalIndex * 3 + verticalIndex) % Colors.primaries.length];

    return Container(
      color: backgroundColor,
      child: Center(
        child: Text(
          '페이지 $horizontalIndex x $verticalIndex',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.custom(
      controller: _horizontalController,
      scrollDirection: Axis.horizontal,
      childrenDelegate: SliverChildBuilderDelegate(
            (BuildContext context, int horizontalIndex) {
          return PageView.custom(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            childrenDelegate: SliverChildBuilderDelegate(
                  (BuildContext context, int verticalIndex) {
                return _buildPage(horizontalIndex, verticalIndex);
              },
              childCount: 3, // 수직 방향 페이지 수
            ),
          );
        },
        childCount: 3, // 수평 방향 페이지 수
      ),
    );
  }
}
