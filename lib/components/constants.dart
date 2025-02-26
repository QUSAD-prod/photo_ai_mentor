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
  final Color background = const Color(0xFF0A0E16);
}
