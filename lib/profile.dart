
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gongguapp/login.dart';
import 'package:gongguapp/product.dart';
import 'package:gongguapp/AppData.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              semanticLabel: 'logout',
            ),
            onPressed: () {
              appProfile = AppProfile(); // init login data.
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
                ModalRoute.withName('/'));
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Image.network(appProfile.loginType == LoginType.Anonymous ? "http://handong.edu/site/handong/res/img/logo.png" : appProfile.user.photoUrl, fit: BoxFit.fitWidth,),
            SizedBox(height: 24.0,),
            Text(appProfile.user.uid),
            SizedBox(height: 16.0,),
            Divider(),
            SizedBox(height: 16.0,),
            Text(appProfile.loginType == LoginType.Anonymous ? "Anonymous" : appProfile.user.email),
          ],
        ),
      )
    );
  }

}