import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestorehelpertest/databaseservice.dart';
import 'package:firestorehelpertest/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FireStoreHelpers Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'FireStoreHelpers Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double newLatitude;
  double newLongitude;
  String newName;

  final DatabaseService dbService = new DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Current position:'),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                    hintText: 'lat',
                  ),
                )),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(hintText: 'long'),
                ))
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Show locations in radius:'),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                    hintText: 'radius in km',
                  ),
                )),
                SizedBox(
                  width: 10.0,
                ),
                RaisedButton(
                  child: Text('Update'),
                ),
              ],
            ),
            Expanded(
              child: Placeholder(),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Add new location:'),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                    child: TextField(
                  onChanged: (s) => setState(() => newName = s),
                  decoration: InputDecoration(
                    hintText: 'name',
                  ),
                )),
                SizedBox(
                  width: 10.0,
                ),
                RaisedButton(
                  child: Text('Add'),
                  onPressed: newName != null &&
                          newLatitude != null &&
                          newLongitude != null
                      ? addLocation
                      : null,
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Position:'),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: TextField(
                    onChanged: (s) => setState(() => newLatitude = double.parse(s)),
                    decoration: InputDecoration(
                      hintText: 'lat',
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: TextField(
                    onChanged: (s) => setState(() => newLongitude = double.parse(s)),
                    decoration: InputDecoration(hintText: 'long'),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addLocation() async {
      await dbService.createLocation(new Location(newName, GeoPoint(newLatitude, newLongitude)));
      newName = null;
      newLatitude = null;
      newLongitude = null;
      setState((){});

  }
}
