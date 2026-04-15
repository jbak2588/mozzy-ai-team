import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'models.dart';
import 'persistence_common.dart';

class FileAppRepository extends AppRepository {
  FileAppRepository({this.overrideFile});

  final File? overrideFile;

  @override
  Future<AppSnapshot?> load() async {
    final file = await _resolveFile();
    if (!await file.exists()) {
      return null;
    }
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return null;
    }
    return AppSnapshot.fromJson(jsonDecode(contents) as Map<String, dynamic>);
  }

  @override
  Future<void> save(AppSnapshot snapshot) async {
    final file = await _resolveFile();
    await file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(snapshot.toJson()));
  }

  Future<File> _resolveFile() async {
    if (overrideFile != null) {
      return overrideFile!;
    }
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/hni_auto_company_mvp_state.json');
  }
}
