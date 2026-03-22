import 'package:carritcholite/src/data/carrinhos_repository.dart';
import 'package:carritcholite/src/domain/carrinho.dart';
import 'package:flutter/foundation.dart';

class CarrinhosController extends ChangeNotifier {
  CarrinhosController(this._repository);

  final CarrinhosRepository _repository;
  final List<Carrinho> _carrinhos = [];
  bool _isDisposed = false;

  List<Carrinho> get carrinhos => List.unmodifiable(_carrinhos);

  Future<void> carregarCarrinhos() async {
    final lista = await _repository.carregarCarrinhos();
    if (_isDisposed) {
      return;
    }

    _carrinhos
      ..clear()
      ..addAll(lista);
    _notifyListenersSafely();
  }

  Future<void> adicionarCarrinho(Carrinho carrinho) async {
    _carrinhos.add(carrinho);
    _notifyListenersSafely();
    await _repository.salvarCarrinhos(_carrinhos);
  }

  Future<void> atualizarCarrinho(Carrinho carrinhoAntigo, Carrinho novoCarrinho) async {
    final index = _carrinhos.indexOf(carrinhoAntigo);
    if (index == -1) {
      return;
    }

    _carrinhos[index] = novoCarrinho;
    _notifyListenersSafely();
    await _repository.salvarCarrinhos(_carrinhos);
  }

  Future<void> removerCarrinho(int index) async {
    if (index < 0 || index >= _carrinhos.length) {
      return;
    }

    _carrinhos.removeAt(index);
    _notifyListenersSafely();
    await _repository.salvarCarrinhos(_carrinhos);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _notifyListenersSafely() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
