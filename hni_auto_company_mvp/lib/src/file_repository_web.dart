import 'models.dart';
import 'persistence_common.dart';

class FileAppRepository extends AppRepository {
  @override
  Future<AppSnapshot?> load() {
    throw UnsupportedError(
      'FileAppRepository is not available on Flutter Web. Set API_BASE_URL or use same-origin backend routing.',
    );
  }

  @override
  Future<void> save(AppSnapshot snapshot) {
    throw UnsupportedError(
      'FileAppRepository is not available on Flutter Web. Set API_BASE_URL or use same-origin backend routing.',
    );
  }
}
