import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/checkout/checkout_models.dart';
import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/payment/payment_gateway.dart';
import '../../../core/payment/payment_models.dart';
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
    this.pendingPayment,
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

  /// Razorpay took the money but the server has not confirmed it yet (e.g. no internet).
  /// Nothing is charged twice: the button then only re-checks this payment.
  final PaymentSucceeded? pendingPayment;

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
    PaymentSucceeded? pendingPayment,
    bool clearPending = false,
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
        pendingPayment:
            clearPending ? null : pendingPayment ?? this.pendingPayment,
      );
}

/// Price check, coupon and "Buy now" for one masterclass or the cart.
class MasterclassCheckoutCubit extends Cubit<MasterclassCheckoutState> {
  MasterclassCheckoutCubit(this._repository, this._gateway, this.args)
      : super(const MasterclassCheckoutState(quoting: true));

  final MasterclassCheckoutRepository _repository;
  final PaymentGateway _gateway;
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

  /// "Buy now". A free order (or the server's test mode) is finished at once; otherwise
  /// Razorpay's payment screen opens, and the order is completed only after the server
  /// has verified the payment. If a payment already went through but was not confirmed,
  /// this only re-checks that payment (the customer is never charged twice).
  Future<void> buy(CheckoutDetails details) async {
    if (!state.canBuy) return;
    final pending = state.pendingPayment;
    if (pending != null) {
      await _confirm(pending);
      return;
    }
    emit(state.copyWith(placing: true, clearOrderError: true));
    try {
      final start = await _repository.placeOrder(
        courseIds: args.courseIds,
        mode: args.mode,
        details: details,
        couponCode: state.couponCode,
      );
      final done = start.result;
      if (done != null) {
        emit(state.copyWith(placing: false, result: done));
        return;
      }
      final outcome = await _gateway.pay(start.payment!);
      if (isClosed) return;
      switch (outcome) {
        case final PaymentSucceeded success:
          await _confirm(success);
        case PaymentCancelled():
          emit(state.copyWith(
            placing: false,
            orderError: const AppException(
              AppErrorType.checkout,
              serverMessage: 'Payment cancelled. You were not charged.',
            ),
          ));
        case final PaymentFailed failed:
          emit(state.copyWith(
            placing: false,
            orderError: AppException(
              AppErrorType.checkout,
              serverMessage: '${failed.message} You can try again.',
            ),
          ));
      }
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      emit(state.copyWith(
        placing: false,
        orderError: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }

  Future<void> _confirm(PaymentSucceeded payment) async {
    emit(state.copyWith(
      placing: true,
      pendingPayment: payment,
      clearOrderError: true,
    ));
    try {
      final result = await _repository.confirmPayment(payment);
      if (isClosed) return;
      emit(state.copyWith(placing: false, result: result, clearPending: true));
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      final normalized =
          ApiErrorHandler.normalize(error, stackTrace: stackTrace);
      // The server answered with a reason (payment not verified, booking not
      // found): trying again cannot help. Anything else (no internet, timeout,
      // server down, a failed save) is worth another try, so the payment is kept.
      final answered = normalized.type == AppErrorType.checkout &&
          normalized.errorCode != 'CHECKOUT_SAVE_FAILED';
      emit(state.copyWith(
        placing: false,
        clearPending: answered,
        orderError: answered
            ? normalized
            : const AppException(
                AppErrorType.checkout,
                serverMessage:
                    'Your payment went through, but we could not confirm it yet. '
                    'Tap "Check payment status".',
              ),
      ));
    }
  }
}
