
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import 'workshop_models.dart';

abstract interface class WorkshopRepository {
 Future<List<WorkshopProgram>> getPrograms();
 Future<WorkshopDetail> getDetail(int bookingId);
 Future<WorkshopVideo> getDayVideo(int itemId);
 Future<void> markDayDone(int itemId);
}
final class ApiWorkshopRepository implements WorkshopRepository {
 ApiWorkshopRepository(this._api);
 final ApiClient _api;
 @override
 Future<List<WorkshopProgram>> getPrograms() async {
   final response=await _api.get(ApiConstants.workshopPrograms);
   final data=workshopMap(response['data']);
   return ((data['programs'] as List?)??const []).whereType<Map>()
    .map((e)=>WorkshopProgram.fromJson(workshopMap(e))).toList(growable:false);
 }
 @override
 Future<WorkshopDetail> getDetail(int bookingId) async {
   final response=await _api.get(ApiConstants.workshopDetail,query:{'gut_reset_workshop_booking_id':bookingId});
   return WorkshopDetail.fromJson(workshopMap(response['data']));
 }
 @override
 Future<WorkshopVideo> getDayVideo(int itemId) async {
   final response=await _api.get(ApiConstants.workshopDayVideo,query:{'gut_reset_workshop_booking_item_id':itemId});
   return WorkshopVideo.fromJson(workshopMap(response['data']));
 }
 @override
 Future<void> markDayDone(int itemId) async {
   await _api.postForm(ApiConstants.workshopMarkDayDone,body:{'gut_reset_workshop_booking_item_id':itemId});
 }
}
