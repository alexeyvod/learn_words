import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../Models/Model.dart';

class AllHearts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FadeInLeft(
          child: Consumer<Model>(
            builder: (context, model, child) {
              return Text(
                  "За сегодня: ${model.AllHearts}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red,
                      fontSize: context.watch<Model>().fontSize + 4,
                      fontWeight: FontWeight.bold)
              );
            },
          ),
        ),
        SizedBox(width: 6,),
        FadeInRight(child: Image.asset("assets/heart.png", width: 20, height: 20, fit: BoxFit.contain)),
      ],
    );
  }
}
