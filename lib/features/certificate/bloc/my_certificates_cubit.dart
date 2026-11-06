import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/certificate_models.dart';
import '../data/certificate_repository.dart';

class MyCertificatesState {
  const MyCertificatesState({
    this.certificates = const [],
    this.loading = false,
    this.loaded = false,
    this.error,
  });

  final List<StudentCertificate> certificates;
  final bool loading;
  final bool loaded;
  final AppException? error;
}

/// The student's generated certificates (newest first, as the server sends them).
class MyCertificatesCubit extends Cubit<MyCertificatesState> {
  MyCertificatesCubit(this._repository) : super(const MyCertificatesState());

  final CertificateRepository _repository;

  Future<void> load() async {
    emit(MyCertificatesState(
      certificates: state.certificates,
      loaded: state.loaded,
      loading: true,
    ));
    try {
      final certificates = await _repository.getMyCertificates();
      if (isClosed) return;
      emit(MyCertificatesState(certificates: certificates, loaded: true));
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      emit(MyCertificatesState(
        certificates: state.certificates,
        loaded: state.loaded,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
