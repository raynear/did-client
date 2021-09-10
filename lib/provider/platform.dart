import 'package:dio/dio.dart';

import 'package:wallet/util/logger.dart';
import 'package:wallet/util/did_document.dart';

class Platform {
  final log = Log();

  final didDocument = DIDDocument();

  Future<Response<dynamic>> getDIDDocument(String getDIDDocumentUri) async {
    log.i("Platform:getDIDDocument(getDIDDocumentUri:$getDIDDocumentUri)");
    log.i(getDIDDocumentUri);
    final response = await Dio().get(getDIDDocumentUri).catchError((onError) {
      log.e("getDIDDocument error: ${onError.toString()}");
    });

    return response;
  }

  Future<Response<dynamic>> setDIDDocument(String setDIDDocumentUri, String did) async {
    log.i("Platform:setDIDDocument(setDIDDocumentUri:$setDIDDocumentUri, did:$did)");
    String document = didDocument.createDIDDocument(did);

    var response = await Dio()
        .post(setDIDDocumentUri, options: Options(contentType: Headers.jsonContentType), data: document)
        .catchError((onError) {
      log.e("setDIDDocument error: ${onError.toString()}");
    });

    return response;
  }

  Future<Response<dynamic>> getSchema(String schemaUri) async {
    log.i("Platform:getSchema(schemaUri:$schemaUri)");
    final response = await Dio().get(schemaUri).catchError((onError) {
      log.e("getSchema error: ${onError.toString()}");
    });

    return response;
  }
}
