import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

class UpladeFiles {
  // * Upload Multiple Images with List of File Paths
  static Future upladeImagesWithPaths({
    required String token,
    required List<String> filePaths, // List of file paths
// List of strings
  }) async {
    try {
      var headers = {
        'Authorization': token,
      };

      var request = http.MultipartRequest('POST',
          Uri.parse('https://wefixApi.oneit.website/Common/uploadMultiFiles'));

      // Iterate over each file path and add the files to the request
      for (var filePath in filePaths) {
        var file = File(filePath);
        if (file.existsSync()) {
          request.files
              .add(await http.MultipartFile.fromPath('files', file.path));
        } else {
          log('File does not exist at path: $filePath');
        }
      }

      request.headers.addAll(headers);

      // Send the request
      http.StreamedResponse response = await request.send();
      var responses = await http.Response.fromStream(response);
      final body = json.decode(responses.body);

      if (responses.statusCode == 200) {
        return body[
            'links']; // You can return a response or handle the returned links as needed
      } else {
        log('upladeImagesWithPaths() [Error] Failed');
        return null;
      }
    } catch (e) {
      log('upladeImagesWithPaths() [Error] : $e');
      return null;
    }
  }
}
