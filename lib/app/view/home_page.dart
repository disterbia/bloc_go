import 'package:eatall/app/bloc/take_video_bloc.dart';
import 'package:eatall/app/router/custom_go_router.dart';
import 'package:eatall/app/view/login_page.dart';
import 'package:eatall/app/view/mypage.dart';
import 'package:eatall/app/view/video_upload.dart';
import 'package:eatall/app/view/videostream.dart';
import 'package:eatall/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (int index) {
            if(index==1){
              if(UserID.uid==null){
                context.push(MyRoutes.Login);
              }else{
                context.read<TakeVideoBloc>().add(InitialEvent());
                context.push(MyRoutes.TAKEVIDEO);
              }

            }else{
              setState(() {
                _selectedIndex = index;
              });
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
