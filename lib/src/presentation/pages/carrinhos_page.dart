import 'dart:io';

import 'package:carritcholite/src/data/carrinhos_repository.dart';
import 'package:carritcholite/src/domain/carrinho.dart';
import 'package:carritcholite/src/presentation/controllers/carrinhos_controller.dart';
import 'package:carritcholite/src/presentation/pages/carrinho_atual_page.dart';
import 'package:flutter/material.dart';

class CarrinhosPage extends StatefulWidget {
  @override
  _CarrinhosPageState createState() => _CarrinhosPageState();
}

class _CarrinhosPageState extends State<CarrinhosPage> {
  final CarrinhosController _controller =
      CarrinhosController(CarrinhosRepository());

  @override
  void initState() {
    super.initState();
    _controller.carregarCarrinhos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _novoCarrinho() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarrinhoAtualPage(
          onCarrinhoFinalizado: (carrinho) {
            _controller.adicionarCarrinho(carrinho);
          },
        ),
      ),
    );
  }

  void _abrirCarrinho(Carrinho carrinho) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarrinhoAtualPage(
          carrinhoExistente: carrinho,
          onCarrinhoFinalizado: (novoCarrinho) {
            _controller.atualizarCarrinho(carrinho, novoCarrinho);
          },
        ),
      ),
    );
  }

  void _removerCarrinho(int index) {
    _controller.removerCarrinho(index);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final carrinhos = _controller.carrinhos;

        return Scaffold(
          appBar: AppBar(title: Text('Carrinhos')),
          body: carrinhos.isEmpty
              ? Center(child: Text('Nenhum carrinho ainda.'))
              : ListView.builder(
                  itemCount: carrinhos.length,
                  itemBuilder: (_, i) {
                    final c = carrinhos[i];
                    return ListTile(
                      leading: c.imagemCapa != null
                          ? Image.file(File(c.imagemCapa!.path),
                              width: 50, height: 50)
                          : null,
                      title: Text('${c.quantidadeTotal} itens'),
                      subtitle: Text('R\$ ${c.valorTotal.toStringAsFixed(2)}'),
                      onTap: () => _abrirCarrinho(c),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removerCarrinho(i),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _novoCarrinho,
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
