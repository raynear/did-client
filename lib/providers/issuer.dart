import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fast_base58/fast_base58.dart';

import 'package:wallet/providers/global_variable.dart';
import 'package:wallet/utils/logger.dart';

class Issuer {
  Issuer(this.schemaLocation);
  final log = Log();
  final g = Get.put(GlobalVariable());

  final String schemaLocation;

  responseCheck(http.Response response) {
    switch ((response.statusCode / 100).floor()) {
      case 2:
        log.i("$response.body");
        return response;
      default:
        log.lw("Response Error $response");
        return response;
      // throw Error();
    }
  }

  getVC(token) async {
    final locations = await getSchemaLocation();
    http.Response response = await http.get(
      Uri.parse(locations['VCGet']),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ' + token
      },
    );
    return responseCheck(response);
  }

  postVC(body, privateKey) async {
    final locations = await getSchemaLocation();
    print("locations: $locations");
    http.Response response = await http.post(
      Uri.parse(locations['VCPost']),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: body,
    );
    final result = responseCheck(response);

    final challenge = jsonDecode(result.body);

    if (challenge.containsKey('payload')) {
      final challengeResult =
          await didAuth(challenge['payload'], challenge['endPoint'], response.headers['authorization'], privateKey);
      if (challengeResult) {
        return response.headers['authorization'];
      }
    }
    return false;
  }

  responseChallenge(challengeUri, encodedSignatureBytes, token) async {
    http.Response response = await http.get(challengeUri.replace(queryParameters: {'signature': encodedSignatureBytes}),
        headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token});
    return responseCheck(response);
  }

  getSchemaLocation() async {
    log.i(schemaLocation);
    http.Response response = await http.get(Uri.parse(schemaLocation));
    final vcLocation = responseCheck(response);
    return json.decode(vcLocation.body);
  }

  didAuth(payload, endPoint, token, privateKey) async {
    log.i('did Auth');
    final passwordBytes = utf8.encode(g.password.value);
    // Generate a random secret key.
    final sink = Sha256().newHashSink();
    sink.add(passwordBytes);
    sink.close();
    final passwordHash = await sink.hash();

    final key = encrypt.Key.fromBase64(base64Encode(passwordHash.bytes));
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypt.Encrypted.fromBase64(base64Encode(Base58Decode(privateKey)));

    final iv = encrypt.IV.fromLength(16);
    var decrypted = encrypter.decrypt(encrypted, iv: iv);

    if (decrypted.substring(0, 7) != "WIGGLER") {
      throw Error();
    }

    decrypted = decrypted.substring(7);

    final clearText = Base58Decode(decrypted);

    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPairFromSeed(clearText);
    // final pubKey = await keyPair.extractPublicKey();
    // final did = 'did:mtm:' + Base58Encode(pubKey.bytes);

    final challengeBytes = utf8.encode(payload);

    final signature = await algorithm.sign(challengeBytes, keyPair: keyPair);

    final response2 = await responseChallenge(Uri.parse(endPoint), Base58Encode(signature.bytes), token);
    if (response2 == "") {
      log.le("Challenge Failed");
      return false;
    }
    return true;
  }
}
