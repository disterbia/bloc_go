import 'package:cached_network_image/cached_network_image.dart';
import 'package:DTalk/app/bloc/chat_bloc.dart';
import 'package:DTalk/app/bloc/user_profile_bloc.dart';
import 'package:DTalk/app/bloc/user_video_bloc.dart';
import 'package:DTalk/app/bloc/video_upload_bloc.dart';
import 'package:DTalk/app/model/video_stream.dart';
import 'package:DTalk/app/router/custom_go_router.dart';
import 'package:DTalk/app/view/home_page.dart';
import 'package:DTalk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserProfile extends StatelessWidget {
  VideoStream video;
  UserProfile(this.video);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          video.userInfo.id,overflow: TextOverflow.fade,
          style: TextStyle(color: Colors.black,),
        ),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () =>context.pop(),
        // ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            _buildProfileHeader(),
            SizedBox(height: 16),
            _buildProfileStats(),
            SizedBox(height: 16),
            _buildProfileBio(context),
            SizedBox(height: 16),
            _buildProfileTabs(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        video.userInfo.image==""?CircleAvatar(
          backgroundImage: AssetImage("assets/logo.png"),
          backgroundColor: Colors.black,
          radius: 50,
        ):
        CircleAvatar(
          backgroundImage: NetworkImage(video.userInfo.image),
          radius: 50,
        ),
        SizedBox(height: 8),
        Text(
          'Your Name',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        SizedBox(height: 4),
        Text(video.userInfo.id),
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
    return video.userInfo.id == UserID.uid
        ? ElevatedButton(
                onPressed: () async {
                  context.push(MyRoutes.VIDEOUPLOAD);
                  context.read<VideoUploadBloc>().add(PickVideoEvent());
                  print("-=-=-=-=-=-=");
                },
                child: Text("동영상 업로드"))
        : Container(
          child: ElevatedButton(
              onPressed: null,
              child: Text("팔로우(아직)")),
        );
    ;
  }

  Widget _buildProfileTabs(BuildContext context) {
    return    BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoadingState)
            return Center(
              child: CircularProgressIndicator(),
            );
          return GridView.builder(
            itemCount: state.userVideos!.length,
             physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2, // 이 줄을 추가하세요.
                crossAxisSpacing: 2, // 이 줄을 추가하세요.
                childAspectRatio:
                VideoAspectRatio.aspectRatio! * 1.5),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  context.read<UserVideoBloc>().add(LoadVideoEvent(
                      currentIndex: index,
                      userVideo: state.userVideos));
                  context.read<ChatBloc>().add(InitialUserChatEvent(video.userInfo.id,index));
                  context.push(MyRoutes.USERVIDEO, extra: index);
                },
                child: CachedNetworkImage(
                  imageUrl: state.userVideos![index].thumbnail,
                  fit: BoxFit.fill,
                ),
              );
            },
          );
        });
  }
}
