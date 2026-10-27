import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/money.dart';

/// A masterclass waiting in the cart.
class CartItem {
  const CartItem({
    required this.courseId,
    required this.title,
    required this.thumbnailUrl,
    required this.price,
  });

  final int courseId;
  final String title;
  final String? thumbnailUrl;
  final Money price;
}

class MasterclassCartState {
  const MasterclassCartState({this.items = const []});

  final List<CartItem> items;

  int get count => items.length;
  bool get isEmpty => items.isEmpty;
  List<int> get courseIds =>
      items.map((item) => item.courseId).toList(growable: false);

  bool contains(int courseId) =>
      items.any((item) => item.courseId == courseId);

  /// Sum of the list prices (the checkout works out the final price).
  Money? get total {
    if (items.isEmpty) return null;
    final first = items.first.price;
    final amount = items.fold<double>(0, (sum, i) => sum + i.price.amount);
    return Money(
      amount: amount,
      currencyCode: first.currencyCode,
      symbol: first.symbol,
    );
  }
}

/// The masterclass cart. Lives for the whole app session (kept in memory).
class MasterclassCartCubit extends Cubit<MasterclassCartState> {
  MasterclassCartCubit() : super(const MasterclassCartState());

  void add(CartItem item) {
    if (state.contains(item.courseId)) return;
    emit(MasterclassCartState(items: [...state.items, item]));
  }

  void remove(int courseId) => emit(MasterclassCartState(
        items: state.items
            .where((item) => item.courseId != courseId)
            .toList(growable: false),
      ));

  void clear() => emit(const MasterclassCartState());
}
