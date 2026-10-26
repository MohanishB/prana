
Map<String,dynamic> workshopMap(Object? value) =>
    value is Map ? Map<String,dynamic>.from(value) : <String,dynamic>{};
int workshopInt(Object? value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
String workshopString(Object? value) => value?.toString() ?? '';

class WorkshopDay {
  const WorkshopDay({required this.number,required this.itemId,required this.videoId,
  required this.title,required this.heading,required this.state,required this.canPlay,
  required this.startsAt,required this.endsAt});
  final int number, itemId, videoId;
  final String title,heading,state,startsAt,endsAt;
  final bool canPlay;
  String get displayedState => state.toLowerCase() == 'missed' ? 'over' : state.toLowerCase();
  bool get countsForProgress => displayedState == 'over' || displayedState == 'watched';
  factory WorkshopDay.fromJson(Map<String,dynamic> j) => WorkshopDay(
    number:workshopInt(j['day_number']),itemId:workshopInt(j['gut_reset_workshop_booking_item_id']),
    videoId:workshopInt(j['gut_reset_video_id']),title:workshopString(j['title']),
    heading:workshopString(j['heading']),state:workshopString(j['state']),
    canPlay:j['can_play']==true,startsAt:workshopString(j['start_date_time']),
    endsAt:workshopString(j['end_date_time']));
}
class WorkshopProgram {
 const WorkshopProgram({required this.bookingId,required this.title,required this.subtitle,
 required this.imageUrl,required this.type,required this.totalDays,required this.status,
 required this.currentDay,required this.nextUnlock});
 final int bookingId,totalDays;
 final String title,subtitle,imageUrl,type,status;
 final WorkshopDay? currentDay,nextUnlock;
 factory WorkshopProgram.fromJson(Map<String,dynamic> j) => WorkshopProgram(
 bookingId:workshopInt(j['gut_reset_workshop_booking_id']),
 title:workshopString(j['title']),subtitle:workshopString(j['sub_title']),
 imageUrl:workshopString(j['image_url']),type:workshopString(j['gut_reset_type']),
 totalDays:workshopInt(j['total_days']),status:workshopString(j['status']),
 currentDay:j['current_day'] is Map ? WorkshopDay.fromJson(workshopMap(j['current_day'])) : null,
 nextUnlock:j['next_unlock'] is Map ? WorkshopDay.fromJson(workshopMap(j['next_unlock'])) : null);
}
class WorkshopNote {
 const WorkshopNote({required this.scope,required this.day,required this.itemId,
 required this.title,required this.available,required this.fileUrl,required this.downloadUrl});
 final String scope,title,fileUrl,downloadUrl;
 final int? day,itemId;
 final bool available;
 factory WorkshopNote.fromJson(Map<String,dynamic> j) => WorkshopNote(
 scope:workshopString(j['scope']),day:j['day_number']==null?null:workshopInt(j['day_number']),
 itemId:j['gut_reset_workshop_booking_item_id']==null?null:workshopInt(j['gut_reset_workshop_booking_item_id']),
 title:workshopString(j['title']),available:j['available']==true,
 fileUrl:workshopString(j['file_url']),downloadUrl:workshopString(j['download_url']));
}
class WorkshopDetail {
 const WorkshopDetail({required this.program,required this.days,required this.notes,required this.totalDays,required this.currentDayNumber});
 final WorkshopProgram program;
 final List<WorkshopDay> days;
 final List<WorkshopNote> notes;
 final int totalDays,currentDayNumber;
 int get progressedDays => days.where((d)=>d.countsForProgress).length;
 int get progressPercent => totalDays <= 0 ? 0 : ((progressedDays / totalDays)*100).round().clamp(0,100);
 factory WorkshopDetail.fromJson(Map<String,dynamic> j) {
 final pj=workshopMap(j['program']);
 return WorkshopDetail(
 program:WorkshopProgram.fromJson({...pj,'total_days':j['total_days'],'status':j['status']}),
 days:((j['days'] as List?)??const []).whereType<Map>().map((e)=>WorkshopDay.fromJson(workshopMap(e))).toList(),
 notes:((j['notes'] as List?)??const []).whereType<Map>().map((e)=>WorkshopNote.fromJson(workshopMap(e))).toList(),
 totalDays:workshopInt(j['total_days']),currentDayNumber:workshopInt(j['current_day_number']));
 }
}
class WorkshopVideo {
 const WorkshopVideo({required this.itemId,required this.bookingId,required this.day,required this.totalDays,
 required this.title,required this.heading,required this.summary,required this.practiceHtml,required this.mainUrl,
 required this.notes,required this.nextStart});
 final int itemId,bookingId,day,totalDays;
 final String title,heading,summary,practiceHtml,mainUrl,nextStart;
 final WorkshopNote? notes;
 factory WorkshopVideo.fromJson(Map<String,dynamic> j) => WorkshopVideo(
 itemId:workshopInt(j['gut_reset_workshop_booking_item_id']),
 bookingId:workshopInt(j['gut_reset_workshop_booking_id']),
 day:workshopInt(j['day_number']),totalDays:workshopInt(j['total_days']),
 title:workshopString(j['title']),heading:workshopString(j['heading']),
 summary:workshopString(j['sub_description']),practiceHtml:workshopString(j['description_html']),
 mainUrl:workshopString(j['main_video_url']).isNotEmpty?workshopString(j['main_video_url']):
 (workshopString(j['vimeo_video_url']).isNotEmpty?workshopString(j['vimeo_video_url']):workshopString(j['video_url'])),
 notes:j['notes'] is Map?WorkshopNote.fromJson(workshopMap(j['notes'])):null,
 nextStart:workshopString(workshopMap(j['next_day'])['start_date_time']));
}
