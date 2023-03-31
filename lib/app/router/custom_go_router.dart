import 'package:eatall/app/bloc/image_bloc.dart';
import 'package:eatall/app/bloc/login_bloc.dart';
import 'package:eatall/app/repository/image_repository.dart';
import 'package:eatall/app/repository/login_repository.dart';
import 'package:eatall/app/view/splash_page.dart';
import 'package:eatall/app/view/login_page.dart';
import 'package:eatall/app/view/upload_page.dart';
import 'package:eatall/app/view/videostream.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MyRoutes {
  static const SPLASH = '/';
  static const Login = '/login';
  static const UPLOAD = '/upload';
  static const VIDEO = '/video';

}

class MyPages {
  static late final  router = GoRouter(
    initialLocation: "/",
    errorBuilder: (context, state) => Container(child: Text("dd"),),
    routes: [
      GoRoute(
          path: MyRoutes.SPLASH,
          builder: (context, state) => SplashScreen()
      ),
      GoRoute(
          path: MyRoutes.VIDEO,
          builder: (context, state) => VideoScreen()
      ),
      GoRoute(
          path: MyRoutes.Login,
          builder: (context, state) => RepositoryProvider(
              create: (context) => LoginRepository(),
              child: BlocProvider(
                  create: (context) => LoginBloc(context.read<LoginRepository>()),
                  child: LoginPage()))
      ),
      GoRoute(
          path: MyRoutes.UPLOAD,
          builder: (context, state) => RepositoryProvider(
              create: (context) => ImageRepository(),
              child: BlocProvider(
                  create: (context) => ImageBloc(context.read<ImageRepository>()),
                  child: UploadPage(title: 'upload',)))
      ),
    ],
  );
}