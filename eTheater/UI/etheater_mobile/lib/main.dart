import 'package:etheater_mobile/providers/predstava_provider.dart';
import 'package:etheater_mobile/screens/home.dart';
import 'package:etheater_mobile/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importuj Provider

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PredstavaProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFB02D2F),
        ), // Koristi hex boju #B02D2F
        useMaterial3: true, // Opcionalno, za Material 3 stilove
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxHeight: 400, minWidth: 400),
            child: Card(
              child: Column(
                children: [
                  Image.asset("assets/images/logo.png", height: 100),
                  Container(
                    height: 200,

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextField(
                          decoration: InputDecoration(labelText: "Username"),
                          controller: _usernameController,
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: "Password"),
                          controller: _passwordController,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            var username = _usernameController.text;
                            var password = _passwordController.text;
                            print("usernam3 $username");
                            print("password $password");

                            Authorization.username = username;
                            Authorization.password = password;

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const Home(),
                              ),
                            );
                          },
                          child: Text("Login"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Login")),
//       body: Center(
//         child: Container(
//           constraints: const BoxConstraints(maxHeight: 400, minWidth: 400),
//           padding: const EdgeInsets.all(20),
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             elevation: 5,
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Logo
//                   Image.asset("assets/images/logo.png", height: 100),
//                   const SizedBox(height: 20),

//                   // Username input
//                   TextField(
//                     decoration: InputDecoration(
//                       labelText: "Username",
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.person),
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // Password input
//                   TextField(
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       labelText: "Password",
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.lock),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Login button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Ovdje možeš dodati login logiku
//                       },
//                       child: const Text("Login"),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
