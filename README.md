# Lev 🌿🧠 — Mental Health & Micro-Habit Companion

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/State-Flutter%20Riverpod%203.4.3-blueviolet)](https://riverpod.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-teal)]()
[![Author](https://img.shields.io/badge/Studio-Inventus%20Tech-orange)]()

> **Lev** es un compañero digital de salud mental y construcción de micro-hábitos enfocado en la introspección personal y el bienestar psicológico. Desarrollado con los más altos estándares de ingeniería de software mediante **Flutter Riverpod** y **Clean Architecture**, ofrece una experiencia cálida, privada y 100% offline-first.

---

## 🌟 Características Principales

* **Clean Architecture por Capas Estrictas:**
  * Separación absoluta entre la capa de dominio (*Domain*), la capa de presentación (*Presentation*) y la capa de infraestructura (*Core/Storage*).
* **Gestión de Estado Moderna con Riverpod 3:**
  * Uso de `ProviderScope`, generadores y controladores de estado reactivos que facilitan el desacoplamiento y la testeabilidad.
* **Registro de Estados de Ánimo & Introspección Emocional:**
  * Calibración diaria de energía, estado de ánimo y detonantes emocionales (*Triggers*).
  * Historial gráfico de evolución anímica a lo largo de las semanas.
* **Micro-Hábitos de Bajo Fricción:**
  * Enfoque pedagógico basado en micro-pasos para evitar la sobrecarga cognitiva.
* **Privacidad Absoluta & Almacenamiento Offline-First:**
  * Todos los registros de salud mental y reflexiones personales se almacenan exclusivamente en el dispositivo del usuario de forma local (`LocalStorageService`), sin intermediarios ni rastreo.

---

## 🏗️ Estructura del Código

```
Lev/
├── lib/
│   ├── core/
│   │   ├── storage/
│   │   │   └── local_storage_service.dart # Abstracción de almacenamiento local offline-first
│   │   ├── theme/
│   │   │   └── lev_theme.dart             # Sistema de diseño, paleta suave y tipografía
│   │   └── utils/
│   │       └── date_utils.dart            # Localización en español y formateo de fechas
│   ├── features/
│   │   ├── home/
│   │   │   ├── presentation/
│   │   │   │   ├── main_navigation_wrapper.dart # Navegación principal por tabs
│   │   │   │   ├── controllers/                 # Notifiers y StateProviders de Riverpod
│   │   │   │   └── widgets/                     # Componentes UI reutilizables
│   │   │   └── domain/
│   │   │       └── models/                      # Entidades puras de hábitos y estados
│   └── main.dart                                # Entrada principal con ProviderScope
```

---

## 🚀 Puesta en Marcha

```bash
cd Lev
flutter pub get
flutter run
```

---

**Desarrollado por Inventus Tech Studio** • *Liderado por Samuel Henríquez*
