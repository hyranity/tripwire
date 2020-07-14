import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwire/Model/classes.dart';
import 'package:weather/weather_library.dart';

import 'Model/CurrentLocation.dart';
import 'Model/Group.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.transparent),
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Weather weather;
  Placemark place;

  void loadData() {
    // Code possible thanks to https://www.digitalocean.com/community/tutorials/flutter-geolocator-plugin

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position currentPos) async {
      try {
        List<Placemark> placeList = await geolocator.placemarkFromCoordinates(
            currentPos.latitude, currentPos.longitude);
        setState(() {
          place = placeList[0];
          new WeatherFactory(CurrentData.weatherAPIkey)
              .currentWeatherByLocation(
                  currentPos.latitude, currentPos.longitude)
              .then((Weather currentWeather) {
            weather = currentWeather;
          });
          if (weather == null) {
            //cannot obtain by coords, try by city
            new WeatherFactory(CurrentData.weatherAPIkey)
                .currentWeatherByCityName(place.locality)
                .then((Weather currentWeather) {
              weather = currentWeather;
            });
          }
          if (weather == null) {
            //cannot obtain by city, try by state
            new WeatherFactory(CurrentData.weatherAPIkey)
                .currentWeatherByCityName(place.administrativeArea)
                .then((Weather currentWeather) {
              weather = currentWeather;
            });
          }
        });
      } catch (error) {
        print(error);
      }
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (place == null || weather == null) {
      loadData();
    }

    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          children: <Widget>[
            titleBar(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
            ),
            currentArea(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
            ),
            groupList(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            joinGroup(),
          ],
        ),
      )),
    );
  }

