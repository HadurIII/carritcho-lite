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
  late String nomeCarrinho;
  final TextEditingController _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    itens = List<ItemCarrinho>.from(widget.carrinhoExistente?.itens ?? []);
    nomeCarrinho = widget.carrinhoExistente?.nome ?? 'Novo carrinho';
    _nomeController.text = nomeCarrinho;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
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

  Future<void> _editarNomeCarrinho() async {
    _nomeController.text = nomeCarrinho;

    final novoNome = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar nome do carrinho'),
          content: TextField(
            controller: _nomeController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome do carrinho',
            ),
            onSubmitted: (_) {
              Navigator.of(dialogContext).pop(_nomeController.text.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(_nomeController.text.trim()),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (novoNome == null || novoNome.isEmpty) {
      return;
    }

    setState(() {
      nomeCarrinho = novoNome;
      _nomeController.text = novoNome;
    });
  }

  void _removerItem(int index) {
    setState(() => itens.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _editarNomeCarrinho,
          child: Text(nomeCarrinho),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              widget.onCarrinhoFinalizado(
                Carrinho(nomeCarrinho, List<ItemCarrinho>.from(itens)),
              );
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
