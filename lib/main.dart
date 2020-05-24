import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:place_picker/place_picker.dart';

void main() {
  //runApp(MaterialApp(home: Text('ss123')));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photographers',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ProfileWidget(title: 'Photographers profile'),
//      home: PhotoEditorWidget(),
    );
  }
}

class ProfileWidget extends StatefulWidget {
  ProfileWidget({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  String _bio;
  File _image;
  LocationResult _location;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  Future showPlacePicker() async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("AIzaSyDBYhfd2OAaTUvce5omhI8Ih2qO5S6G7YA")));

    setState(() => _location = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Card(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Name'),
                    Container(
                      height: 100,
                      child: FlatButton(
                        onPressed: getImage,
                        child: _image == null
                            ? Text('No image selected.')
                            : Image.file(
                                _image,
                                fit: BoxFit.fitHeight,
                              ),
                      ),
                    ),
                  ]),
            ),
            Card(
              child: ListTile(
                leading: Text('Location'),
                trailing: FlatButton(
                  onPressed: showPlacePicker,
                  child: Text(
                    // ignore: null_aware_in_condition
                    _location?.city?.name?.isEmpty ?? true
                        ? 'select location...'
                        : '${_location.city.name}, ${_location.country.shortName}',
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Text('Bio'),
                title: FlatButton(
                  onPressed: () {
                    _navigateAndDisplaySelection(context);
                  },
                  child: Text(
                    // ignore: null_aware_in_condition
                    _bio?.isEmpty ?? true ? '...' : _bio,
                  ),
                ),
              ),
            ),
//            Card(
//              child: ListTile(
//                leading: Text('Phone'),
//                title: FlatButton(
//                  onPressed: _showBioDialog,
//                  child: Text("..."),
//                ),
//              ),
//            ),
          ],
        ),
      ),
    );
  }

  void _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfileBioEditorWidget(
                textValue: _bio,
              )),
    );
    if (!(result?.isEmpty ?? true)) {
      setState(() => _bio = result);
    }
  }
}

class ProfileBioEditorWidget extends StatelessWidget {
  final textController = TextEditingController();

  final String textValue;

  ProfileBioEditorWidget({Key key, @required this.textValue}) : super(key: key);

//  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
//    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    textController.text = textValue;
    return Scaffold(
      appBar: AppBar(
        title: Text("Biography"),
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.pop(context, textController.text);
            },
            child: Text('Ok'),
          ),
        ],
      ),
      body: TextField(
        controller: textController,
        autofocus: true,
        decoration:
            InputDecoration(border: InputBorder.none, hintText: 'Enter a text'),
      ),
    );
  }
}

class PhotoEditorWidget extends StatefulWidget {
  @override
  _PhotoEditorWidgetState createState() => _PhotoEditorWidgetState();
}

class _PhotoEditorWidgetState extends State<PhotoEditorWidget> {
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: Center(
        child: _image == null ? Text('No image selected.') : Image.file(_image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
