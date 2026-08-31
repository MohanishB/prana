import 'video_player_adapter.dart';
import 'video_source.dart';

abstract interface class VideoPlayerFactory {
  VideoPlayerAdapter create(AppVideoSource source);
}
