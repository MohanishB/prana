import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/library/data/library_repository.dart';
import '../../features/library/data/mock_library_repository.dart';
import '../../features/masterclass/data/masterclass_repository.dart';
import '../files/file_download_service.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../session/session_manager.dart';
import '../session/session_store.dart';
import '../video/default_video_player_factory.dart';
import '../video/video_player_factory.dart';
import '../video/video_progress_store.dart';
import 'payment_gateway.dart';

class AppDependencies {
  const AppDependencies({
    required this.libraryRepository,
    required this.paymentGateway,
    required this.authRepository,
    required this.masterclassRepository,
    required this.sessionManager,
    required this.fileDownloadService,
    required this.videoPlayerFactory,
    required this.videoProgressStore,
  });

  final LibraryRepository libraryRepository;
  final PaymentGateway paymentGateway;
  final AuthRepository authRepository;
  final MasterclassRepository masterclassRepository;
  final SessionManager sessionManager;
  final FileDownloadService fileDownloadService;
  final VideoPlayerFactory videoPlayerFactory;
  final VideoProgressStore videoProgressStore;

  factory AppDependencies.bootstrap() {
    final secureStorage = FlutterSecureStorage();
    final sessionManager = SessionManager(SecureSessionStore(secureStorage));
    final networkInfo = DefaultNetworkInfo();
    final api = ApiClient(
      networkInfo: networkInfo,
      sessionManager: sessionManager,
    );
    return AppDependencies(
      libraryRepository: MockLibraryRepository(),
      paymentGateway: MockPaymentGateway(),
      authRepository: ApiAuthRepository(api, sessionManager),
      masterclassRepository: ApiMasterclassRepository(api),
      sessionManager: sessionManager,
      fileDownloadService: LocalFileDownloadService(networkInfo: networkInfo),
      videoPlayerFactory: const DefaultVideoPlayerFactory(),
      videoProgressStore: LocalVideoProgressStore(),
    );
  }
}
