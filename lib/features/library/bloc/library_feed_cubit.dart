import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/library_repository.dart';
import '../domain/library_video.dart';

class LibraryFeedState extends Equatable {
  const LibraryFeedState({
    required this.videos,
    required this.currentIndex,
    required this.query,
    this.nextPageToken,
    this.isLoadingMore = false,
    this.expandedDescriptionVideoId,
  });

  final List<LibraryVideo> videos;
  final int currentIndex;
  final String query;
  final String? nextPageToken;
  final bool isLoadingMore;
  final String? expandedDescriptionVideoId;

  LibraryFeedState copyWith({
    List<LibraryVideo>? videos,
    int? currentIndex,
    String? nextPageToken,
    bool clearNextPageToken = false,
    bool? isLoadingMore,
    String? expandedDescriptionVideoId,
    bool clearExpandedDescription = false,
  }) {
    return LibraryFeedState(
      videos: videos ?? this.videos,
      currentIndex: currentIndex ?? this.currentIndex,
      query: query,
      nextPageToken:
          clearNextPageToken ? null : (nextPageToken ?? this.nextPageToken),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      expandedDescriptionVideoId: clearExpandedDescription
          ? null
          : (expandedDescriptionVideoId ?? this.expandedDescriptionVideoId),
    );
  }

  @override
  List<Object?> get props => [
        videos,
        currentIndex,
        query,
        nextPageToken,
        isLoadingMore,
        expandedDescriptionVideoId,
      ];
}

class LibraryFeedCubit extends Cubit<LibraryFeedState> {
  LibraryFeedCubit(
    this._repository,
    LibraryPlaybackArgs args,
  ) : super(
          LibraryFeedState(
            videos: args.videos,
            currentIndex: args.initialIndex,
            query: args.query,
            nextPageToken: args.nextPageToken,
          ),
        );

  final LibraryRepository _repository;

  void pageChanged(int index) {
    if (index < 0 || index >= state.videos.length) return;
    emit(
      state.copyWith(
        currentIndex: index,
        clearExpandedDescription: true,
      ),
    );

    if (index >= state.videos.length - 3) {
      loadMore();
    }
  }

  void toggleDescription(String videoId) {
    if (state.expandedDescriptionVideoId == videoId) {
      emit(state.copyWith(clearExpandedDescription: true));
      return;
    }

    emit(state.copyWith(expandedDescriptionVideoId: videoId));
  }

  Future<void> loadMore() async {
    final token = state.nextPageToken;
    if (token == null || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));
    try {
      final page = state.query.isEmpty
          ? await _repository.getVideos(pageToken: token)
          : await _repository.search(state.query, pageToken: token);

      final existingIds = state.videos.map((video) => video.id).toSet();
      final appended = page.videos
          .where((video) => existingIds.add(video.id))
          .toList(growable: false);

      emit(
        state.copyWith(
          videos: [...state.videos, ...appended],
          nextPageToken: page.nextPageToken,
          clearNextPageToken: page.nextPageToken == null,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }
}
