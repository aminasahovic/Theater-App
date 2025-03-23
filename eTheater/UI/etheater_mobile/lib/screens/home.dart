import 'package:etheater_mobile/providers/predstava_provider.dart';
import 'package:etheater_mobile/utils/utils.dart';
import 'package:etheater_mobile/widgets/master_screen.dart';
import 'package:etheater_mobile/widgets/predstava_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PredstavaProvider _predstavaProvider;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _predstavaProvider = context.read<PredstavaProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      child: Container(
        child: Column(
          children: [
            Text("data"),
            ElevatedButton(
              onPressed: () => {Navigator.of(context).pop()},
              child: Text("Login"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => const PredstavaDetailScreen(),
                //   ),
                // ),
                print("kliknut");
                print(Authorization.username);

                var data = await _predstavaProvider.get();
                print(data);
              },
              child: Text("Detail"),
            ),
          ],
        ),
      ),
    );
  }
}
