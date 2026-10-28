import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/account/data/account_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/consult/data/consult_checkout_repository.dart';
import '../../features/consult/data/consult_repository.dart';
import '../../features/dosha_quiz/data/dosha_repository.dart';
import '../../features/faq/data/faq_repository.dart';
import '../../features/gut_reset/data/gut_reset_repository.dart';
import '../../features/home/data/home_repository.dart';
import '../../features/library/data/library_data_source.dart';
import '../../features/library/data/library_repository.dart';
import '../../features/masterclass/data/masterclass_checkout_repository.dart';
import '../../features/masterclass/data/masterclass_offer_repository.dart';
import '../../features/masterclass/data/masterclass_repository.dart';
import '../../features/workshops/data/workshop_repository.dart';
import '../data/country_repository.dart';
import '../files/file_download_service.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../session/session_manager.dart';
import '../session/session_store.dart';
import '../video/default_video_player_factory.dart';
import '../video/video_player_factory.dart';
import '../video/video_progress_store.dart';

class AppDependencies {
  const AppDependencies({
    required this.libraryRepository,
    required this.accountRepository,
    required this.faqRepository,
    required this.authRepository,
    required this.masterclassRepository,
    required this.masterclassOfferRepository,
    required this.masterclassCheckoutRepository,
    required this.homeRepository,
    required this.consultRepository,
    required this.consultCheckoutRepository,
    required this.doshaRepository,
    required this.gutResetRepository,
    required this.countryRepository,
    required this.workshopRepository,
    required this.sessionManager,
    required this.fileDownloadService,
    required this.videoPlayerFactory,
    required this.videoProgressStore,
  });

  final LibraryRepository libraryRepository;
  final AccountRepository accountRepository;
  final FaqRepository faqRepository;
  final AuthRepository authRepository;
  final MasterclassRepository masterclassRepository;
  final MasterclassOfferRepository masterclassOfferRepository;
  final MasterclassCheckoutRepository masterclassCheckoutRepository;
  final HomeRepository homeRepository;
  final ConsultRepository consultRepository;
  final ConsultationCheckoutRepository consultCheckoutRepository;
  final DoshaRepository doshaRepository;
  final GutResetRepository gutResetRepository;
  final CountryRepository countryRepository;
  final WorkshopRepository workshopRepository;
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
      libraryRepository: createLibraryRepository(api),
      accountRepository: ApiAccountRepository(api, sessionManager),
      faqRepository: ApiFaqRepository(api),
      authRepository: ApiAuthRepository(api, sessionManager),
      masterclassRepository: ApiMasterclassRepository(api),
      masterclassOfferRepository:
          ApiMasterclassOfferRepository(api, sessionManager),
      masterclassCheckoutRepository:
          ApiMasterclassCheckoutRepository(api, sessionManager),
      homeRepository: ApiHomeRepository(api, sessionManager),
      consultRepository: ApiConsultRepository(api, sessionManager),
      consultCheckoutRepository:
          ApiConsultationCheckoutRepository(api, sessionManager),
      doshaRepository: ApiDoshaRepository(api, sessionManager),
      gutResetRepository: ApiGutResetRepository(api, sessionManager),
      countryRepository: ApiCountryRepository(api),
      workshopRepository: ApiWorkshopRepository(api),
      sessionManager: sessionManager,
      fileDownloadService: LocalFileDownloadService(networkInfo: networkInfo),
      videoPlayerFactory: const DefaultVideoPlayerFactory(),
      videoProgressStore: LocalVideoProgressStore(),
    );
  }
}
