import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Functions/DBProvider.dart';
import '../Functions/LoadFile.dart';
import '../Pages/HomePage.dart';

class SelectLesson extends StatefulWidget {
  const SelectLesson({super.key});

  @override
  State<SelectLesson> createState() => _SelectLessonState();
}

class _SelectLessonState extends State<SelectLesson> {

  late BuildContext mContext;
  late Map<dynamic, dynamic> Lessons;
  late List<Map> LessonsList;
  bool isReady = false;

  @override
  void initState() {
    // TODO: implement initState
    mContext = context;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: (){
          while(Navigator.of(mContext).canPop()){
            Navigator.of(mContext).pop(false);
          }
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(title:"")));
          return Future.value(true);
        },
        child: Scaffold(
            appBar: new AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text("Выбор урока"),
            ),
            body: SafeArea(
              child: Container(
                padding: new EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: wgtListTest()
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          ),
                          child: const Text('Назад',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              ),
            )
        )
    );
  }


  Widget wgtListTest(){
    return FutureBuilder<List<Map>>(
        future: getLessons(),
        builder: (context, AsyncSnapshot<List<Map>> snapshot) {
          if (snapshot.hasData) {
            //print("zzzzzzzzzzzzzzzzz count = " + snapshot.data.length.toString());
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                //print( snapshot.data[index]['id'] + "    " +snapshot.data[index]['name'] );
                return InkWell(
                  onTap: () {
                    Select(
                        snapshot.data?[index]['counter']
                    );
                  },
                  child: Card(
                    elevation: 5,
                    child: ListTile(
                      title: Text(snapshot.data?[index]['Caption']),
                      isThreeLine: false,
                      //trailing: new Icon(Icons.ac_unit),
                    ),
                  ),
                );
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        }
    );
  }


  Future<List<Map>> getLessons() async {
    var box = await Hive.openBox('hive');
    Lessons = box.get('Lessons');
    if(Lessons.length == 0) {
      LoadFile lf = new LoadFile(mContext);
      await lf.selectFile();
    }
    LessonsList = [];
    print("Lessons: ${Lessons.length}");
    int counter = -1;
    Lessons.forEach((LessonCaption, words) {
      counter++;
      Map<dynamic, dynamic> lesson = new Map<dynamic, dynamic>();
      lesson['counter'] = counter;
      lesson['Caption'] = LessonCaption;
      lesson['words'] = words;
      LessonsList.add(lesson);
    });
    isReady = true;
    return LessonsList;
  }

  void Select(int LessonID) async {
    print("Select ${LessonID}");
    await DBProvider.db.clearQuestions();
    for(int i = 0; i <= LessonID; i++){
      var lesson = LessonsList[i];
      String LessonCaption = lesson['Caption'];
      Map<dynamic, dynamic> words = lesson['words'];
      words.forEach((English, Russian) async {
        await DBProvider.db.addQuestion(
            i,
            LessonCaption,
            English,
            Russian,
            100
        );
      });
    }
    await DBProvider.db.setRatingByLesson(LessonID, 111);
    //List<Map> tmp = await DBProvider.db.getAll();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('LessonID', LessonID);
    String LessonCaption = LessonsList[LessonID]['Caption'];
    prefs.setString('LessonCaption', LessonCaption);
    while(Navigator.of(mContext).canPop()){
      Navigator.of(mContext).pop(false);
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(title:"")));
  }











}