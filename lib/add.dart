import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gongguapp/product.dart';
import 'package:gongguapp/AppData.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

String category;

class DisplayCategoryWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DisplayCategory();
}

class DisplayCategory extends State<DisplayCategoryWidget> {
  String dropdownValue = "DailySupply";

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
            category = dropdownValue;
            //isGrid = newValue=='Grid';

            //context.findAncestorStateOfType<HomePageState>().rebuild();
          });

          // query and sorting
        },
        items: Category.values
            .map((e) {
          return DropdownMenuItem<String>(
            value: e.toString().substring(9),
            child: Text(e.toString().substring(9)),
          );
        }).toList(),
      ),
    );
  }
}

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
  final TextEditingController _goalController = new TextEditingController();
  final TextEditingController _descController = new TextEditingController();
  final TextEditingController _addrController = new TextEditingController();
  DateTime endTime = DateTime.now();


  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    final List<ImageLabel> labels = await labeler.processImage(visionImage);

    String text = '';

    if (labels.isNotEmpty)
      text = labels.reduce((curr, next) => curr.confidence > next.confidence ? curr: next).text;

    setState(() {
      _image = image;
      _nameController.text = text;
    });
    labeler.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add'),
        actions: <Widget>[
          Builder(builder: (context) {
            return FlatButton(
              child: Text(
                "save",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              onPressed: () async {
                // firestore save image
                if (_image != null) {
                  //await storage.ref().child("images").child(widget.product.filename).delete(); // delete
                  await uploadImage(_image); // upload
                  //print(path.basename(_image.path));
                  String uuid = Uuid().v1();

                  Firestore.instance
                    .collection('product')
                    .document(uuid)
                    .setData({
                      'uuid': uuid,
                      'creatorUid': appProfile.user.uid,
                      'name': _nameController.text,
                      'price': int.parse(_priceController.text),
                      'objectCount': int.parse(_goalController.text),
                      'shipAddr': _addrController.text,
                      'startTime': DateTime.now(),
                      'endTime': endTime,
                      'filename': path.basename(_image.path),
                      'category': category,
                      'progress': 0.0,
                      'currentCount': 0,
                      'desc': _descController.text,
                  }).then((value) => Navigator.pop(context));
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Please select image file"),
                  ));
                }
              },
            );
          })
        ],
      ),
      body: Builder(
        builder: (context) {
          //final product = widget.product;
//          final NumberFormat formatter = NumberFormat.simpleCurrency(
//              locale: Localizations.localeOf(context).toString());

          return ListView(
            children: <Widget>[
              Column(children: <Widget>[
                _image != null
                    ? Image.file(
                        _image,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        "http://handong.edu/site/handong/res/img/logo.png",
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
              ]),
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
                    SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TextField(
                                controller: _nameController,
                                decoration:
                                    InputDecoration(labelText: "Product Name"),
                              ),
                              //Text(product.name, style: Theme.of(context).textTheme.headline5.merge(TextStyle(color: Color.fromRGBO(42, 88, 149, 1.0), fontWeight: FontWeight.bold)),),
                              SizedBox(
                                height: 12.0,
                              ),
                              TextField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: "Price"),
                                inputFormatters: <TextInputFormatter>[
                                  WhitelistingTextInputFormatter.digitsOnly
                                ],
                              ),
                              //Text(formatter.format(product.price), style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Colors.blueAccent))),
                              SizedBox(
                                height: 12.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    DisplayCategoryWidget(),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextField(
                      controller: _descController,
                      decoration:
                      InputDecoration(labelText: "Descriptoin"),
                    ),
                    TextField(
                      controller: _goalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "목표수량"),
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                    ),
                    TextField(
                      controller: _addrController,
                      decoration:
                      InputDecoration(labelText: "물품수령지"),
                    ),
                    ListTile(
                      title: Text("공구 마감일"),

                      onTap: () {
                        DatePicker.showDateTimePicker(context, showTitleActions: true,
                          onChanged: (date) {
                            //print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                          },
                          onConfirm: (date) {
                            endTime = date;
                          },
                          currentTime: endTime, locale: LocaleType.ko
                        );
                      },
                    ),

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
