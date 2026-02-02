import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const cloudName = "dcceamvvw";  // your cloud name
  static const uploadPreset = "unilost_unsigned"; // your unsigned preset

  static Future<String?> uploadBytes(Uint8List bytes) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields["upload_preset"] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          "file",
          bytes,
          filename: "${DateTime.now().millisecondsSinceEpoch}.png",
        ),
      );

    final response = await request.send();
    final responseStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(responseStr);
      return json["secure_url"];
    } else {
      print("Cloudinary upload failed: $responseStr");
      return null;
    }
  }
}
