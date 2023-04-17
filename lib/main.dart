import 'package:eatall/app/bloc/chat_bloc.dart';
import 'package:eatall/app/bloc/image_bloc.dart';
import 'package:eatall/app/bloc/login_bloc.dart';
import 'package:eatall/app/bloc/spalsh_bloc.dart';
import 'package:eatall/app/bloc/take_video_bloc.dart';
import 'package:eatall/app/bloc/user_profile_bloc.dart';
import 'package:eatall/app/bloc/video_stream_bloc.dart';
import 'package:eatall/app/bloc/video_upload_bloc.dart';
import 'package:eatall/app/const/addr.dart';
import 'package:eatall/app/repository/image_repository.dart';
import 'package:eatall/app/repository/login_repository.dart';
import 'package:eatall/app/repository/video_stream_repository.dart';
import 'package:eatall/app/repository/video_upload_repository.dart';
import 'package:eatall/app/router/custom_go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await SharedPreferencesHelper.removeUserUid();
  UserID.uid = await SharedPreferencesHelper.getUserUid();
  KakaoSdk.init(nativeAppKey: '165742d2ef90b67385060e3bbc9231d9');
  runApp(const MyApp());
}

class UserID {
  static String? uid;
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => LoginBloc(LoginRepository())),
      BlocProvider(create: (context) => SplashBloc()),
      BlocProvider(create: (context) => VideoUploadBloc(VideoUploadRepository())),
      BlocProvider(create: (context) => ImageBloc(ImageRepository())),
      BlocProvider(create: (context) => ChatBloc()),
      BlocProvider(create: (context) => VideoStreamBloc(VideoStreamRepository())),
      BlocProvider(create: (context) => TakeVideoBloc(VideoUploadRepository())),
      BlocProvider(create: (context) => UserProfileBloc(videoRepository: VideoStreamRepository())),
    ],
      child: MaterialApp.router(
        routerConfig: MyPages.router,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}

