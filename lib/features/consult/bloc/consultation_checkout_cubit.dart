import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/checkout/checkout_models.dart';
import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/consult_checkout_models.dart';
import '../data/consult_checkout_repository.dart';

class ConsultationCheckoutState {
  const ConsultationCheckoutState({
    this.quote,
    this.quoting = false,
    this.placing = false,
    this.couponCode = '',
    this.quoteError,
    this.orderError,
    this.result,
  });

  final ConsultationQuote? quote;
  final bool quoting;

  /// "Book now" is in progress.
  final bool placing;

  /// The coupon the current quote was worked out with.
  final String couponCode;
  final AppException? quoteError;
  final AppException? orderError;
  final ConsultationOrderResult? result;

  bool get canBook =>
      quote != null && quote!.canPay && !quoting && !placing && result == null;

  ConsultationCheckoutState copyWith({
    ConsultationQuote? quote,
    bool? quoting,
    bool? placing,
    String? couponCode,
    AppException? quoteError,
    AppException? orderError,
    ConsultationOrderResult? result,
    bool clearQuoteError = false,
    bool clearOrderError = false,
  }) =>
      ConsultationCheckoutState(
        quote: quote ?? this.quote,
        quoting: quoting ?? this.quoting,
        placing: placing ?? this.placing,
        couponCode: couponCode ?? this.couponCode,
        quoteError: clearQuoteError ? null : quoteError ?? this.quoteError,
        orderError: clearOrderError ? null : orderError ?? this.orderError,
        result: result ?? this.result,
      );
}

/// Price check, coupon and "Book now" for one consultation.
class ConsultationCheckoutCubit extends Cubit<ConsultationCheckoutState> {
  ConsultationCheckoutCubit(this._repository, this.consultationId)
      : super(const ConsultationCheckoutState(quoting: true));

  final ConsultationCheckoutRepository _repository;
  final int consultationId;

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
        consultationId: consultationId,
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

  /// "Book now". While payment is in test mode the server records the booking
  /// as paid straight away.
  Future<void> book(CheckoutDetails details) async {
    if (!state.canBook) return;
    emit(state.copyWith(placing: true, clearOrderError: true));
    try {
      final result = await _repository.placeOrder(
        consultationId: consultationId,
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
