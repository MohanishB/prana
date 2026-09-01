import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/faq_models.dart';
import '../data/faq_repository.dart';

sealed class FaqState {
  const FaqState();
}

final class FaqLoading extends FaqState {
  const FaqLoading();
}

final class FaqLoaded extends FaqState {
  const FaqLoaded(this.collection);

  final FaqCollection collection;
}

final class FaqFailure extends FaqState {
  const FaqFailure(this.error);

  final AppException error;
}

class FaqCubit extends Cubit<FaqState> {
  FaqCubit(this._repository) : super(const FaqLoading());

  final FaqRepository _repository;

  Future<void> load() async {
    emit(const FaqLoading());
    try {
      emit(FaqLoaded(await _repository.getFaqs()));
    } on Object catch (error, stackTrace) {
      emit(
        FaqFailure(
          ApiErrorHandler.normalize(error, stackTrace: stackTrace),
        ),
      );
    }
  }
}
