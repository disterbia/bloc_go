import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportWidget extends StatelessWidget {
  bool isChat;
  ReportWidget(this.isChat);
  void _showReportModal(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text('신고하기'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text('잘못된 정보'),
                onPressed: () => _showAlert(context, '잘못된 정보'),
              ),
              CupertinoActionSheetAction(
                child: Text('상업적 광고'),
                onPressed: () => _showAlert(context, '상업적 광고'),
              ),
              CupertinoActionSheetAction(
                child: Text('음란물'),
                onPressed: () => _showAlert(context, '음란물'),
              ),
              CupertinoActionSheetAction(
                child: Text('폭력성'),
                onPressed: () => _showAlert(context, '폭력성'),
              ),
              CupertinoActionSheetAction(
                child: Text('기타'),
                onPressed: () => _showAlert(context, '기타'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text('취소'),
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              },
            ),
          );
        });
  }

  void _showAlert(BuildContext context, String reportType) {
    Navigator.pop(context);
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('신고 완료'),
          content: Text('$reportType에 대한 신고가 완료되었습니다.\n검토까지 최대 24시간이 소요 될 수 있습니다.'),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Center(
        child: CupertinoButton(
          onPressed: () => _showReportModal(context),
          child: Text('신고',style: TextStyle(fontSize: isChat?12.sp:12.sp,color: Colors.red.shade200),),
        ),
      );
  }
}