import 'package:image_picker/image_picker.dart';

class ItemCarrinho {
  final XFile imagem;
  final int quantidade;
  final double valor;
  final String? nome;

  ItemCarrinho(this.imagem, this.quantidade, this.valor, [this.nome]);

  Map<String, dynamic> toJson() => {
        'imagemPath': imagem.path,
        'quantidade': quantidade,
        'valor': valor,
        'nome': nome,
      };

  static Future<ItemCarrinho> fromJson(Map<String, dynamic> json) async {
    return ItemCarrinho(
      XFile(json['imagemPath']),
      json['quantidade'],
      json['valor'],
      json['nome'],
    );
  }
}
