import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'dart:io';
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';

class ExtractMp3{
  late BuildContext mContext;

  ExtractMp3(BuildContext context){
    mContext = context;
  }

  selectZipMp3File() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null){
      print(result.files.single.path!);
      final zipFile = File(result.files.single.path!);
      File file = File(result.files.single.path!);
      file.length().then((len) {
        print("File len: $len");
      });
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'words_mp3');
      final destinationDir = Directory(path);

      bool exist = await destinationDir.exists();
      if (exist) {
        print("Deleting existing unzip directory: ${destinationDir.path}");
        await destinationDir.delete(recursive: true);
      }
      await destinationDir.create();
      try {
        await ZipFile.extractToDirectory(
            zipFile: zipFile,
            destinationDir: destinationDir,
            onExtracting: (zipEntry, progress) {
              print('progress: ${progress.toStringAsFixed(1)}%: ${zipEntry.name}');
              return ZipFileOperation.includeItem;
            });
      } catch (e) {
        print(e);
      }
    }else {
      // Cancel
      print("Cancel");
    }

  }




}