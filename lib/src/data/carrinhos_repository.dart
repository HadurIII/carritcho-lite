import 'dart:convert';

import 'package:carritcholite/src/domain/carrinho.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarrinhosRepository {
  static const String _storageKey = 'carrinhos';

  Future<List<Carrinho>> carregarCarrinhos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrList = prefs.getStringList(_storageKey) ?? [];
    final lista = <Carrinho>[];

    for (final s in jsonStrList) {
      final jsonObj = json.decode(s);
      lista.add(await Carrinho.fromJson(jsonObj));
    }

    return lista;
  }

  Future<void> salvarCarrinhos(List<Carrinho> carrinhos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrList = carrinhos.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonStrList);
  }
}
