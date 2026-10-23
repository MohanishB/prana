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
  static const login = '/auth/login.php';
  static const refreshToken = '/auth/refresh_token.php';
  static const myCourses = '/masterclasses/my_courses.php';
  static const courseDetail = '/masterclasses/course_detail.php';
  static const generateCertificate =
      '/masterclasses/generate_certificate.php';
  static const submitQuiz = '/masterclasses/submit_quiz.php';
  static const accountProfile = '/account/profile.php';
  static const updateProfile = '/account/update_profile.php';
  static const changePassword = '/account/change_password.php';
  static const faqList = '/content/faq_list.php';
  static const youtubeChannelSearch =
      '/youtube_search/youtube_channel_search.php';
  static const requestTimeout = Duration(seconds: 30);
  static const staticDeviceToken = 'prana-static-device-token';
  static const youtubeApiKey = String.fromEnvironment('YOUTUBE_API_KEY');
  static const youtubeChannelHandle = '@dimplejangda_official';
  static const libraryDataSource = String.fromEnvironment(
    'LIBRARY_DATA_SOURCE',
    defaultValue: 'backend',
  );
}
