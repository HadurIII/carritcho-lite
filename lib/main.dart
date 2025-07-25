import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() => runApp(CarrinhoApp());

class CarrinhoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrinhos',
      theme: ThemeData(primarySwatch: Colors.green),
      home: CarrinhosPage(),
    );
  }
}

class Carrinho {
  final List<ItemCarrinho> itens;
  Carrinho(this.itens);
  double get valorTotal =>
      itens.fold(0, (s, e) => s + (e.valor * e.quantidade));
  int get quantidadeTotal => itens.fold(0, (s, e) => s + e.quantidade);
  XFile? get imagemCapa => itens.isNotEmpty ? itens.first.imagem : null;
}

class ItemCarrinho {
  final XFile imagem;
  final int quantidade;
  final double valor;
  ItemCarrinho(this.imagem, this.quantidade, this.valor);
}

class CarrinhosPage extends StatefulWidget {
  @override
  _CarrinhosPageState createState() => _CarrinhosPageState();
}

class _CarrinhosPageState extends State<CarrinhosPage> {
  List<Carrinho> carrinhos = [];

  void _novoCarrinho() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarrinhoAtualPage(
          onCarrinhoFinalizado: (carrinho) {
            setState(() => carrinhos.add(carrinho));
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
            setState(() {
              final index = carrinhos.indexOf(carrinho);
              if (index != -1) {
                carrinhos[index] = novoCarrinho;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _novoCarrinho,
        child: Icon(Icons.add),
      ),
    );
  }
}

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
            onConfirmar: (quantidade, valor) {
              setState(() => itens.add(ItemCarrinho(foto, quantidade, valor)));
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
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
                  title: Text(
                      '${item.quantidade}x - R\$ ${item.valor.toStringAsFixed(2)}'),
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

class CadastroItemPage extends StatefulWidget {
  final XFile imagem;
  final void Function(int, double) onConfirmar;
  CadastroItemPage({required this.imagem, required this.onConfirmar});

  @override
  _CadastroItemPageState createState() => _CadastroItemPageState();
}

class _CadastroItemPageState extends State<CadastroItemPage> {
  final TextEditingController _quantidadeController =
      TextEditingController(text: '1');
  final TextEditingController _valorController =
      TextEditingController(text: '1.00');

  @override
  void dispose() {
    _quantidadeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _incrementarQuantidade() {
    int valor = int.tryParse(_quantidadeController.text) ?? 1;
    _quantidadeController.text = (valor + 1).toString();
    setState(() {});
  }

  void _decrementarQuantidade() {
    int valor = int.tryParse(_quantidadeController.text) ?? 1;
    _quantidadeController.text = (valor > 1 ? valor - 1 : 1).toString();
    setState(() {});
  }

  void _incrementarValor() {
    double valor =
        double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 1.0;
    _valorController.text = (valor + 1.0).toStringAsFixed(2);
    setState(() {});
  }

  void _decrementarValor() {
    double valor =
        double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 1.0;
    _valorController.text =
        (valor - 1.0).clamp(0.01, double.infinity).toStringAsFixed(2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro do Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.file(File(widget.imagem.path),
                height: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantidadeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Quantidade'),
                  ),
                ),
                IconButton(
                    onPressed: _decrementarQuantidade,
                    icon: Icon(Icons.remove)),
                IconButton(
                    onPressed: _incrementarQuantidade, icon: Icon(Icons.add)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valorController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Valor (R\$)'),
                  ),
                ),
                IconButton(
                    onPressed: _decrementarValor, icon: Icon(Icons.remove)),
                IconButton(onPressed: _incrementarValor, icon: Icon(Icons.add)),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final qtd = int.tryParse(_quantidadeController.text) ?? 1;
                final val = double.tryParse(
                        _valorController.text.replaceAll(',', '.')) ??
                    1.0;
                widget.onConfirmar(qtd, val);
              },
              child: Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}
