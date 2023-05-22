import 'package:Dtalk/app/bloc/chat_bloc.dart';
import 'package:Dtalk/app/bloc/follow_bloc.dart';
import 'package:Dtalk/app/bloc/home_bloc.dart';
import 'package:Dtalk/app/bloc/image_bloc.dart';
import 'package:Dtalk/app/bloc/login_bloc.dart';
import 'package:Dtalk/app/bloc/mypage_bloc.dart';
import 'package:Dtalk/app/bloc/spalsh_bloc.dart';
import 'package:Dtalk/app/bloc/take_video_bloc.dart';
import 'package:Dtalk/app/bloc/user_profile_bloc.dart';
import 'package:Dtalk/app/bloc/user_video_bloc.dart';
import 'package:Dtalk/app/bloc/video_stream_bloc.dart';
import 'package:Dtalk/app/bloc/video_upload_bloc.dart';
import 'package:Dtalk/app/const/addr.dart';
import 'package:Dtalk/app/repository/follow_repository.dart';
import 'package:Dtalk/app/repository/image_repository.dart';
import 'package:Dtalk/app/repository/login_repository.dart';
import 'package:Dtalk/app/repository/mypage_repository.dart';
import 'package:Dtalk/app/repository/video_stream_repository.dart';
import 'package:Dtalk/app/repository/video_upload_repository.dart';
import 'package:Dtalk/app/router/custom_go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 // WidgetsBinding widgetsBinding=WidgetsFlutterBinding.ensureInitialized();
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //FlutterNativeSplash.remove();
  await Firebase.initializeApp();
  //await SharedPreferencesHelper.removeUserUid();
  UserID.uid = await SharedPreferencesHelper.getUserUid();
  UserID.nickname = await SharedPreferencesHelper.getUserNickname();
  UserID.userImage = await SharedPreferencesHelper.getUserImage();
  KakaoSdk.init(nativeAppKey: '165742d2ef90b67385060e3bbc9231d9');
  runApp(const MyApp());
}

class UserID {
  static String? uid;
  static String? nickname;
  static String? userImage;
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => SplashBloc()),
      BlocProvider(create: (context) => LoginBloc(LoginRepository())),
      BlocProvider(create: (context) => VideoUploadBloc(VideoUploadRepository())),
      BlocProvider(create: (context) => ImageBloc(ImageRepository())),
      BlocProvider(create: (context) => ChatBloc(VideoStreamRepository())),
      BlocProvider(create: (context) => VideoStreamBloc(VideoStreamRepository())),
      BlocProvider(create: (context) => TakeVideoBloc(VideoUploadRepository())),
      BlocProvider(create: (context) => UserProfileBloc(videoRepository: VideoStreamRepository())),
      BlocProvider(create: (context) => MyPageBloc(myPageRepository: MyPageRepository())),
      BlocProvider(create: (context) => UserVideoBloc()),
      BlocProvider(create: (context) => FollowBloc(FollowRepository())),
      BlocProvider(create: (context) => HomeBloc()),
    ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
          builder: (context , child) {
            return MaterialApp.router(debugShowCheckedModeBanner: false,
              // routerConfig: MyPages.router,
              routeInformationParser: MyPages.router.routeInformationParser,
              routerDelegate: MyPages.router.routerDelegate,
              routeInformationProvider: MyPages.router.routeInformationProvider,
              title: 'Dtalk',
              theme: ThemeData(
                backgroundColor: Colors.black,
                appBarTheme: AppBarTheme(backgroundColor: Colors.black)
              ),
            );
          }

      ),
    );
  }
}

