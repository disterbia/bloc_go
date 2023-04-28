import 'package:cached_network_image/cached_network_image.dart';
import 'package:DTalk/app/bloc/chat_bloc.dart';
import 'package:DTalk/app/bloc/image_bloc.dart';
import 'package:DTalk/app/bloc/mypage_bloc.dart';
import 'package:DTalk/app/bloc/user_video_bloc.dart';
import 'package:DTalk/app/bloc/video_upload_bloc.dart';
import 'package:DTalk/app/router/custom_go_router.dart';
import 'package:DTalk/app/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyPageBloc, MyPageState>(
        builder: (context, state) {
      if (state is! MyPageLoadedState)
        return Center(
          child: CircularProgressIndicator(),
        );
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          title: Text(
            state.mypage!.id,
            style: TextStyle(color: Colors.black),
          ),
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back, color: Colors.black),
          //   onPressed: () =>  context.pop(),
          // ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16),
              _buildProfileHeader(context,state),
              SizedBox(height: 16),
              _buildProfileStats(),
              SizedBox(height: 16),
              _buildProfileBio(context),
              SizedBox(height: 16),
              _buildProfileTabs(state,context),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProfileHeader(BuildContext context,MyPageState state) {
    return Column(
      children: [
        InkWell(onTap: (){
           context.read<ImageBloc>().add(ImageUploadEvent());
        },
          child: BlocBuilder<ImageBloc,String>(
            builder: (context,astate) {
              return astate=="a"?CircularProgressIndicator():
              astate==""?state.mypage!.image==""?CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage:AssetImage("assets/logo.png"),
                radius: 50, // Replace with your own image
              ):CircleAvatar(
                backgroundImage:NetworkImage(state.mypage!.image),
                radius: 50, // Replace with your own image
              ):CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage:NetworkImage(astate),
                radius: 50, // Replace with your own image
              );
            }
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Your Name',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        SizedBox(height: 4),
        Text('@your_username'),
      ],
    );
  }

  Widget _buildProfileStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Following', 123),
        _buildStatItem('Followers', 456),
        _buildStatItem('Likes', 789),
      ],
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildProfileBio(BuildContext context) {
        return ElevatedButton(onPressed: () async{
          context.push(MyRoutes.VIDEOUPLOAD);
          context.read<VideoUploadBloc>().add(PickVideoEvent());
          print("-=-=-=-=-=-=");
        }, child: Text("동영상 업로드"));

  }

  Widget _buildProfileTabs(MyPageState state,BuildContext context) {
    return  GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: state.mypage!.videos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: VideoAspectRatio.aspectRatio!*1.5,
      ),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: (){
            context.read<UserVideoBloc>().add(LoadVideoEvent(currentIndex: index,userVideo: state.mypage!.videos));
            context.read<ChatBloc>().add(InitialUserChatEvent(state.mypage!.id,index));
            context.push(MyRoutes.USERVIDEO,extra: index);
          },
          child: CachedNetworkImage(
            imageUrl: state.mypage!.videos[index].thumbnail,fit: BoxFit.fill,),
        );
      },
    );
  }
}
