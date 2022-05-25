# FlutterFido2
A flutter plugin for using FIDO/WebAuthN APIs. Supports Android and Web.

[![GitHub issues](https://img.shields.io/github/issues/kanyeceejayA/flutter_fido2)](https://github.com/kanyeceejayA/flutter_fido2/issues)
[![GitHub license](https://img.shields.io/github/license/kanyeceejayA/flutter_fido2)](https://github.com/kanyeceejayA/flutter_fido2/blob/main/LICENSE)
[![GitHub forks](https://img.shields.io/github/forks/kanyeceejayA/flutter_fido2)](https://github.com/kanyeceejayA/flutter_fido2/network)


## Contents:
1. [Supported Platforms](#SupportedPlatforms)
2. [Introduction](#Introduction)
3. [API Calls](#APICalls)
4. [Usage](#Usage)
5. [SetUp](#SetUp)
6. [See Also](#SeeAlso)
7. [TODO](#TODO)


##  1. <a name='SupportedPlatforms'></a>Supported Platforms

| Platform | Supported     |
| -------- | ------------- |
| Android  | `18+`         |
| iOS      | `9.0+`        |
| Windows  | `10+`         |
| Web      | `IN PROGRESS` |


##  2. <a name='Introduction'></a>Introduction

FlutterFido2 is a package that supports FIDO2 password-less authentication in apps built with Flutter. It closely follows the WebAuthn specs to deliver a seamless password-free authentication experience.
It lets you register authenticators, sign challenges, communicate with your server and more. The modules include these:

1. **Registration** - A user can be registered by submitting their user name and triggering registration. The credentials received can be handled by you or they can be sent to your server using the ```auth Server``` class.

2. **Signing** - Signing verifies the user's identity. It signs a challenge sent to the authenticator to help prove its identity.

3. **CheckAvailability** - This checks if a device has an authenticator. In some cases, a user might have an authenticator that is not currently visible to the device, so that should be kept in mind.

4. **ListAuthenticators** - This lists available authenticators on the device. This might be helpful in case you would like to let the user choose what they would prefer to use.

5. **CancelAuthentication** - This gives an app user the ability to stop the authentication process for any reason.

6. **Generate Random Credential Ids** - Make random credential Ids to identify generated keys

7. **Store Credentials in Authenticator's Encrypted Storage** - stored credentials are submitted for storage in encrypted storage secured by the authenticator.

8. **Communicate with your Server** - the optional ApiService class lets you enter your RP Server. This lets the plugin handle communications with the server for you, as long as you set up the endpoints accordingly on your server. 


###  2.1. <a name='HowdoesFIDO2verifyausersidentityBriefoverview'></a>How does FIDO2 verify a user's identity? (Brief overview)

FIDO2 works using public key cryptography. FIDO2 is designed with great focus on improved security, privacy, standardization, and ease of use.  It defines two main process flows: registration and authentication, which are explained below. 
When the user is in the registration phase, the client generates an asymmetric keypair (1 public key and 1 private key). 
The private key pair is stored somewhere secure on device while the public key pair is sent to the server and is associated to a particular user.

The next time that the server wants to authenticate a user, they send a challenge - usually a randomly 
generated string with a fixed, predetermined length. 
The FIDO2 client uses the private key it previously stored to sign this string, producing a signature. 
Using the previously registered public key, the server can check whether or not the signature produced was a result of using 
the associated private key to sign the particular challenge. The identity of the user is assumed from their ownership of the private key.

Read more about FIDO [here](#see-also)

##  3. <a name='APICalls'></a>API Calls
###  3.1. <a name='register'></a>`register`

Initiates the registration process.  This launches the FIDO client which authenticates the user associated with [userId] even external authenticators.


####  3.1.1. <a name='Arguments:'></a>Arguments:

| variable                  | type     | description                                                            |
|---------------------------|----------|------------------------------------------------------------------------|
| `challenge`               | `String` | A challenge to prevent replay attacks                                  |
| `excludeCredentials`      | `String` | Previously registered credentials for the user you are registering.    |
| `userId`                  | `String` | The username of the user you are registering a credential for.         |
| `rpDomain`                | `String` | The domain of the Relying Party                                        |
| `rpName`                  | `String` | The name of the Relying Party                                          |
| `options**`               | `Object` | Any extra options you would like to add.                               |

####  3.1.2. <a name='Example:'></a>Example:

```dart
import 'package:flutter_fido2/flutter_fido2.dart';

//This returns a RegistrationResult
RegistrationResult result = await register();
//you can access and send this information on to your server.
result.credentialId;
result.signedChallenge;
result.publicKey;

```

> \* A Relying Party refers to the party on whose behalf the authentication ceremony is being performed. 
> You can view the formal definition [here](https://www.w3.org/TR/webauthn/#webauthn-relying-party)
> For example, if you were using this for a mobile app with a web server backend, then the web server would be the Relying Party.

> \*\* See the supported algorithms: [EC2 algorithms](https://developers.google.com/android/reference/com/google/android/gms/fido/fido2/api/common/EC2Algorithm) and [RSA algorithms](https://developers.google.com/android/reference/com/google/android/gms/fido/fido2/api/common/RSAAlgorithm)
> These 2 links will give you the supported descriptions of the supported algorithms e.g. 'ECDSA w/ SHA-256'.
> You can search for the algorithm identifier using the following links: [COSE registry](https://www.iana.org/assignments/cose/cose.xhtml#algorithms) and [WebAuthn registry](https://www.w3.org/TR/webauthn/#sctn-cose-alg-reg).
> You will find that 'ECDSA w/ SHA-256' has a COSE identifier of -7.

####  3.1.3. <a name='ReturnValues:'></a>Return Values:

The function returns a `RegistrationResult` object with the following fields:

| variable         | type     | encoding                | description                                                                                             |
|------------------|--------- |-------------------------|---------------------------------------------------------------------------------------------------------|
| `credentialId`      | `String` | Base64URL               | A string identifier for the credential generated.                                                       |
| `signedChallenge`     | `String` | Base64URL               | A signed copy of the challenge that was sent with the registration result.               |
| `publicKey` | `String` | CBOR and then Base64URL | The public key to be used to verify any future challenges sent from this user |


###  3.2. <a name='signChallenge'></a>`signChallenge`

This launches the FIDO client which authenticates the user whose credentials were previously registered and are associated with the credential identifier [allowCredentials]. This [allowCredentials] is a comma seperated list of credential ids, and should match the one produced in the registration phase for the same user ([RegistrationResult.credentialId]).
####  3.2.1. <a name='Arguments:-1'></a>Arguments:

| variable    | type     | description                                                                                                                                   |
|-------------|----------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| `allowCredentials` | `List<String>` | is list of credential ids that can verify the identity of the user. It should contain a credential made in the previous function.|
| `challenge` | `String` | The challenge string from the server to be signed by the FIDO client.                                                                         |
| `rpDomain`  | `String` | The domain of the Relying Party. Same as the variable in `initiateRegistration`.                                                              |
| `userId`  | `String`   | An identifier for the user.                                                                                                                   |
| `options`  | `Object`  | Any extra options you would like to add.                                                                                                      |

####  3.2.2. <a name='ReturnValues:-1'></a>Return Values:

The function returns a  `SigningResult` object with the following fields:

| variable     | type     | encoding  | description                                                                                                                                                                                            |
|--------------|----------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `credentialId`  | `String` | Base64URL | An identifier for the credential that was used during signing                                                                                                                                                             |
| `clientData` | `String` | Base64URL | [WebAuthn spec](https://www.w3.org/TR/webauthn/#dom-authenticatorresponse-clientdatajson)                                                                                                              |
| `authData`   | `String` | Base64URL | [WebAuthn spec](https://www.w3.org/TR/webauthn/#authenticator-data)                                                                                                                                    |
| `signature`  | `String` | Base64URL | The signature is to be sent to the server for verification of identity. <br/> It provides proof that the authenticator possesses the private key associated with the public key previously registered. |
| `userHandle` | `String` | Base64URL | An opaque identifier for the user being authenticated.                                                                                                                                                 |

This corresponds to the `AuthenticatorAssertionResponse` in the WebAuthn spec.


##  4. <a name='Usage'></a>Usage

###  4.1. <a name='Android'></a>Android
####  4.1.1. <a name='Dependencies'></a>Dependencies

The plugin uses the native Android library: Fido2ApiClient, specifically `com.google.android.gms:play-services-fido:18.1.0`.

TODO: example here

####  4.1.2. <a name='Hostingassetlinks.jsonVERYIMPORTANT'></a>Hosting assetlinks.json (VERY IMPORTANT!)

To use your server as a relaying party, it needs to host a json file that declares the fact that it handles credentials for your app. This is used by the authenticator and other parties to make sure they can trust your server.
Setting this up is a simple 3 step process:
1. get your app's SHA-256 fingerprint (you can use the method shown here: [here](https://developers.google.com/android/guides/client-auth))
2. place it inside a json file named asset-links.json. a sample is shown below:

**`assetlinks.json`**

```
[
  {
    "relation" : [
      "delegate_permission/common.handle_all_urls",
      "delegate_permission/common.get_login_creds"
    ],
    "target" : {
      "namespace" : "android_app",
      "package_name" : "com.example.android",
      "sha256_cert_fingerprints" : [
         "app sha256 fingerprint"
      ]
    }
  }
]
```

3. Host the JSON file at https://your-domain.com/.well-known/assetlinks.json.

####  4.1.3. <a name='Tyingitalltogether'></a>Tying it all together

1. While the user is logged in via traditional login processes, when the user needs to register a FIDO credential, request registration options from the server - these will be provided as inputs to `initiateRegistration`.
2. Prompt the user to begin the registration phase by calling `initiateRegistration` with the registration options retrieved in the previous step.
3. Format the `RegistrationResult` into something that your web server understands and send the results - the server will save the keyHandle(credential identifier) and public key and associate it to the user.
4. The next time the user needs to verify their identity (e.g. for login), request signing options from the server - these will be provided as inputs to `initiateSigning`.
5. Prompt the user to authenticate themselves by calling `initiateSigning` with the signing options retrieved in the previous step.
5. Once again, format the `SigningResult` into something that your web server understands and send the results for verification. If the server deems that this is indeed a valid signature produced using the private key of the key pair previously registered, then the user has been authenticated.

If you want to see a working example, feel free to reference the [example fido flow](#example-fido-flow).
If there are any issues, you may refer to the section on [common issues](#common-issues).

####  4.1.4. <a name='Example'></a>Example

An example that is fully functional on iOS, Android, and Windows can be viewed here: [fidoApp repo](https://github.com/kanyeceejayA/fidoapp)



```yaml
...
dependencies:
  ...
  fido2_client:
    git:
      url: git://github.com/mojaloop/contrib-fido2-flutter-lib
      ref: <some commit, or leave blank for master>
```

##  5. <a name='SetUp'></a>SetUp
### 5.1 <a name = 'iOSIntegration'></a>iOS Integration
The plugin works without any extra set up for phones using touchID, but to use faceID for authentication too, you need to provide a reason for it's use in the `info.plist` file.
To do this, open the `info.plist` file and add this:
```xml
<key>NSFaceIDUsageDescription</key>
<string>change this to your reason for authenticating</string>
```
### 5.2 <a name = 'AndroidIntegration'></a>Android Integration
On android, you need to set the minimum SDK version to 18 or later.
This can be done in `android/app/build.gradle` as shown here:
```Groovy
defaultConfig{
  //other content
  minSdkVersion 18 //make sure this line is set to 18 or higher
}

```
You also need to update your `AndroidManifest.xml` to state your use of authentication with this:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.example.app">
    <!-- insert only the line below this comment at any point inside the manifest tags, as shown here -->
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/>

<manifest>
```
* If you are using `FlutterActivity` directly, change it to
`FlutterFragmentActivity` in your `AndroidManifest.xml`.
* If you are using a custom activity, update your `MainActivity.java`:

    ```java
    import io.flutter.embedding.android.FlutterFragmentActivity;
    public class MainActivity extends FlutterFragmentActivity {
        // ...
    }
    ```

    or MainActivity.kt:

    ```kotlin
    import io.flutter.embedding.android.FlutterFragmentActivity
    class MainActivity: FlutterFragmentActivity() {
        // ...
    }
    ```

##  6. <a name='SeeAlso'></a>See Also

- [W3 WebAuthn Spec](https://www.w3.org/TR/webauthn/#webauthn-relying-party)
- [Mozilla Web Authentication Docs](https://developer.mozilla.org/en-US/docs/Web/API/Web_Authentication_API)
- [Fido2ApiClient API Reference](https://developers.google.com/android/reference/com/google/android/gms/fido/fido2/Fido2ApiClient)
- [Introduction to WebAuthn API](https://medium.com/@herrjemand/introduction-to-webauthn-api-5fd1fb46c285)



##  7. <a name='TODO'></a>TODO

- add flutter example