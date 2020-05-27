
import 'package:gongguapp/product.dart';
import 'package:gongguapp/AppData.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'dart:io';


class AddPage extends StatefulWidget {
  Product product;

  AddPage({this.product});
  @override
  State<StatefulWidget> createState() => AddPageState();

}

class AddPageState extends State<AddPage> {

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
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Add'),
        actions: <Widget>[
          Builder(
            builder: (context) {
              return FlatButton(
                child: Text("save", style: TextStyle(fontSize: 20.0, color: Colors.white),),
                onPressed: () async {
                  // firestore save image
                  if (_image != null) {
                    //await storage.ref().child("images").child(widget.product.filename).delete(); // delete
                    await uploadImage(_image); // upload
                    //print(path.basename(_image.path));
                    String uuid = Uuid().v1();

                    Firestore.instance.collection('product').document(uuid).setData( // with filename
                    {
                      'uuid' : uuid,
                      'creatorUid' : appProfile.user.uid,
                      'name': _nameController.text,
                      'price': int.parse(_priceController.text),
                      'objectCount' : 100,
                      'shipAddr' : "한동대학교 에벤에셀관 헤브론홀", // TODO : fix it.
                      'startTime' : DateTime.now(),
                      'endTime' : DateTime.now(),
                      'filename': path.basename(_image.path),
                      'category' : "test category",
                      'progress' : 0.0,
                      'currentCount' : 1,
                      'desc': _descController.text,
                    }).then((value) => Navigator.pop(context));
                  }
                  else {
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Please select image file"),));
                  }
                },
              );
            }
          )
        ],
      ),
      body: Builder(
        builder: (context) {
          //final product = widget.product;
//          final NumberFormat formatter = NumberFormat.simpleCurrency(
//              locale: Localizations.localeOf(context).toString());

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
                    Image.network(
                      "http://handong.edu/site/handong/res/img/logo.png",
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
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
                              TextField(controller:_nameController, decoration: InputDecoration(),),
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