import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomePage createState() => HomePage();
}

class HomePage extends State<Home> {
  Timer? searchOnStoppedTyping;
  String _search = '';
  bool _loading = false;
  List _data = [];
  int _offset = 10;

  void _getData() {
    const duration = Duration(milliseconds: 1000);
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping?.cancel());
    }
    setState(() => searchOnStoppedTyping = Timer(duration, () => search()));
  }

  Future search() async {
    setState(() {
      _loading = true;
    });
    try {
      http.Response res = await http.get(Uri.parse(
        "https://api.giphy.com/v1/gifs/search?api_key=OlPboEss2xGosNdNmwCzfqx5bMdDSnPq&q=$_search&limit=10&offset=$_offset&rating=G&lang=en",
      ));
      setState(() {
        _data.addAll(jsonDecode(res.body)["data"]);
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SafeArea(child: Text('GIF search app')),
        centerTitle: true,
        backgroundColor: Colors.purple[900],
      ),
      body: LazyLoadScrollView(
        onEndOfPage: () {
          setState(() {
            _offset += 10;
          });
          search();
        },
        child: ListView(shrinkWrap: true, children: [
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: const Color.fromARGB(255, 124, 49, 216),
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 124, 49, 216), width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 124, 49, 216), width: 2.0),
                    ),
                    labelText: "Search",
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 124, 49, 216)),
                  ),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 74, 20, 140), fontSize: 18.0),
                  onChanged: (text) {
                    _getData();
                    setState(() {
                      _search = text;
                      _offset = 10;
                      _data = [];
                    });
                  },
                ),
              ),
              if (_data.isEmpty && !_loading) ...[
                const Text("Please search for GIFs")
              ] else ...[
                Column(
                  children: _data
                      .map((quote) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                                quote["images"]["fixed_height"]["url"]),
                          ))
                      .toList(),
                )
              ],
              if (_loading) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SpinKitFadingCircle(
                    color: Color.fromARGB(255, 124, 49, 216),
                    size: 90.0,
                  ),
                )
              ]
            ],
          )
        ]),
      ),
    );
  }
}
