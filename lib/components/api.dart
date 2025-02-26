import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'constants.dart';

class AppApi {
  AppApi({required this.context});

  final BuildContext context;

  GraphQLClient get getClient => GraphQLProvider.of(context).value;

  Future<String> getResult(String text) async {
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
