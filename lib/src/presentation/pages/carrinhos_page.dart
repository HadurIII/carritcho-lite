import 'dart:io';

import 'package:carritcholite/src/data/carrinhos_repository.dart';
import 'package:carritcholite/src/domain/carrinho.dart';
import 'package:carritcholite/src/presentation/controllers/carrinhos_controller.dart';
import 'package:carritcholite/src/presentation/pages/carrinho_atual_page.dart';
import 'package:flutter/material.dart';

class CarrinhosPage extends StatefulWidget {
  const CarrinhosPage({super.key});

  @override
  CarrinhosPageState createState() => CarrinhosPageState();
}

class CarrinhosPageState extends State<CarrinhosPage> {
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

  void novoCarrinho() {
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

        return carrinhos.isEmpty
            ? Center(child: Text('Nenhum carrinho ainda.'))
            : ListView.builder(
                itemCount: carrinhos.length,
                itemBuilder: (_, i) {
                  final c = carrinhos[i];
                  final imagem = c.imagemCapa;
                  final imagemFile =
                      imagem != null ? File(imagem.path) : null;
                  final imagemExiste =
                      imagemFile != null && imagemFile.existsSync();
                  return ListTile(
                    leading: imagemExiste
                        ? Image.file(
                            imagemFile!,
                            width: 50,
                            height: 50,
                            errorBuilder: (_, __, ___) =>
                                _buildImagemPlaceholder(50),
                          )
                        : (imagem != null
                            ? _buildImagemPlaceholder(50)
                            : null),
                    title: Text(c.nome),
                    subtitle: Text(
                      '${c.quantidadeTotal} itens - R\$ ${c.valorTotal.toStringAsFixed(2)}',
                    ),
                    onTap: () => _abrirCarrinho(c),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removerCarrinho(i),
                    ),
                  );
                },
              );
      },
    );
  }

  Widget _buildImagemPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 20),
    );
  }
}
