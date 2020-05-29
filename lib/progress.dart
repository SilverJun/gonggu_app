import 'package:flutter/cupertino.dart';
import 'package:gongguapp/add.dart';
import 'package:gongguapp/profile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:gongguapp/product.dart';
import 'package:gongguapp/AppData.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:gongguapp/detail.dart';
import 'package:gongguapp/add.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:url_launcher/url_launcher.dart';


class ProgressPage extends StatefulWidget {

  final Product product;

  ProgressPage({this.product});

  @override
  State<StatefulWidget> createState() => ProgressPageState();
}

class ProgressPageState extends State<ProgressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공구 현황'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[

            Center(child: Text(widget.product.name + ' 공구 진행도', style: Theme.of(context).textTheme.headline4)),
            SizedBox(height: 8.0,),
            Divider(),
            SizedBox(height: 8.0,),
            SleekCircularSlider(
              appearance: CircularSliderAppearance(
                  customWidths: CustomSliderWidths(progressBarWidth: 10)),
              min: 0,
              max: widget.product.objectCount.toDouble(),
              initialValue: widget.product.currentCount.toDouble(),
            ),

            Center(child: Text('현재 수량 / 목표수량')),
            Center(child: Text(widget.product.currentCount.toString()+' / '+widget.product.objectCount.toString(), style: TextStyle(fontSize: 30.0),)),

            SizedBox(height: 32.0,),
            Center(child: Text('공구 참여자 정보', style: Theme.of(context).textTheme.headline4)),
            SizedBox(height: 8.0,),
            Divider(),

            StreamBuilder(
              stream: Firestore.instance.collection('product/'+widget.product.uuid+'/participants').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Container(padding: EdgeInsets.symmetric(vertical: 8.0), child: LinearProgressIndicator());

                return Column(
                  children: snapshot.data.documents.map(
                    (e) => ListTile(
                      title: Text(e.data['displayName']),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(e.data['quantity'].toString()+'개'), Icon(Icons.navigate_next)]),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ParticipationDetailPage(documentSnapshot: e)));
                      },
                    )
                  ).toList(),
                );
              },
            )

          ],
        ),
      ),
    );
  }
}

class ParticipationDetailPage extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;

  ParticipationDetailPage({this.documentSnapshot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.phone),
        onPressed: () {
          var str = 'tel://+82'+(documentSnapshot.data['phoneNumber'].toString().replaceAll('-', ''));
          print(str);
          launch(str);
        },
      ),
      appBar: AppBar(
        title: Text('참여자 세부 정보'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Text('이름'),
            title: Text(documentSnapshot.data['displayName']),
          ),
          Divider(),
          ListTile(
            leading: Text('구매 수량'),
            title: Text(documentSnapshot.data['quantity'].toString()),
          ),
          Divider(),
          ListTile(
            leading: Text('전화번호'),
            title: Text(documentSnapshot.data['phoneNumber']??''),
          ),
        ],
      ),
    );
  }
}
