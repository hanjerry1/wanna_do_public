import 'package:algolia/algolia.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final Algolia algolia = Algolia.init(
  applicationId: dotenv.env['ALGOLIA_APPLICATION_ID'] ?? '',
  apiKey: dotenv.env['ALGOLIA_API_KEY'] ?? '',
);

class AlgoliaManagerSpace {
  static Future<List<AlgoliaObjectSnapshot>> search(String query) async {
    AlgoliaQuery algoliaQuery =
        algolia.instance.index('space_search').query(query);

    AlgoliaQuerySnapshot algoliaSnapshot = await algoliaQuery.getObjects();
    return algoliaSnapshot.hits;
  }
}

class AlgoliaManagerUserManage {
  static Future<List<AlgoliaObjectSnapshot>> search(String query) async {
    AlgoliaQuery algoliaQuery =
        algolia.instance.index('user_search').query(query);

    AlgoliaQuerySnapshot algoliaSnapshot = await algoliaQuery.getObjects();
    return algoliaSnapshot.hits;
  }
}
