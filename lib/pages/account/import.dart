import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:near_test/api.dart';

import '../home.dart';

class Import extends StatefulWidget {
  const Import({Key? key}) : super(key: key);

  static const route = "/Import";

  @override
  State<Import> createState() => _ImportState();
}

class _ImportState extends State<Import> {
  TextEditingController controller = new TextEditingController(
      text:
          "flight people bracket rapid cave unable worth repeat clay enhance arrive alpha");

  bool isSubmiting = false;

  Future import() async {
    setState(() {
      isSubmiting = true;
    });
    Map? res = await webApi?.recoverAccount(controller.text.trim());
    setState(() {
      isSubmiting = false;
    });
    if (res != null) {
      Navigator.popAndPushNamed(context, MyHomePage.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Import"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: controller,
                maxLines: 2,
              ),
            ),
            ElevatedButton(
              onPressed: isSubmiting ? null : import,
              child: Text(isSubmiting ? "Submiting" : "Import"),
            )
          ],
        ),
      ),
    );
  }
}
