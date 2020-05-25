import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:email_validator/email_validator.dart';

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

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  String _email;
  String _phone;
  String _bio;
  String _styles;
  File _image;
  PickResult _location;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  Future showPlacePicker() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey:
              'AIzaSyDBYhfd2OAaTUvce5omhI8Ih2qO5S6G7YA', // Put YOUR OWN KEY here.
          onPlacePicked: (result) {
            setState(() => _location = result);
            Navigator.of(context).pop();
          },
          useCurrentLocation: true, initialPosition: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    // ignore:.null_aware_in_condition
//                      formattedAddress ?? 'select location...'
                    _location?.formattedAddress?.isEmpty ?? true
                        ? 'select location...'
                        : '${_location.formattedAddress}',
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Text('Email'),
                trailing: FlatButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EmailEditorWidget(
                                textValue: _email,
                                caption: 'Email',
                              )),
                    );
                    if (!(result?.isEmpty ?? true)) {
                      setState(() => _email = result);
                    }
                  },
                  child: Text(_email ?? '...'),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Text('Phone'),
                trailing: FlatButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PhoneEditorWidget(
                                textValue: _phone,
                                caption: 'Phone',
                              )),
                    );
                    if (!(result?.isEmpty ?? true)) {
                      setState(() => _phone = result);
                    }
                  },
                  child: Text(_phone ?? '...'),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Text('Styles'),
                trailing: FlatButton(
                  onPressed: () {
                    _showStylesEditor(context);
                  },
                  child: Text(
                    fmtValue(_styles, ', '),
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Text('Bio'),
                trailing: FlatButton(
                  onPressed: () {
                    _showBioEditor(context);
                  },
                  child: Text(
                    fmtValue(_bio, ' '),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String fmtValue(String s, String delimiter) {
    return s?.isEmpty ?? true
        ? '...'
        : (s.length > 40 ? s.substring(0, 40) + '...' : s)
            .replaceAll('\n', delimiter ?? ' ');
  }

  void _showBioEditor(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MemoEditorWidget(
                textValue: _bio,
                caption: 'Biography',
              )),
    );
    if (!(result?.isEmpty ?? true)) {
      setState(() => _bio = result);
    }
  }

  void _showStylesEditor(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MemoEditorWidget(
                textValue: _styles,
                caption: 'Styles',
              )),
    );
    if (!(result?.isEmpty ?? true)) {
      setState(() => _styles = result);
    }
  }
}

class MemoEditorWidget extends StatelessWidget {
  final textController = TextEditingController();

  final String textValue;
  final String caption;

  MemoEditorWidget({Key key, @required this.textValue, @required this.caption})
      : super(key: key);

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
        title: Text(caption),
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
        maxLines: null,
        expands: true,
        controller: textController,
        autofocus: true,
        decoration:
            InputDecoration(border: InputBorder.none, hintText: 'Enter a text'),
      ),
    );
  }
}

class EmailEditorWidget extends StatelessWidget {
  final textController = TextEditingController();

  final String textValue;
  final String caption;

  EmailEditorWidget({Key key, @required this.textValue, @required this.caption})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    textController.text = textValue;
    return Scaffold(
      appBar: AppBar(
        title: Text(caption),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              var email = textController.text;
              if (EmailValidator.validate(email))
                Navigator.pop(context, email);
              else
                _showError(context, 'Email not valid');
            },
            child: Text('Ok'),
          ),
        ],
      ),
      body: TextField(
        controller: textController,
        autofocus: true,
        decoration:
            InputDecoration(border: InputBorder.none, hintText: 'Enter email'),
        onSubmitted: (email) {
          if (EmailValidator.validate(email))
            Navigator.pop(context, email);
          else
            _showError(context, 'Email not valid');
        },
      ),
    );
  }
}

class PhoneEditorWidget extends StatelessWidget {
  final textController = TextEditingController();

  final String textValue;
  final String caption;

  PhoneEditorWidget({Key key, @required this.textValue, @required this.caption})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    textController.text = textValue;
    return Scaffold(
      appBar: AppBar(
        title: Text(caption),
        actions: <Widget>[
          FlatButton(
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
        decoration: InputDecoration(labelText: "Enter your number"),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
    );
  }
}

Future<void> _showError(BuildContext context, String title) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        actions: <Widget>[
          FlatButton(
            child: Text('Back'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
