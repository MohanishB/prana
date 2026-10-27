import 'package:flutter_bloc/flutter_bloc.dart';

/// Tells the tabs (Home, Masterclass, Consult) to reload after a purchase, so
/// bought items move from "available to buy" to "my masterclasses".
class CatalogRefreshCubit extends Cubit<int> {
  CatalogRefreshCubit() : super(0);

  void refresh() => emit(state + 1);
}
