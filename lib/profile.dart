import 'package:firebase_auth/firebase_auth.dart';
import 'package:gongguapp/login.dart';
import 'package:gongguapp/product.dart';
import 'package:gongguapp/AppData.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gongguapp/progress.dart';
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
  Widget _buildCreatedProduct(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('product')
          .where('creatorUid', isEqualTo: appProfile.user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        //print(snapshot);
        if (!snapshot.hasData) return CircularProgressIndicator();
        //print(snapshot.data.documents.asMap());

        return ExpansionTile(
          title: Text("내가 진행한 공구"),
          children: snapshot.data.documents.map((e) {
            Product product = Product.fromSnapshot(e);
            return ListTile(
              title: Text(product.name),
              subtitle: Container(
                child: Row(
                  children: [
                    Text("진행도: "),
                    Flexible(
                      child: LinearProgressIndicator(
                        backgroundColor: Theme.of(context).hintColor,
                        value: product.progress,
                      )
                    ),
                  ],
                ),
              ),
              trailing: Icon(Icons.navigate_next),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProgressPage(
                              product: product,
                            )));
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //print(appProfile.user.phoneNumber==null);
    var phone = appProfile.user.phoneNumber == null
        ? "없음"
        : appProfile.user.phoneNumber;
    final ThemeData theme = Theme.of(context);

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
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()),
                    ModalRoute.withName('/'));
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 8,),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                            image: NetworkImage(appProfile.user.photoUrl),
                            fit: BoxFit.cover,
                        ),
                      borderRadius: BorderRadius.all(Radius.circular(50.0),),
                      border: Border.all(
                        color : theme.accentColor,
                        width: 3
                      )
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            appProfile.user.displayName + '님',
                            style: Theme.of(context).textTheme.headline5,
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(appProfile.user.email),
                          SizedBox(
                            height: 10,
                          ),
                          Text('휴대전화 :' + phone),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Divider(),

//            ListTile(
//              leading: Text('계좌번호'),
//              title: Text(bankAccount),
//            ),
              _buildCreatedProduct(context),
            ],
          ),
        ));
  }
}
