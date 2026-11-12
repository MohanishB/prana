import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PRANA'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @masterclass.
  ///
  /// In en, this message translates to:
  /// **'Masterclass'**
  String get masterclass;

  /// No description provided for @consult.
  ///
  /// In en, this message translates to:
  /// **'Consult'**
  String get consult;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @workshops.
  ///
  /// In en, this message translates to:
  /// **'Workshops'**
  String get workshops;

  /// No description provided for @masterclasses.
  ///
  /// In en, this message translates to:
  /// **'Masterclasses'**
  String get masterclasses;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @certificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get certificate;

  /// No description provided for @transcript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get transcript;

  /// No description provided for @consultations.
  ///
  /// In en, this message translates to:
  /// **'Consultations'**
  String get consultations;

  /// No description provided for @consultPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'This section is intentionally blank for now. The feature boundary is ready for availability, booking and payment.'**
  String get consultPlaceholder;

  /// No description provided for @homeDateLabel.
  ///
  /// In en, this message translates to:
  /// **'SUNDAY, 27 AUGUST'**
  String get homeDateLabel;

  /// No description provided for @namasteUser.
  ///
  /// In en, this message translates to:
  /// **'Namaste, {name}'**
  String namasteUser(String name);

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// No description provided for @bookConsultation.
  ///
  /// In en, this message translates to:
  /// **'Book a consultation'**
  String get bookConsultation;

  /// No description provided for @doctorDietPlan.
  ///
  /// In en, this message translates to:
  /// **'Doctor + diet plan'**
  String get doctorDietPlan;

  /// No description provided for @browseMasterclasses.
  ///
  /// In en, this message translates to:
  /// **'Browse masterclasses'**
  String get browseMasterclasses;

  /// No description provided for @coursesAndWorkshops.
  ///
  /// In en, this message translates to:
  /// **'Courses and workshops'**
  String get coursesAndWorkshops;

  /// No description provided for @dayOpenStatus.
  ///
  /// In en, this message translates to:
  /// **'Day 3 of 7 · open now'**
  String get dayOpenStatus;

  /// No description provided for @gutResetAgni.
  ///
  /// In en, this message translates to:
  /// **'Gut Reset — Agni & digestion'**
  String get gutResetAgni;

  /// No description provided for @closesIn.
  ///
  /// In en, this message translates to:
  /// **'Closes in {time}'**
  String closesIn(String time);

  /// No description provided for @playTodaysVideo.
  ///
  /// In en, this message translates to:
  /// **'Play today\'s video'**
  String get playTodaysVideo;

  /// No description provided for @ayurvedaHerbalism.
  ///
  /// In en, this message translates to:
  /// **'Ayurveda & Herbalism'**
  String get ayurvedaHerbalism;

  /// No description provided for @chapter3Sankhya.
  ///
  /// In en, this message translates to:
  /// **'Chapter 3 · Sankhya Philosophy'**
  String get chapter3Sankhya;

  /// No description provided for @sevenDayGutReset.
  ///
  /// In en, this message translates to:
  /// **'7-Day Gut Reset'**
  String get sevenDayGutReset;

  /// No description provided for @gutResetProgress.
  ///
  /// In en, this message translates to:
  /// **'Started 21 Aug · 2 of 7 watched'**
  String get gutResetProgress;

  /// No description provided for @day3Open.
  ///
  /// In en, this message translates to:
  /// **'Day 3 open'**
  String get day3Open;

  /// No description provided for @threeDayImmunityBooster.
  ///
  /// In en, this message translates to:
  /// **'3-Day Immunity Booster'**
  String get threeDayImmunityBooster;

  /// No description provided for @immunityUnlock.
  ///
  /// In en, this message translates to:
  /// **'Day 1 unlocks 24 Aug, 6:00 AM'**
  String get immunityUnlock;

  /// No description provided for @startsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Starts tomorrow'**
  String get startsTomorrow;

  /// No description provided for @fiveDaySleepRitual.
  ///
  /// In en, this message translates to:
  /// **'5-Day Sleep Ritual'**
  String get fiveDaySleepRitual;

  /// No description provided for @sleepRitualCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed 2 Aug · notes saved'**
  String get sleepRitualCompleted;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @courseProgressPending.
  ///
  /// In en, this message translates to:
  /// **'2 of 5 chapters · 1 quiz pending'**
  String get courseProgressPending;

  /// No description provided for @resumeChapter3.
  ///
  /// In en, this message translates to:
  /// **'Resume Chapter 3'**
  String get resumeChapter3;

  /// No description provided for @ayurvedicNutrition.
  ///
  /// In en, this message translates to:
  /// **'Ayurvedic Nutrition'**
  String get ayurvedicNutrition;

  /// No description provided for @allChaptersComplete.
  ///
  /// In en, this message translates to:
  /// **'All chapters complete'**
  String get allChaptersComplete;

  /// No description provided for @certificateReady.
  ///
  /// In en, this message translates to:
  /// **'Certificate ready'**
  String get certificateReady;

  /// No description provided for @herbsWomensHealth.
  ///
  /// In en, this message translates to:
  /// **'Herbs for Women\'s Health'**
  String get herbsWomensHealth;

  /// No description provided for @sixChaptersDuration.
  ///
  /// In en, this message translates to:
  /// **'6 chapters · 3h 20m'**
  String get sixChaptersDuration;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get notStarted;

  /// No description provided for @masterclassesLifetime.
  ///
  /// In en, this message translates to:
  /// **'Masterclasses stay unlocked for life.'**
  String get masterclassesLifetime;

  /// No description provided for @courseIntro.
  ///
  /// In en, this message translates to:
  /// **'Course intro'**
  String get courseIntro;

  /// No description provided for @watchFirst4Min.
  ///
  /// In en, this message translates to:
  /// **'Watch first · 4 min'**
  String get watchFirst4Min;

  /// No description provided for @foundationsAyurvedaHerbalism.
  ///
  /// In en, this message translates to:
  /// **'Foundations of Ayurveda & Herbalism'**
  String get foundationsAyurvedaHerbalism;

  /// No description provided for @threeVideosNotes.
  ///
  /// In en, this message translates to:
  /// **'3 videos · notes'**
  String get threeVideosNotes;

  /// No description provided for @doshasDhatusBalance.
  ///
  /// In en, this message translates to:
  /// **'Doshas, Dhatus & the Path to Balance'**
  String get doshasDhatusBalance;

  /// No description provided for @fiveVideosQuizNotes.
  ///
  /// In en, this message translates to:
  /// **'5 videos · quiz · notes'**
  String get fiveVideosQuizNotes;

  /// No description provided for @sankhyaGunasHealing.
  ///
  /// In en, this message translates to:
  /// **'Sankhya Philosophy, Gunas & Herbal Healing'**
  String get sankhyaGunasHealing;

  /// No description provided for @fourVideosQuizPending.
  ///
  /// In en, this message translates to:
  /// **'4 videos · quiz pending'**
  String get fourVideosQuizPending;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @spicesForWellness.
  ///
  /// In en, this message translates to:
  /// **'Spices for Wellness: Black Pepper & more'**
  String get spicesForWellness;

  /// No description provided for @sixVideosQuizNotes.
  ///
  /// In en, this message translates to:
  /// **'6 videos · quiz · notes'**
  String get sixVideosQuizNotes;

  /// No description provided for @masterclassEyebrow.
  ///
  /// In en, this message translates to:
  /// **'MASTERCLASS'**
  String get masterclassEyebrow;

  /// No description provided for @certificateCompletion.
  ///
  /// In en, this message translates to:
  /// **'CERTIFICATE OF COMPLETION'**
  String get certificateCompletion;

  /// No description provided for @certificateRecipient.
  ///
  /// In en, this message translates to:
  /// **'Lochan Gaikwad'**
  String get certificateRecipient;

  /// No description provided for @certificateCompletedMasterclass.
  ///
  /// In en, this message translates to:
  /// **'has completed the masterclass'**
  String get certificateCompletedMasterclass;

  /// No description provided for @certificateDateIssuer.
  ///
  /// In en, this message translates to:
  /// **'27 August 2026 · Prana Academy for Ayurvedic Lifesciences'**
  String get certificateDateIssuer;

  /// No description provided for @certificateId.
  ///
  /// In en, this message translates to:
  /// **'ID {id}'**
  String certificateId(String id);

  /// No description provided for @certificateApiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Certificate download is not available yet. Please try again later.'**
  String get certificateApiUnavailable;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @certificateNameNotice.
  ///
  /// In en, this message translates to:
  /// **'Name is printed exactly as it appears in your profile. Change it in Account before downloading if it\'s wrong.'**
  String get certificateNameNotice;

  /// No description provided for @accountUserName.
  ///
  /// In en, this message translates to:
  /// **'Lochan Gaikwad'**
  String get accountUserName;

  /// No description provided for @accountContact.
  ///
  /// In en, this message translates to:
  /// **'lochan@example.com · +91 90000 00000'**
  String get accountContact;

  /// No description provided for @bookedConsultations.
  ///
  /// In en, this message translates to:
  /// **'My booked consultations'**
  String get bookedConsultations;

  /// No description provided for @liveQaSessions.
  ///
  /// In en, this message translates to:
  /// **'Live Q&A sessions'**
  String get liveQaSessions;

  /// No description provided for @myCertificates.
  ///
  /// In en, this message translates to:
  /// **'My certificates'**
  String get myCertificates;

  /// No description provided for @noCertificateGeneratedYet.
  ///
  /// In en, this message translates to:
  /// **'No certificate generated yet'**
  String get noCertificateGeneratedYet;

  /// No description provided for @noLiveSessionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Currently no sessions are available'**
  String get noLiveSessionsAvailable;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get couldNotOpenLink;

  /// No description provided for @cmsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Content coming soon'**
  String get cmsComingSoon;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get contactEmail;

  /// No description provided for @contactCall.
  ///
  /// In en, this message translates to:
  /// **'Call us'**
  String get contactCall;

  /// No description provided for @contactWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get contactWhatsapp;

  /// No description provided for @contactWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit our website'**
  String get contactWebsite;

  /// No description provided for @contactFollowUs.
  ///
  /// In en, this message translates to:
  /// **'Follow us'**
  String get contactFollowUs;

  /// No description provided for @liveSessionJoinOpens.
  ///
  /// In en, this message translates to:
  /// **'Joining opens {time}'**
  String liveSessionJoinOpens(String time);

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @dailyAtSix.
  ///
  /// In en, this message translates to:
  /// **'Daily at 6:00 AM'**
  String get dailyAtSix;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @termsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & privacy'**
  String get termsPrivacy;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Toggle light and dark appearance'**
  String get darkModeDescription;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Prana By Dimple · v1.0'**
  String get copyright;

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search PRANA YouTube'**
  String get librarySearchHint;

  /// No description provided for @librarySearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Search this PRANA YouTube channel across video titles and descriptions, including Shorts and podcast videos.'**
  String get librarySearchDescription;

  /// No description provided for @libraryNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching PRANA YouTube videos found.'**
  String get libraryNoResults;

  /// No description provided for @videoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Video not found.'**
  String get videoNotFound;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Check your internet connection and try again.'**
  String get errorNoInternet;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'This is taking longer than expected. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read the server response. Please try again.'**
  String get errorInvalidResponse;

  /// No description provided for @errorLibraryLoad.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the video library. Please try again.'**
  String get errorLibraryLoad;

  /// No description provided for @errorLibrarySearch.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t search the video library. Please try again.'**
  String get errorLibrarySearch;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your PRANA journey.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get passwordRequired;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect. Please try again.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorAccountInactive.
  ///
  /// In en, this message translates to:
  /// **'Your account is inactive. Please contact PRANA support.'**
  String get errorAccountInactive;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorSessionExpired;

  /// No description provided for @errorAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to access this content.'**
  String get errorAccessDenied;

  /// No description provided for @errorCourseNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'This masterclass is not available in your account.'**
  String get errorCourseNotAssigned;

  /// No description provided for @errorCourseNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this masterclass.'**
  String get errorCourseNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Some information is missing or invalid. Please check and try again.'**
  String get errorValidation;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'PRANA is temporarily unavailable. Please try again shortly.'**
  String get errorServer;

  /// No description provided for @noMasterclasses.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any masterclasses yet.'**
  String get noMasterclasses;

  /// No description provided for @chapterProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} chapters completed'**
  String chapterProgress(int completed, int total);

  /// No description provided for @chapterContents.
  ///
  /// In en, this message translates to:
  /// **'{videos} videos · {quizzes} quiz · {notes} notes'**
  String chapterContents(int videos, int quizzes, int notes);

  /// No description provided for @intro.
  ///
  /// In en, this message translates to:
  /// **'Intro'**
  String get intro;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @chapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapters;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Prev'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noVideos.
  ///
  /// In en, this message translates to:
  /// **'No videos are available for this chapter.'**
  String get noVideos;

  /// No description provided for @quizUnavailable.
  ///
  /// In en, this message translates to:
  /// **'There is no quiz for this chapter.'**
  String get quizUnavailable;

  /// No description provided for @chapterQuiz.
  ///
  /// In en, this message translates to:
  /// **'Chapter quiz'**
  String get chapterQuiz;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start quiz'**
  String get startQuiz;

  /// No description provided for @quizSubmissionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Quiz submission will be enabled when the submit-quiz API is integrated.'**
  String get quizSubmissionComingSoon;

  /// No description provided for @questionShort.
  ///
  /// In en, this message translates to:
  /// **'Q'**
  String get questionShort;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes are available for this chapter.'**
  String get noNotes;

  /// No description provided for @chapterNumber.
  ///
  /// In en, this message translates to:
  /// **'CHAPTER {number}'**
  String chapterNumber(int number);

  /// No description provided for @quizQuestions.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String quizQuestions(int count);

  /// No description provided for @quizScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {correct} of {total}'**
  String quizScore(int correct, int total);

  /// No description provided for @downloadedOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Downloaded · tap to open'**
  String get downloadedOpenFile;

  /// No description provided for @tapToDownloadAndOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to download and open'**
  String get tapToDownloadAndOpen;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get openFile;

  /// No description provided for @downloadFile.
  ///
  /// In en, this message translates to:
  /// **'Download file'**
  String get downloadFile;

  /// No description provided for @errorDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t download this file. Please try again.'**
  String get errorDownloadFailed;

  /// No description provided for @errorFileOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open this file on your device.'**
  String get errorFileOpenFailed;

  /// No description provided for @errorFileNotDownloaded.
  ///
  /// In en, this message translates to:
  /// **'This file hasn\'t been downloaded yet.'**
  String get errorFileNotDownloaded;

  /// No description provided for @certificatePdf.
  ///
  /// In en, this message translates to:
  /// **'Certificate PDF'**
  String get certificatePdf;

  /// No description provided for @tapToViewCertificate.
  ///
  /// In en, this message translates to:
  /// **'Tap to view your certificate.'**
  String get tapToViewCertificate;

  /// No description provided for @certificateGeneratedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on {date}'**
  String certificateGeneratedOn(String date);

  /// No description provided for @errorVideoPlayback.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t play this video. Please try again.'**
  String get errorVideoPlayback;

  /// No description provided for @errorVideoProviderUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This video provider isn\'t supported yet.'**
  String get errorVideoProviderUnsupported;

  /// No description provided for @videoResumedAt.
  ///
  /// In en, this message translates to:
  /// **'Resumed from {position}'**
  String videoResumedAt(String position);

  /// No description provided for @viewChapters.
  ///
  /// In en, this message translates to:
  /// **'View chapters'**
  String get viewChapters;

  /// No description provided for @getCertificate.
  ///
  /// In en, this message translates to:
  /// **'Get certificate'**
  String get getCertificate;

  /// No description provided for @generatingCertificate.
  ///
  /// In en, this message translates to:
  /// **'Generating certificate...'**
  String get generatingCertificate;

  /// No description provided for @certificateNotGenerated.
  ///
  /// In en, this message translates to:
  /// **'Your certificate has not been generated yet.'**
  String get certificateNotGenerated;

  /// No description provided for @submitQuiz.
  ///
  /// In en, this message translates to:
  /// **'Submit quiz'**
  String get submitQuiz;

  /// No description provided for @submittingQuiz.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submittingQuiz;

  /// No description provided for @quizSubmitWarning.
  ///
  /// In en, this message translates to:
  /// **'Quiz answers can only be submitted once. You will not be able to change them afterwards.'**
  String get quizSubmitWarning;

  /// No description provided for @confirmQuizSubmission.
  ///
  /// In en, this message translates to:
  /// **'Submit quiz?'**
  String get confirmQuizSubmission;

  /// No description provided for @confirmSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get confirmSubmit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @answerEveryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Please answer every question before submitting.'**
  String get answerEveryQuestion;

  /// No description provided for @quizResult.
  ///
  /// In en, this message translates to:
  /// **'Quiz result'**
  String get quizResult;

  /// No description provided for @quizCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get quizCorrect;

  /// No description provided for @quizIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get quizIncorrect;

  /// No description provided for @quizSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Quiz submitted successfully.'**
  String get quizSubmitted;

  /// No description provided for @errorChapterNotFound.
  ///
  /// In en, this message translates to:
  /// **'This chapter could not be found.'**
  String get errorChapterNotFound;

  /// No description provided for @errorQuizNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'A quiz is not available for this chapter.'**
  String get errorQuizNotAvailable;

  /// No description provided for @errorIncompleteQuizAnswers.
  ///
  /// In en, this message translates to:
  /// **'Please answer every quiz question before submitting.'**
  String get errorIncompleteQuizAnswers;

  /// No description provided for @errorQuizAlreadySubmitted.
  ///
  /// In en, this message translates to:
  /// **'This quiz has already been submitted.'**
  String get errorQuizAlreadySubmitted;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @middleName.
  ///
  /// In en, this message translates to:
  /// **'Middle name'**
  String get middleName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincode;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @readOnlyField.
  ///
  /// In en, this message translates to:
  /// **'This information cannot be changed here.'**
  String get readOnlyField;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// No description provided for @profileFieldInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use letters, numbers, and spaces only.'**
  String get profileFieldInvalid;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdated;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @changePasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and choose a new password with at least 6 characters.'**
  String get changePasswordDescription;

  /// No description provided for @passwordMinimumSix.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMinimumSix;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @updatingPassword.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updatingPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChanged;

  /// No description provided for @errorProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your profile. Please try again.'**
  String get errorProfileNotFound;

  /// No description provided for @errorCurrentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Your current password is incorrect.'**
  String get errorCurrentPasswordIncorrect;

  /// No description provided for @errorPhotoUpload.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t upload the profile photo. Please try again.'**
  String get errorPhotoUpload;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// No description provided for @profilePhotoFormat.
  ///
  /// In en, this message translates to:
  /// **'Please select a JPG, JPEG, or PNG image.'**
  String get profilePhotoFormat;

  /// No description provided for @profilePhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Profile photo must be 5 MB or smaller.'**
  String get profilePhotoTooLarge;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqTitle;

  /// No description provided for @faqDescription.
  ///
  /// In en, this message translates to:
  /// **'Find quick answers to common questions about the academy, courses, and learning experience.'**
  String get faqDescription;

  /// No description provided for @faqQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String faqQuestionCount(int count);

  /// No description provided for @noFaqsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No FAQs are available right now.'**
  String get noFaqsAvailable;

  /// No description provided for @needMoreHelp.
  ///
  /// In en, this message translates to:
  /// **'Need more help?'**
  String get needMoreHelp;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @errorLibraryConfiguration.
  ///
  /// In en, this message translates to:
  /// **'The video library is temporarily unavailable. Please try again later.'**
  String get errorLibraryConfiguration;

  /// No description provided for @librarySwipeForMore.
  ///
  /// In en, this message translates to:
  /// **'Swipe up or down for more videos'**
  String get librarySwipeForMore;

  /// No description provided for @libraryPlaybackUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This video can’t be played inside the app.'**
  String get libraryPlaybackUnavailable;

  /// No description provided for @libraryWatchOnYoutube.
  ///
  /// In en, this message translates to:
  /// **'Watch on YouTube'**
  String get libraryWatchOnYoutube;

  /// No description provided for @librarySearching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get librarySearching;

  /// No description provided for @libraryLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more videos…'**
  String get libraryLoadingMore;

  /// No description provided for @libraryExpandDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap description to read more'**
  String get libraryExpandDescription;

  /// No description provided for @libraryCollapseDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap again to collapse'**
  String get libraryCollapseDescription;

  /// No description provided for @librarySearchComplete.
  ///
  /// In en, this message translates to:
  /// **'Search complete · {count, plural, =0{No results} =1{1 result loaded} other{{count} results loaded}}'**
  String librarySearchComplete(int count);

  /// No description provided for @skipLogin.
  ///
  /// In en, this message translates to:
  /// **'Skip login'**
  String get skipLogin;

  /// No description provided for @skipLoginHint.
  ///
  /// In en, this message translates to:
  /// **'You can look around and book without an account.'**
  String get skipLoginHint;

  /// No description provided for @guestAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re browsing as a guest'**
  String get guestAccountTitle;

  /// No description provided for @guestAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see what you have booked.'**
  String get guestAccountSubtitle;

  /// No description provided for @friendFallback.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get friendFallback;

  /// No description provided for @gutResetPrograms.
  ///
  /// In en, this message translates to:
  /// **'Gut Reset programs'**
  String get gutResetPrograms;

  /// No description provided for @programsYouCanBook.
  ///
  /// In en, this message translates to:
  /// **'Programs you can book'**
  String get programsYouCanBook;

  /// No description provided for @bookAnotherProgram.
  ///
  /// In en, this message translates to:
  /// **'Book a program'**
  String get bookAnotherProgram;

  /// No description provided for @masterclassesYouCanBook.
  ///
  /// In en, this message translates to:
  /// **'Masterclasses you can book'**
  String get masterclassesYouCanBook;

  /// No description provided for @availableToBook.
  ///
  /// In en, this message translates to:
  /// **'Available to book'**
  String get availableToBook;

  /// No description provided for @nothingToBook.
  ///
  /// In en, this message translates to:
  /// **'Nothing is available to book right now.'**
  String get nothingToBook;

  /// No description provided for @consultListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book a private session with the PRANA team.'**
  String get consultListSubtitle;

  /// No description provided for @dayOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total} · open now'**
  String dayOpenNow(int day, int total);

  /// No description provided for @programDays.
  ///
  /// In en, this message translates to:
  /// **'{count}-day program'**
  String programDays(int count);

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy now'**
  String get buyNow;

  /// No description provided for @bookThisProgram.
  ///
  /// In en, this message translates to:
  /// **'Book this program'**
  String get bookThisProgram;

  /// No description provided for @openMasterclass.
  ///
  /// In en, this message translates to:
  /// **'Open masterclass'**
  String get openMasterclass;

  /// No description provided for @alreadyBooked.
  ///
  /// In en, this message translates to:
  /// **'You have already booked this consultation.'**
  String get alreadyBooked;

  /// No description provided for @programAlreadyBooked.
  ///
  /// In en, this message translates to:
  /// **'You already have this program running or booked.'**
  String get programAlreadyBooked;

  /// No description provided for @notAvailableToBuy.
  ///
  /// In en, this message translates to:
  /// **'This masterclass is not available to buy right now.'**
  String get notAvailableToBuy;

  /// No description provided for @bookingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Booking opens in the next update.'**
  String get bookingComingSoon;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameRequired;

  /// No description provided for @countryRequired.
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get countryRequired;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @mobileNumberIndia.
  ///
  /// In en, this message translates to:
  /// **'Enter a 10 digit mobile number'**
  String get mobileNumberIndia;

  /// No description provided for @mobileNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number'**
  String get mobileNumberInvalid;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @goToCart.
  ///
  /// In en, this message translates to:
  /// **'Go to cart'**
  String get goToCart;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty.'**
  String get cartEmpty;

  /// No description provided for @cartEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add masterclasses to buy them together.'**
  String get cartEmptyHint;

  /// No description provided for @removeFromCart.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeFromCart;

  /// No description provided for @cartPriceNote.
  ///
  /// In en, this message translates to:
  /// **'The final price, with Level 1 and any discount, is shown at checkout.'**
  String get cartPriceNote;

  /// No description provided for @cartItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 masterclass} other{{count} masterclasses}}'**
  String cartItemsCount(int count);

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get proceedToCheckout;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @yourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get yourDetails;

  /// No description provided for @couponCode.
  ///
  /// In en, this message translates to:
  /// **'Discount code'**
  String get couponCode;

  /// No description provided for @applyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyCoupon;

  /// No description provided for @removeCoupon.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeCoupon;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @totalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total payable'**
  String get totalPayable;

  /// No description provided for @includedFree.
  ///
  /// In en, this message translates to:
  /// **'Included free'**
  String get includedFree;

  /// No description provided for @alreadyEnrolledNote.
  ///
  /// In en, this message translates to:
  /// **'Already enrolled'**
  String get alreadyEnrolledNote;

  /// No description provided for @buyNowAmount.
  ///
  /// In en, this message translates to:
  /// **'Buy now · {amount}'**
  String buyNowAmount(String amount);

  /// No description provided for @confirmFreeOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get confirmFreeOrder;

  /// No description provided for @checkingPrice.
  ///
  /// In en, this message translates to:
  /// **'Checking price…'**
  String get checkingPrice;

  /// No description provided for @checkPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Check payment status'**
  String get checkPaymentStatus;

  /// No description provided for @testModeNotice.
  ///
  /// In en, this message translates to:
  /// **'Test mode: no payment is taken. Your order is recorded as paid so the flow can be checked.'**
  String get testModeNotice;

  /// No description provided for @orderSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed'**
  String get orderSuccessTitle;

  /// No description provided for @orderSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your masterclass is ready.'**
  String get orderSuccessBody;

  /// No description provided for @newAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Your student account is ready'**
  String get newAccountTitle;

  /// No description provided for @newAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in with {email} and the password {password}. Please change it after you sign in.'**
  String newAccountBody(String email, String password);

  /// No description provided for @existingAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your existing password to start learning.'**
  String get existingAccountBody;

  /// No description provided for @checkEmailNote.
  ///
  /// In en, this message translates to:
  /// **'We have also emailed the details to {email}.'**
  String checkEmailNote(String email);

  /// No description provided for @emailNotSentNote.
  ///
  /// In en, this message translates to:
  /// **'We could not send the email, but your account is ready.'**
  String get emailNotSentNote;

  /// No description provided for @coursesAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to your account'**
  String get coursesAdded;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get amountPaid;

  /// No description provided for @testOrderBadge.
  ///
  /// In en, this message translates to:
  /// **'Test order'**
  String get testOrderBadge;

  /// No description provided for @signInToStart.
  ///
  /// In en, this message translates to:
  /// **'Sign in to start'**
  String get signInToStart;

  /// No description provided for @openMyMasterclasses.
  ///
  /// In en, this message translates to:
  /// **'Open my masterclasses'**
  String get openMyMasterclasses;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get bookNow;

  /// No description provided for @bookNowAmount.
  ///
  /// In en, this message translates to:
  /// **'Book now · {amount}'**
  String bookNowAmount(String amount);

  /// No description provided for @confirmFreeBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmFreeBooking;

  /// No description provided for @consultationLabel.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get consultationLabel;

  /// No description provided for @bookingConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get bookingConfirmedTitle;

  /// No description provided for @bookingConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'Your consultation is booked. Next, choose your date and time.'**
  String get bookingConfirmedBody;

  /// No description provided for @scheduleNow.
  ///
  /// In en, this message translates to:
  /// **'Choose date and time'**
  String get scheduleNow;

  /// No description provided for @scheduleEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We have emailed the link to schedule to {email}.'**
  String scheduleEmailSent(String email);

  /// No description provided for @scheduleEmailNotSent.
  ///
  /// In en, this message translates to:
  /// **'We could not send the email. Open My consultations any time to choose your date and time.'**
  String get scheduleEmailNotSent;

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule your consultation'**
  String get scheduleTitle;

  /// No description provided for @backToConsultations.
  ///
  /// In en, this message translates to:
  /// **'Back to consultations'**
  String get backToConsultations;

  /// No description provided for @myConsultations.
  ///
  /// In en, this message translates to:
  /// **'My consultations'**
  String get myConsultations;

  /// No description provided for @noBookedConsultations.
  ///
  /// In en, this message translates to:
  /// **'You have not booked a consultation yet.'**
  String get noBookedConsultations;

  /// No description provided for @bookedOnDate.
  ///
  /// In en, this message translates to:
  /// **'Booked on {date}'**
  String bookedOnDate(String date);

  /// No description provided for @scheduledFor.
  ///
  /// In en, this message translates to:
  /// **'Scheduled: {when}'**
  String scheduledFor(String when);

  /// No description provided for @scheduleNotReady.
  ///
  /// In en, this message translates to:
  /// **'The scheduling page is not ready yet. We will email you.'**
  String get scheduleNotReady;

  /// No description provided for @doshaQuiz.
  ///
  /// In en, this message translates to:
  /// **'Dosha Quiz'**
  String get doshaQuiz;

  /// No description provided for @doshaQuizSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find your Prakriti: Vata, Pitta or Kapha'**
  String get doshaQuizSubtitle;

  /// No description provided for @doshaQuestionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String doshaQuestionOf(int current, int total);

  /// No description provided for @doshaBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get doshaBack;

  /// No description provided for @doshaDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost done'**
  String get doshaDetailsTitle;

  /// No description provided for @doshaDetailsBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to see your Prakriti result.'**
  String get doshaDetailsBody;

  /// No description provided for @doshaGetResult.
  ///
  /// In en, this message translates to:
  /// **'Get your Prakriti result'**
  String get doshaGetResult;

  /// No description provided for @doshaHi.
  ///
  /// In en, this message translates to:
  /// **'Hi {name},'**
  String doshaHi(String name);

  /// No description provided for @doshaYourDosha.
  ///
  /// In en, this message translates to:
  /// **'YOUR DOSHA : {dosha}'**
  String doshaYourDosha(String dosha);

  /// No description provided for @doshaRetake.
  ///
  /// In en, this message translates to:
  /// **'Take the quiz again'**
  String get doshaRetake;

  /// No description provided for @gutResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Book now (test mode)?'**
  String get gutResetConfirmTitle;

  /// No description provided for @gutResetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'No payment is taken. Your booking is recorded as paid so the flow can be checked.'**
  String get gutResetConfirmBody;

  /// No description provided for @gutResetBookedStarts.
  ///
  /// In en, this message translates to:
  /// **'Your program starts on {date}. Its days open on Friday, Saturday and Sunday.'**
  String gutResetBookedStarts(String date);

  /// No description provided for @gutResetBookedStartWhenReady.
  ///
  /// In en, this message translates to:
  /// **'Open Day 1 whenever you are ready. Each next day opens 24 hours after the one before.'**
  String get gutResetBookedStartWhenReady;

  /// No description provided for @openMyPrograms.
  ///
  /// In en, this message translates to:
  /// **'Open my programs'**
  String get openMyPrograms;

  /// No description provided for @startDayOne.
  ///
  /// In en, this message translates to:
  /// **'Start Day 1'**
  String get startDayOne;

  /// No description provided for @startDayOneConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Day 1 now?'**
  String get startDayOneConfirmTitle;

  /// No description provided for @startDayOneConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Day 1 opens right away. Each next day opens 24 hours after the one before.'**
  String get startDayOneConfirmBody;

  /// No description provided for @programNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get programNotStarted;

  /// No description provided for @programNotStartedHint.
  ///
  /// In en, this message translates to:
  /// **'Tap Start Day 1 when you are ready.'**
  String get programNotStartedHint;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @notificationsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get notificationsLoadMore;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeMinutesAgo(int count);

  /// No description provided for @pushPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop'**
  String get pushPromptTitle;

  /// No description provided for @pushPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Get class reminders, booking updates and messages from Prana right on your phone.'**
  String get pushPromptBody;

  /// No description provided for @pushPromptTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get pushPromptTurnOn;

  /// No description provided for @pushPromptNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get pushPromptNotNow;

  /// No description provided for @pushOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get pushOffTitle;

  /// No description provided for @pushOffNote.
  ///
  /// In en, this message translates to:
  /// **'To get reminders and updates, turn on notifications for Prana in your phone\'s settings.'**
  String get pushOffNote;

  /// No description provided for @pushBannerOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get pushBannerOpen;

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String timeHoursAgo(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
