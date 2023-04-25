
import 'package:eatall/app/bloc/chat_bloc.dart';
import 'package:eatall/app/model/video_stream.dart';
import 'package:eatall/app/widget/chat_widget.dart';
import 'package:eatall/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatStateWidget extends StatefulWidget {
  final VideoStream? video;
  SocketState? socketState;
  ChatStateWidget({required this.video,this.socketState});

  @override
  _ChatStateWidgetState createState() => _ChatStateWidgetState();
}

class _ChatStateWidgetState extends State<ChatStateWidget> with TickerProviderStateMixin{


  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  late AnimationController _chatAnimationController;
  late Animation<double> _chatAnimation;
  double iconSize = 24.0;
  double animaiteSize = 12.0;
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

  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _chatAnimationController.dispose();
    super.dispose();
  }

  void _startLikeAnimation() {
    _likeAnimationController.forward().then((_) {
      _chatAnimationController.reverse();
      _likeAnimationController.reverse();

    });
  }

  void _startChatAnimation() {
    _chatAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
      _chatAnimationController.reverse();

    });
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc,ChatState>(
        builder: (context,chatState) {

          if(chatState is FirstState){
            _startChatAnimation();
            _startLikeAnimation();
          }
          if (chatState is ChatChange) {
            _startChatAnimation();
          } else if (chatState is LikeChange) {
            _startLikeAnimation();
          }
          return chatState is ChatLoading || chatState is ChatInitial?Stack(
            children: [
              Positioned( bottom: 150,
                  right: 25,child: CircularProgressIndicator(color: Colors.white,)),
            ],
          ):Stack(children: [
            Positioned(
              bottom: 150,
              right: 25,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      context.read<ChatBloc>().add(LikeOrDisLikeEvent(UserID.uid!));
                    },
                    child: AnimatedBuilder(
                        animation: _likeAnimation,
                        builder: (context, child) {
                          return Icon(
                            Icons.favorite,
                            color: (widget.socketState?.userLike ?? false)?Colors.red:Colors.grey,
                            size: iconSize+ (animaiteSize* _likeAnimationController.value),
                          );
                        }
                    ),
                  ),
                  Text((widget.socketState?.totalLike).toString()),
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
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return Container(
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
                                  child: chatWidget(context, widget.video!.url,widget.socketState),
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
                  Text((widget.socketState?.messages!=null?widget.socketState!.messages!.last.totalCount:100).toString()),
                ],
              ),
            ),
          ],);
        }
    );
  }
}