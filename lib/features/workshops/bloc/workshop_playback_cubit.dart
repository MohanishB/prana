import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/video/video_playback_snapshot.dart';
import '../../../core/video/video_player_adapter.dart';
import '../../../core/video/video_player_factory.dart';
import '../../../core/video/video_progress_store.dart';
import '../../../core/video/video_source.dart';
import '../../../core/video/video_watch_tracker.dart';

class WorkshopPlaybackState {
 const WorkshopPlaybackState({this.snapshot=const VideoPlaybackSnapshot.initial(),this.error,this.fullscreen=false});
 final VideoPlaybackSnapshot snapshot;
 final String? error;
 final bool fullscreen;
}
class WorkshopPlaybackCubit extends Cubit<WorkshopPlaybackState> {
 WorkshopPlaybackCubit(this.factory,this.url,this.itemId,this.progressStore,{this.watchTracker}):super(const WorkshopPlaybackState());
 // Same resume rules as the Masterclass player: save about every 5 seconds and
 // when paused or leaving, continue from there next time, forget at 95%.
 static const Duration _saveInterval=Duration(seconds:5);
 static const double _completionThreshold=0.95;
 final VideoPlayerFactory factory;
 final String url;
 final int itemId;
 final VideoProgressStore progressStore;
 final VideoWatchTracker? watchTracker;
 VideoPlayerAdapter? _adapter;
 StreamSubscription<VideoPlaybackSnapshot>? _subscription;
 Duration _storedPosition=Duration.zero;
 Duration _lastSaved=Duration.zero;
 bool _resumeResolved=false;
 bool _waitingForSeek=false;
 VideoPlayerAdapter? get adapter=>_adapter;
 String get _progressKey=>'workshop_$itemId';
 Future<void> initialize() async {
  try{
   _storedPosition=await progressStore.read(_progressKey);
   final adapter=factory.create(AppVideoSource.fromUrl(id:'workshop_$itemId',url:url));
   _adapter=adapter;
   _subscription=adapter.snapshots.listen((snapshot){
    if(isClosed)return;
    watchTracker?.onSnapshot(snapshot);
    _resolveResumeIfPossible(snapshot);
    _saveProgress(snapshot);
    emit(WorkshopPlaybackState(snapshot:snapshot,error:snapshot.errorMessage,fullscreen:state.fullscreen));
   });
   await adapter.initialize();
   await adapter.play();
  }catch(e){if(!isClosed)emit(WorkshopPlaybackState(error:e.toString()));}
 }
 Future<void> toggle() async{
  final a=_adapter;
  if(a==null)return;
  if(a.current.playing){
   await a.pause();
   if(!_waitingForSeek)await _persist(a.current.position,force:true);
  }else{await a.play();}
 }
 Future<void> seek(Duration position) async {
   await _adapter?.seekTo(position);
   _waitingForSeek=false;
   await _persist(position,force:true);
 }
 Future<void> fullscreen(bool enabled)async {
  if(!isClosed)emit(WorkshopPlaybackState(snapshot:state.snapshot,error:state.error,fullscreen:enabled));
 }
 // The player reports its length only once it is ready; that is the moment to jump to the saved spot.
 void _resolveResumeIfPossible(VideoPlaybackSnapshot snapshot){
  if(_resumeResolved||!snapshot.initialized||snapshot.duration<=Duration.zero)return;
  _resumeResolved=true;
  if(_shouldResume(_storedPosition,snapshot.duration)){
   _lastSaved=_storedPosition;
   _waitingForSeek=true;
   unawaited(_adapter?.seekTo(_storedPosition));
   return;
  }
  if(_storedPosition>Duration.zero)unawaited(progressStore.clear(_progressKey));
 }
 bool _shouldResume(Duration stored,Duration duration){
  if(stored<=Duration.zero||duration<=Duration.zero)return false;
  final ratio=stored.inMilliseconds/duration.inMilliseconds;
  return ratio>0&&ratio<_completionThreshold;
 }
 void _saveProgress(VideoPlaybackSnapshot snapshot){
  // Until the saved spot has been applied, the player is still at 0: do not overwrite it.
  if(!_resumeResolved)return;
  if(_waitingForSeek){
   if(snapshot.position+const Duration(seconds:2)>=_storedPosition)_waitingForSeek=false;
   return;
  }
  final duration=snapshot.duration;
  if(duration>Duration.zero&&snapshot.position.inMilliseconds>=duration.inMilliseconds*_completionThreshold){
   unawaited(progressStore.clear(_progressKey));
   _lastSaved=Duration.zero;
   return;
  }
  unawaited(_persist(snapshot.position));
 }
 Future<void> _persist(Duration position,{bool force=false}) async {
  if(position<=Duration.zero)return;
  final duration=_adapter?.current.duration??Duration.zero;
  if(duration>Duration.zero&&position.inMilliseconds>=duration.inMilliseconds*_completionThreshold){
   await progressStore.clear(_progressKey);
   _lastSaved=Duration.zero;
   return;
  }
  if(!force&&(position-_lastSaved).inMilliseconds.abs()<_saveInterval.inMilliseconds)return;
  _lastSaved=position;
  await progressStore.write(_progressKey,position);
 }
 @override
 Future<void> close()async{
  if(_resumeResolved&&!_waitingForSeek&&_adapter!=null)await _persist(_adapter!.current.position,force:true);
  try{await watchTracker?.flush().timeout(const Duration(seconds:3));}on Object{/* watch tracking must never block leaving the video */}
  await _subscription?.cancel();
  await _adapter?.dispose();
  return super.close();
 }
}
