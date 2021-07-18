import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fast_base58/fast_base58.dart';

import 'package:wallet/providers/global_variable.dart';
import 'package:wallet/utils/logger.dart';

class LoginController extends GetxController {
  final storage = FlutterSecureStorage();
  final g = Get.put(GlobalVariable());
  final log = Log();

  login(password) async {
    try {
      final passwordBytes = utf8.encode(password);
      // Generate a random secret key.
      final sink = Sha256().newHashSink();
      sink.add(passwordBytes);
      sink.close();
      final passwordHash = await sink.hash();

      final key = encrypt.Key.fromBase64(base64Encode(passwordHash.bytes));
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final didListStr = await storage.read(key: 'DIDList') as String;
      log.i("didListStr: $didListStr");
      final didList = json.decode(didListStr);
      log.i("did first: $didList, ${didList.runtimeType}");
      final privateKey = didList.values.toList()[0];
      final encrypted = encrypt.Encrypted.fromBase64(base64Encode(Base58Decode(privateKey)));

      final iv = encrypt.IV.fromLength(16);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      final clearText = Base58Decode(decrypted);

      final algorithm = Ed25519();
      final keyPair = await algorithm.newKeyPairFromSeed(clearText);
      final pubKey = await keyPair.extractPublicKey();
      final did = 'did:mtm:' + Base58Encode(pubKey.bytes);
      g.inputPassword(password);
      g.inputDID(did);
      Get.offAllNamed('/');
    } catch (e) {
      log.e(e);
      // log.i("${password} is not correct password");
      await Get.defaultDialog(
          title: "incorrectPassword".tr,
          content: Text('incorrectPassword'.tr),
          confirm: ElevatedButton(
            child: Text('ok'.tr),
            style: Get.theme.textButtonTheme.style,
            onPressed: () {
              Get.back();
            },
          ));
    }
  }
}
