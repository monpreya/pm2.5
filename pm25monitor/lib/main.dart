import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

/// Data structure

/// PM25 Sensoring Location
class Location {
  String _name;
  String _url;
  Location(this._name, this._url);
  @override
  String toString() {
    return '{${this._name}, ${this._url}}';
  }
  String get name {
    return _name;
  }
  String get url {
    return _url;
  }

}

/// PM25 Sensoring Value
class AqicnPm25 {
  int value;
  String location;
  AqicnPm25({this.value, this.location});

  factory AqicnPm25.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('data')) {
        Map data = json['data'];
        if (data.containsKey('iaqi') && data['iaqi'] is Map) {
          Map iaqi = data['iaqi'];
          if (iaqi.containsKey('pm25')) {
            Map pm25 = iaqi['pm25'];
            if (pm25.containsKey('v')) {
              return AqicnPm25(value: pm25['v'], location: '--');
            }
          }
        }
      }
      return null;
    } on Exception {
      return null;
    }
  }
}

/// Main Application Structure
void main() => runApp(MyApp());

/// Main Application Widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PM25 Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PM25Monitor(),
    );
  }
}

/// Main Page
class PM25Monitor extends StatefulWidget {
  @override
  PM25MonitorState createState() => PM25MonitorState();
}

/// Main Page State
class PM25MonitorState extends State<PM25Monitor> {
  List<Location> _locations = List<Location>();
  // GET YOUR OWN TOKEN
  // GET YOUR OWN TOKEN
  // GET YOUR OWN TOKEN
  // GET YOUR OWN TOKEN
  // GET YOUR OWN TOKEN
  // GET YOUR OWN TOKEN
  final _aqicnAPIKey = '?token=878f20fba6506273c2771abbaca64ebac0e12dff';
  // base URL for the API
  final _aqicnAPIbaseURL = 'http://api.waqi.info/feed/';
  final _biggerFont = const TextStyle(fontSize: 20);
  Future<AqicnPm25> futurePM25;
  BuildContext _context;

  // List of location, url
  @override
  PM25MonitorState() {

    _locations.add(Location('Chiang Mai', 'chiang-mai/'));
    _locations.add(Location( 'Lamphun', 'thailand/lamphun/provincial-administrative-stadium/'));
    _locations.add(Location('Yupparaj','thailand/chiangmai/yupparaj-wittayalai-school/'));
    _locations.add(Location('CMIS','thailand/chiangmai---cmis/'));
    _locations.add(Location('City Hall','thailand/chiangmai/city-hall/'));
    _locations.add(Location('Bangkok','bangkok/'));
    _locations.add(Location('Phitsanulok','thailand/mobile-1/'));
    _locations.add(Location('Ubonratchathani','thailand/ubon-ratchathani/mueang/nai-mueang/'));
    _locations.add(Location('Russia','russia/tomsk/ivan-chernykh/'));
    _locations.add(Location('India','india/ghaziabad/loni/'));
  }

  // Initial state, we need to do this to make sure future is working OK.
  @override
  void initState() {
    super.initState();
    futurePM25 = fetchPM25(0);
  }

