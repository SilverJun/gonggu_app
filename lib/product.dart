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

import 'dart:wasm';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gongguapp/AppData.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

FirebaseStorage storage = FirebaseStorage(
    storageBucket: storagePath
);

Future<dynamic> uploadImage(File imageFile) async {
  //Create a reference to the location you want to upload to in firebase
  StorageReference reference = storage.ref().child("images").child(path.basename(imageFile.path));
  //Upload the file to firebase
  return reference.putFile(imageFile).onComplete;
}

Future<String> getImageURL(String filename) async {
  return await storage.ref().child('images').child(filename).getDownloadURL();
}

class Product {
  Product({
    @required this.uuid,
    @required this.creatorUid,
    @required this.name,
    @required this.price,
    @required this.currentCount,
    @required this.objectCount,
    @required this.shipAddr,
    @required this.startTime,
    @required this.endTime,
    @required this.filename, // TODO : 배열로 바꾸기.
    @required this.category,
    @required this.progress,
    @required this.desc
  }) :
        assert(uuid != null),
        assert(creatorUid != null),
        assert(name != null),
        assert(price != null),
        assert(currentCount != null),
        assert(objectCount != null),
        assert(shipAddr != null),
        assert(startTime != null),
        assert(endTime != null),
        assert(filename != null),
        assert(category != null),
        assert(progress != null),
        assert(desc != null)
  ;

  final String uuid; // 이 아이템의 uuid
  final String creatorUid; // 이 아이템을 만든 사람의 uid
  final String name; // 상품이름
  final int price; // 가격
  final int currentCount; // 목표수량
  final int objectCount; // 목표수량
  final String shipAddr; // 배송지
  final Timestamp startTime; // 시작시간
  final Timestamp endTime; // 마감시간
  final String filename; // 이미지 이름, TODO : 배열로 바꾸기.
  final String category; // 카테고리
  final double progress; // 공구 진행도
  final String desc; // 부가 설명

  DocumentReference reference;

  Product.fromMap(Map<String, dynamic> map, {this.reference})
      :
        assert(map['uuid'] != null),
        assert(map['creatorUid'] != null),
        assert(map['name'] != null),
        assert(map['price'] != null),
        assert(map['currentCount'] != null),
        assert(map['objectCount'] != null),
        assert(map['shipAddr'] != null),
        assert(map['startTime'] != null),
        assert(map['endTime'] != null),
        assert(map['filename'] != null),
        assert(map['category'] != null),
        assert(map['progress'] != null),
        assert(map['desc'] != null),
        uuid = map['uuid'],
        creatorUid = map['creatorUid'],
        name = map['name'],
        price = map['price'],
        currentCount = map['currentCount'],
        objectCount = map['objectCount'],
        shipAddr = map['shipAddr'],
        startTime = map['startTime'],
        endTime = map['endTime'],
        filename = map['filename'],
        category = map['category'],
        progress = map['progress'],
        desc = map['desc']
  ;

  Product.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}
