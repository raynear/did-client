import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallet/providers/global_variable.dart';

import 'package:wallet/controller/did_list_controller.dart';
import 'package:wallet/widgets/background.dart';
import 'package:wallet/pages/vc_list.dart';

class DIDList extends StatelessWidget {
  final g = Get.put(GlobalVariable());
  final c = Get.put(DIDListController());

  @override
  Widget build(BuildContext context) {
    g.log.i("DIDList build");
    return Background(
        mainAxisAlignment: MainAxisAlignment.start,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
              child: Text('Mitum DID',
                  style: GoogleFonts.kaushanScript(
                      textStyle: Get.theme.textTheme.headline5?.copyWith(color: Colors.white)))),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder(
                  future: c.getDIDList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        g.log.i("DID : ${json.encode(snapshot.data)}");
                        final dids = snapshot.data as Map<String, dynamic>;

                        return Column(children: dids.keys.map((did) => VCList(did: did)).toList());
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  })
            ]));
  }
}
