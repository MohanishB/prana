import 'network_video_player_adapter.dart';
import 'video_player_adapter.dart';
import 'video_player_factory.dart';
import 'video_source.dart';
import 'vimeo_video_player_adapter.dart';

final class DefaultVideoPlayerFactory implements VideoPlayerFactory {
  const DefaultVideoPlayerFactory();

  @override
  VideoPlayerAdapter create(AppVideoSource source) {
    return switch (source.provider) {
      VideoProvider.network => NetworkVideoPlayerAdapter(source),
      VideoProvider.vimeo => VimeoVideoPlayerAdapter(source),
    };
  }
}
