abstract final class ApiConstants {
  static const baseUrl =
      'https://www.pranabydimpleacademy.com/lms/asdqw/student_app_webservices';
  static const login = '/auth/login.php';
  static const myCourses = '/masterclasses/my_courses.php';
  static const courseDetail = '/masterclasses/course_detail.php';
  static const generateCertificate =
      '/masterclasses/generate_certificate.php';
  static const submitQuiz = '/masterclasses/submit_quiz.php';
  static const requestTimeout = Duration(seconds: 30);
  static const staticDeviceToken = 'prana-static-device-token';
}
