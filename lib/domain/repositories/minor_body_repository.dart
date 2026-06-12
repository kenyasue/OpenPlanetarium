import '../models/minor_body.dart';

/// Access to the minor body (asteroid/comet) catalog.
abstract interface class MinorBodyRepository {
  Future<List<MinorBody>> loadAll();
}
