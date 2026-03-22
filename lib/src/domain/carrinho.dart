import 'package:carritcholite/src/domain/item_carrinho.dart';
import 'package:image_picker/image_picker.dart';

class Carrinho {
  final List<ItemCarrinho> itens;

  Carrinho(this.itens);

  double get valorTotal =>
      itens.fold(0, (s, e) => s + (e.valor * e.quantidade));

  int get quantidadeTotal => itens.fold(0, (s, e) => s + e.quantidade);

  XFile? get imagemCapa => itens.isNotEmpty ? itens.first.imagem : null;

  Map<String, dynamic> toJson() => {
        'itens': itens.map((e) => e.toJson()).toList(),
      };

  static Future<Carrinho> fromJson(Map<String, dynamic> json) async {
    final itens = <ItemCarrinho>[];
    for (var e in json['itens']) {
      itens.add(await ItemCarrinho.fromJson(e));
    }
    return Carrinho(itens);
  }
}
