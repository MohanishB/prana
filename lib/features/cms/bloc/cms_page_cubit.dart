import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/cms_models.dart';
import '../data/cms_repository.dart';

class CmsPageState {
  const CmsPageState({
    this.page,
    this.loading = false,
    this.error,
  });

  final CmsPage? page;
  final bool loading;
  final AppException? error;
}

/// One admin-edited page (Contact support or Terms & privacy).
class CmsPageCubit extends Cubit<CmsPageState> {
  CmsPageCubit(this._repository, this._key) : super(const CmsPageState());

  final CmsRepository _repository;
  final CmsPageKey _key;

  Future<void> load() async {
    emit(CmsPageState(page: state.page, loading: true));
    try {
      final page = await _repository.getPage(_key);
      if (isClosed) return;
      emit(CmsPageState(page: page));
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      emit(CmsPageState(
        page: state.page,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
