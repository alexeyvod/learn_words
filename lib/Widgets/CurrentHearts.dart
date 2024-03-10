import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../Models/Model.dart';

class CurrentHearts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FadeInLeft(duration: Duration(milliseconds: 150), child: Image.asset("assets/heart.png", width: 30, height: 30, fit: BoxFit.contain)),
        SizedBox(width: 6,),
        FadeInRight(
          child: Consumer<Model>(
            builder: (context, model, child) {
              return Text(
                  "${model.hearts}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)
              );
            },
          ),
        )
      ],
    );
  }
}
