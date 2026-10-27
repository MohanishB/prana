import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/home_models.dart';
import '../data/home_repository.dart';

class HomeState {
  const HomeState({this.home, this.loading = false, this.error});

  final HomeData? home;
  final bool loading;
  final AppException? error;
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState());

  final HomeRepository _repository;

  Future<void> load() async {
    emit(HomeState(home: state.home, loading: true));
    try {
      emit(HomeState(home: await _repository.getHome()));
    } on Object catch (error, stackTrace) {
      emit(HomeState(
        home: state.home,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
