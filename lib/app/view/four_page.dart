import 'package:DTalk/app/bloc/follow_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class FollowingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Following'),backgroundColor: Colors.black,
      ),
      body: BlocBuilder<FollowBloc,FollowState>(
        builder: (context, state)  {
          if(state is! FollowInfoState) return Center(child: CircularProgressIndicator(),);
          if(state.followInfo!.length==0)return Center(child: Text("팔로잉이 없습니다.",style: TextStyle(color: Colors.white),));
          return Center(
            child: CarouselSlider.builder(
              itemCount: state.followInfo!.length,
              itemBuilder: (BuildContext context, int index, int realIndex) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        state.followInfo![index].userInfo.thumbnail,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.6,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            state.followInfo![index].userInfo.id,
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Followers: ${state.followInfo![index].followerCount}',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Folloings: ${state.followInfo![index].followingCount}',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            'good: ${state.followInfo![index].totalLike}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              options: CarouselOptions(
                enableInfiniteScroll: false,
                autoPlay: false,
                enlargeCenterPage: true,
                aspectRatio: 1,
                viewportFraction: 0.8,
              ),
            ),
          );
        }
      ),
    );
  }
}