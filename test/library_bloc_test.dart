import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prana/features/library/bloc/library_bloc.dart';
import 'package:prana/features/library/data/mock_library_repository.dart';

void main() {
  group('LibraryBloc', () {
    blocTest<LibraryBloc, LibraryState>(
      'loads static library',
      build: () => LibraryBloc(MockLibraryRepository()),
      act: (bloc) => bloc.add(const LibraryStarted()),
      expect: () => [
        const LibraryLoading(),
        isA<LibraryLoaded>(),
      ],
    );

    blocTest<LibraryBloc, LibraryState>(
      'searches transcript content',
      build: () => LibraryBloc(MockLibraryRepository()),
      act: (bloc) => bloc.add(const LibraryQueryChanged('bloating')),
      expect: () => [
        isA<LibraryLoaded>().having(
          (state) => state.videos.length,
          'result count',
          1,
        ),
      ],
    );
  });
}
