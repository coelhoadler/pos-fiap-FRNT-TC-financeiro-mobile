# 💸 Projeto Financeiro — Pós FIAP

Aplicativo Flutter para visualizar e gerenciar as principais **transações financeiras** de um usuário, com autenticação, armazenamento seguro, gráficos e integração com Firebase (Auth, Firestore e Storage).

## 👨‍💻 Autores do projeto

- [@Adler Coelho](https://www.linkedin.com/in/adlercoelhosantos/)
- [@Erick Nunes](https://www.linkedin.com/in/erick-nunes-bb81a9136/)
- [@Robson Rodrigues](https://www.linkedin.com/in/robson-rodrigues-ribeiro/)
- [@Luiz Paulo](https://www.linkedin.com/in/luizpaulocaldas/)
- [@Virgílio Cano](https://www.linkedin.com/in/virgiliocano/)

## Sumário

- [Requisitos](#requisitos)
- [Instalação](#instalação)
- [Execução](#execução)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Configuração do Firebase](#configuração-do-firebase)
- [Dependências e propósito](#dependências-e-propósito)
- [Permissões por plataforma](#permissões-por-plataforma)
- [Ícone do app](#ícone-do-app)
- [Testes](#testes)
- [Contribuição](#contribuição)
- [Recursos úteis](#recursos-úteis)

## Requisitos

- Flutter instalado (Stable) e configurado no PATH
- Dart SDK compatível com `>= 3.8.1` (fornecido pelo Flutter)
- Conta Firebase com projeto configurado (para Auth/Firestore/Storage)

## Instalação

1. Instale o [Flutter](https://docs.flutter.dev/get-started/install).
2. Clone o repositório:
   ```sh
   git clone https://github.com/coelhoadler/pos-fiap-FRNT-TC-financeiro-mobile.git
   cd pos-fiap-FRNT-TC-financeiro-mobile
   ```
3. Instale as dependências do projeto:
   ```sh
   flutter pub get
   ```

## Execução

Para rodar o app:

- Android/iOS:
  ```sh
  flutter run
  ```

## Estrutura do Projeto

```
lib/
  main.dart
  assets/
    svg/
  components/
    screens/
    ui/
  screens/
    dashboard.dart
    image_gallery.dart
    login.dart
    register.dart
    transfers.dart
  utils/
    routes.dart
assets/
  icon/
    ic_logo.png
android/
ios/
macos/
test/
```

- `lib/screens`: Telas principais do app (dashboard, login, transferências, etc.).
- `lib/components`: Componentes reutilizáveis e UI.
- `lib/utils/routes.dart`: Mapeamento de rotas de navegação.
- `lib/assets/svg`: Ícones e ilustrações em SVG usados na UI.
- `assets/icon/ic_logo.png`: Base do ícone do aplicativo (usado pelo gerador de ícones).

## Configuração do Firebase

O projeto utiliza Firebase para autenticação, banco de dados e arquivos.

1. Crie um projeto no Firebase console e adicione os apps (Android, iOS, Web se necessário).
2. Android: coloque o `google-services.json` em `android/app/` (já presente no repo). iOS: adicione `GoogleService-Info.plist` ao Runner.
3. (Recomendado) Gere o arquivo `firebase_options.dart` via [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/):
   - Ative a CLI: `dart pub global activate flutterfire_cli`
   - Configure: `flutterfire configure`
4. Inicialize o Firebase no `main.dart` antes do `runApp(...)`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

## Dependências e propósito

Principais pacotes utilizados (conforme `pubspec.yaml`):

- firebase_core ^4.0.0 — Inicialização do Firebase
  - https://pub.dev/packages/firebase_core
- firebase_auth ^6.0.1 — Autenticação de usuários (e-mail/senha, etc.)
  - https://pub.dev/packages/firebase_auth
- cloud_firestore ^6.0.1 — Banco de dados NoSQL em tempo real
  - https://pub.dev/packages/cloud_firestore
- firebase_storage ^13.0.0 — Upload/Download de arquivos (imagens, etc.)
  - https://pub.dev/packages/firebase_storage
- image_picker ^1.2.0 — Seleção de imagens/arquivos da galeria e câmera
  - https://pub.dev/packages/image_picker
- flutter_secure_storage ^9.2.4 — Armazenamento seguro (tokens, chaves)
  - https://pub.dev/packages/flutter_secure_storage
- flutter_multi_formatter ^2.13.10 — Máscaras e formatações (ex.: moeda)
  - https://pub.dev/packages/flutter_multi_formatter
- fl_chart ^1.1.0 — Gráficos para dashboards financeiros
  - https://pub.dev/packages/fl_chart
- flutter_svg ^2.0.7 — Renderização de SVG
  - https://pub.dev/packages/flutter_svg
- fluttertoast ^8.2.4 — Toasts simples para feedback ao usuário
  - https://pub.dev/packages/fluttertoast
- cupertino_icons ^1.0.8 — Conjunto de ícones estilo iOS
  - https://pub.dev/packages/cupertino_icons
- collection ^1.19.1 — Utilitários extra para coleções Dart
  - https://pub.dev/packages/collection

Dev dependencies:

- icons_launcher ^3.0.3 — Geração de ícone do app multi-plataforma
  - https://pub.dev/packages/icons_launcher
- flutter_test — Testes de unidade e widget
  - https://docs.flutter.dev/cookbook/testing/unit/introduction
- flutter_lints — Regras de lint recomendadas
  - https://pub.dev/packages/flutter_lints

### Dicas rápidas de uso

- Image Picker: para selecionar múltiplas imagens, use `pickMultiImage()` e trate permissões.
- Flutter Secure Storage: use para tokens/sessões; evite armazenar dados sensíveis em preferências simples.
- FL Chart: envolva o gráfico em `SizedBox` com altura fixa para evitar layouts infinitos.
- Flutter SVG: prefira assets otimizados; referencie em `pubspec.yaml` (ex.: `lib/assets/svg/logo-bytebank.svg`).

## Permissões por plataforma

Alguns recursos exigem permissões do sistema.

### Android

- Image Picker / Câmera e Galeria:
  - Android 13+: `READ_MEDIA_IMAGES` (para ler imagens) e `CAMERA` (se usar câmera).
  - Versões anteriores: `READ_EXTERNAL_STORAGE`/`WRITE_EXTERNAL_STORAGE` (se necessário) e `CAMERA`.
  - Declare em `AndroidManifest.xml` e trate o fluxo de permissão em tempo de execução quando aplicável.
- Firebase: mantenha o `google-services.json` em `android/app/` e o plugin do Google Services aplicado no `build.gradle` do módulo app.

## Ícone do app

O projeto usa o `icons_launcher` com a imagem base em `assets/icon/ic_logo.png`.

Configuração (já presente no `pubspec.yaml`):

```yaml
icons_launcher:
  image_path: 'assets/icon/ic_logo.png'
  platforms:
    android:
      enable: true
```

Gerar ícones:

```sh
dart run icons_launcher:create
```

## Testes

Execute os testes com:

```sh
flutter test
```

## Contribuição

1. Faça um fork do projeto.
2. Crie uma branch (`git checkout -b feature/nome-da-feature`).
3. Commit suas alterações (`git commit -m 'Descrição da alteração'`).
4. Faça push (`git push origin feature/nome-da-feature`).
5. Abra um Pull Request.

## Recursos úteis

- [Documentação Flutter](https://docs.flutter.dev/)
- [Guia de Estilo Dart](https://dart.dev/guides/language/effective-dart/style)
- [FlutterFire (Firebase no Flutter)](https://firebase.flutter.dev/)
- [Pacotes no pub.dev](https://pub.dev/)