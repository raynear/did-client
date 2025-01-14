import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wallet/controller/vc_card_controller.dart';
import 'package:wallet/provider/global_variable.dart';
import 'package:wallet/util/logger.dart';

class VCCard extends StatelessWidget {
  VCCard(
      {key,
      required this.name,
      required this.display,
      required this.description,
      required this.type,
      required this.icon,
      required this.status})
      : super(key: key);

  final String name;
  final String display;
  final String description;
  final String type;
  final IconData icon;
  final String status;

  final c = Get.put(VCCardController());

  final GlobalVariable g = Get.find();
  final log = Log();

  Widget _getLogoByName() {
    log.i("VCCard:getLogoByName");
    const double height = 20;
    if (name == "drivers license" || name == "driverLicense" || name == "Driver's license") {
      return Image.asset('assets/images/drivers_license_logo.png', height: height);
    } else if (name == "protoconpass" || name == "protoconPass" || name == "Protocon pass") {
      return Image.asset('assets/images/protoconpass_logo.png', height: height);
    } else {
      return Image.asset('assets/icons/flutter.png', height: height);
    }
  }

  Widget _getCardByName() {
    log.i("VCCard:getCardByName");
    const double height = 200;

    if (name == "drivers license" || name == "driverLicense" || name == "Driver's license") {
      return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset('assets/images/drivers_license.png', height: height));
    } else if (name == "protoconpass" || name == "protoconPass" || name == "Protocon pass") {
      return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset('assets/images/protoconpass.png', height: height));
    } else {
      return ClipRRect(
          borderRadius: BorderRadius.circular(15), child: Image.asset('assets/icons/flutter.png', height: height));
    }
  }

  Widget _getDeniedImageByName() {
    log.i("VCCard:getWaitImageByName");
    const double height = 50;
    if (name == "drivers license" || name == "driverLicense" || name == "Driver's license") {
      return Image.asset('assets/images/idDeny.png', height: height);
    } else if (name == "protoconpass" || name == "protoconPass" || name == "Protocon pass") {
      return Image.asset('assets/images/idDeny.png', height: height);
    } else {
      return Image.asset('assets/icons/flutter.png', height: height);
    }
  }

  Widget _getWaitImageByName() {
    log.i("VCCard:getWaitImageByName");
    const double height = 50;
    if (name == "drivers license" || name == "driverLicense" || name == "Driver's license") {
      return Image.asset('assets/images/idReview.png', height: height);
    } else if (name == "protoconpass" || name == "protoconPass" || name == "Protocon pass") {
      return Image.asset('assets/images/idReview.png', height: height);
    } else {
      return Image.asset('assets/icons/flutter.png', height: height);
    }
  }

  Widget _contentByStatus(String status) {
    log.i("VCCard:contentByStatus");
    if (status == "noVC") {
      return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [_getLogoByName()]),
            Text(description, style: Get.textTheme.bodyText1),
            Text(display + ' 추가하기', style: Get.textTheme.button!.copyWith(color: Get.theme.primaryColor)),
          ]));
    } else if (status == "VC") {
      return _getCardByName();
    } else if (status == "denied") {
      return Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [_getLogoByName()]),
        _getDeniedImageByName(),
        Text('$display 발급이 거절 되었습니다.'),
        Text('재신청하기', style: Get.textTheme.button!.copyWith(color: Get.theme.primaryColor)),
      ]);
    } else {
      // wait
      return Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [_getLogoByName()]),
        _getWaitImageByName(),
        Text('담당자 확인 후 $display 이(가) 발급됩니다.')
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    log.i("VCCard:build");

    if (c.animationOffset == null) return const Text('loading');

    return SlideTransition(
        position: c.animationOffset!,
        child: Container(
            margin: EdgeInsets.only(left: Get.width * 0.125, right: Get.width * 0.125, top: 18, bottom: 18),
            height: 200,
            width: Get.width * 0.75,
            child: Stack(children: [
              Card(
                color: Colors.red, //Get.theme.cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Colors.grey.shade200])),
                    child: _contentByStatus(status)),
              ),
              Opacity(
                  opacity: 1.0,
                  child: Image.asset(
                    'assets/images/cardGlow.png',
                    height: 200,
                    width: Get.width * 0.75,
                  )),
            ])));
  }
}
