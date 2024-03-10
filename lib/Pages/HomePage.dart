import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Functions/DBProvider.dart';
import '../Models/Model.dart';
import '../Functions/LoadFile.dart';
import '../Pages/SelectLesson.dart';
import '../Widgets/AllHearts.dart';
import '../Widgets/ButtonAnswer.dart';
import '../Widgets/CurrentHearts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {

  late BuildContext mContext;
  late SharedPreferences prefs;
  String Title = "";


  @override
  void initState() {
    super.initState();
    Start();
  }

  void Start() async{
    List<Map> tmp = await DBProvider.db.getAll();
    if(tmp.length == 0) {
      await DBProvider.db.initDB();
      LoadFile lf = new LoadFile(mContext);
      await lf.selectFile();
      Navigator.of(context).pop();
      await Navigator.push(context, MaterialPageRoute(builder: (context) => SelectLesson()));
    }else{
      prefs = await SharedPreferences.getInstance();
      Title = prefs.getString('LessonCaption') ?? "";
      if(!mounted) return;
      Provider.of<Model>(context, listen: false).startProgramm();
    }
  }

  /*
  Future<LottieComposition> _loadComposition() async {
    var assetData = await rootBundle.load('assets/0.json');
    return await LottieComposition.fromByteData(assetData);
  }
   */

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.watch<Model>().sTitle.toString(),
              style: new TextStyle(fontSize: context.watch<Model>().fontSize)),
          actions: <Widget>[
            PopupMenuButton<int>(
              onSelected: (item) => handleClick(item),
              itemBuilder: (context) => [
                PopupMenuItem<int>(value: 0, child: Text('Увеличить шрифт')),
                PopupMenuItem<int>(value: 1, child: Text('Уменьшить шрифт')),
                PopupMenuItem<int>(value: 2, child: Text('Загрузка файла')),
                PopupMenuItem<int>(value: 3, child: Text('Выбор урока')),
              ],
            )
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CurrentHearts(),
                    AllHearts()
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Consumer<Model>(
                    builder: (context, model, child) {
                      if(model.loaded){
                        return Lottie(
                          composition: model.CurrentLottie,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                          repeat: model.LottieRepeat,
                        );
                      }else{
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                SizedBox(height: 5,),
                Expanded(
                  child: Consumer<Model>(
                    builder: (context, model, child) {
                      return Column(
                        children: [
                          !model.isShow ? Container(): FadeInDown(
                            child: Text(
                                "${model.Primer}",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.indigo,
                                    fontSize: context.watch<Model>().fontSize + 8,
                                    fontWeight: FontWeight.bold)
                            ),
                          ),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(context.watch<Model>().sLessonCaption.toString(),
                                  style: new TextStyle(fontSize: context.watch<Model>().fontSize - 4)),
                              IconButton(
                                iconSize: 40,
                                icon: const Icon(Icons.help_outline, color: Colors.indigo),
                                onPressed: () {
                                  Provider.of<Model>(context, listen: false).getHelp();
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 1,),
                          Provider.of<Model>(context, listen: false).GameOver ? Container() :
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              !model.isShow ? Container(): FadeInLeft(
                                  duration: Duration(milliseconds: 200),
                                  child: ButtonAnswer(value: model.sAnswers[0])),
                              !model.isShow ? Container(): FadeInRight(
                                  duration: Duration(milliseconds: 200),
                                  child: ButtonAnswer(value: model.sAnswers[1])),
                              !model.isShow ? Container(): FadeInLeft(
                                  duration: Duration(milliseconds: 200),
                                  child: ButtonAnswer(value: model.sAnswers[2])),
                              !model.isShow ? Container(): FadeInUp(
                                  duration: Duration(milliseconds: 200),
                                  child: ButtonAnswer(value: model.sAnswers[3])),
                            ],
                          ),
                          !Provider.of<Model>(context, listen: false).GameOver ? Container() :
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FadeInLeft(child: Image.asset("assets/heart.png", width: 100, height: 100, fit: BoxFit.contain)),
                                  FadeInRight(
                                    child: Consumer<Model>(
                                      builder: (context, model, child) {
                                        return Text(
                                            "${model.hearts}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.red,
                                                fontSize: 70,
                                                fontWeight: FontWeight.bold)
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 40,),
                              FadeInUp(
                                delay: const Duration(seconds: 1),
                                child: Center(
                                  child: SizedBox(
                                      width: 160,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Provider.of<Model>(context, listen: false).reStart();
                                        },
                                        child:
                                        Text("Начать заново",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.white,
                                                fontSize: context.watch<Model>().fontSize + 2,
                                                fontWeight: FontWeight.bold)
                                        ),
                                      )
                                  ),
                                ),
                              )
                            ],
                          )
                  
                        ],
                      );
                    },
                  ),
                ),
                Text("Водопьянов Алексей, 2024",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black38,
                        fontSize: 8,
                        fontWeight: FontWeight.normal)
                ),
              ],
            ),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  void handleClick(int item) async {
    switch (item) {
      case 0:
        Provider.of<Model>(context, listen: false).fontIncrease();
        break;
      case 1:
        Provider.of<Model>(context, listen: false).fontDecrease();
        break;
      case 2:
      // Загрузка слов
        Provider.of<Model>(context, listen: false).cancelTimer();
        LoadFile lf = new LoadFile(mContext);
        await lf.selectFile();
        break;
      case 3:
      // Select Lesson
        Provider.of<Model>(context, listen: false).cancelTimer();
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(builder: (context) => SelectLesson()));
        break;
    }
  }










}