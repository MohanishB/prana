import 'package:flutter_bloc/flutter_bloc.dart';

enum MasterclassSection { workshops, masterclasses }

class MasterclassCubit extends Cubit<MasterclassSection> {
  MasterclassCubit() : super(MasterclassSection.workshops);

  void select(MasterclassSection section) => emit(section);
}
