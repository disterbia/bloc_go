import 'package:bloc/bloc.dart';
import 'package:Dtalk/app/const/addr.dart';

class SplashBloc extends Bloc<SplashEvent, bool> {
  SplashBloc() : super(false) {
    on<SplashEvent>((event, emit) async{
     await Future.delayed(Duration(seconds: 2),()=> emit(true));
    });
    add(SplashEvent());
  }
}
class SplashEvent {}

