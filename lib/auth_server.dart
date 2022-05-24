// ignore_for_file: unused_import, avoid_print

import 'dart:convert';
import 'dart:math';

import 'api_service.dart';
import 'package:crypton/crypton.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
/// A helper class that lets you communicate with your server if you 
/// decide to let the plugin handle networking for you. It can 
/// alternatively stick to authenticating through the [Fido2Flutter] class.
/// It is used in conjunction with the Api Service Class
class AuthServer{

	// Create Local storage
	// final _storage = FlutterSecureStorage();

  /// The base Url of your server. This is the endpoint that is 
  /// fed with all requests if you choose to let the plugin handle 
  /// your networking. 
  var baseUrl = 'https://fido.silbaka.com';

	// Create online  storage
	final _storage = ApiService();

  AuthServer({String baseUrl = 'https://fido.silbaka.com'});

  /// create a registration request
	Future<Map<String,dynamic>> registrationRequest({required String userId}) async{
		if(userId == '') throw PlatformException(code: 'User_Name_Cannot_Be_Blank',message: 'Username cannot be blank');
		String challenge = _generateChallenge();

		var _data = (await _storage.read(key: userId)) ??'{"credentials":[]}';
    print('sent data:'+_data.toString());
		// [
		// 	{"credentialId": credentialId, "publicKey": publicKey}, 
		// 	{"credentialId": credentialId, "publicKey": publicKey}
		// ]
		List credentials = (json.decode(_data))['credentials'];
		List ids = [];
		for (var item in credentials) {
		  ids.add(item['credentialId']);
		}

		var writeResult = await _storage.write(key: 'RequestChallengeFor'+userId,value: challenge);
    print('sent write result:'+writeResult.toString());

		print  ({'challenge': challenge,'credentials':ids});
		return {'challenge': challenge,'credentials':ids};
	}

	Future<Map<String,dynamic>> signingRequest({required String userId}) async{
		if(userId == '') throw PlatformException(code: 'User_Name_Cannot_Be_Blank',message: 'Username cannot be blank');
		String challenge = _generateChallenge();

		var _data = (await _storage.read(key: userId)) ??'{"credentials":[]}';
		List credentials = (json.decode(_data))['credentials'];
		List<String> ids = [];
		for (var item in credentials) {
		  ids.add(item['credentialId']);
		}

		await _storage.write(key: 'RequestChallengeFor'+userId,value: challenge);

		print  ({'challenge': challenge,'credentials':ids});
		return {'challenge': challenge,'credentials':ids};
	}

	Future<String> confirmSignIn({ required String userId, required String credentialId,required String signedChallenge}) async{
		try {
			var _data = (await _storage.read(key: userId)) ??'{"credentials":[]}';
			List credentials = (json.decode(_data))['credentials'];
			List<String> ids = [];
			String publicKey = '';
			for (var item in credentials) {
				if (item['credentialId'] != credentialId) continue;
				publicKey =item['publicKey'];
				break;
			}
			if (publicKey == '') return 'Sorry, Login Unsuccessful. please try again or register.';
			bool isValid = await _validateChallenge(userId, publicKey, signedChallenge); 
			if(!isValid){ return 'Sorry, Login Unsuccessful.';}
			print('AKBR IT IS VALID');
			
			return 'Successfully Logged in. User Id:$userId';
		} on PlatformException catch (e) {
		  return 'error occured: ${e.message}';
		}
	}

	
	Future<String> storeCredential({ required String userId, required String credentialId,required String signedChallenge, required String publicKey}) async{
		try {
		  bool isValid = await _validateChallenge(userId, publicKey, signedChallenge); 
		  if(!isValid){ return 'false';}
		  print('AKBR IT IS VALID');
		  
		  var _data = (await _storage.read(key: userId)) ??'{"credentials":[]}';
		  List credentials = (json.decode(_data))['credentials'];
		  credentials.add({"credentialId": credentialId, "publicKey": publicKey});
		  
		  
		  String storeData = json.encode({"userId": userId, "credentials": credentials});
		  await _storage.write(key: userId,value: storeData);
		  
		  return 'Storage Successful. User Id: $userId';
		} on PlatformException catch (e) {
		  return 'error occured: ${e.message}';
		}
	}

	Future<bool> _validateChallenge(String userId, String publicKey, String signedChallenge) async{
		String challenge = await _storage.read(key: 'RequestChallengeFor'+userId)?? _generateChallenge() ;
		await _storage.delete(key: 'RequestChallengeFor'+userId);

		return ECPublicKey.fromString(publicKey).verifySignature(challenge, signedChallenge);
	}

	String _generateChallenge([int length = 64]) {
		const charset ='0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
		final random = Random.secure();
		return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
	}

}