// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class UpladeImages {
  // * Uplade Image
  static Future upladeImage(
      {required String token, required dynamic file}) async {
    try {
      var headers = {
        'authrization': token,
      };
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://api.wefixjo.com/Common/uploadMultiFiles'));
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var responses = await http.Response.fromStream(response);
      final body = json.decode(responses.body);
      if (responses.statusCode == 200) {
        return body['link'];
      } else {
        log('upladeImage() [ Error ]');
        return null;
      }
    } catch (e) {
      log('upladeImage() [ Error ] : $e ');
      return null;
    }
  }
}
