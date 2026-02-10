import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'DataHolder.dart';

class ImageGridItem extends StatefulWidget {
  final int index; //each grid item index
  final Function onImageSelected;
  final int type;
  const ImageGridItem({Key? key, required this.index, required this.onImageSelected, required this.type}) : super(key: key);

  @override
  _ImageGridItemState createState() => _ImageGridItemState();
}

class _ImageGridItemState extends State<ImageGridItem> {
  late String imageFile; //to store image file


  //getting image from the firestore
  getImage(int type) {
    if (!requestedIndex.contains(widget.index)) {
      //when requested index does not cotain in the list

      int MAX_SIZE = 7 * 1024 * 1024; //maximum file size for an image
      //firebase storage reference
      var photosReference =
      FirebaseStorage.instance.ref().child("ortak").child("profil").child(type ==0 ?"profilePic": "banner");

      //accessing firebase storage to get the photo
      String path= widget.type==0 ? "profile_${widget.index+1}.png" :"banner_${widget.index+1}.jpeg";
      photosReference
          .child(path).getDownloadURL()
          .then((value) {
        //value is image reference
        this.setState(() {
          imageFile = value; //updating imageFile
        });
        //insert image file to the imageData map
        imageData.putIfAbsent(widget.index, () {
          return value;
        });
      }).catchError((error) {});
      //insert image file index to the requestedIndex list in the data_holder.dart
      requestedIndex.add(widget.index);
    }
  }

  //to decide whether to show the default text or actual image
  Widget decideGrideTileWidget() {
    if (imageFile.isEmpty) {
      //showing default text until it show the image
      return Center(child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Platform.isIOS
              ? CupertinoActivityIndicator(
            radius: 35,
          )
              : CircularProgressIndicator(
            strokeWidth: 2,
          ),
          Image.asset(
            'assets/images/casy.png',
            height: 30,
            width: 30,
          )
        ],
      ));
    } else {
      return Hero(
        tag: imageFile.toString(),
        child: widget.type==0 ? Container(
          padding: EdgeInsets.symmetric(horizontal: 0),
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: 5),
            shape: BoxShape.circle,
            image: DecorationImage(
                image: NetworkImage(imageFile),
                fit: BoxFit.cover),
          ),
          // child: CircleAvatar(
          //   radius: 40,
          //   backgroundImage: imageFile != null
          //       ? NetworkImage(imageFile)
          //       : customAdvanceNetworkImage(authstate.userModel.profilePic),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Colors.black38,
          //     ),
          //     child: Center(
          //       child: IconButton(
          //         onPressed: uploadImage,
          //         icon: Icon(Icons.camera_alt, color: Colors.white),
          //       ),
          //     ),
          //   ),
          // ),
        ) :ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child:Image.network(
            //showing the actual image
              imageFile,
              fit: BoxFit.cover),
        )
      );
    }
  }

  @override
  void initState() {
    super.initState();
    imageFile = '';
    if (!imageData.containsKey(widget.index)) {
      getImage(widget.type);
    } else {
      imageFile = imageData[widget.index] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: GridTile(
            child: decideGrideTileWidget(),
          ),
        ),
        onTap: () {widget.onImageSelected(imageFile.toString());
        Navigator.pop(context);
        }
    );
  }
}