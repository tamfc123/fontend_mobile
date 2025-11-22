class ApiConfig {
  static const String baseUrl =
      'https://xbox-lib-conversion-jack.trycloudflare.com/api';

  // upload
  static const String upload = "/upload";
  static const String uploadAudio = "/upload-audio";
  static const String teacherGetMyMedia = "/my-media"; // GET
  static String teacherDeleteMedia(String id) => "/delete-media/$id"; // DELETE

  // auth
  static const String authLogin = "/auth/login";
  static const String authRegister = "/auth/register";
  static const String authForgotPassword = "/auth/forgot-password";
  static const String authResetPassword = "/auth/reset-password";

  // Profile
  static const String profileAvatar = "/profile/avatar";
  static const String profileMe = "/profile/me";
  static const String profile = "/profile";
  static const String profileChangePassword = "/profile/change-password";

  // --- ADMIN: USERS ---
  static const String users = "/users";
  static String userById(String id) => "/users/$id";
  static String userToggleStatus(String id) => "/users/$id/toggle-status";
  static String usersByRole(String role) => "/users/role/$role";
  static const String adminCreateUser = "/users/create-user";

  // --- ADMIN: COURSES ---
  static const String courses = "/courses";
  static String courseById(String id) => "/courses/$id";
  static const String adminGetAllCourses = "/courses/all-active";

  // --- ADMIN: CLASSES ---
  static const String classes = "/classes";
  static String classById(String id) => "/classes/$id";
  static const String adminGetAllActiveClasses = "/classes/all-active";

  // ✅ --- ADMIN: QUIZZES (MỚI) ---
  // Backend: api/admin/courses/{courseId}/quizzes
  static String adminCourseQuizzes(String courseId) =>
      "/admin/courses/$courseId/quizzes";
  // Backend: api/admin/courses/{courseId}/quizzes/{quizId}
  static String adminCourseQuizById(String courseId, String quizId) =>
      "/admin/courses/$courseId/quizzes/$quizId";
  // Backend: api/admin/courses/{courseId}/quizzes/questions/{questionId} (Xóa câu hỏi lẻ)
  static String adminDeleteQuestion(String courseId, String questionId) =>
      "/admin/courses/$courseId/quizzes/questions/$questionId";

  // ADMIN DASHBOARD STATS
  static const String adminDashboardStats = "/admin/dashboard-stats";
  static const String adminNewUsersChart = "/admin/new-users-chart";
  static const String adminQuizSkillDistribution =
      "/admin/quiz-skill-distribution";
  static const String adminRecentTeachers = "/admin/recent-teachers";
  static const String adminTopStudents = "/admin/top-students";

  // --- ADMIN: ROOMS ---
  static const String adminRooms = "/admin/rooms"; // Dùng cho (GET all, CREATE)
  static String adminRoomById(String id) => "/admin/rooms/$id";
  static const String adminGetAllActiveRooms = "/admin/rooms/all-active";

  // --- ADMIN: SCHEDULES ---
  static const String adminSchedules =
      "/admin/schedules"; // Dùng cho (GET all, CREATE)
  static String adminScheduleById(String id) => "/admin/schedules/$id";

  // --- ADMIN MODULE ---
  static const String adminModules = '$baseUrl/admin/modules';
  static String adminModuleById(String id) => '$baseUrl/admin/modules/$id';

  // --- ADMIN LESSON
  static const String adminLessons = '$baseUrl/admin/lessons';
  static String adminLessonById(String id) => '$baseUrl/admin/lessons/$id';

  // Không thêm /api vì baseUrl đã có /api
  static const String uploadContentImage = '$baseUrl/upload-content-image';

  // --- ADMIN VOCABULARY
  static const String adminVocabularies = '$baseUrl/admin/vocabularies';
  static String adminVocabularyById(String id) =>
      '$baseUrl/admin/vocabularies/$id';

  // --- TEACHER: DASHBOARD ---
  static const String teacherDashboardSummary = '/teacher/dashboard/summary';

  // --- TEACHER: CLASSES ---
  static const String teacherClasses = "/teacher/classes"; // Dùng cho (GET all)
  static String teacherClassById(String id) => "/teacher/classes/$id";
  static String getStudentsInClass(String classId) =>
      "/teacher/classes/$classId/students";

  // --- TEACHER: SCHEDULES ---
  static const String teacherSchedules = "/teacher/schedules";
  static String teacherScheduleById(String id) => "/teacher/schedules/$id";

  // --- STUDENT: SCHEDULES ---
  static const String studentSchedules = "/student/schedules";

  // --- STUDENT: MODULES ---
  static const String studentModules = '$baseUrl/student/modules';

  // --- STUDENT: LESSONS ---
  static const String studentLessons = '$baseUrl/student/lessons';

  // --- STUDENT: VOCABULARIES ---
  static const String studentVocabularies = '$baseUrl/student/vocabularies';

  // --- STUDENT: COURSES ---
  static const String studentAvailableCourses = "/studentcourses/courses";
  static String studentClassesByCourse(String courseId) =>
      "/studentcourses/$courseId/classes";
  static String studentJoinClass(String classId) =>
      "/student/classes/join/$classId";

  // --- STUDENT: CLASSES (JOINED) ---
  static const String studentJoinedClasses = "/student/classes";
  static String studentLeaveClass(String classId) =>
      "/student/classes/leave/$classId";

  // GET: Lấy danh sách quiz của 1 lớp
  static String getStudentQuizList(String classId) =>
      '/student/classes/$classId/quizzes';

  // GET: Lấy chi tiết 1 quiz để làm bài
  static String getQuizForTaking(String classId, String quizId) =>
      '/student/classes/$classId/quizzes/$quizId/take';

  // POST: Nộp bài
  static String submitQuiz(String classId, String quizId) =>
      '/student/classes/$classId/quizzes/$quizId/submit';

  // GET: Lấy kết quả bài đã nộp
  static String getQuizResult(String classId, String quizId) =>
      '/student/classes/$classId/quizzes/$quizId/result';

  static const String uploadRawFile = '$baseUrl/upload';

  // GET: /api/student/vocabulary-levels
  static const String studentVocabularyLevels =
      '$baseUrl/student/vocabulary-levels';

  // GET: /api/student/vocabulary-levels/{levelId}/topics
  static String studentVocabularyModules(String levelId) {
    return '/student/vocabulary-levels/$levelId/topics';
  }

  // ✅ THÊM CÁI NÀY:
  static String studentModuleLessons(String moduleId) {
    return '/student/vocabulary-modules/$moduleId/lessons';
  }

  // GET: /student/vocabulary-lessons/{lessonId}/flashcards
  static String studentLessonFlashcards(String lessonId) {
    return '/student/vocabulary-lessons/$lessonId/flashcards';
  }

  // POST: /api/student/assess-pronunciation
  static const String studentAssessPronunciation =
      '/student/assess-pronunciation';

  // GET: /api/student/grades
  static const String studentGrades = '/student/grades';

  // GET: /api/student/leaderboard
  static const String studentLeaderboard = '/leaderboard';
}
