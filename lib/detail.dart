
import 'dart:io';

import 'package:gongguapp/product.dart';
import 'package:gongguapp/AppData.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import 'package:image_picker/image_picker.dart';

class DetailPage extends StatefulWidget {
  Product product;

  DetailPage({this.product});

  @override
  State<StatefulWidget> createState() => DetailPageState();

}

class DetailPageState extends State<DetailPage> {

  Widget _buildDetailPage(BuildContext context, Product product) {
    //final product = Product.fromSnapshot(snapshot);
    //final NumberFormat formatter = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).toString());

    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            FutureBuilder(
              future: getImageURL(product.filename),
              builder: (context, AsyncSnapshot<String> value) {
                return Image.network(
                  value.hasData ? value.data : "http://handong.edu/site/handong/res/img/logo.png",
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                );
              }
            ),
          ]
        ),
        Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 8.0,),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(product.name, style: Theme.of(context).textTheme.headline5.merge(TextStyle(color: Color.fromRGBO(42, 88, 149, 1.0), fontWeight: FontWeight.bold)),),
                        SizedBox(height: 12.0,),
                        Text('₩'+product.price.toString(), style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Colors.blueAccent))),
                      ],
                    ),
                  ),
//                  IconButton(
//                    icon: Icon(Icons.thumb_up),
//                    color: Colors.blue,
//                    onPressed: () async {
//                      // check if this user already like
//                      //   like decrease
//                      // else like increase
//                      final uuid = product.uuid;
//                      final uid = appProfile.user.uid;
//
//                      Firestore.instance.collection('users').document(uid).get().then((value) {
//                        //print(value.data);
//                        List<dynamic> likes = value.data['likes'];
//                        //print(likes);
//                        if (likes.contains(uuid)) {
//                          Scaffold.of(context).showSnackBar(SnackBar(content:Text("You already like it!")));
//                        }
//                        else {
//                          product.reference.updateData({'likes': FieldValue.increment(1)});
//                          value.reference.updateData({'likes': FieldValue.arrayUnion([uuid])});
//                          Scaffold.of(context).showSnackBar(SnackBar(content:Text("Like it!")));
//                        }
//                      });
//                    },
//                  ),
//                  Text(
//                    "test",//product.likes.toString(),
//                    style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Colors.blueAccent),)
//                  ),
                ],
              ),
              SizedBox(height: 8.0,),
              Divider(thickness: 1.5,),
              SizedBox(height: 8.0,),
              Text("목표수량: "+product.objectCount.toString(), style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Colors.blueAccent))),
              SizedBox(height: 8.0,),
              Divider(thickness: 1.5,),
              SizedBox(height: 8.0,),
              Text("배송지: "+product.shipAddr, style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Colors.blueAccent))),
              SizedBox(height: 8.0,),
              Divider(thickness: 1.5,),
              SizedBox(height: 8.0,),
              Text("마감일: "+product.endTime.toDate().toString(), style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Colors.blueAccent))),
              SizedBox(height: 8.0,),
              Divider(thickness: 1.5,),
              SizedBox(height: 8.0,),
              Text("카테고리: "+product.category, style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Colors.blueAccent))),
              SizedBox(height: 8.0,),
              Divider(thickness: 1.5,),
              SizedBox(height: 8.0,),
              Text(product.desc, style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Colors.blueAccent))),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.edit,
                  semanticLabel: 'edit',
                ),
                onPressed: () {
                  if (widget.product.creatorUid == appProfile.user.uid) { // can edit
                    print("Can edit!");
                    Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => EditPagePopup(product: widget.product)));
                  }
                  else {                //can't edit
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("You don't have permission to edit this product."),));
                  }
                },
              );
            }
          ),
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.delete,
                  semanticLabel: 'delete',
                ),
                onPressed: () async {
                  if (widget.product.creatorUid == appProfile.user.uid) { // can delete
                    print("Can delete!");
                    await Firestore.instance.collection('product').document(widget.product.uuid).delete();
                    Navigator.pop(context);
                  }
                  else { //can't edit
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("You don't have permission to delete this product.")));
                  }
                },
              );
            }
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance.collection('product').document(widget.product.reference.documentID).snapshots(),
        builder: (context, snapshot) {
          //print(snapshot);
          if (!snapshot.hasData) return _buildDetailPage(context, widget.product);
          widget.product = Product.fromSnapshot(snapshot.data);
          return _buildDetailPage(context, widget.product);
        }
      )
    );
  }
}

class EditPagePopup extends StatefulWidget {
  Product product;

  EditPagePopup({this.product});
  @override
  State<StatefulWidget> createState() => EditPagePopupState();

}

class EditPagePopupState extends State<EditPagePopup> {

  File _image;
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _priceController = new TextEditingController();
  final TextEditingController _descController = new TextEditingController();

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }
  @override
  void initState() {
    super.initState();

    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
    _descController.text = widget.product.desc;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text('Edit'),
          actions: <Widget>[
            FlatButton(
              child: Text("save", style: TextStyle(fontSize: 20.0, color: Colors.white),),
              onPressed: () async {
                // firestore save image
                if (_image != null) {
                  await storage.ref().child("images").child(widget.product.filename).delete(); // delete
                  await uploadImage(_image); // upload
                  //print(path.basename(_image.path));
                  widget.product.reference.updateData( // with filename
                  {
                    'name': _nameController.text,
                    'price': int.parse(_priceController.text),
                    'desc': _descController.text,
                    'filename': path.basename(_image.path),
                    'modified': FieldValue.serverTimestamp()
                  }).then((value) => Navigator.pop(context));
                }
                else {
                  widget.product.reference.updateData( // without filename
                  {
                    'name': _nameController.text,
                    'price': int.parse(_priceController.text),
                    'desc': _descController.text,
                    'modified': FieldValue.serverTimestamp()
                  }).then((value) => Navigator.pop(context));
                }

              },
            )
          ],
        ),
        body: Builder(
          builder: (context) {
            //final product = widget.product;
            final NumberFormat formatter = NumberFormat.simpleCurrency(
                locale: Localizations.localeOf(context).toString());

            return ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _image != null ?
                    Image.file(
                      _image,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ) :
                    FutureBuilder(
                      future: getImageURL(widget.product.filename),
                      builder: (context, AsyncSnapshot<String> value) {
                        return Image.network(
                          value.hasData ? value.data : "http://handong.edu/site/handong/res/img/logo.png",
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        );
                      }
                    ),
                  ]
                ),
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.photo_camera),
                          onPressed: () async {
                            // image picker
                            await getImage();
                          },
                        ),
                      ),
                      SizedBox(height: 8.0,),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TextField(controller:_nameController,),
                                //Text(product.name, style: Theme.of(context).textTheme.headline5.merge(TextStyle(color: Color.fromRGBO(42, 88, 149, 1.0), fontWeight: FontWeight.bold)),),
                                SizedBox(height: 12.0,),
                                TextField(controller:_priceController, keyboardType: TextInputType.number, inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],),
                                //Text(formatter.format(product.price), style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Colors.blueAccent))),
                                SizedBox(height: 12.0,),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0,),
                      Divider(thickness: 1.5,),
                      SizedBox(height: 8.0,),
                      TextField(controller: _descController,),
                      //Text(product.desc, style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Colors.blueAccent)))
                    ],
                  ),
                ),

              ],
            );
          },
        ),
    );
  }

}
