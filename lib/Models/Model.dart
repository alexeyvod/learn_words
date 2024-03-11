import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../Functions/DBProvider.dart';


class Model extends ChangeNotifier {

  late SharedPreferences prefs;

  late LottieComposition CurrentLottie;
  bool LottieRepeat = true;
  Map<int, LottieComposition> compositions = {};
  Map<String, LottieComposition> lotties = {};
  List<int> answers = [0,0,0,0];
  int currentEmoji = 0;
  bool loaded = false;
  int Number1 = 0;
  int Number2 = 0;
  bool isFirstAttempt = false;
  String Primer = '';
  bool GameOver = false;
  bool isShow = false;
  int hearts = 100;
  int AllHearts = 0;
  int RightAnswer = 0;
  int MinNumber = 2;
  int Rating = 0;

  String sRightAnswer = '';
  String sLessonCaption = '';
  String sTitle = '';
  int sLessonId = -1;
  int sQuestionId = -1;
  List<String> sAnswers = [];
  int sMaxAnswers = 4;
  bool Help = false;

  int penaltyValid = -6;
  int penaltyHelp = 0;
  int penaltyWrong = 0;
  double fontSize = 12;

  Random random = new Random();
  late Timer timer1;

  bool isSpeak = true;
  late AudioPlayer player;
  String EnglishWord = '';
  String RussianWord = '';

  Future startProgramm() async {
    if(isSpeak) player = AudioPlayer();
    prefs = await SharedPreferences.getInstance();
    fontSize = prefs.getDouble('fontSize') ?? 12;
    lotties['ok'] = await AssetLottie('assets/ok.json').load();
    lotties['bad'] = await AssetLottie('assets/bad.json').load();
    lotties['award'] = await AssetLottie('assets/award.json').load();
    compositions[-3] = await AssetLottie('assets/-3.json').load();
    compositions[-2] = await AssetLottie('assets/-2.json').load();
    compositions[-1] = await AssetLottie('assets/-1.json').load();
    compositions[0] = await AssetLottie('assets/0.json').load();
    compositions[1] = await AssetLottie('assets/+1.json').load();
    compositions[2] = await AssetLottie('assets/+2.json').load();
    compositions[3] = await AssetLottie('assets/+3.json').load();
    compositions[4] = await AssetLottie('assets/+4.json').load();
    compositions[5] = await AssetLottie('assets/+5.json').load();
    CurrentLottie = compositions[currentEmoji]!;
    reStart();
  }

  void cancelTimer(){
    timer1!.cancel();
  }

  reStart() async {
    List<Map> tmp = await DBProvider.db.getAll();
    if(tmp.length == 0) {
      return;
    }

    currentEmoji = 0;
    hearts = 100;
    await newPrimer();
    loaded = true;
    GameOver = false;
    timer1 = Timer.periodic(const Duration(seconds: 1), (timer) {
      //print(timer.tick);
      hearts--;
      notifyListeners();
      if (hearts == 0) {
        print('Cancel timer');
        GameOver = true;
        hearts = 0;
        currentEmoji = -3;
        CurrentLottie = compositions[currentEmoji]!;
        Primer = "Старайся лучше";
        timer1.cancel();
        notifyListeners();
      }
    });
    notifyListeners();
  }


  newPrimer() async {
    Help = false;
    prefs = await SharedPreferences.getInstance();
    sTitle = prefs.getString('LessonCaption') ?? "";

    DateTime now = new DateTime.now();
    String formattedDate = now.year.toString() + now.month.toString() + now.day.toString();
    String lastDate = prefs.getString('lastDate') ?? '';
    AllHearts = prefs.getInt('AllHearts') ?? 0;
    if(formattedDate != lastDate){
      lastDate = formattedDate;
      AllHearts = 0;
      prefs.setInt('AllHearts', AllHearts);
      prefs.setString('lastDate', lastDate);
    }

    Map<String, dynamic> Question = await DBProvider.db.getQuestionMaxRating();
    sLessonId  = Question['LessonId'];
    sQuestionId = Question['id'];
    if(Random().nextBool()){
      sRightAnswer = Question['English'];
      Primer = Question['Russian'];
      sAnswers = await DBProvider.db.getAnotherEnglish (sLessonId, sRightAnswer, sMaxAnswers - 1);
    }else{
      sRightAnswer = Question['Russian'];
      Primer = Question['English'];
      sAnswers = await DBProvider.db.getAnotherRussian (sLessonId, sRightAnswer, sMaxAnswers - 1);
    }
    EnglishWord = Question['English'].toString();
    RussianWord = Question['Russian'].toString();
    sAnswers.add(sRightAnswer);
    sAnswers.shuffle();
    sLessonCaption = Question['LessonCaption'];
    Rating = Question['Rating'];
    isFirstAttempt = true;
    isShow = true;
    if(EnglishWord != sRightAnswer) Speak(EnglishWord);
    notifyListeners();
  }

