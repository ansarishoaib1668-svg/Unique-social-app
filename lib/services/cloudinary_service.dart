import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'mxbx6vll';
  static const String uploadPreset = 'Viewsta upload';

  static Future<String> uploadFile(
    File file, {
    void Function(double progress)? onProgress,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
    );

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    final body = request.finalize();
    final totalBytes = request.contentLength;
    var sentBytes = 0;

    final streamedRequest = http.StreamedRequest('POST', uri);
    streamedRequest.headers.addAll(request.headers);
    streamedRequest.contentLength = totalBytes;

    body.listen(
      (chunk) {
        sentBytes += chunk.length;

        if (totalBytes > 0) {
          onProgress?.call(
            (sentBytes / totalBytes).clamp(0.0, 1.0),
          );
        }

        streamedRequest.sink.add(chunk);
      },
      onDone: () => streamedRequest.sink.close(),
      onError: (Object error, StackTrace stackTrace) {
        streamedRequest.sink.addError(error, stackTrace);
        streamedRequest.sink.close();
      },
      cancelOnError: true,
    );

    final response = await streamedRequest.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Cloudinary upload failed: ${response.statusCode} $responseBody',
      );
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final secureUrl = data['secure_url'] as String?;

    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary did not return a secure URL.');
    }

    onProgress?.call(1.0);
    return secureUrl;
  }
}
