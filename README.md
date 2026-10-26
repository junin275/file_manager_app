# 📁 FileManagerApp - Gerenciador de Arquivos Material 3

![Flutter](https://img.shields.io/badge/Flutter-3.47.8-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.13.7-blue?logo=dart)
![Android](https://img.shields.io/badge/Android-24%2B-green?logo=android)
![License](https://img.shields.io/badge/License-MIT-blue)
![Build](https://github.com/junin275/file_manager_app/actions/workflows/build.yml/badge.svg)

Um gerenciador de arquivos moderno, bonito e completo para Android, construído com **Flutter** e **Material Design 3**. Suporte total a tema claro/escuro, ZIP, busca, ordenação e seleção múltipla.

---

## ✨ Funcionalidades

| Funcionalidade | Descrição |
|----------------|-----------|
| 📂 **Navegação completa** | Pastas, voltar, breadcrumb na toolbar |
| 🔍 **Busca em tempo real** | Filtre arquivos/pastas instantaneamente |
| 📋 **Visualização dupla** | Lista compacta ou Grade com ícones grandes |
| ↕️ **Ordenação inteligente** | Por nome, tamanho, data ou tipo (asc/desc) |
| ✅ **Seleção múltipla** | Long press → checkboxes → ações em lote |
| 📦 **ZIP nativo** | Compactar selecionados / Descompactar qualquer ZIP |
| 🔗 **Compartilhar** | Share nativo do Android |
| ✏️ **Renomear / Excluir** | Com confirmação segura |
| 🌙 **Tema automático** | Material 3 Light / Dark / System |
| 🔐 **Permissões Android 13+** | `MANAGE_EXTERNAL_STORAGE` nativo |

---

## 📸 Capturas de Tela

<div align="center">
  <table>
    <tr>
      <td align="center"><strong>Lista (Light)</strong></td>
      <td align="center"><strong>Grade (Dark)</strong></td>
      <td align="center"><strong>Seleção + Bottom Bar</strong></td>
    </tr>
    <tr>
      <td>📱</td>
      <td>📱</td>
      <td>📱</td>
    </tr>
  </table>
</div>

---

## 🚀 Instalação

### APK Direto (Releases)
Baixe o APK mais recente na aba [**Releases**](https://github.com/junin275/file_manager_app/releases) ou nos **Artifacts** do [GitHub Actions](https://github.com/junin275/file_manager_app/actions).

```bash
# Via ADB
adb install file_manager_app-release.apk
```

### Compilar Localmente
```bash
# Pré-requisitos: Flutter 3.47.8+, Android SDK 34
git clone https://github.com/junin275/file_manager_app.git
cd file_manager_app
flutter pub get
flutter build apk --release
# APK em: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🏗️ Arquitetura

```
lib/
├── main.dart                           # App entry + temas Material 3
├── models/
│   └── file_item.dart                  # FileItem + FileType enum
├── providers/
│   └── file_manager_provider.dart      # State management (ChangeNotifier)
├── screens/
│   └── home_screen.dart                # Tela principal completa
├── utils/
│   └── zip_helper.dart                 # ZIP compress/decompress (archive)
└── widgets/
    ├── file_icon.dart                  # Ícones Material por tipo + cores
    ├── file_item.dart                  # ListTile + Grid item
    └── bottom_action_bar.dart          # Barra contextual (ações em lote)
```

**Padrões:** Provider (state), Material 3, Clean Architecture simplificada.

---

## 🎨 Design System

- **Cores:** Indigo primário (#6366F1) + Rosa secundário (#EC4899)
- **Tipografia:** Material 3 Type Scale (Display → Label)
- **Espaçamento:** 4dp base (4, 8, 12, 16, 20, 24, 32)
- **Raio:** 8/12/16dp (cards, botões, bottom sheets)
- **Ícones:** Material Icons por tipo de arquivo (imagem, vídeo, áudio, PDF, código, etc.)

---

## 🔧 Tecnologias

| Camada | Tecnologia |
|--------|------------|
| UI Framework | Flutter 3.47.8 |
| Language | Dart 3.13.7 |
| State | Provider 6.1.5 |
| ZIP | Archive 4.5.2 |
| Permissions | Permission Handler 11.3.1 |
| Path | Path 1.9.0 |
| Min SDK | Android 24 (7.0) |
| Target SDK | Android 34 (14) |

---

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

---

## 👨‍💻 Autor

**junin275** - [GitHub](https://github.com/junin275)

---

⭐ **Se gostou, deixe uma estrela no repositório!**