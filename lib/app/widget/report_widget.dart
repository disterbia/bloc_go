import 'package:Dtalk/app/bloc/video_stream_bloc.dart';
import 'package:Dtalk/app/router/custom_go_router.dart';
import 'package:Dtalk/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ReportWidget extends StatelessWidget {
  bool isChat;
  int? currentIndex;
  String? blockId;
  ReportWidget(this.isChat, {this.blockId,this.currentIndex});
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

  void _showBlock(BuildContext context) {
    // Navigator.pop(context);
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('경고'),
          content: Text('해당 동영상을 차단하면 더이상 보여지지 않으며 복구 할 수 없습니다. 정말로 차단하시겠습니까?'),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: false,
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('차단'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<VideoStreamBloc>().add(BlockVideoControllers(blockId: blockId!,currentIndex: currentIndex ));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return  !isChat?PopupMenuButton<String>(
      onSelected: (String result) {
        if(UserID.uid==null) context.push(MyRoutes.Login);
        else if(result=="신고") _showReportModal(context);
        else _showBlock(context);
      },
      icon: Image.asset("assets/img/set_w.png",width: 30.w),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
         PopupMenuItem<String>(
          value: '신고',
          child: Container(width: 70.w,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/img/ic_warning.png",width: 30.w),
                Text('신고',),
              ],
            ),
          ),
        ),
         PopupMenuItem<String>(
          value: '차단',
          child: Container(width: 70.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/img/ic_blocking2.png",width: 30.w,),
                Text('차단',style: TextStyle(color: Colors.red),),
              ],
            ),
          ),
        ),
      ],
    ):Center(
        child: CupertinoButton(
          onPressed: () => _showReportModal(context),
          child: Text('신고',style: TextStyle(fontSize: isChat?12.sp:12.sp,color: Colors.red.shade200),),
        ),
      );
  }
}