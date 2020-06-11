import 'dart:io';

import 'package:flutter/cupertino.dart';
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
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _phoneController = TextEditingController();

  Widget _buildDetailPage(BuildContext context, Product product) {
    //final product = Product.fromSnapshot(snapshot);
    //final NumberFormat formatter = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).toString());

    return ListView(
      children: <Widget>[
        Column(children: <Widget>[
          FutureBuilder(
              future: getImageURL(product.filename),
              builder: (context, AsyncSnapshot<String> value) {
                return Image.network(
                  value.hasData
                      ? value.data
                      : "http://handong.edu/site/handong/res/img/logo.png",
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                );
              }),
        ]),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                product.name,
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .merge(TextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 8.0,
              ),
              //
              // 공구 진행자
              Builder(builder: (context) {
                return FutureBuilder(
                    future: Firestore.instance
                        .collection('users')
                        .document(product.creatorUid)
                        .get(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot> value) {
                      return Row(
                        children: <Widget>[
                          Container(
                            width: 30,
                            height: 30,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: value.hasData
                                  ? NetworkImage(value.data['photoUrl'])
                                  : null,
                              backgroundColor: Colors.grey,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(value.hasData
                              ? value.data['displayName'] + ' >'
                              : ''),
                        ],
                      );
                    });
              }),
              SizedBox(
                height: 8.0,
              ),
              Text(product.price.toString() + '원',
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .merge(TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(
                height: 8.0,
              ),
              Divider(
                thickness: 1.5,
              ),
              ListTile(
                leading: Text("구매수량"),
                title: Text(product.currentCount.toString()),
              ),
              Divider(
                thickness: 1.5,
              ),
              ListTile(
                leading: Text("목표수량"),
                title: Text(product.objectCount.toString()),
              ),
              Divider(
                thickness: 1.5,
              ),
              ListTile(
                leading: Text("물품 수령지"),
                title: Text(product.shipAddr),
              ),
              Divider(
                thickness: 1.5,
              ),
              ListTile(
                leading: Text("마감일"),
                title: Text(product.endTime.toDate().toString()),
              ),
              Divider(
                thickness: 1.5,
              ),
              ListTile(
                leading: Text("카테고리"),
                title: Text(product.category),
              ),
              Divider(
                thickness: 1.5,
              ),
              ListTile(
                leading: Text("상세설명"),
                title: Text(product.desc,
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              SizedBox(
                height: 45.0,
              ),
              //Text(product.desc, style: Theme.of(context).textTheme.bodyText1),
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
          Builder(builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.edit,
                semanticLabel: 'edit',
              ),
              onPressed: () {
                if (widget.product.creatorUid == appProfile.user.uid) {
                  // can edit
                  print("Can edit!");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) =>
                              EditPagePopup(product: widget.product)));
                } else {
                  //can't edit
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content:
                        Text("You don't have permission to edit this product."),
                  ));
                }
              },
            );
          }),
          Builder(builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.delete,
                semanticLabel: 'delete',
              ),
              onPressed: () async {
                if (widget.product.creatorUid == appProfile.user.uid) {
                  // can delete
                  print("Can delete!");
                  Navigator.pop(context);
                  Firestore.instance
                      .collection('product')
                      .document(widget.product.uuid)
                      .delete();
                } else {
                  //can't edit
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "You don't have permission to delete this product.")));
                }
              },
            );
          }),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .collection('product')
              .document(widget.product.reference.documentID)
              .snapshots(),
          builder: (context, snapshot) {
            //print(snapshot);
            if (!snapshot.hasData)
              return _buildDetailPage(context, widget.product);
            widget.product = Product.fromSnapshot(snapshot.data);
            return _buildDetailPage(context, widget.product);
          }),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Buy"),
        onPressed: () {
          _nameController.text = appProfile.user.displayName;
          _phoneController.text = appProfile.user.phoneNumber;
          return showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  // myController의 현재 텍스트 값을 컨텐트로 AlertDialog 출력
                  title: Text('구매 정보'),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "구매자 성함"),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: _quantityController,
                      decoration: InputDecoration(labelText: "수량"),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: "휴대전화"),
                    ),
                  ]),
                  actions: <Widget>[
                    Builder(builder: (BuildContext context) {
                      return new FlatButton(
                        child: new Text('구매하기'),
                        onPressed: () async {
                          var _quantity = int.parse(_quantityController.text);
                          await widget.product.reference
                            .collection('participants')
                            .document(appProfile.user.uid)
                            .setData({// with filename
                              'displayName': _nameController.text,
                              'phoneNumber': _phoneController.text,
                              'quantity': _quantity,
                              'check': false,
                          }).then((value) {
                            Navigator.pop(context);
                          });
                          _quantity = widget.product.currentCount + _quantity;
                          await widget.product.reference.updateData({
                            'participants' : FieldValue.arrayUnion([appProfile.user.uid]),
                            'currentCount': FieldValue.increment(
                                int.parse(_quantityController.text))
                          }); // 구매수량 업데이트
                          await widget.product.reference.updateData({
                            'progress': _quantity / widget.product.objectCount as double
                          }); // 프로그레스 업데이트
                          print(widget.product.objectCount);
//                          Scaffold.of(context).showSnackBar(SnackBar(
//                            content: Text('성공적으로 구매했습니다!'),
//                          )); // TODO : snack bar doesn't show.
                        },
                      );
                    })
                  ],
                );
              });
        },
        icon: Icon(Icons.shopping_cart),
      ),
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
  final TextEditingController _goalController = new TextEditingController();
  final TextEditingController _addrController = new TextEditingController();

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
    _goalController.text = widget.product.objectCount.toString();
    _addrController.text = widget.product.shipAddr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "save",
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
            onPressed: () async {
              // firestore save image
              if (_image != null) {
                await storage
                    .ref()
                    .child("images")
                    .child(widget.product.filename)
                    .delete(); // delete
                await uploadImage(_image); // upload
                //print(path.basename(_image.path));
                widget.product.reference.updateData(// with filename
                    {
                  'name': _nameController.text,
                  'price': int.parse(_priceController.text),
                  'desc': _descController.text,
                  'shipAddr': _addrController.text,
                  'objectCount': int.parse(_goalController.text),
                  'filename': path.basename(_image.path),
                  'modified': FieldValue.serverTimestamp()
                }).then((value) => Navigator.pop(context));
              } else {
                widget.product.reference.updateData(// without filename
                    {
                  'name': _nameController.text,
                  'price': int.parse(_priceController.text),
                  'desc': _descController.text,
                  'shipAddr': _addrController.text,
                  'objectCount': int.parse(_goalController.text),
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
              Column(children: <Widget>[
                _image != null
                    ? Image.file(
                        _image,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      )
                    : FutureBuilder(
                        future: getImageURL(widget.product.filename),
                        builder: (context, AsyncSnapshot<String> value) {
                          return Image.network(
                            value.hasData
                                ? value.data
                                : "http://handong.edu/site/handong/res/img/logo.png",
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          );
                        }),
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
                                decoration:
                                    InputDecoration(labelText: "Product Name"),
                                controller: _nameController,
                              ),
                              //Text(product.name, style: Theme.of(context).textTheme.headline5.merge(TextStyle(color: Color.fromRGBO(42, 88, 149, 1.0), fontWeight: FontWeight.bold)),),
                              SizedBox(
                                height: 12.0,
                              ),
                              TextField(
                                decoration: InputDecoration(labelText: "Price"),
                                controller: _priceController,
                                keyboardType: TextInputType.number,
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
                    SizedBox(
                      height: 8.0,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: "Descriptoin"),
                      controller: _descController,
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
                      decoration: InputDecoration(labelText: "물품수령지"),
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
