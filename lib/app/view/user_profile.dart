import 'package:cached_network_image/cached_network_image.dart';
import 'package:eatall/app/bloc/user_profile_bloc.dart';
import 'package:eatall/app/model/video_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
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
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage:NetworkImage(video.userInfo.image), // Replace with your own image
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Hello, this is my TikTok profile bio. I create awesome content!',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildProfileTabs() {
    return DefaultTabController(
      length: 2,
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
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
              SizedBox(
                height: 400,
                child: TabBarView(
                  children: [
                    BlocBuilder<UserProfileBloc,UserProfileState>(
                      builder: (context,state) {
                        if(state is UserProfileLoadingState) return Center(child: CircularProgressIndicator(),);
                        return GridView.builder(
                          itemCount: state.userVideos!.length,
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            print( "---${state.userVideos![index].thumbnail}");
                            return CachedNetworkImage(imageUrl:
                              state.userVideos![index].thumbnail
                            );
                          },
                        );
                      }
                    ),
                    Center(child: Text('Your liked videos')),
                  ],
                ),
              ),
            ],
          )
      );
  }
}