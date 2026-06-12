import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/survey_layer.dart';

/// HiPS tile fetch client (HTTPS only).
///
/// Replaced with a fake implementation in tests.
abstract class HipsTileFetcher {
  Future<Uint8List> fetchTile(SurveyLayerDef survey, HipsTileRef ref);
}

class DioHipsTileFetcher implements HipsTileFetcher {
  DioHipsTileFetcher({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<Uint8List> fetchTile(SurveyLayerDef survey, HipsTileRef ref) async {
    final url =
        '${survey.baseUrl}/${ref.pathWithExtension(survey.tileExtension)}';
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const DownloadException('Empty tile response');
      }
      return Uint8List.fromList(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      throw DownloadException(
        'Tile fetch failed ($status): ${ref.key}',
        retryable: status == null || status >= 500,
      );
    }
  }
}
