import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Helper.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SettingsBody(),
    );
  }
}

class SettingsBody extends StatefulWidget {
  @override
  _SettingsBodyState createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  String _userID = "";
  String _userName = "";
  bool _isValid = true;

  //a method to save user information from text input field into preferences
  void saveUserData() async {
    int userID = int.tryParse(_userID);
    if (userID != null && _userName != "") {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      bool resultSaveUserID = await prefs.setInt('userID', userID);
      bool resultSaveUserName = await prefs.setString('username', _userName);

      if (resultSaveUserID && resultSaveUserName) {
        showSnack(context, "Successfully saved user");
        setState(() {
          _isValid = true;
        });
      } else {
        showSnack(context, "Failure to save user");
        setState(() {
          _isValid = true;
        });
      }
    } else {
      setState(() {
        _isValid = false;
      });
    }
  }

  //black bar that serves as a notification after a successfully set user
  void showSnack(BuildContext context, String message) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'Hide', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
      child: Column(
        children: [
          LabelInput("User ID"),
          TextField(
            decoration: InputDecoration(),
            onChanged: (String value) {
              _userID = value;
              print("UserID: " + _userID);
              setState(() {
                _isValid = true;
              });
            },
          ),
          LabelInput("User Name"),
          TextField(
            decoration: InputDecoration(),
            onChanged: (String value) {
              _userName = value;
              print("User Name: " + _userName);
              setState(() {
                _isValid = true;
              });
            },
          ),
          if (!_isValid) LabelInput("Failure to save user", isWarning: true),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 20),
            child: RaisedButton(
              child: Text(
                "Save User",
                style: TextStyle(fontSize: 16),
              ),
              textColor: Colors.white,
              color: Colors.teal,
              onPressed: saveUserData,
            ),
          ),
        ],
      ),
    );
  }
}
