import 'package:flutter/material.dart';
import 'package:new_version/new_version.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loadingVersions = false;
  NewVersionFields? _androidVersion;
  NewVersionFields? _iosVersion;

  @override
  void initState() {
    super.initState();

    // Instantiate NewVersion manager object (Using GCP Console app as example)
    final newVersion = NewVersion(
      iOSId: 'com.google.Vespa',
      androidId: 'com.google.android.apps.cloudconsole',
    );

    // You can let the plugin handle fetching the status and showing a dialog,
    // or you can fetch the status and display your own dialog, or no dialog.
    const simpleBehavior = true;

    if (simpleBehavior) {
      basicStatusCheck(newVersion);
    } else {
      advancedStatusCheck(newVersion);
    }

    printAllPlatforms();
  }

  basicStatusCheck(NewVersion newVersion) {
    newVersion.showAlertIfNecessary(context: context);
  }

  advancedStatusCheck(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      debugPrint(status.releaseNotes);
      debugPrint(status.appStoreLink);
      debugPrint(status.localVersion);
      debugPrint(status.storeVersion);
      debugPrint(status.canUpdate.toString());
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: 'Custom Title',
        dialogText: 'Custom Text',
      );
    }
  }

  printAllPlatforms() async {
    setState(() => _loadingVersions = true);

    final androidVersion = await NewVersion()
        .getAndroidStoreVersion('com.google.android.apps.cloudconsole');
    debugPrint("Android version: ${androidVersion?.version}");
    final iosVersion =
        await NewVersion().getIosStoreVersion('com.google.Vespa');
    debugPrint("iOS version: ${iosVersion?.version}");

    setState(() {
      _loadingVersions = false;
      _androidVersion = androidVersion;
      _iosVersion = iosVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Example App"),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: _loadingVersions
                ? CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(
                          "Android version: ${_androidVersion?.version}",
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          _androidVersion?.releaseNotes ?? "",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "iOS version: ${_iosVersion?.version}",
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          _iosVersion?.releaseNotes ?? "",
                          textAlign: TextAlign.center,
                        ),
                      ]),
          ),
        ));
  }
}
