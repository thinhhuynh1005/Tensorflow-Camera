import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MaterialApp(
  home: DetectMain(),
  debugShowCheckedModeBanner: false,
));

class DetectMain extends StatefulWidget{
  @override
  _DetectMainState createState() => new _DetectMainState();
}

class _DetectMainState extends State<DetectMain>{
  File _image;
  double _imageWidth;
  double _imageHeight;
  var _recognitions;
  
  loadModel() async {
    Tflite.close();
    try{
      String res;
      res = await Tflite.loadModel(
          model: "assets/training.tflite",
          labels:"assets/labels.txt");
      print(res);
    } on PlatformException{
      print("Failed to load the model");
    }
  }
  
  Future predict(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true
    );
    print(recognitions);

    setState(() {
      _recognitions = recognitions;
    });
  }
  sendImage(File image) async {
    if(image == null) return;
    await predict(image);

    // get the width and height of selected image
    FileImage(image).resolve(ImageConfiguration()).addListener((ImageStreamListener((ImageInfo info, bool _){
      setState(() {
        _imageWidth = info.image.width.toDouble();
        _imageHeight = info.image.height.toDouble();
        _image = image;
      });
    })));
  }
  selectFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image == null)return;
    setState(() {

    });
    sendImage(image);
  }
  selectFromCamera() async{
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if(image == null)return;
    setState(() {

    });
    sendImage(image);
  }
  @override
  void initState(){
    super.initState();
    loadModel().then((val){
      setState(() {

      });
    });
  }
  Widget printValue(rcg){
    if(rcg == null){
      return Text('',style: TextStyle(fontSize: 30,fontWeight: FontWeight.w700));
    }else if(rcg.isEmpty){
      return Center(child: Text("Could not recognize",style: TextStyle(fontSize: 25,fontWeight: FontWeight.w700)));
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Center(
        child: Text(
          "Prediction: "+_recognitions[0]['label'].toString().toUpperCase(),
          style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    double finalW;
    double finalH;

    if(_imageWidth == null && _imageHeight == null){
      finalW = size.width;
      finalH = size.height;
    }else{
      double ratioW = size.width / _imageWidth;
      double ratioH = size.height / _imageHeight;
      finalW = _imageWidth * ratioW*.85;
      finalH = _imageHeight * ratioH*.50;
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text("Flutter x TF-Lite",style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
            child: printValue(_recognitions),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: _image == null ? Center(child: Text("Select image from camera or gallery"),): Center(child: Image.file(_image,fit: BoxFit.fill,width: finalW,height: finalH)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Container(
                  height: 50,
                    width: 150,
                  color: Colors.redAccent,
                  child: FlatButton.icon(onPressed: selectFromCamera,
                      icon: Icon(Icons.camera_alt,color: Colors.white,size: 30,),
                      color: Colors.deepPurple,
                      label: Text(
                        "Camera",style: TextStyle(color: Colors.white,fontSize: 20),
                      )),
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                ),
              ),
              Container(
                height: 50,
                width: 150,
                color: Colors.tealAccent,
                child: FlatButton.icon(onPressed: selectFromGallery,
                    icon: Icon(Icons.file_upload,color: Colors.white,size: 30,),
                    color: Colors.blueAccent,
                    label: Text(
                      "Gallery",style: TextStyle(color: Colors.white,fontSize: 20),
                    )),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
              )
            ],
          )
        ],
      ),
    );
  }


}

