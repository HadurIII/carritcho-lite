import 'dart:io';

import 'package:carritcholite/src/domain/carrinho.dart';
import 'package:carritcholite/src/domain/item_carrinho.dart';
import 'package:carritcholite/src/presentation/pages/cadastro_item_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CarrinhoAtualPage extends StatefulWidget {
  final Carrinho? carrinhoExistente;
  final void Function(Carrinho) onCarrinhoFinalizado;

  CarrinhoAtualPage(
      {this.carrinhoExistente, required this.onCarrinhoFinalizado});

  @override
  _CarrinhoAtualPageState createState() => _CarrinhoAtualPageState();
}

class _CarrinhoAtualPageState extends State<CarrinhoAtualPage> {
  late List<ItemCarrinho> itens;

  @override
  void initState() {
    super.initState();
    itens = List<ItemCarrinho>.from(widget.carrinhoExistente?.itens ?? []);
  }

  void _tirarFoto() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CadastroItemPage(
            imagem: foto,
            onConfirmar: (quantidade, valor, nome) {
              setState(
                  () => itens.add(ItemCarrinho(foto, quantidade, valor, nome)));
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
  }

  void _removerItem(int index) {
    setState(() => itens.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrinho Atual'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              widget.onCarrinhoFinalizado(Carrinho(itens));
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: itens.isEmpty
          ? Center(child: Text('Nenhum item ainda.'))
          : ListView.builder(
              itemCount: itens.length,
              itemBuilder: (_, i) {
                final item = itens[i];
                return ListTile(
                  leading:
                      Image.file(File(item.imagem.path), width: 50, height: 50),
                  title: Text(item.nome != null && item.nome!.isNotEmpty
                      ? '${item.nome}'
                      : '${item.quantidade}x - R\$ ${item.valor.toStringAsFixed(2)}'),
                  subtitle: item.nome != null && item.nome!.isNotEmpty
                      ? Text(
                          '${item.quantidade}x - R\$ ${item.valor.toStringAsFixed(2)}')
                      : null,
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removerItem(i),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tirarFoto,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
