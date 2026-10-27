import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/masterclass_checkout_models.dart';
import '../data/masterclass_checkout_repository.dart';

class MasterclassCheckoutState {
  const MasterclassCheckoutState({
    this.quote,
    this.quoting = false,
    this.placing = false,
    this.couponCode = '',
    this.quoteError,
    this.orderError,
    this.result,
  });

  final MasterclassQuote? quote;
  final bool quoting;

  /// "Buy now" is in progress.
  final bool placing;

  /// The coupon the current quote was worked out with.
  final String couponCode;
  final AppException? quoteError;
  final AppException? orderError;
  final MasterclassOrderResult? result;

  bool get canBuy =>
      quote != null && quote!.canPay && !quoting && !placing && result == null;

  MasterclassCheckoutState copyWith({
    MasterclassQuote? quote,
    bool? quoting,
    bool? placing,
    String? couponCode,
    AppException? quoteError,
    AppException? orderError,
    MasterclassOrderResult? result,
    bool clearQuoteError = false,
    bool clearOrderError = false,
  }) =>
      MasterclassCheckoutState(
        quote: quote ?? this.quote,
        quoting: quoting ?? this.quoting,
        placing: placing ?? this.placing,
        couponCode: couponCode ?? this.couponCode,
        quoteError: clearQuoteError ? null : quoteError ?? this.quoteError,
        orderError: clearOrderError ? null : orderError ?? this.orderError,
        result: result ?? this.result,
      );
}

/// Price check, coupon and "Buy now" for one masterclass or the cart.
class MasterclassCheckoutCubit extends Cubit<MasterclassCheckoutState> {
  MasterclassCheckoutCubit(this._repository, this.args)
      : super(const MasterclassCheckoutState(quoting: true));

  final MasterclassCheckoutRepository _repository;
  final CheckoutArgs args;

  int _quoteCounter = 0;

  /// Works out the price. Call again when the email or coupon changes. An older
  /// answer that arrives late is ignored.
  Future<void> refresh({String email = '', String? coupon}) async {
    final code = (coupon ?? state.couponCode).trim();
    final id = ++_quoteCounter;
    emit(state.copyWith(
      quoting: true,
      couponCode: code,
      clearQuoteError: true,
      clearOrderError: true,
    ));
    try {
      final quote = await _repository.quote(
        courseIds: args.courseIds,
        mode: args.mode,
        email: email.trim(),
        couponCode: code,
      );
      if (id != _quoteCounter || isClosed) return;
      emit(state.copyWith(quote: quote, quoting: false));
    } on Object catch (error, stackTrace) {
      if (id != _quoteCounter || isClosed) return;
      emit(state.copyWith(
        quoting: false,
        quoteError: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }

  void removeCoupon({String email = ''}) => refresh(email: email, coupon: '');

  /// "Buy now". While payment is in test mode the server records the booking as
  /// paid straight away.
  Future<void> buy(CheckoutDetails details) async {
    if (!state.canBuy) return;
    emit(state.copyWith(placing: true, clearOrderError: true));
    try {
      final result = await _repository.placeOrder(
        courseIds: args.courseIds,
        mode: args.mode,
        details: details,
        couponCode: state.couponCode,
      );
      emit(state.copyWith(placing: false, result: result));
    } on Object catch (error, stackTrace) {
      emit(state.copyWith(
        placing: false,
        orderError: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
