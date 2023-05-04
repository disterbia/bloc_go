
import 'package:DTalk/app/bloc/chat_bloc.dart';
import 'package:DTalk/app/bloc/video_stream_bloc.dart';
import 'package:DTalk/app/model/video_stream.dart';
import 'package:DTalk/app/router/custom_go_router.dart';
import 'package:DTalk/app/widget/floating_heart.dart';
import 'package:DTalk/app/widget/chat_widget.dart';
import 'package:DTalk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChatStateWidget extends StatefulWidget {
  final VideoStream? video;

  ChatStateWidget({required this.video});

  @override
  _ChatStateWidgetState createState() => _ChatStateWidgetState();
}

class _ChatStateWidgetState extends State<ChatStateWidget> with TickerProviderStateMixin{

  bool _isVisible = false;
  bool preventMultipleTap = false;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  late AnimationController _chatAnimationController;
  late Animation<double> _chatAnimation;
  double iconSize = 36.0;
  double animaiteSize = 24.0;

  List<Widget> _hearts = [];

  @override
  void initState() {

    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _likeAnimation = CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.easeInOut,
    );

    _chatAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _chatAnimation = CurvedAnimation(
      parent: _chatAnimationController,
      curve: Curves.easeInOut,
    );


    _likeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.read<ChatBloc>().add(ResetAnimationEvent(widget.video!.id));
      }
    });
    _chatAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.read<ChatBloc>().add(ResetAnimationEvent(widget.video!.id));
      }
    });
  }


  @override
  void dispose() {
    _chatAnimationController.removeListener(() { });
    _likeAnimationController.removeListener(() { });
    _likeAnimationController.dispose();
    _chatAnimationController.dispose();

    super.dispose();
  }

  void _startLikeAnimation(String roomId) {
    if (_isVisible) {
      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reverse();
        setState(() {
          preventMultipleTap = false;
        });
      });
    }
  }


  void _startChatAnimation(String roomId) {
    if (_isVisible) {
      _chatAnimationController.forward().then((_) {
        _chatAnimationController.reverse();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.video!.id),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 1) {
          // 완전히 보이는 경우
          _isVisible = true;
        } else {
          // 완전히 보이지 않는 경우
          _isVisible = false;
        }
      },
      child: BlocBuilder<ChatBloc,ChatState>(
          builder: (context,chatState) {
            if (chatState is ChatChange && chatState.chatRoomStates[widget.video!.id]?.animate == true) {
              _startChatAnimation(widget.video!.id);
            } else if (chatState is LikeChange && chatState.chatRoomStates[widget.video!.id]?.animate == true) {
              _startLikeAnimation(widget.video!.id);
            }
            return chatState is ChatInitial?Stack(
              children: [

                Positioned( bottom: 150,
                    right: 25,child: CircularProgressIndicator(color: Colors.white,)),
              ],
            ):Stack(children: [
              ..._hearts,
              Positioned(
                bottom: 170,
                right: 25,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if(preventMultipleTap) return;
                        setState(() {
                          preventMultipleTap=true;
                        });
                        if(UserID.uid==null){
                          setState(() {
                            preventMultipleTap=false;
                          });
                          context.push(MyRoutes.Login);

                         // widget.controller.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
                        }
                        else {
                          context.read<ChatBloc>().add(LikeOrDisLikeEvent(roomId: widget.video!.id,userId: UserID.uid!));
                        }
                      },
                      child: AnimatedBuilder(
                          animation: _likeAnimation,
                          builder: (context, child) {
                            return Icon(
                              Icons.favorite,
                              color: (chatState.chatRoomStates[widget.video!.id]?.isLike==null?false:chatState.chatRoomStates[widget.video!.id]!.isLike)?Colors.red:Colors.grey,
                              size: iconSize+ (animaiteSize* _likeAnimationController.value),
                            );
                          }
                      ),
                    ),
                    SizedBox(height: 5,),
                    Text(((chatState.chatRoomStates[widget.video!.id]?.totalLike==null?0:chatState.chatRoomStates[widget.video!.id]!.totalLike)).toString()),
                  ],
                ),
              ),
              Positioned(
                bottom: 100,
                right: 25,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return Container(height:MediaQuery.of(context).size.height*0.7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(Icons.close,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: chatWidget(context, widget.video!.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: AnimatedBuilder(
                        animation: _chatAnimation,
                        builder: (context, child) {
                          return Icon(
                              Icons.comment,
                              size: iconSize+ (animaiteSize * _chatAnimationController.value)
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 5,),
                    Text(((chatState.chatRoomStates[widget.video!.id]?.messages==null?[]:chatState.chatRoomStates[widget.video!.id]!.messages).isNotEmpty?chatState.chatRoomStates[widget.video!.id]!.messages.first.totalCount:0).toString()),
                  ],
                ),
              ),
            ],);
          }
      ),
    );
  }
}