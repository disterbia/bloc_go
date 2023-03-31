import 'package:eatall/app/bloc/spalsh_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc(),
      child: Scaffold(
        body: BlocListener<SplashBloc,bool>(
          listenWhen: (previous, current) => current,
          listener: (context,state) {
            context.pushReplacement("/video");
          },
          child:Center(
        child: Image.asset("assets/product_img2.jpeg"),
      ),
        ),),
    );
  }
}
