class ApiConfig {
  static const String baseUrl =
      'https://interactive-gathering-incl-shoot.trycloudflare.com/api';

  // upload
  static const String upload = "/upload";
  static const String uploadAudio = "/upload-audio";
  static const String teacherGetMyMedia = "/my-media"; // GET
  static String teacherDeleteMedia(int id) => "/delete-media/$id"; // DELETE

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
  static const String users = "/users"; // Dùng cho (getAll, getPaged)
  static String userById(String id) => "/users/$id"; // Dùng cho (update/delete)
  static String userToggleStatus(String id) => "/users/$id/toggle-status";
  static String usersByRole(String role) => "/users/role/$role";
  static const String adminCreateUser = "/users/create-user";

  // --- ADMIN: COURSES ---
  static const String courses = "/courses"; // Dùng cho (getAll, create)
  static String courseById(int id) => "/courses/$id";

  // --- ADMIN: CLASSES ---
  static const String classes = "/classes"; // Dùng cho (getAll, create)
  static String classById(int id) => "/classes/$id";

  // --- ADMIN: ROOMS ---
  static const String adminRooms = "/admin/rooms"; // Dùng cho (GET all, CREATE)
  static String adminRoomById(int id) => "/admin/rooms/$id";

  // --- ADMIN: SCHEDULES ---
  static const String adminSchedules =
      "/admin/schedules"; // Dùng cho (GET all, CREATE)
  static String adminScheduleById(int id) => "/admin/schedules/$id";

  // --- ADMIN MODULE ---
  static const String adminModules = '$baseUrl/admin/modules';
  static String adminModuleById(int id) => '$baseUrl/admin/modules/$id';

  // --- ADMIN LESSON
  static const String adminLessons = '$baseUrl/admin/lessons';
  static String adminLessonById(int id) => '$baseUrl/admin/lessons/$id';

  // Không thêm /api vì baseUrl đã có /api
  static const String uploadContentImage = '$baseUrl/upload-content-image';

  // --- ADMIN VOCABULARY
  static const String adminVocabularies = '$baseUrl/admin/vocabularies';
  static String adminVocabularyById(int id) =>
      '$baseUrl/admin/vocabularies/$id';

  // --- TEACHER: CLASSES ---
  static const String teacherClasses = "/teacher/classes"; // Dùng cho (GET all)
  static String teacherClassById(int id) => "/teacher/classes/$id";
  static String getStudentsInClass(int classId) =>
      "/teacher/classes/$classId/students";

  // --- TEACHER: SCHEDULES ---
  static const String teacherSchedules = "/teacher/schedules";
  static String teacherScheduleById(int id) => "/teacher/schedules/$id";

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
  static String studentClassesByCourse(int courseId) =>
      "/studentcourses/$courseId/classes";
  static String studentJoinClass(int classId) =>
      "/student/classes/join/$classId";

  // --- STUDENT: CLASSES (JOINED) ---
  static const String studentJoinedClasses = "/student/classes";
  static String studentLeaveClass(int classId) =>
      "/student/classes/leave/$classId";

  // GET /api/teacher/classes/{classId}/quizzes
  // POST /api/teacher/classes/{classId}/quizzes
  static String teacherQuizzes(int classId) =>
      '/teacher/classes/$classId/quizzes';

  // GET /api/teacher/classes/{classId}/quizzes/{quizId}
  // DELETE /api/teacher/classes/{classId}/quizzes/{quizId}
  static String teacherQuizById(int classId, int quizId) =>
      '/teacher/classes/$classId/quizzes/$quizId';

  // GET: Lấy danh sách quiz của 1 lớp
  static String getStudentQuizList(int classId) =>
      '/student/classes/$classId/quizzes';

  // GET: Lấy chi tiết 1 quiz để làm bài
  static String getQuizForTaking(int classId, int quizId) =>
      '/student/classes/$classId/quizzes/$quizId/take';

  // POST: Nộp bài
  static String submitQuiz(int classId, int quizId) =>
      '/student/classes/$classId/quizzes/$quizId/submit';

  // GET: Lấy kết quả bài đã nộp
  static String getQuizResult(int classId, int quizId) =>
      '/student/classes/$classId/quizzes/$quizId/result';

  static const String uploadRawFile = '$baseUrl/upload';

  // GET: /api/student/vocabulary-levels
  static const String studentVocabularyLevels =
      '$baseUrl/student/vocabulary-levels';

  // GET: /api/student/vocabulary-levels/{levelId}/topics
  static String studentVocabularyModules(int levelId) {
    return '/student/vocabulary-levels/$levelId/topics';
  }

  // ✅ THÊM CÁI NÀY:
  static String studentModuleLessons(int moduleId) {
    return '/student/vocabulary-modules/$moduleId/lessons';
  }

  // GET: /student/vocabulary-lessons/{lessonId}/flashcards
  static String studentLessonFlashcards(int lessonId) {
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
