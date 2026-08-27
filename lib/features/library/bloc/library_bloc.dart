import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/library_repository.dart';
import '../domain/library_video.dart';

sealed class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

final class LibraryStarted extends LibraryEvent {
  const LibraryStarted();
}

final class LibraryQueryChanged extends LibraryEvent {
  const LibraryQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

sealed class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

final class LibraryLoading extends LibraryState {
  const LibraryLoading();
}

final class LibraryLoaded extends LibraryState {
  const LibraryLoaded({
    required this.videos,
    this.query = '',
  });

  final List<LibraryVideo> videos;
  final String query;

  @override
  List<Object?> get props => [videos, query];
}

final class LibraryFailure extends LibraryState {
  const LibraryFailure({
    required this.error,
    this.query = '',
  });

  final AppException error;
  final String query;

  @override
  List<Object?> get props => [error.type, query];
}

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc(this._repository) : super(const LibraryLoading()) {
    on<LibraryStarted>(_onStarted);
    on<LibraryQueryChanged>(_onQueryChanged);
  }

  final LibraryRepository _repository;

  Future<void> _onStarted(
    LibraryStarted event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      emit(const LibraryLoading());
      emit(LibraryLoaded(videos: await _repository.getVideos()));
    } catch (error, stackTrace) {
      emit(
        LibraryFailure(
          error: ApiErrorHandler.normalize(
            error,
            stackTrace: stackTrace,
            fallback: AppErrorType.libraryLoad,
          ),
        ),
      );
    }
  }

  Future<void> _onQueryChanged(
    LibraryQueryChanged event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      final videos = await _repository.search(event.query);
      emit(LibraryLoaded(videos: videos, query: event.query));
    } catch (error, stackTrace) {
      emit(
        LibraryFailure(
          error: ApiErrorHandler.normalize(
            error,
            stackTrace: stackTrace,
            fallback: AppErrorType.librarySearch,
          ),
          query: event.query,
        ),
      );
    }
  }
}
