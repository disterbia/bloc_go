import 'package:bloc/bloc.dart';
import 'package:eatall/app/repository/login_repository.dart';

class LoginBloc extends Bloc<LoginEvent, bool> {

  final LoginRepository loginRepository;

  LoginBloc(this.loginRepository) : super(false) {
    on<LoginEvent>((event, emit) async{
      var result = await loginRepository.request(event.id,event.pw);
      print("-=-=-=-=$result");
    });
  }
}
class LoginEvent {
  final String id;
  final String pw;
  LoginEvent(this.id,this.pw);
}