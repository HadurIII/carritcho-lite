import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
