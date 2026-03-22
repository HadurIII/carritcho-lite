import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

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

class CarrinhosPage extends StatefulWidget {
  @override
  _CarrinhosPageState createState() => _CarrinhosPageState();
}

class _CarrinhosPageState extends State<CarrinhosPage> {
  List<Carrinho> carrinhos = [];

  @override
  void initState() {
    super.initState();
    _carregarCarrinhos();
  }

  Future<void> _carregarCarrinhos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrList = prefs.getStringList('carrinhos') ?? [];
    final lista = <Carrinho>[];
    for (var s in jsonStrList) {
      final jsonObj = json.decode(s);
      lista.add(await Carrinho.fromJson(jsonObj));
    }
    setState(() => carrinhos = lista);
  }

  Future<void> _salvarCarrinhos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrList = carrinhos.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList('carrinhos', jsonStrList);
  }

  void _novoCarrinho() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarrinhoAtualPage(
          onCarrinhoFinalizado: (carrinho) {
            setState(() => carrinhos.add(carrinho));
            _salvarCarrinhos();
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
            _salvarCarrinhos();
          },
        ),
      ),
    );
  }

  void _removerCarrinho(int index) {
    setState(() => carrinhos.removeAt(index));
    _salvarCarrinhos();
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

class CadastroItemPage extends StatefulWidget {
  final XFile imagem;
  final void Function(int, double, String?) onConfirmar;
  CadastroItemPage({required this.imagem, required this.onConfirmar});

  @override
  _CadastroItemPageState createState() => _CadastroItemPageState();
}

class _CadastroItemPageState extends State<CadastroItemPage> {
  final TextEditingController _quantidadeController =
      TextEditingController(text: '1');
  final TextEditingController _valorController =
      TextEditingController(text: '1.00');
  final TextEditingController _nomeController = TextEditingController();

  @override
  void dispose() {
    _quantidadeController.dispose();
    _valorController.dispose();
    _nomeController.dispose();
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
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome (opcional)'),
            ),
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
                final nome = _nomeController.text.trim().isEmpty
                    ? null
                    : _nomeController.text.trim();
                widget.onConfirmar(qtd, val, nome);
              },
              child: Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}
