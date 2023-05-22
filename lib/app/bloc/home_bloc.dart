import 'package:bloc/bloc.dart';
import 'package:Dtalk/app/const/addr.dart';

class HomeBloc extends Bloc<HomeEvent, int> {
  HomeBloc() : super(0) {
    on<HomeEvent>((event, emit) {
      emit(event.index);
    });
  }
}
class HomeEvent {
  int index;
  HomeEvent(this.index);
}

