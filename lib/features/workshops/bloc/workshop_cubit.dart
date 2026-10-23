
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/workshop_models.dart';
import '../data/workshop_repository.dart';

class WorkshopListState {
 const WorkshopListState({this.loading=false,this.programs=const [],this.progress=const {},this.error});
 final bool loading;
 final List<WorkshopProgram> programs;
 final Map<int,int> progress;
 final String? error;
}
class WorkshopListCubit extends Cubit<WorkshopListState> {
 WorkshopListCubit(this.repository):super(const WorkshopListState());
 final WorkshopRepository repository;
 Future<void> load() async {
   emit(WorkshopListState(loading:true,programs:state.programs));
   try {
     final programs=await repository.getPrograms();
     final progress=<int,int>{};
     // Detail day states, not backend progress_pct, are authoritative.
     await Future.wait(programs.map((program) async {
       try {
         final detail=await repository.getDetail(program.bookingId);
         progress[program.bookingId]=detail.progressPercent;
       } catch (_) {
         // Individual detail errors must not hide the enrolled workshop list.
       }
     }));
     emit(WorkshopListState(programs:programs,progress:progress));
   }
   catch(e){emit(WorkshopListState(programs:state.programs,error:e.toString()));}
 }
}
class WorkshopDetailState {
 const WorkshopDetailState({this.loading=false,this.detail,this.error});
 final bool loading;
 final WorkshopDetail? detail;
 final String? error;
}
class WorkshopDetailCubit extends Cubit<WorkshopDetailState> {
 WorkshopDetailCubit(this.repository,this.bookingId):super(const WorkshopDetailState());
 final WorkshopRepository repository;
 final int bookingId;
 Future<void> load() async {
  emit(WorkshopDetailState(loading:true,detail:state.detail));
  try{emit(WorkshopDetailState(detail:await repository.getDetail(bookingId)));}
  catch(e){emit(WorkshopDetailState(detail:state.detail,error:e.toString()));}
 }
}
class WorkshopVideoState {
 const WorkshopVideoState({this.loading=false,this.submitting=false,this.video,this.error,this.marked=false});
 final bool loading,submitting,marked;
 final WorkshopVideo? video;
 final String? error;
}
class WorkshopVideoCubit extends Cubit<WorkshopVideoState> {
 WorkshopVideoCubit(this.repository,this.itemId):super(const WorkshopVideoState());
 final WorkshopRepository repository;
 final int itemId;
 Future<void> load() async {
  emit(const WorkshopVideoState(loading:true));
  try{emit(WorkshopVideoState(video:await repository.getDayVideo(itemId)));}
  catch(e){emit(WorkshopVideoState(error:e.toString()));}
 }
 Future<void> markDone() async {
  if(state.submitting||state.marked||state.video==null)return;
  emit(WorkshopVideoState(video:state.video,submitting:true));
  try{await repository.markDayDone(itemId);
    emit(WorkshopVideoState(video:state.video,marked:true));
  }catch(e){emit(WorkshopVideoState(video:state.video,error:e.toString()));}
 }
}
