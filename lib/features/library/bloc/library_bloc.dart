import 'dart:async';

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

final class LibrarySearchSubmitted extends LibraryEvent {
  const LibrarySearchSubmitted(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class LibraryLoadMoreRequested extends LibraryEvent {
  const LibraryLoadMoreRequested();
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
    this.nextPageToken,
    this.isSearching = false,
    this.isLoadingMore = false,
  });

  final List<LibraryVideo> videos;
  final String query;
  final String? nextPageToken;
  final bool isSearching;
  final bool isLoadingMore;

  LibraryLoaded copyWith({
    List<LibraryVideo>? videos,
    String? query,
    String? nextPageToken,
    bool clearNextPageToken = false,
    bool? isSearching,
    bool? isLoadingMore,
  }) {
    return LibraryLoaded(
      videos: videos ?? this.videos,
      query: query ?? this.query,
      nextPageToken:
          clearNextPageToken ? null : (nextPageToken ?? this.nextPageToken),
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        videos,
        query,
        nextPageToken,
        isSearching,
        isLoadingMore,
      ];
}

final class LibraryFailure extends LibraryState {
  const LibraryFailure({
    required this.error,
    this.query = '',
  });

  final AppException error;
  final String query;

  @override
  List<Object?> get props => [error.type, error.errorCode, query];
}

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc(this._repository) : super(const LibraryLoading()) {
    on<LibraryStarted>(_onStarted);
    on<LibraryQueryChanged>(_onQueryChanged);
    on<LibrarySearchSubmitted>(_onSearchSubmitted);
    on<LibraryLoadMoreRequested>(_onLoadMoreRequested);
  }

  static const _searchDebounce = Duration(milliseconds: 650);

  final LibraryRepository _repository;
  Timer? _searchTimer;
  String _latestQuery = '';

  Future<void> _onStarted(
    LibraryStarted event,
    Emitter<LibraryState> emit,
  ) async {
    _latestQuery = '';
    _searchTimer?.cancel();
    try {
      emit(const LibraryLoading());
      final page = await _repository.getVideos();
      emit(
        LibraryLoaded(
          videos: page.videos,
          nextPageToken: page.nextPageToken,
        ),
      );
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

  void _onQueryChanged(
    LibraryQueryChanged event,
    Emitter<LibraryState> emit,
  ) {
    final query = event.query.trim();
    _latestQuery = query;
    _searchTimer?.cancel();

    final current = state;
    if (current is LibraryLoaded) {
      emit(
        current.copyWith(
          query: query,
          isSearching: true,
          isLoadingMore: false,
          clearNextPageToken: true,
        ),
      );
    }

    _searchTimer = Timer(
      _searchDebounce,
      () => add(LibrarySearchSubmitted(query)),
    );
  }

  Future<void> _onSearchSubmitted(
    LibrarySearchSubmitted event,
    Emitter<LibraryState> emit,
  ) async {
    if (event.query != _latestQuery) return;

    try {
      final page = event.query.isEmpty
          ? await _repository.getVideos()
          : await _repository.search(event.query);

      if (event.query != _latestQuery) return;
      emit(
        LibraryLoaded(
          videos: page.videos,
          query: event.query,
          nextPageToken: page.nextPageToken,
        ),
      );
    } catch (error, stackTrace) {
      if (event.query != _latestQuery) return;
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

  Future<void> _onLoadMoreRequested(
    LibraryLoadMoreRequested event,
    Emitter<LibraryState> emit,
  ) async {
    final current = state;
    if (current is! LibraryLoaded ||
        current.isLoadingMore ||
        current.isSearching ||
        current.nextPageToken == null) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = current.query.isEmpty
          ? await _repository.getVideos(pageToken: current.nextPageToken)
          : await _repository.search(
              current.query,
              pageToken: current.nextPageToken,
            );

      if (_latestQuery != current.query) return;

      final existingIds = current.videos.map((video) => video.id).toSet();
      final appended = page.videos
          .where((video) => existingIds.add(video.id))
          .toList(growable: false);

      emit(
        current.copyWith(
          videos: [...current.videos, ...appended],
          nextPageToken: page.nextPageToken,
          clearNextPageToken: page.nextPageToken == null,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}
