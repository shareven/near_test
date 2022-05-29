import 'package:flutter/material.dart';
import 'package:near_test/api.dart';
import 'package:near_test/pages/account/entry.dart';
import 'package:near_test/app_storage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  static const route = "/";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map? account;

  @override
  void initState() {
    super.initState();
    webApi = Api(context);
    webApi!.init();
    getAccountDataFromStorage();
  }

  Future getAccountDataFromStorage() async {
    Map? data = await AppStorage.getAccount();
    if (data == null) {
      Navigator.pushNamed(context, Entry.route);
    } else {
      setState(() {
        account = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Home page',
              style: TextStyle(fontSize: 30),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Current Account: ${account?["accountId"] ?? ""}',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await AppStorage.setAccount(null);
                Navigator.pushNamed(context, Entry.route);
              },
              child: Text("Clear account"),
            )
          ],
        ),
      ),
    );
  }
}
