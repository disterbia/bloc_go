import 'package:DTalk/app/const/addr.dart';
import 'package:DTalk/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:DTalk/app/bloc/chat_bloc.dart';
import 'package:DTalk/app/bloc/image_bloc.dart';
import 'package:DTalk/app/bloc/mypage_bloc.dart';
import 'package:DTalk/app/bloc/user_video_bloc.dart';
import 'package:DTalk/app/bloc/video_upload_bloc.dart';
import 'package:DTalk/app/router/custom_go_router.dart';
import 'package:DTalk/app/view/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MyPage extends StatefulWidget {
  _MyPageState createState() => _MyPageState();
}
class _MyPageState extends State<MyPage> {
  bool isFirst=true;
  @override
  void initState() {
    super.initState();
  }
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 0),
      child: Container(height: 80.h,decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.grey.shade200,),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 팔로잉 수
                StreamBuilder<int>(
                  stream: followingCountStream(UserID.uid!),
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {

                    if (snapshot.hasData) {
                      return _buildStatItem('Following',snapshot.data!);
                    } else {
                      return _buildStatItem('Following', 0);
                    }
                  },
                ),

// 팔로워 수
                StreamBuilder<int>(
                  stream: followersCountStream(UserID.uid!),
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    if (snapshot.hasData) {
                      return _buildStatItem('Followers', snapshot.data!);
                    } else {
                      return _buildStatItem('Followers', 0);
                    }
                  },
                ),
                StreamBuilder<int>(
                  stream: likesCountStream(UserID.uid!),
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    if (snapshot.hasData) {
                      return _buildStatItem('Likes',snapshot.data!);
                    } else {
                      return _buildStatItem('Likes', 0);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
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
        return ConstrainedBox(constraints: BoxConstraints.tightFor(width: 200.w, height: 60.h),
          child: ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      )
                  )),

                  onPressed: () async{
            context.push(MyRoutes.VIDEOUPLOAD);
            //context.push(MyRoutes.VIDEOTRIM);
            context.read<VideoUploadBloc>().add(PickVideoEvent());
            print("-=-=-=-=-=-=");
          }, child: Text("동영상 업로드")),
        );

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
            context.push(MyRoutes.USERVIDEO,extra: {"index":index, "image":state.mypage!.image});
          },
          child: CachedNetworkImage(
            imageUrl: state.mypage!.videos[index].thumbnail,fit: BoxFit.fill,),
        );
      },
    );
  }
}

Stream<int> followingCountStream(String userId) {
  return FirebaseFirestore.instance
      .collection('followings')
      .doc(userId)
      .snapshots()
      .map((snapshot) => (snapshot.data()?['followingIds'] as List<dynamic> ?? []).length);
}

Stream<int> followersCountStream(String userId) {
  return FirebaseFirestore.instance
      .collection('followers')
      .doc(userId)
      .snapshots()
      .map((snapshot) => (snapshot.data()?['followerIds'] as List<dynamic> ?? []).length);
}

Stream<int> likesCountStream(String userId) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 쿼리를 작성하여 userId가 업로드한 동영상을 찾습니다.
  final Query<Map<String, dynamic>> query =
  firestore.collection('videos').where('uploader', isEqualTo: userId);

  // 쿼리 스냅샷을 스트림으로 가져와 각각의 스냅샷에 대해 좋아요 수를 계산하고 반환합니다.
  return query.snapshots().map((querySnapshot) {
    int totalLikes = 0;

    for (final doc in querySnapshot.docs) {
      int likeCount = doc.data()?['like_count'] ?? 0;
      totalLikes += likeCount;
    }

    return totalLikes;
  });
}