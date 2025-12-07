import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/router/routes/auth_routes.dart';
import 'package:mobile/core/router/routes/student_routes.dart';
import 'package:mobile/core/router/routes/admin_routes.dart';
import 'package:mobile/core/router/routes/teacher_routes.dart';

/// Global navigator key for the root navigator
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Main application router configuration
///
/// This router is organized into modular route files:
/// - [AuthRoutes]: Authentication routes (login, signup, password recovery)
/// - [StudentRoutes]: Student portal routes with ShellRoute layout
/// - [AdminRoutes]: Admin panel routes with ShellRoute layout
/// - [TeacherRoutes]: Teacher portal routes with ShellRoute layout
///
/// Each route module is self-contained and can be modified independently.
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Authentication routes
    ...AuthRoutes.routes,

    // Student routes with layout
    StudentRoutes.shellRoute,

    // Admin routes with layout
    AdminRoutes.shellRoute,

    // Teacher routes with layout
    TeacherRoutes.shellRoute,
  ],
);
