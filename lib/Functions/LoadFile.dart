import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../Pages/SelectLesson.dart';
import 'package:hive/hive.dart';

class LoadFile{
  late BuildContext mContext;

  LoadFile(BuildContext context){
    mContext = context;
  }

  selectFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      print(result.files.single.path!);
      File file = File(result.files.single.path!);
      file.length().then((len) {
        print("File len: $len");
      });
      final String contents = await file.readAsString();
      List<String> lines = contents.replaceAll('\r', '').split('\n');
      print("Lines: ${lines.length}");
      Map<String, dynamic> Lessons = new Map<String, dynamic>();
      Map<String, String> Words = new Map<String, String>();
      String LessonCaption = '';
      for(String line in lines){
        List<String> cols = line.split('\t');
        if(cols.length == 1 || (cols.length > 1 && cols[1].trim().length == 0) ){
          if(cols[0].trim().length > 0){
            LessonCaption = cols[0].trim();
            if(Words.length > 0){
              Lessons[LessonCaption] = Words;
            }
            Words = new Map<String, String>();
          }
        }
        if(cols.length > 1 && cols[1].length > 0){
          Words[cols[0].trim()] = cols[1].trim();
          //print(cols[0].trim());
        }
      }
      Lessons[LessonCaption] = Words;

      var box = await Hive.openBox('hive');
      box.put('Lessons', Lessons);

      /*
      var Lessons2 = box.get('Lessons');
      print("Lessons: ${Lessons2.length}");
      Lessons2.forEach((LessonCaption, words) {
        print(words);
      });
       */
      while(Navigator.of(mContext).canPop()){
        Navigator.of(mContext).pop(false);
      }
      Navigator.push(mContext, MaterialPageRoute(builder: (context) => SelectLesson()));
    } else {
      // Cancel
      print("Cancel");
    }
    //Navigator.pop(mContext);
  }


}
