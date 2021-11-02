import 'dart:async';
//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'APICall.dart';
import 'SettingsPage.dart';
import 'Helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainActivity(),
    );
  }
}

class MainActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Main Activity"),
        backgroundColor: Colors.teal,
      ),
      body: MainActivityBody(),
    );
  }
}

class MainActivityBody extends StatefulWidget {
  @override
  _MainActivityBodyState createState() => _MainActivityBodyState();
}

class _MainActivityBodyState extends State<MainActivityBody> {
  String _storedName;
  int _storedID;

  StreamSubscription<ConnectivityResult> _subscription;
  Connectivity _connectivity;
  ConnectivityResult _resultConnectivity;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //add listener to connectivity if it's changing update the connectivity result
    _connectivity = new Connectivity();
    _subscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      print(result);
      setState(() {
        _resultConnectivity = result;
      });
    });
    initConnectivity();

    getSavedPreference();
  }

  //get connectivity status immediately by calling this function
  //result is going to be enum of none || mobile || wifi
  Future<void> initConnectivity() async {
    ConnectivityResult resultConnectivity =
        await _connectivity.checkConnectivity();
    setState(() {
      _resultConnectivity = resultConnectivity;
    });
  }

  //cancel the subscription when no longer needed
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  //get value of preferences by key that has been saved into the app
  void getSavedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedName = prefs.getString('username');
    int storedID = prefs.getInt('userID');

    setState(() {
      _storedName = storedName;
      _storedID = storedID;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _resultConnectivity == ConnectivityResult.none
        ? Center(
            child: Container(
              alignment: Alignment(0, 0),
              child: Text(
                "No Connection, Connect to internet to use the app.",
                style: TextStyle(fontSize: 14),
              ),
            ),
          )
        : Container(
            margin: EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.settings),
                            Text(
                              "Settings",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                    textColor: Colors.black,
                    color: Colors.white,
                    onPressed: () => {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingsPage()))
                          .then((value) {
                        getSavedPreference();
                      })
                    },
                  ),
                ),
                if (_storedID != null)
                  Content(_storedID.toString(), _storedName)
                else
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "No Username Saved, Please Go to Settings",
                          style: TextStyle(fontSize: 20),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_alt_1,
                                color: Colors.red,
                                size: 32,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          );
  }
}

class Content extends StatefulWidget {
  final String _userID;
  final String _userName;
  Content(this._userID, this._userName);

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  String _description = "";
  bool _isValid = true;
  String _position = "";

  @override
  void initState() {
    super.initState();
  }

  //a method to activate and prepare API Call
  void sendLocation() async {
    int userID = int.tryParse(widget._userID);
    if (userID != null && _description != "") {
      //Get Current lat and long based on geolocator package
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      //print("lat: ${position.latitude}, lng: ${position.longitude}");

      if (position == null) {
        setState(() {
          _position = "Position Not Found";
        });

        return;
      }

      try {
        //send All information into The API set by ken, returning HTTP Response
        var apiResult = await APILocationData(userID, position.latitude, position.longitude, _description).getLocations();

        if (apiResult.statusCode == 200) {
          var jsonResponse = convert.jsonDecode(apiResult.body);
          var latitude = jsonResponse['latitude'];
          var longitude = jsonResponse['longitude'];
          print("$latitude : $longitude");
          setState(() {
            _position = "Successfully sending location into API";
          });
        } else {
          setState(() {
            _position = "Failure in sending information into API";
          });
        }
      } catch (e) {
        print("error occured on posting data!");
      }
    } else {
      setState(() {
        _isValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
      child: Column(
        children: [
          Container(
            width: 300,
            child: Column(
              children: [
                Text(
                  "Current User",
                  style: TextStyle(fontSize: 26),
                ),
                Container(
                  margin: EdgeInsets.only(top: 25, bottom: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "User ID: ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget._userID,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "User Name: ",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget._userName,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 35),
            child: Column(
              children: [
                LabelInput("Description"),
                TextField(
                  decoration: InputDecoration(),
                  onChanged: (String value) {
                    _description = value;
                    print("Description: " + _description);
                    setState(() {
                      _position = "";
                    });
                  },
                )
              ],
            ),
          ),
          if (!_isValid) LabelInput("Wrong Input!", isWarning: true),
          LabelInput(_position), // Warning message fail or success
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 20),
            child: RaisedButton(
              child: Text(
                "Send Data",
                style: TextStyle(fontSize: 16),
              ),
              textColor: Colors.white,
              color: Colors.teal,
              onPressed: sendLocation,
            ),
          ),
        ],
      ),
    );
  }
}
