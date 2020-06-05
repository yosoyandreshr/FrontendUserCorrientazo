import 'package:flutter/material.dart';
import 'package:front_app_corrientazo/src/pages/Payment_Method.dart';
import 'package:front_app_corrientazo/src/providers/Profile_Provider.dart';
import 'package:front_app_corrientazo/src/services/Alert.dart';
import 'package:front_app_corrientazo/src/utils/UserInformation.dart';
import 'package:front_app_corrientazo/src/utils/token.dart';

class DirectionPage extends StatefulWidget {
  final String value;

  DirectionPage({this.value});
  static final String path = "lib/src/pages/animations/anim5.dart";

  @override
  _DirectionPage createState() => _DirectionPage(value: this.value);
}

class _DirectionPage extends State<DirectionPage> {
  ProfileProvider profileProvider;
  UserInformation userInformation;
  TextEditingController addressInput;
  TextEditingController cityInput;
  Token token;
  Alerts alerts;

  final String value;

  List userDirections;
  List<String> itemDirection;
  List<String> itemCity;
  List<String> itemDirectionId;
  Map userData;

  _DirectionPage({this.value}) {
    userInformation = UserInformation();
    profileProvider = ProfileProvider();
    addressInput = TextEditingController();
    cityInput = TextEditingController();
    token = Token();
    alerts = Alerts();
    userData = {};
  }

  Future directionUser() async {
    userData = await userInformation.getUserInformation();
    profileProvider
        .getDirectionsByUserId(userData['userId'].toString())
        .then((resp) {
      setState(() {
        userDirections = resp;
        if (userDirections.length > 0) {}
      });
      for (var i = 0; i < userDirections.length; i++) {
        itemDirection.insert(
            itemDirection.length, userDirections[i]['nameDirection']);
        itemCity.insert(itemCity.length, userDirections[i]['userCity']);
        itemDirectionId.insert(itemDirectionId.length,
            userDirections[i]['directionId'].toString());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    itemDirection = [];
    itemCity = [];
    itemDirectionId = [];
    directionUser();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('ELIJA LA DIRECCION'),
          backgroundColor: Color(0xFFF44336),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                final route = MaterialPageRoute(builder: (context) {
                  return PaymentMethod(value: value);
                });

                Navigator.push(context, route);
              }),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _listDirections();
                },
                childCount: 1,
              ),
            )
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.white70,
          height: 95,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 90.0),
          child: FloatingActionButton.extended(
            onPressed: () async {
              newDirection(context);
            },
            label: Text('NUEVA DIRECCION'),
            backgroundColor: Color(0xFFF44336),
          ),
        ),
      ),
    );
  }

  Widget _cardOrder(context, String address, String city, String directionId) {
    final list = Container(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.circular(5)),
          elevation: 3.0,
          child: Column(children: <Widget>[
            ListTile(
              title: Text('Dirección: $address',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              subtitle: Text('Ciudad:' '$city',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
      ),
    );
    return GestureDetector(
      child: list,
      onTap: () {
        token.setString('direction', '$address');
        token.setString('city', '$city');
        final route = MaterialPageRoute(builder: (context) {
          return PaymentMethod(
            value: value,
          );
        });

        Navigator.push(context, route);
      },
    );
  }

  Widget _listDirections() {
    return ListView.builder(
        physics: new NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemDirection == null ? 0 : itemDirection.length,
        itemBuilder: (BuildContext context, int index) {
          return _cardOrder(context, itemDirection[index], itemCity[index],
              itemDirectionId[index].toString());
        });
  }

  Future newDirection(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Divider(
                thickness: 2,
              ),
              TextField(
                controller: addressInput,
                decoration: InputDecoration(
                    hintText: 'Dirección*',
                    prefixIcon: Icon(Icons.location_on, color: Colors.red),
                    hintStyle: TextStyle(fontWeight: FontWeight.w600)),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              TextField(
                controller: cityInput,
                decoration: InputDecoration(
                    hintText: 'Ciudad*',
                    prefixIcon: Icon(Icons.location_city, color: Colors.red),
                    hintStyle: TextStyle(fontWeight: FontWeight.w600)),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
                child: Text('CANCELAR',
                    style: TextStyle(color: Color(0xFFF44336))),
                onPressed: () {
                  Navigator.pop(context);
                }),
            FlatButton(
                child:
                    Text('ACEPTAR', style: TextStyle(color: Color(0xFFF44336))),
                onPressed: () {
                  if (addressInput.text.toString() == '' ||
                      cityInput.text.toString() == '') {
                  } else {
                    profileProvider.saveDirection(
                      {
                        'nameDirection': addressInput.text.toUpperCase().trim(),
                        'userCity': cityInput.text.toUpperCase().trim(),
                        'userId': userData['userId'].toString(),
                      },
                    ).then((res) {
                      setState(() {
                        if (res['message'].toString() ==
                            'la direccion ya existe') {
                          alerts.errorAlert(context, 'La Direccion ya existe');
                          addressInput.clear();
                          cityInput.clear();
                        } else {
                          itemDirection.insert(
                              itemDirection.length, res['nameDirection']);
                          itemCity.insert(itemCity.length, res['userCity']);
                          itemDirectionId.insert(itemDirectionId.length,
                              res['directionId'].toString());
                          addressInput.clear();
                          cityInput.clear();
                          Navigator.pop(context);
                        }
                      });
                    });
                  }
                }),
          ],
        );
      },
    );
  }
}
