import 'dart:async';
import 'dart:typed_data';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class GoogleapisService {
  DriveApi? driveAPi;

  Future<void> loginUserForRequest() async {
    final googleSignIn = GoogleSignIn(
      scopes: <String>[DriveApi.driveScope],
    );
    var account = await googleSignIn.signIn();
    final httpCLient = (await googleSignIn.authenticatedClient());
    if (httpCLient != null) {
      driveAPi = DriveApi(httpCLient);
    }
  }

  Future<String> upload(Uint8List encrypted) async {
    final mediaStream =
        Future.value(List<int>.from(encrypted)).asStream().asBroadcastStream();

    var media = Media(
      mediaStream,
      List<int>.from(encrypted).length,
    );
    var driveFile = File();
    driveFile.name = "do_not_delete.txt";
    final result = await driveAPi?.files.create(
      driveFile,
      uploadMedia: media,
    );
    final fileId = result?.id ?? "";
    return fileId;
  }

  Future<Uint8List> loadFileFromGoogleDrive(String fileId) async {
    try {
      await loginUserForRequest();
      String content;
      print("https://www.googleapis.com/drive/v3/files/$fileId");

      final result = await driveAPi?.files
          .get(fileId, downloadOptions: DownloadOptions.fullMedia);
      List<int> dataStore = [];
      final completer = Completer<Uint8List>();

      (result as Media?)?.stream.listen(
        (data) {
          print("DataReceived: ${data.length}");
          dataStore.insertAll(dataStore.length, data);
        },
        onDone: () async {
          io.Directory tempDir =
              await getTemporaryDirectory(); //Get temp folder using Path Provider
          String tempPath = tempDir.path; //Get path to that location
          io.File file = io.File('$tempPath/test'); //Create a dummy file
          await file.writeAsBytes(
              dataStore); //Write to that file from the datastore you created from the Media stream
          final data = await file.readAsBytes(); // Read String from the file
          print(data); //Finally you have your text
          completer.complete(data);
        },
        onError: (error) {
          print(error);
          throw Exception(error);
        },
      );
      return completer.future;
    } catch (e) {
      throw Exception(e);
    }
  }
}
