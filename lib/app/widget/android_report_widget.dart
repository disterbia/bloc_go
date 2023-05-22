import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AndroidReportWidget extends StatelessWidget {
  bool isChat;
  AndroidReportWidget(this.isChat);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: TextButton(child: Text('신고',style: TextStyle(fontSize: isChat?12.sp:12.sp,color: Colors.red.shade200)),onPressed: ()=>_showReportDialog(context),),
      );
  }

  void _showReportDialog(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.error),
                    title: Text('잘못된 정보'),
                    onTap: () => _showReportCompleteDialog(context,'잘못된 정보'),
                  ),
                  ListTile(
                    leading: Icon(Icons.error),
                    title: Text('상업적 광고'),
                    onTap: () => _showReportCompleteDialog(context,'상업적 광고'),
                  ),
                  ListTile(
                    leading: Icon(Icons.error),
                    title: Text('음란물'),
                    onTap: () => _showReportCompleteDialog(context,'음란물'),
                  ),
                  ListTile(
                    leading: Icon(Icons.error),
                    title: Text('폭력성'),
                    onTap: () => _showReportCompleteDialog(context,'폭력성'),
                  ),
                  ListTile(
                    leading: Icon(Icons.error),
                    title: Text('기타'),
                    onTap: () => _showReportCompleteDialog(context,'기타'),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text('취소'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportCompleteDialog(BuildContext context,String reportType) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('신고 완료'),
          content: Text('$reportType에 대한 신고가 완료되었습니다.\n검토까지 최대 24시간이 소요 될 수 있습니다.'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('확인'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}