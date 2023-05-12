import 'package:DTalk/app/bloc/chat_bloc.dart';
import 'package:DTalk/app/bloc/mypage_bloc.dart';
import 'package:DTalk/app/bloc/take_video_bloc.dart';
import 'package:DTalk/app/bloc/video_stream_bloc.dart';
import 'package:DTalk/app/router/custom_go_router.dart';
import 'package:DTalk/app/view/mypage.dart';
import 'package:DTalk/app/view/videostream.dart';
import 'package:DTalk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';


class VideoAspectRatio{
  static double? aspectRatio;
  static double? aspectRatio2;
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  int _selectedIndex = 0;

  final List _widgetOptions = [
   VideoScreenPage(),
    Container(),
    MyPage()
  ];

@override
  void initState() {
  super.initState();
  initialization();
  }

  void initialization()  {
    context.read<VideoStreamBloc>().add(LoadVideoEvent());
    context.read<ChatBloc>().add(InitialChatEvent());
    Future.delayed(Duration(seconds: 2),()=>FlutterNativeSplash.remove());

  }

  @override
  Widget build(BuildContext context) {
    VideoAspectRatio.aspectRatio = MediaQuery.of(context).size.width/( MediaQuery.of(context).size.height-MediaQuery.of(context).padding.top-kBottomNavigationBarHeight );
    VideoAspectRatio.aspectRatio2 = MediaQuery.of(context).size.width/( MediaQuery.of(context).size.height-MediaQuery.of(context).padding.top);
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(backgroundColor: Colors.black,
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(backgroundColor:_selectedIndex==2?Colors.white: Color(0xFF272727),
            currentIndex: _selectedIndex,
            onTap: (int index) {
              if(index==0){
                context.read<VideoStreamBloc>().add(VideoPlayEvent());
                setState(() {
                  _selectedIndex = index;
                });
              }
              else if(index==1){
                context.read<VideoStreamBloc>().add(VideoPauseEvent());
                if(UserID.uid==null){
                  context.push(MyRoutes.Login);
                }else{
                  context.read<TakeVideoBloc>().add(InitialEvent());
                  context.push(MyRoutes.TAKEVIDEO);
                }

              }
              else if(index==2){
                context.read<VideoStreamBloc>().add(VideoPauseEvent());
                if(UserID.uid==null){
                  context.push(MyRoutes.Login);
                }else{
                  context.read<MyPageBloc>().add(GetMyPageEvent(userId: UserID.uid!));
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              }
            },
            type: BottomNavigationBarType.fixed,
            items:  [
              BottomNavigationBarItem(
                icon: _selectedIndex==0?Image.asset("assets/img/menu_home_on.png",):Image.asset("assets/img/menu_home_b.png",),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _selectedIndex==2?Image.asset("assets/img/menu_plus_b.png"):Image.asset("assets/img/menu_plus_w.png"),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _selectedIndex==2?Image.asset("assets/img/menu_my_on.png",):Image.asset("assets/img/menu_my_w.png"),
                label: '',
              ),
            ],
            selectedFontSize: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
          ),
        ),
      ),
    );
  }
}
