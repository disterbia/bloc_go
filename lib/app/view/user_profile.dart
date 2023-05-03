import 'package:cached_network_image/cached_network_image.dart';
import 'package:DTalk/app/bloc/chat_bloc.dart';
import 'package:DTalk/app/bloc/user_profile_bloc.dart';
import 'package:DTalk/app/bloc/user_video_bloc.dart';
import 'package:DTalk/app/bloc/video_upload_bloc.dart';
import 'package:DTalk/app/model/video_stream.dart';
import 'package:DTalk/app/router/custom_go_router.dart';
import 'package:DTalk/app/view/home_page.dart';
import 'package:DTalk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


class UserProfile extends StatefulWidget {

  VideoStream video;
  UserProfile(this.video);
  @override
  _UserProfileState createState() => _UserProfileState();
}
class _UserProfileState extends State<UserProfile> {
  bool _isFollowing = false;
  bool _preventMultipleTap=false;

  @override
  void initState() {
    super.initState();
    _checkFollowing();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          widget.video.userInfo.id,overflow: TextOverflow.fade,
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
  void _checkFollowing() async {
    if(UserID.uid==null) return;
    bool isFollowingResult = await isFollowing(UserID.uid!, widget.video.uploader); // 'creatorId'를 실제 생성자 ID로 바꾸세요.
    setState(() {
      _isFollowing = isFollowingResult;
    });
  }

  void _toggleFollow() async {
    setState(() {
      _preventMultipleTap=true;
    });
    if (_isFollowing) {
      await unfollow(UserID.uid!, widget.video.uploader); // 'creatorId'를 실제 생성자 ID로 바꾸세요.
    } else {
      await follow(UserID.uid!, widget.video.uploader); // 'creatorId'를 실제 생성자 ID로 바꾸세요.
    }
    setState(() {
      _isFollowing = !_isFollowing;
      _preventMultipleTap=false;
    });
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        widget.video.userInfo.image==""?CircleAvatar(
          backgroundImage: AssetImage("assets/logo.png"),
          backgroundColor: Colors.black,
          radius: 50,
        ):
        CircleAvatar(
          backgroundImage: NetworkImage(widget.video.userInfo.image),
          radius: 50,
        ),
        SizedBox(height: 8),
        Text(
          'Your Name',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        SizedBox(height: 4),
        Text(widget.video.userInfo.id),
      ],
    );
  }

  Widget _buildProfileStats() {

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 팔로잉 수
            StreamBuilder<int>(
              stream: followingCountStream(widget.video.uploader),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                // if (snapshot.hasError) {
                //   return Text('Error: ${snapshot.error}');
                // }
                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return CircularProgressIndicator();
                // }
                if (snapshot.hasData) {
                  return _buildStatItem('Following',snapshot.data!);
                } else {
                  return _buildStatItem('Following', 0);
                }
              },
            ),

// 팔로워 수
            StreamBuilder<int>(
              stream: followersCountStream(widget.video.uploader),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {

                if (snapshot.hasData) {
                  return _buildStatItem('Followers', snapshot.data!);
                } else {
                  return _buildStatItem('Followers', 0);
                }
              },
            ),
            StreamBuilder<int>(
              stream: likesCountStream(widget.video.uploader),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {

                if (snapshot.hasData) {
                  return _buildStatItem('Likes',snapshot.data!);
                } else {
                  return _buildStatItem('Likes', 0);
                }
              },
            ),
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
    return widget.video.userInfo.id == UserID.uid
        ? ElevatedButton(
                onPressed: () async {
                  context.push(MyRoutes.VIDEOUPLOAD);
                  context.read<VideoUploadBloc>().add(PickVideoEvent());
                  print("-=-=-=-=-=-=");
                },
                child: Text("동영상 업로드"))
        : Container(
          child: AbsorbPointer(
            absorbing: _preventMultipleTap,
            child: ElevatedButton(
              onPressed: () => UserID.uid==null?context.push(MyRoutes.Login):_toggleFollow(),
              child: Text(_isFollowing ? 'Unfollow' : 'Follow'),
            ),
          ),
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
                  context.read<ChatBloc>().add(InitialUserChatEvent(widget.video.userInfo.id,index));
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


Future<bool> isFollowing(String userId, String creatorId) async {
  final followingDoc = await FirebaseFirestore.instance.collection('followings').doc(userId).get();
  final followingIds = followingDoc.data()?['followingIds'] as List<dynamic>? ?? [];
  return followingIds.contains(creatorId);
}

Future<void> follow(String userId, String creatorId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 팔로잉 목록에 팔로우 대상 추가
  await firestore.collection('followings').doc(userId).set({
    'followingIds': FieldValue.arrayUnion([creatorId]),
  }, SetOptions(merge: true));

  // 팔로워 목록에 팔로우하는 사람 추가
  await firestore.collection('followers').doc(creatorId).set({
    'followerIds': FieldValue.arrayUnion([userId]),
  }, SetOptions(merge: true));
}

Future<void> unfollow(String userId, String creatorId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 팔로잉 목록에서 팔로우 대상 제거
  await firestore.collection('followings').doc(userId).set({
    'followingIds': FieldValue.arrayRemove([creatorId]),
  }, SetOptions(merge: true));

  // 팔로워 목록에서 팔로우하는 사람 제거
  await firestore.collection('followers').doc(creatorId).set({
    'followerIds': FieldValue.arrayRemove([userId]),
  }, SetOptions(merge: true));
}


