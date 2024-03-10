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

class ButtonAnswer extends StatelessWidget {
  ButtonAnswer({super.key, required this.value});
    final String value;

  bool helping = false;
  double fsize = 16;
  FontWeight isBold = FontWeight.normal;

  @override
  Widget build(BuildContext context) {
    helping = context.watch<Model>().Help;
    fsize = context.watch<Model>().fontSize + 2;
    if(helping && value == context.watch<Model>().sRightAnswer ){
      fsize = 16;
      isBold = FontWeight.bold;
    }
    return Card(
        elevation: 5,
        child: InkWell(
          onTap: () {
            Provider.of<Model>(context, listen: false).answer(value);
          },
          child: ListTile(
            title: Container(
              child: Text(value,
                  style: TextStyle(
                      fontSize: fsize,
                      fontWeight: isBold
                  )),
            ),
            isThreeLine: false,
          ),
        )
    );
  }
}
