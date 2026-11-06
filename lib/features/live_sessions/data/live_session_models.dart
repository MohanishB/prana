import '../../../core/models/json_readers.dart';

/// One live Q&A session set up by the admin: some text, when it runs and the
/// button that opens its link (a Zoom / YouTube / other web address).
class LiveSession {
  const LiveSession({
    required this.id,
    required this.title,
    required this.text,
    required this.start,
    required this.end,
    required this.buttonText,
    required this.buttonUrl,
  });

  final int id;

  /// Small heading shown above the description; may be empty.
  final String title;
  final String text;

  /// Server time (IST), as typed in the admin. Null when the server value is unreadable.
  final DateTime? start;
  final DateTime? end;
  final String buttonText;
  final String buttonUrl;

  factory LiveSession.fromJson(Map<String, dynamic> json) => LiveSession(
        id: jsonInt(json['session_id']),
        title: jsonString(json['title']).trim(),
        text: jsonString(json['text']).trim(),
        start: DateTime.tryParse(jsonString(json['start_datetime'])),
        end: DateTime.tryParse(jsonString(json['end_datetime'])),
        buttonText: jsonString(json['button_text']).trim(),
        buttonUrl: jsonString(json['button_url']).trim(),
      );
}

/// The sessions plus the server's clock, so the Join button follows server time
/// even when the phone's clock is wrong.
class LiveSessionsData {
  const LiveSessionsData({required this.sessions, this.serverTime});

  final List<LiveSession> sessions;
  final DateTime? serverTime;
}
