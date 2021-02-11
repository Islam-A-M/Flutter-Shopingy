import 'package:flutter/material.dart';
import './helpers/custom_route.dart';
import './screens/splash_screen.dart';
import './screens/orders.dart';
import './providers/orders.dart';
import './screens/cart.dart';
import './screens/products_overview.dart';
import './screens/product_detail.dart';
import './providers/products.dart';
import 'package:provider/provider.dart';
import './providers/cart.dart' as cProvider;
import './screens/user_products.dart';
import './screens/edit_product.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart' as authProvider;
import 'helpers/keys.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => authProvider.Auth()),
        ChangeNotifierProxyProvider<authProvider.Auth, Products>(
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
          create: null,
        ),
        ChangeNotifierProvider(create: (ctx) => cProvider.Cart()),
        ChangeNotifierProxyProvider<authProvider.Auth, Orders>(
          update: (ctx, auth, previousOders) => Orders(auth.token, auth.userId,
              previousOders == null ? [] : previousOders.orders),
          create: null,
        ),
      ],
      child: Consumer<authProvider.Auth>(
        builder: (ctx, auth, child) => MaterialApp(
          navigatorKey: Keys.navKey,
          title: 'Flutter Demo',
          theme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            }),
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
            accentColor: Colors.blueAccent,
            fontFamily: 'Lato',
            errorColor: Colors.red,
            // This makes the visual density adapt to the platform that you run
            // the app on. For desktop platforms, the controls will be smaller and
            // closer together (more dense) than on mobile platforms.
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                  future: auth.tryAutoSignin(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeNamee: (ctx) => EditProductScreen(),
            //AuthScreen.routeName: (ctx) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