//  loadLocation() {
//    // Code possible thanks to https://www.digitalocean.com/community/tutorials/flutter-geolocator-plugin
//
//    geolocator
//        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
//        .then((Position currentPos) async {
//      try {
//        List<Placemark> placeList = await geolocator.placemarkFromCoordinates(
//            currentPos.latitude, currentPos.longitude);
//        Placemark place = placeList[0];
//        setState(() {
//          currentPlace = place;
//          CurrentData.placeList = place;
//          CurrentData.latitude = currentPos.latitude;
//          CurrentData.longitude = currentPos.longitude;
//        });
//      } catch (error) {
//        print(error);
//      }
//    }).catchError((error) {
//      print(error);
//    });
//  }

  Widget titleBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Hello,",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      color: Color(0xff669260),
                      fontSize: 35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Johann",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      color: Color(0xff8FBF88),
                      fontSize: 20,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              new Spacer(),
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 25,
                        color: Colors.grey.withOpacity(0.3),
                      )
                    ]),
                child: Icon(
                  Icons.menu,
                  size: 25,
                  color: Color(0xff669260),
                ),
              )
            ],
          )),
    );
  }

  Widget currentArea() {
    return Container(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              // Shift the text to the right a bit
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                "CURRENT VIBE",
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Color(0xff90C78A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                locationWidget(),
                SizedBox(
                  width: 10,
                ),
                new Expanded(
                  child: InkWell(
                    child: weatherWidget(),
                    onTap: () {
                      weatherPopup(context);
                    },
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Widget weatherWidget() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
          color: Color(0xffC4D6FC),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 25,
              color: Colors.grey.withOpacity(0.3),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            weather == null
                ? "N/A"
                : weather.temperature.celsius.toStringAsFixed(0) + "°C",
            textAlign: TextAlign.left,
            style: GoogleFonts.poppins(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              color: Color(0xff64749A),
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: 100,
            ),
            child: Text(
              weather == null ? "N/A" : weather.weatherMain.toUpperCase(),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 17,
                color: Color(0xff94A5CB),
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget locationData() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, right: 10.0, top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.location_on,
            color: Color(0xff83AFCC),
            size: 40,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  place == null ? "N/A" : place.locality,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    color: Color(0xff83AFCC),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                //STATE, COUNTRY
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: 110,
                        ),
                        child: Text(
                          place == null ? "N/A" : place.administrativeArea,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            color: Color(0xffB8D0DF),
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                      Text(
                        ", " + (place == null ? "N/A" : place.isoCountryCode),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          color: Color(0xffB8D0DF),
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget locationWidget() {
    return Container(
      height: 90,
      width: MediaQuery.of(context).size.width * 0.55,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 25,
              color: Colors.grey.withOpacity(0.3),
            )
          ]),
      child: locationData(),
    );
  }

  Widget groupList() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            // Shift the text to the right a bit
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              "YOUR GROUPS",
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Color(0xff90C78A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          groupListWidget(),
        ],
      ),
    );
  }

  Future<List<Group>> fetchGroupData() async {
    List<Group> groupList = new List();
    groupList.add(new Group(name: "RSD3 dumbass trip LOOL", isActive: true));
    groupList.add(new Group(name: "test"));
    groupList.add(new Group(name: "test"));
    groupList.add(new Group(name: "test"));
    groupList.add(new Group(name: "test"));
    return groupList;
  }

  Widget groupListWidget() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: FutureBuilder<List<Group>>(
          future: fetchGroupData(),
          // Get async data of groups
          builder: (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
            //If data not loaded
            if (snapshot.connectionState != ConnectionState.done) {
              return new CircularProgressIndicator();
            }

            //Else, return the listview itself
            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 15,
                    );
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return groupItem(snapshot.data[index]);
                  }),
            );
          }),
    );
  }

  Widget groupItem(Group group) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
          color: group.isActive ? Color(0xffECC68C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.grey.withOpacity(0.1),
            )
          ]),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 25.0, right: 25.0, top: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 7,
                      color: Colors.black.withOpacity(0.3),
                    )
                  ],
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                  )),
            ),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    group.name,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: group.isActive ? Colors.white : Color(0xff8AB587),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  group.hoursSince.toString() + " hrs ago",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    color:
                        group.isActive ? Color(0xff9E8259) : Color(0xffC3D6C2),
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget joinGroup() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
          color: Color(0xffD5F5D1),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 25,
              color: Colors.grey.withOpacity(0.3),
            )
          ]),
      child: Text(
        "+",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Color(0xff669260),
        ),
      ),
    );
  }

  Widget weatherPopup(context) {
    showModalBottomSheet(
        barrierColor: Color.fromRGBO(0, 0, 0, 0.01),
        context: context,
        builder: (BuildContext builder) {
          return Container(
            decoration: BoxDecoration(
                color: Color(0xffC4D6FC),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.grey.withOpacity(1),
                  )
                ]),
            child: Padding(
              padding: const EdgeInsets.only(left: 28.0, right: 28.0, top: 15),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      //Temp and condition
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              weather.temperature.celsius.toStringAsFixed(0) +
                                  "°C",
                              style: GoogleFonts.poppins(
                                fontSize: 65,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff64749A),
                              )),
                          Text(weather.weatherMain.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff94A5CB),
                                height: 0.6,
                              ))
                        ],
                      ),
                      new Spacer(),
                      Container(
                        height: 90,
                        constraints: BoxConstraints(maxWidth: 150),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 25,
                                color: Colors.grey.withOpacity(0.3),
                              )
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 20, bottom: 20),
                          child: Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  place == null ? "N/A" : place.locality,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    color: Color(0xff83AFCC),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                //STATE, COUNTRY
                                Flexible(
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: 110,
                                    ),
                                    child: Text(
                                      place == null
                                          ? "N/A"
                                          : place.administrativeArea,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        color: Color(0xffB8D0DF),
                                        fontWeight: FontWeight.w700,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  detailedWeatherInfo(), //Weather info
                ],
              ),
            ),
          );
        });
  }

  Widget weatherBubble(){

  }

  Widget detailedWeatherInfo() {
  List<WeatherBubble> weatherInfo = new List();
  weatherInfo.add(new WeatherBubble(title: "Humidity", value: (weather.humidity * 100).toStringAsFixed(0)+"%"));
  weatherInfo.add(new WeatherBubble(title: "Sunrise", amOrPm: "AM", value: (weather.sunrise.hour.toString() + weather.sunrise.minute.toString())));
  weatherInfo.add(new WeatherBubble(title: "Sunset", amOrPm: "PM", value: ((12-weather.sunset.hour).toString() + weather.sunset.minute.toString())));

    return Container(
      child: ListView.separated(
          itemBuilder: (BuildContext context, int index){
            print(weatherInfo[index].value);


            return Container(
              height: 10,
            );
          },
          separatorBuilder: (BuildContext context, int index){
            return SizedBox(height: 10);
          },
          itemCount: weatherInfo.length,
      ),
    );

  }
}
