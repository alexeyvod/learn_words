import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBProvider {

  final int database_version = 1;
  final String database_file_name = "db_lessons.sqlite";
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database? _database;

  final String CreateDatabase = """
    CREATE TABLE questions (
      id INTEGER PRIMARY KEY, 
      LessonId INTEGER, 
      LessonCaption TEXT, 
      English TEXT,
      Russian TEXT,
      Rating INTEGER
    )
  """;

  Future<Database?> get database async {
    if (_database != null) return _database!;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database!;
  }



  initDB() async {
    final prefs = await SharedPreferences.getInstance();
    int dbVersion = prefs.getInt('dbVersion') ?? 1;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, database_file_name);

    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound
        || dbVersion == "" || dbVersion != database_version ){
      /*
      // Load database from asset and copy
      ByteData data = await rootBundle.load(join('assets', database_file_name));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      prefs.setString('dbVersion', database_version);

      // Save copied asset to documents
      await new File(path).writeAsBytes(bytes);
      if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound){
        print("xxxxxxxxxxxxxxxxxxxxxxx notFound");
      }else{
        print("VVVVVVVVVVVVVVVVVVVVVV Found");
      }
      */
    }

    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound){
      print("ZZZZZZZZZZZZZZZZZZZZZZZZZZ notFound");
    }

    return await openDatabase(
        path,
        version: database_version,
        onOpen: (db) {
          print("onOpen");
        },
        onCreate: (Database db, int version) async {
          print("onCreate");
          await db.execute(CreateDatabase);
          prefs.setInt('dbVersion', dbVersion);
        },
        onUpgrade: (Database db, int OldVersion, int NewVersion) async{
          await db.execute(CreateDatabase);
          prefs.setInt('dbVersion', dbVersion);
        }
    );
  }


  Future<List<Map>> getAll() async {
    final db = await database;
    List<Map> list = await db!.rawQuery('SELECT * FROM questions');
    return list;
    //var res = await db.query("info", where: "id = ?", whereArgs: [id]);
    //return res.isNotEmpty ? Client.fromMap(res.first) : null;
  }

  Future<void> addQuestion(int LessonID, String LessonCaption, String English, String Russian, int Rating) async{
    final db = await database;
    int id2 = await db!.rawInsert(
        'INSERT INTO questions(LessonID, LessonCaption, English, Russian, Rating) VALUES(?, ?, ?, ?, ?)',
        [LessonID, LessonCaption, English, Russian, Rating]);
    //print('inserted2: $id2');
  }

  Future<void> clearQuestions() async {
    final db = await database;
    var res = await db!.rawQuery("DELETE FROM questions;");
  }

  Future<List<String>> getAnotherRussian (int LessonID, String Russian, int max) async {
    final db = await database;
    List<String> words = [];
    var res = await db!.rawQuery("SELECT * FROM questions WHERE LessonId=" + LessonID.toString() +";");
    int count = 0;
    for(var row in res){
      if(row['Russian'] != Russian) {
        words.add(row['Russian'].toString());
        count++;
        if(count >= max) break;
      }
    }
    return words;
  }

  Future<List<String>> getAnotherEnglish (int LessonID, String English, int max) async {
    final db = await database;
    List<String> words = [];
    var res = await db!.rawQuery("SELECT * FROM questions WHERE LessonId=" + LessonID.toString() +";");
    int count = 0;
    for(var row in res){
      if(row['English'] != English) {
        words.add(row['English'].toString());
        count++;
        if(count >= max) break;
      }
    }
    return words;
  }

  Future<Map<String, dynamic>> getQuestionMaxRating() async {
    final db = await database;
    var res = await db!.rawQuery("SELECT * FROM questions WHERE Rating = (SELECT MAX(rating) FROM questions);");
    int num = Random().nextInt(res.length);
    Map<String, dynamic> rez = res[num];
    return(rez);
  }

  Future<void> setRating(int id, int Rating) async{
    final db = await database;
    String sql = "UPDATE questions SET Rating=" + Rating.toString() + " Where id=" + id.toString();
    //print("setRating");
    //print(sql);
    var res = await db!.rawQuery(sql);
  }

  Future<void> setRatingByLesson(int LessonID, int Rating) async{
    final db = await database;
    String sql = "UPDATE questions SET Rating=" + Rating.toString() + " Where LessonId=" + LessonID.toString();
    //print("setRating");
    //print(sql);
    var res = await db!.rawQuery(sql);
  }

  Future<List<Map>> getTestsList() async {
    final db = await database;
    List<Map> list = await db!.rawQuery('SELECT * FROM list');
    return list;
    //var res = await db.query("info", where: "id = ?", whereArgs: [id]);
    //return res.isNotEmpty ? Client.fromMap(res.first) : null;
  }

  Future<List<Map>> getProblems(String tableName) async {
    final db = await database;
    String sql ='SELECT * FROM ' + tableName + ' WHERE errors > 0 ORDER BY errors DESC';
    List<Map> list = await db!.rawQuery(sql);
    return list;
  }



  resetRating(String tableName) async{
    final db = await database;
    await db!.rawQuery("UPDATE " + tableName + " SET rating=100, errors=0");
  }







}