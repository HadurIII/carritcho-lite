# Carritcho Lite

Protótipo de app Flutter para registrar carrinhos com foto, quantidade e valor.

## Estrutura atual

- `lib/main.dart`: entrypoint atual do app.
- `lib/src/app`: bootstrap do `MaterialApp`.
- `lib/src/domain`: modelos de domínio.
- `lib/src/data`: persistência local com `SharedPreferences`.
- `lib/src/presentation`: páginas, controllers e fluxo de interface.

## Execução

```bash
flutter run -d edge
```

## Observação

O protótipo ainda usa armazenamento local simples e está sendo organizado em etapas.
