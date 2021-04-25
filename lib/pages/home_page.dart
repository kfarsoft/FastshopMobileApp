import 'dart:async';
import 'package:fastshop_mobile/blocs/home/promo_bloc.dart';
import 'package:fastshop_mobile/functions/getUsername.dart';
import 'package:fastshop_mobile/models/promocion.dart';
import 'package:fastshop_mobile/pages/active_offer.dart';
import 'package:fastshop_mobile/pages/category_page.dart';
import 'package:fastshop_mobile/pages/listados/shop_list_page.dart';
import 'package:fastshop_mobile/pages/shopping/cart_page.dart';
import 'package:fastshop_mobile/pages/test_page.dart';
import 'package:fastshop_mobile/repos/user_repository.dart';
import 'package:fastshop_mobile/user_repository/user_repository.dart';
import 'package:fastshop_mobile/widgets/log_out_button.dart';
import 'package:fastshop_mobile/widgets/shopping_basket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preferences.dart';

class HomePage extends StatefulWidget {
  final int index;

  const HomePage({Key key, @required this.index}) : super(key: key);
  @override
  HomePageSample createState() => new HomePageSample();
}

class HomePageSample extends State<HomePage>
    with SingleTickerProviderStateMixin {
  var user;
  final _prefs = Preferences();

  Timer timer;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  // HomePageSample(this.user);
  // Future<void> _getUsername() async {
  //   user = await getUsername();
  // }

  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(Duration(seconds: 13), (Timer t) => bloc.fetchAllTodo());
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    Future.delayed(Duration(seconds: 2));
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Nueva promocion!!!"),
          content: Text(payload),
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.of(context).pop(), child: Text('Ok'))
          ],
        );
      },
    );
  }

  Future _showNotification(List<Promocion> data) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
        importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    if (data.length > _prefs.promoCant) {
      _prefs.promoCant = data.length;
      await flutterLocalNotificationsPlugin.show(
        0,
        'Nueva Promocion',
        '${data.last.promocion} - ${data.last.producto}',
        platformChannelSpecifics,
        payload:
            'Tenemos una nueva promocion del producto: ${data.last.producto}',
      );
    } else if (data.length < _prefs.promoCant) {
      _prefs.promoCant = data.length;
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Future<bool> _onWillPopScope() async {
    return false;
  }

  List<Widget> _tabItems() => [
        Tab(text: "Promociones", icon: new Icon(Icons.pages)),
        Tab(text: "Categorias", icon: new Icon(Icons.shop)),
        Tab(text: "Carrito", icon: new Icon(Icons.shopping_cart)),
        Tab(text: "Listado", icon: new Icon(Icons.list)),
      ];

  TabBar _tabBarLabel() => TabBar(
        tabs: _tabItems(),
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        onTap: (index) {
          var content = "";
          switch (index) {
            case 0:
              content = "Promociones";
              break;
            case 1:
              content = "Categorias";
              break;
            case 2:
              content = "Carrito";
              break;
            case 3:
              content = "Listado";
              break;
            default:
              content = "Other";
              break;
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<UserRepository>(context);
    print('Usuario logueado: ${userData.userData.idCliente}');
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: DefaultTabController(
        length: 4,
        initialIndex: widget.index,
        child: StreamBuilder(
            stream: bloc.allTodo,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _showNotification(snapshot.data);
              }
              return Scaffold(
                  appBar: AppBar(
                    title: Text(userData.userData.nombre),
                    leading: LogOutButton(),
                    actions: <Widget>[
                      InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ShoppingBasket(),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed('/shoppingBasket');
                        },
                      ),
                    ],
                    bottom: _tabBarLabel(),
                  ),
                  body: Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: TabBarView(children: <Widget>[
                            ActiveOfferPage(),
                            CategoryPage(),
                            BlocCartPage(),
                            ShopListPage()
                          ]),
                        ),
                      )
                    ],
                  ));
            }),
      ),
    );
  }
}
