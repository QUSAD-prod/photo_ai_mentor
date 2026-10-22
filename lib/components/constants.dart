import 'package:flutter/material.dart';

class AppConstants {
  final String requestOpenAiQuery = """
query requestOpenAI(\$input: openAIInput!) {
  requestOpenApi(input: \$input)
}
""";

  final String getUser = """
query GetUser {
  user {
    id
  }
}
""";

  final String createUser = """
mutation CreateUser(\$userData: CreateUserInput!) {
  createUser(userData: \$userData) {
    id
  }
}
""";

  final Color accent = const Color(0xFFE7522E);
  final Color accentLight = const Color(0xFFFF8A4C);
  final Color background = const Color(0xFF0A0E16);
  final Color surface = const Color(0xFF131925);
  final Color surfaceHigh = const Color(0xFF1B2332);
  final Color border = const Color(0x1AFFFFFF);
  final Color textSecondary = const Color(0x99FFFFFF);

  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accentLight, accent],
      );
}
