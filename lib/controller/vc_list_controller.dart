import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:wallet/providers/issuer.dart';
import 'package:wallet/providers/secure_storage.dart';
import 'package:wallet/providers/global_variable.dart';
import 'package:wallet/models/vc.dart';
import 'package:wallet/utils/logger.dart';

class VCListController extends GetxController {
  VCListController(this.did);

  final storage = FlutterSecureStorage();
  final g = Get.put(GlobalVariable());
  final log = Log();

  final String did;

  VCManager? vcManager;

  @override
  onInit() async {
    super.onInit();

    vcManager = VCManager(did);
    vcManager?.init();
  }

  getVCList(did) async {
    log.i("getVCList");

    for (var vc in vcManager!.vcs) {
      if (vc.vc.isEmpty && vc.jwt != "") {
        log.i("getVC from issuer");

        final issuer = Issuer(vc.schemaRequest);
        var response = await issuer.getVC(vc.jwt);

        if (json.decode(response.body).containsKey('error')) {
          continue;
        }

        var data = json.decode(response.body)['vc'];

        // vc.vc = data;
        await VCManager(did).setByName(vc.name, 'vc', data);
        await VCManager(did).setByName(vc.name, 'jwt', "");
      }
    }
    return vcManager!.vcs;
  }
}
