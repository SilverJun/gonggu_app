// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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

bool isGrid = true;

class DisplayMenuWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DisplayMenuWidgetState();
}

class DisplayMenuWidgetState extends State<DisplayMenuWidget> {
  String dropdownValue = 'Grid';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        value: dropdownValue,
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        underline: Container(
          height: 2,
        ),
        onChanged: (String newValue) {
          setState(() {
            dropdownValue = newValue;
            isGrid = newValue=='Grid';

            context.findAncestorStateOfType<HomePageState>().rebuild();
          });

          // query and sorting
        },
        items: <String>['Grid', 'List']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();

}

class HomePageState extends State<HomePage> {

  void rebuild() {
    setState(() {});
  }

  Widget _buildBody(BuildContext context) {
    List<DocumentSnapshot> list;
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('product').snapshots(),
      builder: (context, snapshot) {
        //print(snapshot);
        if (!snapshot.hasData) return LinearProgressIndicator();
        list = snapshot.data.documents;
//        list.sort((a, b) {
//          if (isDescending) return b['price'].compareTo(a['price']);
//          else return a['price'].compareTo(b['price']);
//        });
        return isGrid ? _buildGrid(context, list) : _buildList(context, list);
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<DocumentSnapshot> snapshot) {
    return GridView.count(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      crossAxisCount: 2,
      padding: EdgeInsets.all(16.0),
      childAspectRatio: 8.0 / 9.0,
      children: snapshot.map((data) => _buildCard(context, data)).toList(),
    );
  }

  Widget _buildCard(BuildContext context, DocumentSnapshot data) {
    final Product product = Product.fromSnapshot(data);
    final ThemeData theme = Theme.of(context);
    //final NumberFormat formatter = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).toString());

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 18 / 11,
                child: FutureBuilder(
                  future: getImageURL(data['filename']),
                  builder: (context, AsyncSnapshot<String> value) {
                    return Image.network(
                      value.hasData ? value.data : "http://handong.edu/site/handong/res/img/logo.png",
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    );
                  }
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.name,
                        style: theme.textTheme.bodyText1,
                        maxLines: 1,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        '₩'+product.price.toString(),//formatter.format(product.price),
                        style: theme.textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              height: 30,
              width: 70,
              child: FlatButton(
                child: Text('more', style: TextStyle(fontSize: 12),),
                textColor: theme.primaryColor,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(product: product,)));
                },
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: snapshot.map((data) => _buildTile(context, data)).toList(),
    );
  }

  Widget _buildTile(BuildContext context, DocumentSnapshot data) {
    final Product product = Product.fromSnapshot(data);
    final ThemeData theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: FutureBuilder(
          future: getImageURL(data['filename']),
          builder: (context, AsyncSnapshot<String> value) {
            return Image.network(
              value.hasData ? value.data : "http://handong.edu/site/handong/res/img/logo.png",
              fit: BoxFit.fitHeight,
            );
          }
        ),
        title: Text(product.name,style: theme.textTheme.bodyText1,),
        subtitle: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("공구가: ₩"+product.price.toString(),style: theme.textTheme.bodyText2,),
              Row(
                children: [
                  Text("진행도: "),
                  Flexible(child: LinearProgressIndicator(backgroundColor: theme.hintColor, value: product.progress,)),
                ],
              )
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.favorite_border),
          onPressed: () {
            // TODO : favorite page 만들기.
          },
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(product: product,)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Container(
                padding: EdgeInsets.symmetric(),
                child:
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: NetworkImage(appProfile.user.photoUrl),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(40.0),),
                          border: Border.all(
                              color : Theme.of(context).accentColor,
                              width: 2
                          )
                      ),
                    ),
                    SizedBox(width: 8,),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              '안녕하세요,',
                              style: Theme.of(context).textTheme.headline5.merge(TextStyle(color: Colors.white, fontSize: 15)),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              appProfile.user.displayName + '님',
                              style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: Colors.white)),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ExpansionTile(
              title: Text('카테고리', style: Theme.of(context).textTheme.subtitle1,),
              initiallyExpanded: true,
              children: Category.values.map((e) => ListTile(
                title: Text(e.toString().substring(9)),
                trailing: IconButton(icon: Icon(Icons.favorite_border)), // TODO : here too..
                onTap: () {
                  // TODO : firebase 연동하기.
                },
              )).toList()
            ),
          ],
        ),
      ),
      appBar: AppBar(
//        leading: IconButton(
//          icon: Icon(
//            Icons.person,
//            semanticLabel: 'profile',
//          ),
//          onPressed: () {
//            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
//          },
//        ),
        title: Text('Main'),
        actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.person,
            semanticLabel: 'profile',
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
          },
        ),
//          IconButton(
//            icon: Icon(
//              Icons.add,
//              semanticLabel: 'add',
//            ),
//            onPressed: () {
//              Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => AddPage()));
//            },
//          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          semanticLabel: 'add',
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => AddPage()));
        },
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 8.0,),
          DisplayMenuWidget(),
          SizedBox(height: 8.0,),
          Container(
            child: _buildBody(context)
          ),
          SizedBox(height: 80.0,),
        ]
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
