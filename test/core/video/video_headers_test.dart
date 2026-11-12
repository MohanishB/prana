import 'package:flutter_test/flutter_test.dart';
import 'package:prana/core/video/network_video_player_adapter.dart';
import 'package:prana/core/video/video_source.dart';

void main() {
  test('referer is the origin of the api server', () {
    expect(
      videoRequestHeaders(
          baseUrl: 'https://www.retailsite.co.za/prana/student_app_webservices'),
      {'Referer': 'https://www.retailsite.co.za/'},
    );
    expect(
      videoRequestHeaders(
          baseUrl:
              'https://www.pranabydimpleacademy.com/lms/asdqw/student_app_webservices'),
      {'Referer': 'https://www.pranabydimpleacademy.com/'},
    );
    expect(videoRequestHeaders(baseUrl: 'not a url'), isEmpty);
  });

  test('vimeo and player page links still use the vimeo route', () {
    expect(
      AppVideoSource.fromUrl(
              id: '1',
              url: 'https://x.com/prana/student_app_webservices/player/player.php?t=a.b')
          .provider,
      VideoProvider.vimeo,
    );
    expect(
      AppVideoSource.fromUrl(id: '2', url: 'https://player.vimeo.com/video/123456').provider,
      VideoProvider.vimeo,
    );
    expect(
      AppVideoSource.fromUrl(id: '3', url: 'https://a.com/chapter_video/mumbai.mp4').provider,
      VideoProvider.network,
    );
  });
}
