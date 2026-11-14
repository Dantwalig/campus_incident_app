import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants.dart';

/// Thrown with a message that is safe to show to the user.
class PhotoUploadException implements Exception {
  const PhotoUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Uploads incident photos to Cloudinary using an unsigned upload preset.
/// The returned secure URL is saved in the incident document (photoUrl).
class PhotoService {
  PhotoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  bool get isConfigured =>
      !AppConstants.cloudinaryCloudName.startsWith('YOUR_') &&
      !AppConstants.cloudinaryUploadPreset.startsWith('YOUR_');

  Future<String> uploadIncidentPhoto(File file, String uid) async {
    if (!isConfigured) {
      throw const PhotoUploadException(
        'Photo upload is not set up yet. Add your Cloudinary details in '
        'lib/core/constants.dart.',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
    );

    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = AppConstants.cloudinaryUploadPreset
        ..fields['folder'] = 'campus_incidents/$uid'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed =
          await _client.send(request).timeout(const Duration(seconds: 45));
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode != 200) {
        throw PhotoUploadException(_describeError(streamed.statusCode, body));
      }
      final json = jsonDecode(body) as Map<String, dynamic>;
      final url = json['secure_url'] as String?;
      if (url == null) {
        throw const PhotoUploadException('Cloudinary did not return an image link.');
      }
      return url;
    } on TimeoutException {
      throw const PhotoUploadException(
        'The photo upload timed out. Check your connection and try again.',
      );
    } on SocketException {
      throw const PhotoUploadException(
        'No internet connection. The photo could not be uploaded.',
      );
    } on http.ClientException {
      throw const PhotoUploadException(
        'No internet connection. The photo could not be uploaded.',
      );
    }
  }

  String _describeError(int status, String body) {
    String? detail;
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      detail = (json['error'] as Map<String, dynamic>?)?['message'] as String?;
    } catch (_) {
      detail = null;
    }
    return detail == null
        ? 'Photo upload failed (error $status).'
        : 'Photo upload failed: $detail';
  }
}
