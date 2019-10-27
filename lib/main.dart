import 'package:flutter/material.dart';
import 'package:launcher_assist/launcher_assist.dart';
import 'package:localstorage/localstorage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LocalStorage _storage = LocalStorage('launchapp');
  List<AppItem> _appList = [];

  void getListOfApps() async {
    LauncherAssist.getAllInstalledApps().then((apps) {
      List<Map<dynamic,dynamic>> listApps = List.from(apps);
      Future.wait([sortApps(listApps)]);
      appToAppList(listApps);
    });
  }

  Future sortApps(listApps) async {
    listApps.sort((a, b) {
      return (a['label']).toString().toUpperCase().compareTo((b['label']).toString().toUpperCase());
    });
  }

  void appToAppList(List<Map<dynamic,dynamic>> listApps) {
    for(int i = 0; i < listApps.length; i++) {
      Map<dynamic, dynamic> item = listApps[i];
      // item is a map of {package, icon, label}
      AppItem appItem = AppItem(item['label'], item['package'], item['icon']);
      _appList.add(appItem);
    }
    setState(() {});
    setListToPref(_appList);
  }

  void setListToPref(listApps) {
    _storage.setItem('apps', listApps);
    _storage.setItem('hasApps', true);
  }

  void getListOfAppsFromPref() async {
    await _storage.ready;
    setState(() {
      _appList = _storage.getItem('apps');
    });
  }

  @override
  void initState() {
    super.initState();
    if (_storage.getItem('hasApps') != null) {
      if (_storage.getItem('hasApps') == true)
        getListOfAppsFromPref();
    } else getListOfApps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        itemCount: _appList.length,
        itemBuilder: (context, idx) {
          return GridTile(
            child: InkWell(
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        child: Image.memory(_appList[idx].icon),
                      ),
                      SizedBox(height: 8.0,),
                      Text(_appList[idx].name.toUpperCase(),
                        style: TextStyle(fontSize: 10.0, ),
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                LauncherAssist.launchApp(_appList[idx].package);
              },
            ),
          );
        }
      )
    );
  }
}

class AppItem {
  String name, package;
  var icon;

  AppItem(this.name, this.package, this.icon);

  toJson() {
    Map<String, dynamic> m = Map();
    m['name'] = name;
    m['package'] = package;
    m['icon'] = icon;
    return m;
  }
}