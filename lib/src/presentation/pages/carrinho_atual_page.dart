import 'dart:io';

import 'package:carritcholite/src/domain/carrinho.dart';
import 'package:carritcholite/src/domain/item_carrinho.dart';
import 'package:carritcholite/src/presentation/pages/cadastro_item_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
    try {
      final foto = await picker.pickImage(source: ImageSource.camera);
      if (foto == null) {
        return;
      }
      final fotoPersistida = await _persistirImagem(foto);
      if (!mounted) {
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CadastroItemPage(
            imagem: fotoPersistida,
            onConfirmar: (quantidade, valor, nome) {
              setState(() => itens
                  .add(ItemCarrinho(fotoPersistida, quantidade, valor, nome)));
              Navigator.pop(context);
            },
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nao foi possivel abrir a camera. Verifique as permissoes.',
          ),
        ),
      );
    }
  }

  Future<XFile> _persistirImagem(XFile foto) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final imagensDir = Directory('${baseDir.path}${Platform.pathSeparator}imagens');
    if (!await imagensDir.exists()) {
      await imagensDir.create(recursive: true);
    }
    final extension = _extrairExtensao(foto.path);
    final nomeArquivo =
        'item_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final novoPath =
        '${imagensDir.path}${Platform.pathSeparator}$nomeArquivo';
    final arquivoCopiado = await File(foto.path).copy(novoPath);
    return XFile(arquivoCopiado.path);
  }

  String _extrairExtensao(String path) {
    final ponto = path.lastIndexOf('.');
    if (ponto == -1 || ponto == path.length - 1) {
      return 'jpg';
    }
    return path.substring(ponto + 1);
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
                final imagemFile = File(item.imagem.path);
                final imagemExiste = imagemFile.existsSync();
                return ListTile(
                  leading: imagemExiste
                      ? Image.file(
                          imagemFile,
                          width: 50,
                          height: 50,
                          errorBuilder: (_, __, ___) =>
                              _buildImagemPlaceholder(50),
                        )
                      : _buildImagemPlaceholder(50),
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

  Widget _buildImagemPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 20),
    );
  }
}