  // Build the Main Page UI
  @override
  Widget build(BuildContext context) {
    _context  = context;
    return Scaffold(
      appBar: AppBar (
        title: Text('PM25 Monitor'),
      ),
      body: Center(
          child:SingleChildScrollView(
                      child: Column (
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                       // Showing PM25 value
                  _buildDisplayValue(), 
         
                  // Showing list of locations
                  _buildLocationList(),
              ],
            ),
          ),
      ),
    );
  }

  // Builder for displaying PM25 value,
  // FutureBuilder is used to handle async operation from server
  Widget _buildDisplayValue() {
    return FutureBuilder<AqicnPm25> (
      
      future: futurePM25,
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.done) {
          if(snapshot.hasData) {
            // Value = -1 means we get the result from server, but
            // the result is not OK.
            if (snapshot.data.value == -1) {
              return Text('Can\'t retrieve data for {$snapshot.data.location}, try another');
             } 
             if(snapshot.data.value >= 0 && snapshot.data.value <= 50)
             {
               return
               Container(
                 child: Text('${snapshot.data.location}:${snapshot.data.value} ug/m^3',
                        style: _biggerFont),
                  color: Colors.green,
               );
             }

             if(snapshot.data.value >= 51 && snapshot.data.value <= 100)
             {
               return
               Container(
                 child: Text('${snapshot.data.location}:${snapshot.data.value} ug/m^3',
                        style: _biggerFont),
                  color: Colors.yellow,
               );
             }
              if(snapshot.data.value >= 101 && snapshot.data.value <= 150)
             {
               return
               Container(
                 child: Text('${snapshot.data.location}:${snapshot.data.value} ug/m^3',
                        style: _biggerFont),
                  color: Color(0xffF67636),
               );
             }
              if(snapshot.data.value >= 151 && snapshot.data.value <= 200)
             {
               return
               Container(
                 child: Text('${snapshot.data.location}:${snapshot.data.value} ug/m^3',
                        style: _biggerFont),
                  color: Color(0xff730C10),
               );
             }
              if(snapshot.data.value >= 201 && snapshot.data.value <= 300)
             {
               return
               Container(
                 child: Text('${snapshot.data.location}:${snapshot.data.value} ug/m^3',
                        style: _biggerFont),
                  color: Color(0xff7710DC),
               );
             }
              if(snapshot.data.value >= 300)
             {
               return
               Container(
                 child: Text('${snapshot.data.location}:${snapshot.data.value} ug/m^3',
                        style: _biggerFont),
                  color: Color(0xffFD2A05),
               );
             }
             //else {
            //   return Text(
            //     '${snapshot.data.location}:${snapshot.data.value} ug/m^3',
            //     style: _biggerFont,
            //     );
            // }
          } else if (snapshot.hasError) {
            return Text(
              '${snapshot.error}',
              style: _biggerFont
              );
          }
        }
        return CircularProgressIndicator();
      }
    );
  }

  // Builder for the location list
  Widget _buildLocationList() {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder : (context, index) => Divider (
        color: Colors.blue
        ),
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      itemCount: _locations.length,
      itemBuilder: (context, i) {
        // For detecting on screen tap
        return GestureDetector(
          child: ListTile(
            title: Text (
              _locations[i].name,
              style: _biggerFont,
            ),
          ),
          // When user tap on a location, load new data
          onTap: () {
            // We need to change state to force FutureBuilder to reload
            setState(() {
              futurePM25 = fetchPM25(i);
            });
          }
        );
      }
    );
  }

  // Fetch PM25 data from API, future to handle async data
  Future<AqicnPm25> fetchPM25(int _currentSelectedIndex) async {
    // Construct request QPI
    String url = _aqicnAPIbaseURL + _locations[_currentSelectedIndex]._url + _aqicnAPIKey;
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Parse responsed JSON into future object
        AqicnPm25 pm25 = AqicnPm25.fromJson(json.decode(response.body));
        if (pm25 == null) {
          throw Exception('No PM25 data for:' + _locations[_currentSelectedIndex]._name);
        }
        pm25.location = _locations[_currentSelectedIndex]._name;
        return pm25;
      } else {
        throw Exception('Failed to load data from AQICN Server');
      }
    } catch(e) {
      // Something is wrong, show dialog then report -1  to FutureBuilder
      showDialog(
        context: _context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('Error:'),
            content: new Text(e.toString()),
            actions: <Widget> [
              new FlatButton(
                child: new Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                }

              )
            ]

          );
        }
      );
      AqicnPm25 pm25 = new AqicnPm25();
      pm25.value = -1;
      pm25.location = e.toString();
      return pm25;
    }
  }
}

