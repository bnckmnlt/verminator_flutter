import 'dart:convert';

extension ResponseExtensions on String {
  String parseErrorMessage() {
    final decodedBody = jsonDecode(this);
    return decodedBody["error"]?["issues"]?[0]?["message"] ??
        decodedBody["message"] ??
        "An unknown error occurred";
  }
}
