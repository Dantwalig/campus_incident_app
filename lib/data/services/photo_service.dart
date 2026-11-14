import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants.dart';

/// Uploads incident photos to Cloudinary using an unsigned upload preset.
/// The returned secure URL is saved in the incident document (photoUrl).
class PhotoService {
  PhotoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> uploadIncidentPhoto(File file, String uid) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConstants.cloudinaryUploadPreset
      ..fields['folder'] = 'campus_incidents/$uid'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed =
        await _client.send(request).timeout(const Duration(seconds: 45));
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception('Photo upload failed (${streamed.statusCode}): $body');
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    final url = json['secure_url'] as String?;
    if (url == null) throw Exception('Cloudinary did not return an image URL');
    return url;
  }
}
