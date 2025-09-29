# 💸 Projeto Financeiro — Pós FIAP

Aplicativo Flutter desenvolvido para gerenciar transações financeiras pessoais, com autenticação segura, visualização gráfica de dados, armazenamento de imagens e integração completa com Firebase (Auth, Firestore e Storage).

## 👨‍💻 Autores

- [@Adler Coelho](https://www.linkedin.com/in/adlercoelhosantos/)
- [@Erick Nunes](https://www.linkedin.com/in/erick-nunes-bb81a9136/)
- [@Robson Rodrigues](https://www.linkedin.com/in/robson-rodrigues-ribeiro/)
- [@Luiz Paulo](https://www.linkedin.com/in/luizpaulocaldas/)
- [@Virgílio Cano](https://www.linkedin.com/in/virgiliocano/)

## 📦 Requisitos

- Flutter SDK instalado e configurado
- Dart SDK >= 3.8.1
- Conta Firebase com projeto configurado
- Android Studio ou VS Code com plugins Flutter/Dart

## 🚀 Instalação e Execução

 ```sh
 git clone https://github.com/coelhoadler/pos-fiap-FRNT-TC-financeiro-mobile.git
cd pos-fiap-FRNT-TC-financeiro-mobile
flutter pub get
flutter run
```

## 🧭 Estrutura do Projeto

   ```sh
   lib/
├── main.dart
├── assets/
│   └── svg/                # Ícones e ilustrações em SVG
├── components/
│   ├── screens/            # Widgets específicos de tela
│   └── ui/                 # Componentes visuais reutilizáveis
├── screens/
│   ├── dashboard.dart
│   ├── image_gallery.dart
│   ├── login.dart
│   ├── register.dart
│   └── transfers.dart
├── utils/
│   └── routes.dart         # Definição de rotas de navegação
assets/
└── icon/
    └── ic_logo.png         # Ícone base do app

   ```
Outros diretórios:

- android/, ios/, macos/: configurações específicas por plataforma
- test/: testes unitários e de widget

## 🔥 Firebase

O projeto usa Firebase para:

- Autenticação (firebase_auth)
- Banco de dados (cloud_firestore)
- Armazenamento de imagens (firebase_storage)

Inicialização no main.dart:
   ```sh
   await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## 📄 Arquivos YAML
pubspec.yaml

Define as dependências do projeto
```sh
dependencies:
  firebase_core: ^4.0.0
  firebase_auth: ^6.0.1
  cloud_firestore: ^6.0.1
  firebase_storage: ^13.0.0
  image_picker: ^1.2.0
  flutter_secure_storage: ^9.2.4
  flutter_multi_formatter: ^2.13.10
  fl_chart: ^1.1.0
  flutter_svg: ^2.0.7
  fluttertoast: ^8.2.4
  cupertino_icons: ^1.0.8
  collection: ^1.19.1

dev_dependencies:
  icons_launcher: ^3.0.3
  flutter_test:
  flutter_lints:
```
Inclui também configurações para geração de ícones

```sh
icons_launcher:
  image_path: 'assets/icon/ic_logo.png'
  platforms:
    android:
      enable: true
```
analysis_options.yaml

Define regras de lint para manter o código limpo e padronizado

```sh
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    avoid_print: true
    unnecessary_this: true
```

## 🔐 Permissões Android

```sh
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

### 🧪 Testes

Execute com

```sh
flutter test
```

## 🤝 Contribuição

1. Fork do projeto
2. Crie uma branch: git checkout -b feature/nome-da-feature
3. Commit: git commit -m 'Descrição da alteração'
4. Push: git push origin feature/nome-da-feature
5. Abra um Pull Request

### 📚 Recursos úteis

- Flutter Docs
- Dart Style Guide
- Firebase para Flutter
- Pub.dev
