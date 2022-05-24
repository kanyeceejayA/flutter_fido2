// ignore_for_file: avoid_print

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// A helper class that lets you communicate with your server if you 
/// decide to let the plugin handle networking for you. It can 
/// alternatively stick to authenticating through the [Fido2Flutter] class
class ApiService {
  final _storage = const FlutterSecureStorage();
  
  /// The base Url of your server. This is the endpoint that is 
  /// fed with all requests if you choose to let the plugin handle 
  /// your networking. 
  var baseUrl = 'https://fido.silbaka.com';

  ApiService({String baseUrl = 'https://fido.silbaka.com'});

  Future<String?> read({required String key}) async{
    try{
      baseUrl = (await _storage.read(key:'baseUrl'))?? 'https://fido.silbaka.com';
      if (baseUrl == 'http://fido.local') {return await _storage.read(key:key);}
      
      final response = await http.get(Uri.parse(baseUrl+'/read.php?key='+Uri.encodeComponent(key)));
      if(response.statusCode != 200) return null;
      var data = response.body;
      String? result = data;
      return result;
    }catch(e){
      return null;
    }
  }

  Future<String?> write({required String key,required String value}) async{
    try{
      baseUrl = (await _storage.read(key:'baseUrl'))?? 'https://fido.silbaka.com';
      if (baseUrl == 'http://fido.local') {await _storage.write(key:key, value: value); return 'ok';}
      print('url is '+Uri.parse(baseUrl+'/write.php?key='+Uri.encodeComponent(key)+'&d='+Uri.encodeComponent(value)).toString() );
      final response = await http.get(Uri.parse(baseUrl+'/write.php?key='+Uri.encodeComponent(key)+'&d='+Uri.encodeComponent(value)));
      if(response.statusCode != 200) return null;
      var data = response.body;
      String? result = data;
      return result;
    }catch(e){
      return null;
    }
  }

  Future<String?> delete({required String key}) async{
    try{
      baseUrl = (await _storage.read(key:'baseUrl'))?? 'https://fido.silbaka.com';
      if (baseUrl == 'http://fido.local') {await _storage.delete(key:key); return null;}
      final response = await http.get(Uri.parse(baseUrl+'/del.php?key='+Uri.encodeComponent(key)));
      if(response.statusCode != 200) return null;
      var data = response.body;
      String? result = data;
      return result;
    }catch(e){
      return null;
    }
  }
}