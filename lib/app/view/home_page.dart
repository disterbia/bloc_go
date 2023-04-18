import 'package:eatall/app/bloc/mypage_bloc.dart';
import 'package:eatall/app/bloc/take_video_bloc.dart';
import 'package:eatall/app/bloc/user_profile_bloc.dart';
import 'package:eatall/app/bloc/video_stream_bloc.dart';
import 'package:eatall/app/router/custom_go_router.dart';
import 'package:eatall/app/view/login_page.dart';
import 'package:eatall/app/view/mypage.dart';
import 'package:eatall/app/view/splash_page.dart';
import 'package:eatall/app/view/video_upload.dart';
import 'package:eatall/app/view/videostream.dart';
import 'package:eatall/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';


class VideoAspectRatio{
  static double? aspectRatio;
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

  void initialization() async {
    context.read<VideoStreamBloc>().add(LoadVideoEvent(page: 0));
    Future.delayed(Duration(seconds: 2),()=> FlutterNativeSplash.remove());
  }

  @override
  Widget build(BuildContext context) {
    VideoAspectRatio.aspectRatio = MediaQuery.of(context).size.width/(MediaQuery.of(context).size.height-MediaQuery.of(context).padding.top-kBottomNavigationBarHeight);
    return SafeArea(
      child: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (int index) {
            if(index==0){
              setState(() {
                _selectedIndex = index;
              });
            }
            else if(index==1){
              if(UserID.uid==null){
                context.push(MyRoutes.Login);
              }else{
                context.read<TakeVideoBloc>().add(InitialEvent());
                context.push(MyRoutes.TAKEVIDEO);
              }

            }
            else if(index==2){
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}
