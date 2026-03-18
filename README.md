# Lista de Compras

Aplicativo **mobile** desenvolvido em **Flutter**, utilizando a arquitetura **MVVM (Model–View–ViewModel)** e **SQLite** para armazenamento local.

O objetivo do projeto é gerenciar listas de compras de forma organizada, permitindo o controle de itens por setores e o acompanhamento dos produtos já adquiridos.

---

## 📚 Descrição do Projeto

O sistema tem como finalidade o **gerenciamento completo de listas de compras**, permitindo a criação e organização de itens agrupados por setores, além do acompanhamento em tempo real dos produtos já adquiridos durante a compra.

A aplicação foi desenvolvida seguindo a arquitetura **MVVM (Model–View–ViewModel)**, separando responsabilidades entre a interface, a lógica de negócio e o acesso aos dados, garantindo um código mais organizado e de fácil manutenção.

Todos os dados são **persistidos localmente no dispositivo** utilizando **SQLite**, garantindo que as listas sejam mantidas mesmo após fechar o aplicativo.

---

## 🎯 Funcionalidades

- ✅ Criação, edição e exclusão de listas de compras
- ✅ Organização de itens por setores
- ✅ Marcação de itens como comprados
- ✅ Persistência dos dados com SQLite
- ✅ Recuperação automática das listas ao reabrir o app

---

## 🛠️ Tecnologias Utilizadas

- Flutter
- Dart
- SQLite
- Arquitetura MVVM

---

## ▶️ Como Executar o Projeto

### Pré-requisitos

- Flutter SDK 3.x ou superior
- Dart SDK
- Android Studio ou VS Code com extensão Flutter

### Passos para execução

1. Clonar o repositório:

   ```bash
   git clone https://github.com/eduardoalmeidajesus/lista_compras
   ```

2. Acessar a pasta do projeto:

   ```bash
   cd lista_compras
   ```

3. Instalar as dependências:

   ```bash
   flutter pub get
   ```

4. Executar o app:

   ```bash
   flutter run
   ```
