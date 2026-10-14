# clubcash

Aplicativo Flutter de cashback por pontos para o comércio local.

---

## 1) Visão Geral
- Usuários registram compras em empresas parceiras
- As empresas aprovam ou recusam as compras
- Pontos são creditados após aprovação
- Pontos podem ser trocados por produtos ou serviços
- Não há saque em dinheiro

---

## 2) Plataformas
- Flutter Mobile (Android / iOS)
- Flutter Web (Admin e Portal do Parceiro)

---

## 3) Stack Principal
- Flutter
- Firebase Auth
- Cloud Firestore
- Firebase Storage
- Cloud Functions
- Firebase Cloud Messaging
- Crashlytics / Analytics / Logging

Regra:
- O app não altera saldo, pontos ou status críticos diretamente
- Toda regra sensível passa por Cloud Functions

---

## 4) Papéis do Sistema
- Customer (usuário)
- Partner (empresa parceira)
- Admin (gestão e auditoria)

Responsabilidades:
- Customer: registra compras e resgata pontos
- Partner: aprova ou recusa compras do seu parceiro
- Admin: gerencia empresas, recompensas e auditoria

---

## 5) Estrutura do Projeto

```
lib/
  app/
    app.dart
    bootstrap.dart
    router.dart
    theme/
    localization/
  core/
    config/
      env.dart
      flavors.dart
    constants/
    errors/
      app_exception.dart
      failure.dart
    logging/
    utils/
    widgets/
  features/
    auth/
      data/
      domain/
      presentation/
    onboarding/
      presentation/
    home/
      presentation/
    partners/
      data/
      domain/
      presentation/
    purchases/
      data/
      domain/
      presentation/
    ledger/
      data/
      domain/
      presentation/
    rewards/
      data/
      domain/
      presentation/
    profile/
      presentation/
    admin/
      data/
      domain/
      presentation/
    partner_portal/
      data/
      domain/
      presentation/
  services/
    firebase/
      firebase_init.dart
      firestore_refs.dart
      storage_service.dart
      functions_service.dart
      auth_service.dart
  main.dart
  main_dev.dart
  main_prod.dart
```

---

## 6) Organização por Feature
Cada feature segue o padrão:
- `presentation/`: UI, páginas e controllers
- `domain/`: entidades e regras de negócio
- `data/`: repositórios, Firebase e DTOs

---

## 7) Fluxo Principal
- Registrar compra → status `pending`
- Aprovação ou recusa pela empresa parceira
- Crédito de pontos via ledger
- Resgate de pontos
- Geração de voucher

---

## 8) Modelo de Pontos (Ledger)
Tipos de evento:
- `earn`: crédito de pontos
- `burn`: resgate de pontos
- `reversal`: ajuste manual

Observações:
- Ledger é imutável
- O saldo exibido é apenas cache
- A fonte de verdade é sempre o ledger

---

## 9) Ambientes
- **DEV**: desenvolvimento e testes
- **PROD**: produção

Controle por:
- `main_dev.dart`
- `main_prod.dart`
- Firebase separado por ambiente

---

## 10) CI / Qualidade
CI básico configurado:
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

Regras:
- Pull Request obrigatório para `develop` e `main`
- CI deve estar verde para merge

---

## 11) Execução Local

```bash
flutter pub get
flutter run --dart-define=APP_ENV=dev
```

---

## 12) Documentação

Os documentos técnicos do projeto ficam na pasta `/docs`.

Conteúdo esperado:
- Arquitetura técnica
- Padrões de desenvolvimento
- Ambientes e configurações
- Decisões técnicas relevantes

---

## 13) Padrões de Nome e Organização

Padrões adotados no projeto:

- Pastas e arquivos: `snake_case`
- Classes: `PascalCase`
- Providers / Controllers: `*_controller.dart`
- Telas (Pages): `*_page.dart`
- Widgets menores: `*_widget.dart`
- Models do domínio: `entities/`
- Models Firestore / DTOs: `dtos/`

---

## 14) Stack de Dependências

### Estado e Injeção de Dependência
- `riverpod`
- `flutter_riverpod`
- (opcional) `riverpod_annotation`
- `build_runner`

### Rotas
- `go_router`
  (redirect por autenticação e role)

### Models e Serialização
- `freezed`
- `json_serializable`
- (opcional) `equatable`

### Firebase
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`
- `cloud_functions`

### UX e Utilitários
- `intl`
- `image_picker`
- `flutter_image_compress`
- `file_picker`
- `cached_network_image`
