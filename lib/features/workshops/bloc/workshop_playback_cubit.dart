
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/video/video_playback_snapshot.dart';
import '../../../core/video/video_player_adapter.dart';
import '../../../core/video/video_player_factory.dart';
import '../../../core/video/video_source.dart';

class WorkshopPlaybackState {
 const WorkshopPlaybackState({this.snapshot=const VideoPlaybackSnapshot.initial(),this.error,this.fullscreen=false});
 final VideoPlaybackSnapshot snapshot;
 final String? error;
 final bool fullscreen;
}
class WorkshopPlaybackCubit extends Cubit<WorkshopPlaybackState> {
 WorkshopPlaybackCubit(this.factory,this.url,this.itemId):super(const WorkshopPlaybackState());
 final VideoPlayerFactory factory;
 final String url;
 final int itemId;
 VideoPlayerAdapter? _adapter;
 StreamSubscription<VideoPlaybackSnapshot>? _subscription;
 VideoPlayerAdapter? get adapter=>_adapter;
 Future<void> initialize() async {
  try{
   final adapter=factory.create(AppVideoSource.fromUrl(id:'workshop_$itemId',url:url));
   _adapter=adapter;
   _subscription=adapter.snapshots.listen((snapshot){
    if(isClosed)return;
    emit(WorkshopPlaybackState(snapshot:snapshot,error:snapshot.errorMessage,fullscreen:state.fullscreen));
   });
   await adapter.initialize();
   await adapter.play();
  }catch(e){if(!isClosed)emit(WorkshopPlaybackState(error:e.toString()));}
 }
 Future<void> toggle() async{
  final a=_adapter;
  if(a==null)return;
  if(a.current.playing){await a.pause();}else{await a.play();}
 }
 Future<void> seek(Duration position) async {
   await _adapter?.seekTo(position);
 }
 Future<void> fullscreen(bool enabled)async {
  if(!isClosed)emit(WorkshopPlaybackState(snapshot:state.snapshot,error:state.error,fullscreen:enabled));
 }
 @override
 Future<void> close()async{
  await _subscription?.cancel();
  await _adapter?.dispose();
  return super.close();
 }
}
