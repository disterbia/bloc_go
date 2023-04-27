import 'package:cached_network_image/cached_network_image.dart';
import 'package:eatall/app/bloc/user_profile_bloc.dart';
import 'package:eatall/app/bloc/user_video_bloc.dart';
import 'package:eatall/app/bloc/video_upload_bloc.dart';
import 'package:eatall/app/model/video_stream.dart';
import 'package:eatall/app/router/custom_go_router.dart';
import 'package:eatall/app/view/home_page.dart';
import 'package:eatall/main.dart';
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
          video.userInfo.id,
          style: TextStyle(color: Colors.black),
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
            _buildProfileBio(),
            SizedBox(height: 16),
            _buildProfileTabs(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
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

  Widget _buildProfileBio() {
    return video.userInfo.id == UserID.uid
        ? BlocConsumer<VideoUploadBloc, UploadState>(
            listener: (context, state) {
            if (state.videos != null && state.videoPlayerController != null)
              context.push(MyRoutes.VIDEOUPLOAD);
          }, builder: (context, state) {
            return ElevatedButton(
                onPressed: () async {
                  context.read<VideoUploadBloc>().add(PickVideoEvent());
                  print("-=-=-=-=-=-=");
                },
                child: Text("동영상 업로드"));
          })
        : Container(
          child: ElevatedButton(
              onPressed: () async {
                print("-=-=-=-=-=-=");
              },
              child: Text("팔로우")),
        );
    ;
  }

  Widget _buildProfileTabs() {
    return DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.grey.shade300, width: 1)),
              ),
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(icon: Icon(Icons.grid_on_outlined)),
                  Tab(icon: Icon(Icons.favorite_border_outlined)),
                ],
              ),
            ),
            Container(height: 400,
              child: TabBarView(
                children: [
                  BlocBuilder<UserProfileBloc, UserProfileState>(
                      builder: (context, state) {
                    if (state is UserProfileLoadingState)
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    return GridView.builder(
                      itemCount: state.userVideos!.length,

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
                            context.push(MyRoutes.USERVIDEO, extra: index);
                          },
                          child: CachedNetworkImage(
                            imageUrl: state.userVideos![index].thumbnail,
                            fit: BoxFit.fill,
                          ),
                        );
                      },
                    );
                  }),
                  Center(child: Text('Your liked videos')),
                ],
              ),
            ),
          ],
        ));
  }
}
