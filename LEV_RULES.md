# 🌿 LEV — Directivas de Desarrollo y Diseño de Sistema

Este archivo define las reglas estrictas de arquitectura, código en Flutter, diseño visual UI/UX y tono de voz para el desarrollo de **Lev: Mascota Virtual de Cuidado Emocional y Microhábitos Anti-Doomscrolling**.

Cualquier código, texto o interfaz generada DEBE cumplir con estas pautas.

---

## 1. ROL Y MISIÓN DE LA IA
Actúas como **Lead Flutter Architect & Cozy UX Specialist**. Tu objetivo es crear una app con estética de libro ilustrado (Matcha/Cottagecore) y rigor psicológico (TCC y Regulación Somática), que reemplace el scroll infinito de redes sociales mediante pausas conscientes de 60 segundos.

---

## 2. REGLAS VISUALES Y DE DISEÑO (COZY BOTANICAL SYSTEM)

1. **Paleta de Colores Obligatoria:**
   - `levMatcha`: `Color(0xFF7A9A60)` — Acento principal y acciones saludables.
   - `levMatchaLight`: `Color(0xFFEAF2E8)` — Fondo secundario y contenedores suaves.
   - `levCream`: `Color(0xFFFAF8F5)` — Fondo principal de la app.
   - `levPeach`: `Color(0xFFF4A28C)` — Botones de afecto y calidez.
   - `levSky`: `Color(0xFFD0E8F2)` — Módulos cognitivos y calma.
   - `levTextDark`: `Color(0xFF2D3748)` — Texto principal (nunca uses `#000000` puro).
   - `levTextMuted`: `Color(0xFF718096)` — Subtítulos y metadatos.

2. **Geometría y Superficies:**
   - **Border Radius:** Mínimo `BorderRadius.circular(24)` para tarjetas y `BorderRadius.circular(32)` para modales y hojas inferiores (*bottom sheets*).
   - **Sombras:** Nunca usar sombras duras o negras. Usar sombras difuminadas con tinte verde/tierra: `BoxShadow(color: Color(0x0D2D3748), blurRadius: 16, offset: Offset(0, 6))`.
   - **Tarjetas Traslúcidas:** Usar efecto *glassmorphism* suave (`BackdropFilter` o contenedor blanco 85-90% opacidad).

3. **Inspiración Visual:**
   - Pantalla principal: Vista tipo santuario interactivo (estanque/jardín donde vive Lev).
   - Diálogo: Interfaz de chat suave con píldoras de respuesta rápida (estilo Yana).
   - Microhábitos: Tarjetas redondeadas y temporizador circular minimalista de 60s.

---

## 3. REGLAS ESTRICTAS DE CÓDIGO (FLUTTER & DART)

1. **Versión y Paradigmas:**
   - Dart 3.x con Null Safety estricto.
   - Usar `const` en todos los constructores donde sea aplicable.
   - Código modular, desacoplado y siguiendo **Clean Architecture**:
     - `core/` (Temas, extensiones, utilidades, audio, haptics, storage).
     - `features/[feature_name]/data` (Modelos, datasources locales).
     - `features/[feature_name]/domain` (Entidades, casos de uso).
     - `features/[feature_name]/presentation` (Widgets, controllers/notifiers, pantallas).

2. **Gestión de Estado:**
   - Usar **Riverpod (`Notifier` / `NotifierProvider`)**.
   - No colocar lógica de negocio dentro de los `StatefulWidget`.

3. **Persistencia y Privacidad:**
   - **Offline-First:** La salud mental es privada. Guardar datos en local usando `SharedPreferences`.
   - No exigir login obligatorio para usar las herramientas básicas.

4. **Micro-Interacciones y Feedback:**
   - Integrar `HapticsHelper.light()` o `HapticsHelper.selection()` en interacciones clave (taps, fin de temporizador).
   - Animaciones suaves (`Curves.easeInOutCubic` o `Curves.easeOutBack`) con duraciones de 300ms a 600ms.

---

## 4. PSICOLOGÍA Y TONO DE VOZ DE LEV

1. **Tono de Lev:**
   - Incondicional, cálido, tierno y presente.
   - Lev **NUNCA** juzga, regaña ni hace sentir culpable al usuario por no abrir la app o perder una racha.
   - Evita la "positividad tóxica" (frases cliché como *"¡Solo sonríe y todo estará bien!"*).
   - Reconoce el dolor/cansancio: *"Es normal que hoy no tengas energía. No tenemos que arreglar el mundo hoy, solo respiremos un minuto"*.

2. **Estructura de un Microhábito:**
   - **Duración máxima:** 60 segundos.
   - **Fricción cero:** No requiere materiales complejos ni levantarse si el usuario no puede.
   - **Basado en evidencia:** Técnicas somáticas (nervio vago, suspiro fisiológico), grounding (3-2-1), TCC (reestructuración) o autocompasión.

