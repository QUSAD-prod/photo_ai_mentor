import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'constants.dart';
import 'demo.dart';

class AppApi {
  AppApi({required this.context});

  final BuildContext context;

  GraphQLClient get getClient => GraphQLProvider.of(context).value;

  Future<String> getResult(String text) async {
    if (kDemoMode) {
      final String languageCode = Localizations.localeOf(context).languageCode;
      await Future.delayed(DemoData.latency);
      return DemoData.answer(languageCode);
    }
    GraphQLClient client = getClient;
    String result = json.decode((await client.query(
      QueryOptions(
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
        document: gql(AppConstants().requestOpenAiQuery),
        variables: {
          "input": {
            "type": "mobile_scan",
            "args": {
              "request": text,
            },
          },
        },
      ),
    ))
        .data!["requestOpenApi"])["choices"][0]["text"];
    return result;
  }

  Future<int?> getUserId() async {
    if (kDemoMode) return 1;
    try {
      GraphQLClient client = getClient;
      int id = (await client.query(
        QueryOptions(
          cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
          document: gql(
            AppConstants().getUser,
          ),
        ),
      ))
          .data?["user"]?["id"];
      return id;
    } catch (e) {
      return null;
    }
  }

  Future<int> createUser(Map<String, dynamic> variables) async {
    if (kDemoMode) return 1;
    GraphQLClient client = getClient;
    int id = (await client.mutate(
      MutationOptions(
        variables: variables,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
        document: gql(
          AppConstants().createUser,
        ),
      ),
    ))
        .data!["createUser"]["id"];
    return id;
  }
}
