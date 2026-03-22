import 'package:flutter/material.dart';

import 'package:carritcholite/src/app/app.dart';
import 'package:carritcholite/src/presentation/pages/carrinhos_page.dart';

final GlobalKey<CarrinhosPageState> carrinhosPageKey =
    GlobalKey<CarrinhosPageState>();

// Current Flutter entrypoint for the app.
void main() => runApp(
      CarrinhoApp(
        home: CarrinhosPage(key: carrinhosPageKey),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            carrinhosPageKey.currentState?.novoCarrinho();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
