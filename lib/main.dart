import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:math';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter/services.dart';
import 'package:kdgaugeview/kdgaugeview.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp( MaterialApp(debugShowCheckedModeBanner: false, home:
  AnimatedSplashScreen(
    backgroundColor: const Color.fromARGB(255, 38, 38, 38),
          animationDuration: const Duration(milliseconds: 500),
        splashTransition: SplashTransition.scaleTransition,
        splashIconSize: 350,
        splash: Center(child: Image.asset("assets/aaa.png"),),
  nextScreen: const MyApp()),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Object phone;
  late Object phone2;
  double _force = 0.0;

  double _AngleX = 0.0;
  double _AngleY = 0.0;
  double _AngleZ = 0.0;

  double _rotationAngleX = 0.0;
  double _rotationAngleY = 0.0;
  double _rotationAngleZ = 0.0;
  final double _DeviceMass = 0.2;
  final List<double> _forceList = [];
  final List<double> _rotationAngleXList = [];
  final List<double> _rotationAngleYList = [];
  final List<double> _rotationAngleZList = [];
  bool _recording = false;

  double avgForce = 0.0;
  double maxRotationX = 0.0;
  double maxRotationY = 0.0;
  double maxRotationZ = 0.0;

  GlobalKey<KdGaugeViewState> key = GlobalKey<KdGaugeViewState>();

  @override
  void initState() {
    phone = Object(fileName: "assets/pphone.obj");
    phone2 = Object(fileName: "assets/pphone.obj");

    super.initState();
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        double ax = event.x;
        double ay = event.y;
        double az = event.z;

        double a = sqrt((ax * ax) + (ay * ay) + (az * az));
        _force = _DeviceMass * a;
        key.currentState!.updateSpeed(_force,
            animate: true, duration: const Duration(microseconds: 0));
        if (_recording) {
          _forceList.add(_force);
        }
      });
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        double gx = event.x;
        double gy = event.y;
        double gz = event.z;

        // double gg = sqrt((gx * gx) + (gy * gy) + (gz * gz));

        _AngleX = gx;
        _AngleY = gy;
        _AngleZ = -gz;

        _rotationAngleX = (gx * 180 / pi).abs();
        _rotationAngleY = (gy * 180 / pi).abs();
        _rotationAngleZ = (gz * 180 / pi).abs();

        phone.rotation
            .setValues(_rotationAngleX, _rotationAngleZ, _rotationAngleY);
        phone.updateTransform();

        if (_recording) {
          _rotationAngleXList.add(_rotationAngleX);
          _rotationAngleYList.add(_rotationAngleY);
          _rotationAngleZList.add(_rotationAngleZ);
        }
      });
    });

    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Tennis Racket',
                style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    fontFamily: "KaushanScript")),
            centerTitle: true,
            foregroundColor: Colors.black,
            backgroundColor: Colors.amber,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 400,
                    height: 320,
                    margin: const EdgeInsets.only(top: 25),
                    child: KdGaugeView(
                      key: key,
                      minSpeed: 0,
                      gaugeWidth: 10,
                      maxSpeed: 10,
                      divisionCircleColors: Colors.white,
                      subDivisionCircleColors: Colors.transparent,
                      speedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Adamina"),
                      unitOfMeasurementTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Adamina"),
                      minMaxTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: "Adamina"),
                      unitOfMeasurement: "N",
                      fractionDigits: 1,
                      alertColorArray: const [
                        Colors.green,
                        Colors.green,
                        Colors.orange,
                        Colors.orange,
                        Colors.orange,
                        Colors.red,
                        Colors.red
                      ],
                      alertSpeedArray: const [
                        0,
                        1.66,
                        (1.66 * 2),
                        (1.66 * 3),
                        (1.667 * 4),
                        (1.668 * 5),
                        10
                      ],
                      child: Center(
                        child: Container(
                            margin: const EdgeInsets.only(bottom: 150),
                            child: const Text("Force",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontFamily: 'Mogra',
                                    color: Colors.amber))),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: const Text(
                            "Rotation Angles",
                            style: TextStyle(
                                fontSize: 23,
                                fontFamily: 'Mogra',
                                color: Colors.amber),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              AnimatedContainer(
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                duration: const Duration(milliseconds: 100),
                                transform: Matrix4.rotationX(_AngleX),
                                width: 50,
                                height: 100,
                                //color: Colors.blue,
                                child: const Center(
                                    child: Text(
                                  "    X\n Axis\nAngle",
                                  style: TextStyle(
                                      color: Colors.black, fontFamily: "Adamina"),
                                )),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                child: Text(
                                  ' X: ${(_rotationAngleX - (_rotationAngleX % 5)).toStringAsFixed(0)}°',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: "Adamina"),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              AnimatedContainer(
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                duration: const Duration(milliseconds: 100),
                                transform: Matrix4.rotationY(_AngleY),
                                width: 50,
                                height: 100,
                                child: const Center(
                                    child: Text(
                                  "    Y\n Axis\nAngle",
                                  style: TextStyle(
                                      color: Colors.black, fontFamily: "Adamina"),
                                )),
                                //color: Colors.blue,
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                child: Text(
                                  ' Y: ${(_rotationAngleY - (_rotationAngleY % 5)).toStringAsFixed(0)}°',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: "Adamina"),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              AnimatedContainer(
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                duration: const Duration(milliseconds: 100),
                                transform: Matrix4.rotationZ(_AngleZ),
                                width: 50,
                                height: 100,
                                child: const Center(
                                    child: Text(
                                  "    Z\n Axis\nAngle",
                                  style: TextStyle(
                                      color: Colors.black, fontFamily: "Adamina"),
                                )),
                                //color: Colors.blue,
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                child: Text(
                                  ' Z: ${(_rotationAngleZ - (_rotationAngleZ % 5)).toStringAsFixed(0)}°',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: "Adamina"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30.0),
                  Column(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            children: const [
                              Text(
                                "Phone State based on",
                                style: TextStyle(
                                    fontSize: 23,
                                    fontFamily: 'Mogra',
                                    color: Colors.amber),
                              ),
                              Text(
                                "Rotation Angles",
                                style: TextStyle(
                                    fontSize: 23,
                                    fontFamily: 'Mogra',
                                    color: Colors.amber),
                              ),
                              Text(
                                "( 3D Model )",
                                style: TextStyle(
                                    fontSize: 23,
                                    fontFamily: 'Mogra',
                                    color: Colors.amber),
                              ),
                            ],
                          )),
                      SizedBox(
                          height: 150,
                          width: 150,
                          child: Cube(
                            onSceneCreated: (Scene scene) {
                              scene.world.add(phone);
                              scene.camera.zoom = 10;
                            },
                          )),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(25, 25, 25, 25),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        backgroundColor: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          if (!_recording) {
                            _forceList.clear();
                            _rotationAngleXList.clear();
                            _rotationAngleYList.clear();
                            _rotationAngleZList.clear();
      
                            // Start recording data for 5 seconds
                            _recording = true;
      
                            Timer(const Duration(seconds: 3), () {
                              setState(() {
                                _recording = false;
                                //avgForce = _forceList.reduce((a, b) => a + b) / _forceList.length;
                                avgForce = _forceList.average;
                                //maxRotationX = _rotationAngleXList.reduce(max);
                                maxRotationX = _rotationAngleXList.max;
                                //maxRotationY = _rotationAngleYList.reduce(max);
                                maxRotationY = _rotationAngleYList.max;
                                //maxRotationZ = _rotationAngleZList.reduce(max);
                                maxRotationZ = _rotationAngleZList.max;
      
                                phone2.rotation.setValues(maxRotationX,maxRotationY, maxRotationZ);
                                phone2.updateTransform();
                              });
      
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        const Color.fromARGB(255, 38, 38, 38),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15)),
                                    title: const Center(
                                        child: Text('Results',
                                            style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "KaushanScript",
                                                color: Colors.amber))),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 200,
                                            height: 200,
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 20),
                                            child: KdGaugeView(
                                              minSpeed: 0,
                                              gaugeWidth: 10,
                                              maxSpeed: 10,
                                              animate: true,
                                              duration:
                                                  const Duration(seconds: 2),
                                              speed: avgForce,
                                              divisionCircleColors: Colors.white,
                                              subDivisionCircleColors:
                                                  Colors.transparent,
                                              speedTextStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Adamina"),
                                              unitOfMeasurementTextStyle:
                                                  const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: "Adamina"),
                                              minMaxTextStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontFamily: "Adamina"),
                                              unitOfMeasurement: "N",
                                              fractionDigits: 1,
                                              alertColorArray: const [
                                                Colors.green,
                                                Colors.green,
                                                Colors.orange,
                                                Colors.orange,
                                                Colors.orange,
                                                Colors.red,
                                                Colors.red
                                              ],
                                              alertSpeedArray: const [
                                                0,
                                                1.66,
                                                (1.66 * 2),
                                                (1.66 * 3),
                                                (1.667 * 4),
                                                (1.668 * 5),
                                                10
                                              ],
                                              child: Center(
                                                child: Container(
                                                    margin: const EdgeInsets.only(
                                                        bottom: 80),
                                                    child: const Text(
                                                        "Avg. Force",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontFamily: 'Mogra',
                                                            color:
                                                                Colors.amber))),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                AnimatedContainer(
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber,
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  duration: const Duration(
                                                      milliseconds: 100),
                                                  transform: Matrix4.rotationX(
                                                      maxRotationX * pi / 180),
                                                  width: 20,
                                                  height: 40,
                                                  //color: Colors.blue,
                                                  child: const Center(
                                                      child: Text(
                                                    "X",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Adamina"),
                                                  )),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5),
                                                  child: Text(
                                                    ' X: ${maxRotationX > 360 ? (maxRotationX%360).toStringAsFixed(0) : maxRotationX.toStringAsFixed(0)}°',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontFamily: "Adamina"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                AnimatedContainer(
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber,
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  duration: const Duration(
                                                      milliseconds: 100),
                                                  transform: Matrix4.rotationY(
                                                      maxRotationY * pi / 180),
                                                  width: 20,
                                                  height: 40,
                                                  child: const Center(
                                                      child: Text(
                                                    "Y",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Adamina"),
                                                  )),
                                                  //color: Colors.blue,
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5),
                                                  child: Text(
                                                    ' Y: ${maxRotationY > 360 ? (maxRotationY%360).toStringAsFixed(0) : maxRotationY.toStringAsFixed(0)}°',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontFamily: "Adamina"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                AnimatedContainer(
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber,
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  duration: const Duration(
                                                      milliseconds: 100),
                                                  transform: Matrix4.rotationZ(
                                                      maxRotationZ * pi / 180),
                                                  width: 20,
                                                  height: 40,
                                                  child: const Center(
                                                      child: Text(
                                                    "Z",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Adamina"),
                                                  )),
                                                  //color: Colors.blue,
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5),
                                                  child: Text(
                                                    ' Z: ${maxRotationZ > 360 ? (maxRotationZ%360).toStringAsFixed(0) : maxRotationZ.toStringAsFixed(0)}°',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontFamily: "Adamina"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Center(
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(top: 15,bottom: 10),
                                            child: const Text(
                                              "( 3D Model )",
                                              style: TextStyle(
                                                  fontSize: 23,
                                                  fontFamily: 'Mogra',
                                                  color: Colors.amber),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: SizedBox(
                                              height: 100,
                                              width: 100,
                                              child: Cube(
                                                onSceneCreated: (Scene scene) {
                                                  scene.world.add(phone2);
      
                                                  scene.camera.zoom = 10;
                                                },
                                              )),
                                        ),
                                        // Text(
                                        //   'Average Force: ${avgForce.toStringAsFixed(1)} N',
                                        //   style: const TextStyle(
                                        //       color: Colors.white),
                                        // ),
                                        // const SizedBox(height: 10.0),
                                        // Text(
                                        //     'Highest Rotation Angle X: ${maxRotationX.toStringAsFixed(0)}°',
                                        //     style: const TextStyle(
                                        //         color: Colors.white)),
                                        // const SizedBox(height: 10.0),
                                        // Text(
                                        //     'Highest Rotation Angle Y: ${maxRotationY.toStringAsFixed(0)}°',
                                        //     style: const TextStyle(
                                        //         color: Colors.white)),
                                        // const SizedBox(height: 10.0),
                                        // Text(
                                        //     'Highest Rotation Angle Z: ${maxRotationZ.toStringAsFixed(0)}°',
                                        //     style: const TextStyle(
                                        //         color: Colors.white)),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      Center(
                                        child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.amber,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15)),
                                            ),
                                            child: const Text(
                                              "Okay",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Rye"),
                                            )),
                                      ),
                                    ],
                                  );
                                },
                              );
                            });
                          }
                        });
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _recording ? 'Recording...' : 'Hit with the Tennis Racket',
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontFamily: "Rye"),
                              ),
                              _recording
                                  ? Container(
                                      margin: const EdgeInsets.only(
                                          left: 3),
                                      height: 15,
                                      width: 15,
                                      child: const CircularProgressIndicator(
                                        color: Colors.black,
                                      ),
                                    )
                                  : Container(),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
