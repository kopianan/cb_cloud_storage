import 'dart:typed_data';

import 'package:cloud_storage/services/google_api_service.dart';

class CloudStorage {
  final googleApi = GoogleapisService();

  Future<String> uploadFileToGoogleDrive(Uint8List data) async {
    try {
      await googleApi.loginUserForRequest();
      final fileId = await googleApi.upload(data);
      return fileId;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Uint8List> downloadKeyFromGoogleDrive(String fileId) async {
    try {
      await googleApi.loginUserForRequest();
      final key = await googleApi.loadFileFromGoogleDrive(fileId);
      return key;
    } catch (e) {
      throw Exception(e);
    }
  }
}
