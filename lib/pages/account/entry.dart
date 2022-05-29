import 'package:flutter/material.dart';
import 'package:near_test/pages/account/create.dart';
import 'package:near_test/pages/account/import.dart';

class Entry extends StatelessWidget {
  const Entry({Key? key}) : super(key: key);

  static const route = "/entry";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("entry"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Create.route),
              child: Text("Create account"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Import.route),
              child: Text("Import account"),
            ),
          ],
        ),
      ),
    );
  }
}
