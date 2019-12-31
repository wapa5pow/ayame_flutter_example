import 'package:ayame_flutter_example/sendrecv_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

typedef void RouteCallback(BuildContext context);

class RouteItem {
  final String title;
  final RouteCallback push;

  RouteItem({
    @required this.title,
    this.push,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayame Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TopPage(
        title: 'Ayame Flutter Example',
      ),
    );
  }
}

class TopPage extends StatefulWidget {
  TopPage({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<RouteItem> items;

  @override
  void initState() {
    super.initState();
    _initItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(0),
          itemCount: items.length,
          itemBuilder: (context, i) {
            return _buildRow(context, items[i]);
          },
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initItems() {
    items = <RouteItem>[
      RouteItem(
        title: 'Sendrecv',
        push: (context) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SendrecvScreen()));
        },
      ),
    ];
  }

  Widget _buildRow(BuildContext context, RouteItem item) {
    return ListBody(
      children: <Widget>[
        ListTile(
          title: Text(item.title),
          onTap: () => item.push(context),
          trailing: Icon(Icons.arrow_right),
        ),
        Divider(),
      ],
    );
  }
}