  void Speak(String word) async {
    if(isSpeak){
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String mp3FileName = join(documentsDirectory.path, 'words_mp3', word.toString().trim().replaceAll("?", "").replaceAll("!", "").replaceAll(" ", "_") + ".mp3");
      File mp3File =File(mp3FileName);
      print(mp3FileName);
      try{
        if (mp3File.existsSync()){
          player.play(UrlSource(mp3FileName));
        }else{
         print("Error play mp3: Not found ${mp3FileName}");
        }
      }catch (e){
        print("Error play mp3: ${e.toString()}");
      }
    }
  }

  getHelp(){
    Speak(EnglishWord);
    isFirstAttempt = false;
    Help = true;
    notifyListeners();
  }

  answer(String answer) async {
    if(answer == sRightAnswer) {
      Primer = EnglishWord + " = " + RussianWord;
      int ishRating = Rating;
      if(isFirstAttempt){
        Rating += penaltyValid;
      }else{
        Rating += penaltyWrong;
      }
      if(Help) {
        Rating += penaltyHelp;
      }
      print("Рейтинг: ${ishRating} -> ${Rating}");
      await DBProvider.db.setRating(sQuestionId, Rating);
      //hearts += 1;
      Timer(Duration(milliseconds: 900), () {
        CurrentLottie = compositions[currentEmoji]!;
        LottieRepeat = true;
        isShow = true;
        if(!GameOver) newPrimer();
        notifyListeners();
      });
      CurrentLottie = lotties['ok']!;
      LottieRepeat = false;
      isShow = false;
    }
    if(isFirstAttempt && answer == sRightAnswer){
      currentEmoji++;
    }
    if(answer != sRightAnswer){
      Rating += penaltyWrong;
      currentEmoji--;
      hearts -= 15;
      Timer(Duration(milliseconds: 900), () {
        CurrentLottie = compositions[currentEmoji]!;
        LottieRepeat = true;
        notifyListeners();
      });
      CurrentLottie = lotties['bad']!;
      LottieRepeat = false;
    }

    isFirstAttempt = false;
    if(currentEmoji == 5){ // Выигрыш
      GameOver = true;
      if(hearts > 85){
        Primer = "Молодец!";
      }else if(hearts > 75){
        Primer = "Хорошо!";
      }else if(hearts > 55){
        Primer = "Можно и лучше";
      }else {
        Primer = "Маловато";
      }
      timer1.cancel();
      AllHearts += hearts;
      prefs.setInt('AllHearts', AllHearts);
      notifyListeners();
      return;
    }
    if(currentEmoji == -3){ // Проигрыш
      GameOver = true;
      Primer = "Старайся лучше";
      hearts = 0;
      timer1.cancel();
      notifyListeners();
      return;
    }
    notifyListeners();
  }

  void Plus(){
    currentEmoji++;
    notifyListeners();
  }
  void Minus(){
    currentEmoji--;
    notifyListeners();
  }

  void fontIncrease() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    fontSize = prefs.getDouble('fontSize') ?? 12;
    fontSize += 2;
    prefs.setDouble('fontSize', fontSize);
    notifyListeners();
  }
  void fontDecrease() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    fontSize = prefs.getDouble('fontSize') ?? 12;
    fontSize -= 2;
    prefs.setDouble('fontSize', fontSize);
    notifyListeners();
  }

}