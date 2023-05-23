import 'package:Dtalk/app/const/addr.dart';
import 'package:Dtalk/app/view/splash_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Dtalk/app/bloc/chat_bloc.dart';
import 'package:Dtalk/app/bloc/user_profile_bloc.dart';
import 'package:Dtalk/app/bloc/user_video_bloc.dart';
import 'package:Dtalk/app/bloc/video_upload_bloc.dart';
import 'package:Dtalk/app/model/video_stream.dart';
import 'package:Dtalk/app/router/custom_go_router.dart';
import 'package:Dtalk/app/view/home_page.dart';
import 'package:Dtalk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';


class UserProfile extends StatefulWidget {

  VideoStream video;
  bool isBackbutton;
  UserProfile(this.video,this.isBackbutton);
  @override
  _UserProfileState createState() => _UserProfileState();
}
class _UserProfileState extends State<UserProfile> {
  bool _isFollowing = false;
  bool _preventMultipleTap=false;
  bool isLoading = false;
  int temp =0;

  @override
  void initState() {
    super.initState();
    _checkFollowing();
  }

  @override
  Widget build(BuildContext context) {
    temp=0;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          //Color(0xFF272727),
          elevation: 1,
          titleSpacing: 0,
          centerTitle: !widget.isBackbutton,
          leading: !widget.isBackbutton! ?Container():Container(child: InkWell(onTap:()=> context.pop(),child: Image.asset("assets/img/ic_back.png")),padding: EdgeInsets.all(15)),
          title: Text(
            widget.video.userInfo.nickname,overflow: TextOverflow.fade,
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
              SizedBox(height: 20),
              _buildProfileHeader(),
              SizedBox(height: 20),
              _buildProfileStats(),
              SizedBox(height: 20),
              _buildProfileBio(context),
              SizedBox(height: 20),
              _buildProfileTabs(context),
              SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );

  }

  void _checkFollowing() async {
    if(UserID.uid==null) return;
    isLoading=true;
    bool isFollowingResult = await isFollowing(UserID.uid!, widget.video.uploader); // 'creatorId'를 실제 생성자 ID로 바꾸세요.
    setState(() {
      isLoading=false;
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
          backgroundImage: AssetImage("assets/img/profile3_lg.png"),
          backgroundColor: Colors.black,
          radius: 50,
        ):
        CircleAvatar(
          backgroundImage: NetworkImage(widget.video.userInfo.image),
          radius: 50,
        ),
        SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("@",style: TextStyle(color: Address.color,fontWeight: FontWeight.bold, fontSize: 18.sp),),
            SizedBox(width: 5,),
            Text(
              widget.video.userInfo.nickname,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
          ],
        ),
        SizedBox(height: 4),
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(widget.video.userInfo.intro),
        ),
      ],
    );
  }

  Widget _buildProfileStats() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 0),
    child: Container(height: 80.h,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.grey.shade200,),
    child: Column(mainAxisAlignment: MainAxisAlignment.center,
    children: [
         Row(
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
                  return _buildStatItem('팔로잉',snapshot.data!);
                } else {
                  return _buildStatItem('팔로잉', 0);
                }
              },
            ),

// 팔로워 수
            StreamBuilder<int>(
              stream: followersCountStream(widget.video.uploader),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {

                if (snapshot.hasData) {
                  return _buildStatItem('팔로워', snapshot.data!);
                } else {
                  return _buildStatItem('팔로워', 0);
                }
              },
            ),
            StreamBuilder<int>(
              stream: likesCountStream(widget.video.uploader),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {

                if (snapshot.hasData) {
                  return InkWell(onDoubleTap: (){
                    print(temp%20);
                    temp+=1;
                    if(temp%20==0){
                      context.push("/admin");
                    }
                  },child: _buildStatItem('좋아요',snapshot.data!));
                } else {
                  return InkWell(onDoubleTap: (){
                    print(temp%20);
                    temp+=1;
                    if(temp%20==0){
                      context.push("/admin");
                    }
                  },child: _buildStatItem('좋아요', 0));
                }
              },
            ),
          ],
        ),          ],
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
    return this.isLoading?Container():widget.video.userInfo.id == UserID.uid
        ? ConstrainedBox(constraints: BoxConstraints.tightFor(width: 200.w, height: 50.h),
          child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(_isFollowing?Colors.grey:Address.color),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )
              )
          ),
                  onPressed: () async {
                    context.push(MyRoutes.VIDEOUPLOAD);
                    context.read<VideoUploadBloc>().add(PickVideoEvent());
                    print("-=-=-=-=-=-=");
                  },
                  child: Text("동영상 업로드")),
        )
        : Container(
          child: AbsorbPointer(
            absorbing: _preventMultipleTap,
            child: ConstrainedBox(constraints: BoxConstraints.tightFor(width: 200.w, height: 50.h),
              child: ElevatedButton(style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(_isFollowing?Colors.grey:Address.color),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                      )
                  )
              ),
                onPressed: () => UserID.uid==null?context.push(MyRoutes.Login):_toggleFollow(),
                child: Text(_isFollowing ? '팔로우 취소' : '팔로우'),
              ),
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
             padding: EdgeInsets.all(4),
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
                  context.read<UserVideoBloc>().add(UserLoadVideoEvent(
                      currentIndex: index,
                      userVideo: state.userVideos));
                  context.read<ChatBloc>().add(InitialUserChatEvent(widget.video.userInfo.id,index));
                  context.push(MyRoutes.USERVIDEO, extra: {"index":index,"image":widget.video.userInfo.image,"nickname":widget.video.userInfo.nickname});
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


