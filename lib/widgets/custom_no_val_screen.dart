// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_color.dart';

import '../const/app_font.dart';
import '../const/utils.dart';

class NoValScreen extends StatefulWidget {
  String? title = "";
  NoValScreen({Key? key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NoValScreen();
  }
}

class _NoValScreen extends State<NoValScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 60,
            centerTitle: true,
            backgroundColor: AppColor.backgroundBlack(),
            elevation: 0,
            title: Text(Utils.getTranslated(context, widget.title.toString()),
                style: AppFont.montRegular(18, color: Colors.white)),
            leading: InkWell(
                onTap: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: Image.asset(
                    'assets/images/white-left-icon.png') // child: Image.asset('assets/images/white-left-icon.png')
                )),
        body: Container(
            color: Colors.black,
            height: height,
            width: width,
            child: SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Image.asset(
                    'assets/images/no-records-icon.png',
                  ),
                  Text(Utils.getTranslated(context, 'no_record_found'),
                      style: AppFont.montRegular(16,
                          color: AppColor.dividerColor()))
                ]))));
  }
}
