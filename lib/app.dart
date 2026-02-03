/// アプリケーションのルートウィジェット
library;

import 'package:flutter/material.dart';
import 'package:reading_progress_app/presentation/router/app_router.dart';
import 'package:reading_progress_app/presentation/theme/app_theme.dart';

/// 読書進捗管理アプリ
class ReadingProgressApp extends StatelessWidget {
  const ReadingProgressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '読書進捗',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
