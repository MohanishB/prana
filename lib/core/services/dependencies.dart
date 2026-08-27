import '../../features/library/data/library_repository.dart';
import '../../features/library/data/mock_library_repository.dart';
import 'payment_gateway.dart';

class AppDependencies {
  const AppDependencies({
    required this.libraryRepository,
    required this.paymentGateway,
  });

  final LibraryRepository libraryRepository;
  final PaymentGateway paymentGateway;

  factory AppDependencies.bootstrap() {
    return AppDependencies(
      libraryRepository: MockLibraryRepository(),
      paymentGateway: MockPaymentGateway(),
    );
  }
}
