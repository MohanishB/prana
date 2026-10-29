abstract final class ApiConstants {
  // Temporary backend URL for the current integration environment.
  // Restore the production URL only when the backend team confirms the switch.
  // https://www.pranabydimpleacademy.com/lms/asdqw/student_app_webservices
  static const baseUrl =
      'https://www.retailsite.co.za/prana/student_app_webservices';
  static const workshopPrograms = '/gut_reset/my_programs.php';
  static const workshopDetail = '/gut_reset/program_detail.php';
  static const workshopDayVideo = '/gut_reset/day_video.php';
  static const workshopMarkDayDone = '/gut_reset/mark_day_done.php';
  static const workshopStartDayOne = '/gut_reset/start_day_one.php';
  static const login = '/auth/login.php';
  static const logout = '/auth/logout.php';
  static const devicesRegister = '/devices/register.php';
  // Home data for a logged-in student, and the public (guest) catalogue.
  static const home = '/home/home.php';
  static const catalogHome = '/catalog/home.php';
  // Public lists / details; a token is sent when the visitor is logged in.
  static const catalogMasterclasses = '/catalog/masterclasses.php';
  static const catalogMasterclassDetail = '/catalog/masterclass_detail.php';
  static const catalogConsultations = '/catalog/consultations.php';
  static const catalogConsultationDetail = '/catalog/consultation_detail.php';
  static const catalogGutReset = '/catalog/gut_reset.php';
  static const catalogCountries = '/catalog/countries.php';
  static const catalogFaqList = '/catalog/faq_list.php';
  // Masterclass checkout (guest or student).
  static const masterclassQuote = '/checkout/masterclass_quote.php';
  static const masterclassCreateOrder = '/checkout/masterclass_create_order.php';
  static const consultationQuote = '/checkout/consultation_quote.php';
  static const consultationCreateOrder = '/checkout/consultation_create_order.php';
  static const doshaQuestions = '/dosha/questions.php';
  static const doshaSubmit = '/dosha/submit.php';
  static const gutResetCreateOrder = '/checkout/gut_reset_create_order.php';
  static const myConsultations = '/consultation/my_bookings.php';
  static const videoProgress = '/video/progress.php';
  static const notificationsList = '/notifications/list.php';
  static const notificationsUnreadCount = '/notifications/unread_count.php';
  static const notificationsMarkRead = '/notifications/mark_read.php';
  static const refreshToken = '/auth/refresh_token.php';
  static const myCourses = '/masterclasses/my_courses.php';
  static const courseDetail = '/masterclasses/course_detail.php';
  static const generateCertificate =
      '/masterclasses/generate_certificate.php';
  static const submitQuiz = '/masterclasses/submit_quiz.php';
  static const accountProfile = '/account/profile.php';
  static const updateProfile = '/account/update_profile.php';
  static const changePassword = '/account/change_password.php';
  static const youtubeChannelSearch =
      '/youtube_search/youtube_channel_search.php';
  static const requestTimeout = Duration(seconds: 30);
  static const youtubeApiKey = String.fromEnvironment('YOUTUBE_API_KEY');
  static const youtubeChannelHandle = '@dimplejangda_official';
  static const libraryDataSource = String.fromEnvironment(
    'LIBRARY_DATA_SOURCE',
    defaultValue: 'backend',
  );
}
