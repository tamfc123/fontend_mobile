class ApiConfig {
  static const String baseUrl = 'https://backend-english-app.onrender.com/api';

  // upload
  static const String upload = "/upload";

  // auth
  static const String authLogin = "/auth/login";
  static const String authRegister = "/auth/register";
  static const String authForgotPassword = "/auth/forgot-password";
  static const String authResetPassword = "/auth/reset-password";

  // Profile
  static const String profileAvatar = "/student/profile/avatar";
  static const String profileMe = "/student/profile/me";
  static const String profile = "/student/profile";
  static const String profileChangePassword =
      "/student/profile/change-password";

  // --- ADMIN: USERS ---
  static const String users = "/admin/users";
  static String userById(String id) => "/admin/users/$id";
  static String userToggleStatus(String id) => "/admin/users/$id/toggle-status";
  static String usersByRole(String role) => "/admin/users/role/$role";
  static const String adminCreateUser = "/admin/users/create-user";

  // --- ADMIN: COURSES ---
  static const String adminCourses = "/admin/courses";
  static String adminCourseById(String id) => "/admin/courses/$id";
  static const String adminGetAllCourses = "/admin/courses/all-active";

  // --- ADMIN: CLASSES ---
  static const String adminClasses = "/admin/classes";
  static String adminClassById(String id) => "/admin/classes/$id";
  static const String adminGetAllActiveClasses = "/admin/classes/all-active";

  // --- ADMIN: QUIZZES ---
  static String adminCourseQuizzes(String courseId) =>
      "/admin/courses/$courseId/quizzes";
  static String adminCourseQuizById(String courseId, String quizId) =>
      "/admin/courses/$courseId/quizzes/$quizId";
  static String adminDeleteQuestion(String courseId, String questionId) =>
      "/admin/courses/$courseId/quizzes/questions/$questionId";
  static String adminRestoreQuiz(String courseId, String quizId) =>
      "/admin/courses/$courseId/quizzes/$quizId/restore";

  // ADMIN DASHBOARD STATS
  static const String adminDashboardStats = "/admin/dashboard-stats";
  static const String adminNewUsersChart = "/admin/new-users-chart";
  static const String adminQuizSkillDistribution =
      "/admin/quiz-skill-distribution";
  static const String adminRecentTeachers = "/admin/recent-teachers";
  static const String adminTopStudents = "/admin/top-students";

  // --- ADMIN: ROOMS ---
  static const String adminRooms = "/admin/rooms";
  static String adminRoomById(String id) => "/admin/rooms/$id";
  static const String adminGetAllActiveRooms = "/admin/rooms/all-active";

  // --- ADMIN: SCHEDULES ---
  static const String adminSchedules = "/admin/schedules";
  static String adminScheduleById(String id) => "/admin/schedules/$id";

  // --- ADMIN MODULE ---
  static const String adminModules = '$baseUrl/admin/modules';
  static String adminModuleById(String id) => '$baseUrl/admin/modules/$id';

  // --- ADMIN LESSON
  static const String adminLessons = '$baseUrl/admin/lessons';
  static String adminLessonById(String id) => '$baseUrl/admin/lessons/$id';
  static const String uploadContentImage = '$baseUrl/upload-content-image';

  // --- ADMIN VOCABULARY
  static const String adminVocabularies = '$baseUrl/admin/vocabularies';
  static String adminVocabularyById(String id) =>
      '$baseUrl/admin/vocabularies/$id';
  static String adminRestoreVocabulary(String id) =>
      '$baseUrl/admin/vocabularies/$id/restore';

  // POST: /api/admin/media/upload-audio
  static const String adminUploadAudio = "/admin/media/upload-audio";
  static const String adminMedia = '/admin/media';
  static String adminDeleteMedia(String id) => "/admin/media/$id";
  // ---ADMIN: GIFT
  static const String adminGifts = "/admin/gifts"; // GET All, POST Create
  static String adminGiftById(String id) => "/admin/gifts/$id";
  static String adminRestoreGift(String id) => "/admin/gifts/$id/restore";

  static String adminUserRedemptions(String userId) =>
      "/admin/gifts/student/$userId/redemptions";

  // Xác nhận đã trao quà
  static String adminConfirmRedemption(String redemptionId) =>
      "/admin/gifts/redemptions/$redemptionId/confirm";

  // --- TEACHER: DASHBOARD ---
  static const String teacherDashboardSummary = '/teacher/dashboard/summary';

  // --- TEACHER: CLASSES ---
  static const String teacherClasses = "/teacher/classes";
  static String teacherClassById(String id) => "/teacher/classes/$id";
  static String getStudentsInClass(String classId) =>
      "/teacher/classes/$classId/students";
  static String teacherClassSkills(String classId) =>
      '/teacher/classes/$classId/skills';
  static String getStudentDetail(String classId, String studentId) =>
      '/teacher/classes/$classId/students/$studentId';
  static String teacherClassQuizzes(String classId) =>
      "/teacher/classes/$classId/quizzes";
  static String teacherQuizDetail(String classId, String quizId) =>
      "/teacher/classes/$classId/quizzes/$quizId";

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
  // --- STUDENT: GIFT STORE ---
  static const String studentGifts = "/student/gifts";
  static const String studentMyRedemptions = "/student/gifts/my-redemptions";
  static String studentRedeemGift(String id) => "/student/gifts/$id/redeem";
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
  static String submitWritingQuiz(String classId, String quizId) =>
      '/student/classes/$classId/quizzes/$quizId/submit-writing';
  static String getQuizResult(String classId, String quizId) =>
      '/student/classes/$classId/quizzes/$quizId/result';

  static const String uploadRawFile = '$baseUrl/uploadAudioFileWeb';
  static const String studentVocabularyLevels =
      '$baseUrl/student/vocabulary-levels';
  static String studentVocabularyModules(String levelId) {
    return '/student/vocabulary-levels/$levelId/topics';
  }

  static String studentModuleLessons(String moduleId) {
    return '/student/vocabulary-modules/$moduleId/lessons';
  }

  static String studentLessonFlashcards(String lessonId) {
    return '/student/vocabulary-lessons/$lessonId/flashcards';
  }

  static const String studentAssessPronunciation =
      '/student/assess-pronunciation';
  static const String studentGrades = '/student/grades/summary';
  static const String studentLeaderboard = '/student/leaderboard';
}
