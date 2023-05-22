import 'package:Dtalk/app/bloc/chat_bloc.dart';
import 'package:Dtalk/app/bloc/home_bloc.dart';
import 'package:Dtalk/app/bloc/mypage_bloc.dart';
import 'package:Dtalk/app/bloc/take_video_bloc.dart';
import 'package:Dtalk/app/bloc/video_stream_bloc.dart';
import 'package:Dtalk/app/router/custom_go_router.dart';
import 'package:Dtalk/app/view/mypage.dart';
import 'package:Dtalk/app/view/videostream.dart';
import 'package:Dtalk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  final List _widgetOptions = [
   VideoScreenPage(),
    Container(),
    MyPage()
  ];

// @override
//   void initState() {
//   super.initState();
//   initialization();
//   }
//
//   void initialization()  {
//     context.read<VideoStreamBloc>().add(LoadVideoEvent());
//     context.read<ChatBloc>().add(InitialChatEvent());
//     Future.delayed(Duration(seconds: 2),()=>FlutterNativeSplash.remove());
//
//   }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocBuilder<HomeBloc,int>(
        builder: (context,state) {
          return SafeArea(
            child: Scaffold(backgroundColor: Colors.black,
              body: _widgetOptions.elementAt(state),
              bottomNavigationBar: BottomNavigationBar(backgroundColor:state==2?Colors.white: Color(0xFF272727),
                currentIndex: state,
                onTap: (int index) {
                  if(index==0){
                    context.read<VideoStreamBloc>().add(VideoPlayEvent());
                    context.read<HomeBloc>().add(HomeEvent(index));
                    // setState(() {
                    //   _selectedIndex = index;
                    // });
                  }
                  else if(index==1){
                    context.read<VideoStreamBloc>().add(VideoPauseEvent());
                    if(UserID.uid==null){
                      context.push(MyRoutes.Login);
                    }else{
                      context.read<TakeVideoBloc>().add(InitialEvent(1));
                      context.push(MyRoutes.TAKEVIDEO);
                    }

                  }
                  else if(index==2){
                    context.read<VideoStreamBloc>().add(VideoPauseEvent());
                    if(UserID.uid==null){
                      context.push(MyRoutes.Login);
                    }else{
                      context.read<MyPageBloc>().add(GetMyPageEvent(userId: UserID.uid!));
                      context.read<HomeBloc>().add(HomeEvent(index));
                      // setState(() {
                      //   _selectedIndex = index;
                      // });
                    }
                  }
                },
                type: BottomNavigationBarType.fixed,
                items:  [
                  BottomNavigationBarItem(
                    icon: state==0?Image.asset("assets/img/menu_home_on.png",):Image.asset("assets/img/menu_home_b.png",),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: state==2?Image.asset("assets/img/menu_plus_b.png"):Image.asset("assets/img/menu_plus_w.png"),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: state==2?Image.asset("assets/img/menu_my_on.png",):Image.asset("assets/img/menu_my_w.png"),
                    label: '',
                  ),
                ],
                selectedFontSize: 0,
                showSelectedLabels: false,
                showUnselectedLabels: false,
              ),
            ),
          );
        }
      ),
    );
  }
}
