# Checklist de ASO — Apple App Store y Google Play

Checklist de App Store Optimization para creadores de apps y agentes de IA. Actualizada: **2026-10-01**.
Forma parte de la [skill `aso`](https://github.com/shipflutter/skills/tree/develop/skills/aso) de [ShipFlutter](https://shipflutter.app) · MIT.

> Esta es una traducción. La referencia es el original en inglés, y los ID de los puntos son los mismos en todos los idiomas: <https://github.com/shipflutter/skills/blob/develop/skills/aso/ASO-CHECKLIST.md>

- Ver: <https://github.com/shipflutter/skills/blob/develop/skills/aso/i18n/ASO-CHECKLIST.es.md>
- Sin formato (para agentes): <https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/i18n/ASO-CHECKLIST.es.md>
- Instalar la skill completa: `npx skills add shipflutter/skills --skill aso`

---

## Si eres un agente de IA, lee esto primero

1. **El modo predeterminado es auditar.** Lee la ficha, marca cada punto de abajo e informa. Edita archivos
   solo si el usuario pidió correcciones. **Nunca subas nada a App Store Connect / Play Console ni lo envíes
   a revisión** salvo que el usuario lo haya pedido en esta conversación.
2. **Encuentra la ficha.** fastlane: `fastlane/metadata/ios/<locale>/*.txt` (o
   `fastlane/metadata/<locale>/`) y `fastlane/metadata/android/<locale>/*.txt`. Si no existe, pide
   al usuario que pegue nombre / subtítulo / palabras clave / descripción de cada idioma, o el título /
   la descripción breve / la descripción completa de Play.
3. **Cuenta con código, nunca a ojo.** Los puntos marcados **(auto)** los comprueba el script gratuito:
   ```bash
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/aso_check.py
   python3 aso_check.py --root .            # markdown report; exit 1 on errors
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/keyword_suggest.py
   python3 keyword_suggest.py "habit tracker" --az --country us --competition
   ```
   (Python 3.10+, solo la biblioteca estándar, sin claves de API).
4. **Marca cada punto** `✅ pass` / `⚠️ improve` / `❌ fail` / `N/A` (correcto / mejorable / falla / no aplica), con evidencia (archivo, recuento, cita).
   Cada ⚠️/❌ necesita una corrección concreta que quepa en el límite. Usa la plantilla de informe del final.
5. **No inventes datos.** Nada de volúmenes de búsqueda, posiciones ni valoraciones que no hayas medido. Escribe "no
   medido" en su lugar. Los datos marcados como UNCONFIRMED más abajo son observaciones de proveedores, no reglas de las tiendas.

---

## Límites de un vistazo

| Tienda | Campo | Límite | Indexado en la búsqueda |
|---|---|---|---|
| App Store | Nombre de la app | 30 | ✅ el de más peso |
| App Store | Subtítulo | 30 | ✅ |
| App Store | Campo de palabras clave (oculto) | 100 | ✅ |
| App Store | Texto promocional | 170 | ❌ (editable sin revisión) |
| App Store | Descripción | 4000 | ❌ para la búsqueda de App Store |
| App Store | Novedades | 4000 | ❌ |
| App Store | Evento dentro de la app (in-app event): nombre / descripción breve / larga | 30 / 50 / 120 | ✅ nombre del evento |
| App Store | Compra dentro de la app (IAP): nombre visible / descripción | 30 / 45 | ✅ IAP promocionadas |
| Google Play | Título | 30 | ✅ el de más peso |
| Google Play | Descripción breve | 80 | ✅ |
| Google Play | Descripción completa | 4000 | ✅ (no hay campo oculto de palabras clave) |
| Google Play | Notas de la versión (What's new) | 500 | ❌ |

La documentación de Apple habla de "100 bytes" para el campo de palabras clave, pero App Store Connect cuenta caracteres
(el 2026-10-01 se aceptó un campo en japonés de 100 caracteres / 220 bytes).

---

## 0. Antes de empezar

- [ ] **PRE-01** Escribe, con las palabras de los usuarios, las 3 **tareas** principales que resuelve la app ("dividir gastos con amigos"), además de su público y sus 5 competidores principales.
- [ ] **PRE-02** Elige los mercados prioritarios: tienda del país (storefront) + idioma, ordenados por instalaciones actuales o por usuarios objetivo.
- [ ] **PRE-03** La ficha vive en el control de versiones (metadatos de `deliver` / `supply` de fastlane), para que cada cambio se pueda comparar con un diff.
- [ ] **PRE-04** Línea base registrada **antes** de cualquier cambio: impresiones en búsquedas, visitas a la página de producto, tasa de conversión, descargas por origen, valoración media y número de valoraciones, por cada país prioritario (consulta la sección 10).
- [ ] **PRE-05** Existe un registro de cambios (p. ej., `docs/aso-log.md`): fecha, campos modificados, antes → después, métrica que vigilar, fecha de seguimiento.

## 1. Investigación de palabras clave

- [ ] **KW-01** 5–10 palabras semilla sacadas de las tareas y de los sustantivos de la categoría — ni la marca ni solo funciones.
- [ ] **KW-02** Ampliadas con el **autocompletado** de cada tienda, por mercado e idioma (cola larga: semilla + cada letra a–z). El orden de las sugerencias = señal de popularidad.
- [ ] **KW-03** Leídos los títulos / subtítulos del top 10 de competidores para cada término principal, anotando las palabras que comparten. Nunca uses sus marcas.
- [ ] **KW-04** **Reseñas** propias y de la competencia analizadas para extraer los sustantivos y verbos que usan los usuarios.
- [ ] **KW-05** Cada candidata puntuada: relevancia (0–3, descarta las < 2), popularidad (posición en el autocompletado o popularidad en Apple Ads), apertura / dificultad (cuántas apps del top 10 apuntan a ella y cuán fuertes son).
- [ ] **KW-06** Las apps nuevas o pequeñas apuntan primero a términos de cola larga que puedan ganar (3–4 palabras, popularidad media, apertura alta) y después a los términos principales.
- [ ] **KW-07** Un **mapa de palabras clave** por idioma: qué términos ocupan el nombre / título, el subtítulo / descripción breve y el campo de palabras clave / descripción completa. Ningún término sin hueco, ningún hueco sin término.
- [ ] **KW-08** Identificados los términos que ya posicionan entre los puestos 11–50: las victorias más baratas.
- [ ] **KW-09** La investigación se rehace **por mercado**: las palabras clave se investigan en el idioma local, no se traducen del inglés.

## 2. Metadatos de App Store (por idioma)

- [ ] **AS-01** (auto) Nombre ≤ 30, subtítulo ≤ 30, campo de palabras clave ≤ 100, texto promocional ≤ 170, descripción ≤ 4000.
- [ ] **AS-02** (auto) Nombre, subtítulo y campo de palabras clave llenos al ≥ 90% cada uno: cada carácter vacío es posicionamiento perdido.
- [ ] **AS-03** Nombre = marca + el término de mayor prioridad, y que se lea con naturalidad ("Marca: Seguimiento de hábitos").
- [ ] **AS-04** (auto) El subtítulo añade palabras **nuevas**: ninguna repetida del nombre.
- [ ] **AS-05** (auto) Campo de palabras clave: comas, **sin espacios después de las comas**, sin coma final.
- [ ] **AS-06** (auto) El campo de palabras clave no repite palabras del nombre ni del subtítulo, ni tiene duplicados.
- [ ] **AS-07** (auto) Singular **o** plural, no ambos.
- [ ] **AS-08** (auto) Sin palabras desperdiciadas: "app", "apps", "free", "iPhone", "iPad", "iOS", "Apple", el nombre de la marca / empresa; (manual) el nombre de la categoría y los equivalentes locales ("aplicación", "gratis").
- [ ] **AS-09** (auto, warning) Prefiere palabras sueltas a frases: Apple combina las palabras del nombre + subtítulo + campo de palabras clave del mismo idioma.
- [ ] **AS-10** Ningún nombre de competidor, marca registrada ni nombre de famoso en ningún campo (Directrices 2.3.7, 5.2.1).
- [ ] **AS-11** (auto) Sin palabras de precio / ranking / llamada a la acción en el nombre, el subtítulo ni las palabras clave: "free", "best", "#1", "sale", "% off" (2.3.7), en ningún idioma (en español: "gratis", "mejor", "oferta", "% de descuento").
- [ ] **AS-12** (auto) Sin emojis; sin marcas de Apple usadas como si formaran parte de tu nombre (iPhone, Siri…).
- [ ] **AS-13** La **categoría principal** es la más relevante (cuenta para la relevancia del texto); categoría secundaria configurada.
- [ ] **AS-14** Descripción: las 3 primeras líneas presentan la tarea principal y la prueba; viñetas fáciles de escanear; no se usa para palabras clave (no se indexa en la búsqueda de App Store), pero la leen la búsqueda web de Google y el generador de etiquetas de Apple.
- [ ] **AS-15** Texto promocional usado para noticias / ofertas del momento (se puede cambiar sin revisión).
- [ ] **AS-16** (auto) Las URL de la política de privacidad y de soporte usan https; (manual) ambas se abren correctamente.
- [ ] **AS-17** Los nombres visibles de las compras dentro de la app describen lo que obtiene el usuario, con un término de búsqueda si queda natural ("Seguimiento de hábitos Pro").
- [ ] **AS-18** Eventos dentro de la app (si los hay): palabra clave en el nombre del evento (30 caracteres); hasta 10 publicados a la vez.
- [ ] **AS-19** **Etiquetas de app** (App tags; tienda de EE. UU., metadatos en-US): revisadas en App Store Connect y desmarcadas las incorrectas (no puedes añadir etiquetas: haz que la descripción en-US explique los casos de uso con claridad).
- [ ] **AS-20** Cuestionario de clasificación por edad respondido con los niveles de 2025 (4+ / 9+ / 13+ / 16+ / 18+).

## 3. Metadatos de Google Play (por idioma)

- [ ] **GP-01** (auto) Título ≤ 30, descripción breve ≤ 80, descripción completa ≤ 4000, notas de la versión ≤ 500.
- [ ] **GP-02** (auto) Título y descripción breve llenos al ≥ 90%.
- [ ] **GP-03** Título = marca + término principal; descripción breve = una frase completa con 2–3 términos secundarios y el beneficio principal.
- [ ] **GP-04** (auto) Las palabras clave del título aparecen en la descripción completa, y dentro de sus primeros ~300 caracteres.
- [ ] **GP-05** Cada término objetivo aparece 2–3 veces de forma natural en la descripción completa; se usan términos relacionados y sinónimos; nada de listas de palabras clave.
- [ ] **GP-06** (auto) Ninguna palabra supera el ~3% de densidad (el relleno de palabras clave infringe las políticas).
- [ ] **GP-07** (auto) Título / descripción breve / nombre del desarrollador: sin emojis, sin caracteres especiales repetidos (`!!!`, `★★`), sin palabras EN MAYÚSCULAS (salvo que sea la marca).
- [ ] **GP-08** (auto) Nada de "Free", "#1", "Best", "Top", "Popular", "New", "Editor's choice", "No ads" (ni sus equivalentes: "Gratis", "Mejor", "Nuevo", "Selección de los editores", "Sin anuncios"…), precios ni promociones en el título, el icono o el nombre del desarrollador, en ninguna traducción.
- [ ] **GP-09** Sin testimonios sin atribuir ni citas anónimas de usuarios en la descripción.
- [ ] **GP-10** La descripción completa tiene estructura: gancho (2 líneas) → funciones clave con encabezados / viñetas → prueba → llamada a la acción; usa frases sencillas que un LLM pueda citar ("Usa X para …"), porque Ask Play y los AI highlights la leen.
- [ ] **GP-11** Categoría y hasta 5 **etiquetas** configuradas (en Store settings / Configuración de la tienda).
- [ ] **GP-12** Correo de contacto, sitio web y política de privacidad completados; el sitio web también describe la app (Ask Play lo lee).
- [ ] **GP-13** Formulario de Seguridad de los datos (Data safety) completo y coherente con la app.

## 4. Localización

- [ ] **L10N-01** Cada mercado prioritario tiene su propia ficha: ni la traducción automática de Play ni la versión en inglés.
- [ ] **L10N-02** (auto) El campo de palabras clave / la descripción breve **no es una copia** del idioma base.
- [ ] **L10N-03** Términos de búsqueda locales, sacados del autocompletado local y de la competencia local (KW-09).
- [ ] **L10N-04** **Localización cruzada** (cross-localization) en App Store: para cada tienda prioritaria, anota los idiomas adicionales que Apple indexa en ella (EE. UU.: en-US + es-MX, ar, zh-Hans, zh-Hant, fr-FR, ko, pt-BR, ru, vi; Reino Unido: en-GB; Canadá: en-CA + fr-CA; Japón: ja + en-US; casi todas las demás: idioma nativo + en-GB) y da a cada idioma palabras **distintas** en el campo de palabras clave.
- [ ] **L10N-05** Los idiomas usados para la localización cruzada siguen sonando correctos a los hablantes nativos de ese idioma (los ven usuarios reales).
- [ ] **L10N-06** (auto) Las fichas en CJK (chino, japonés, coreano) / tailandés / árabe también se llenan hasta el límite: ahí los campos cortos son el desperdicio más habitual.
- [ ] **L10N-07** Capturas de pantalla y sus textos localizados para los idiomas prioritarios; diseño de derecha a izquierda para árabe / hebreo.
- [ ] **L10N-08** Palabras promocionales revisadas en el idioma local ("miễn phí", "gratis", "無料", "무료", "免费"…).

## 5. Icono, capturas de pantalla y video

- [ ] **CR-01** Icono: un símbolo claro, sin palabras, legible a 40 px y distinguible al ponerlo junto a los iconos del top 10 de competidores.
- [ ] **CR-02** iOS 26: icono Liquid Glass por capas revisado en los modos claro, oscuro, tintado y transparente.
- [ ] **CR-03** (auto, Play) Icono PNG de 512×512; gráfico de funciones de 1024×500 sin canal alfa y sin menciones de ranking / precio / premios.
- [ ] **CR-04** La captura 1 muestra la **tarea principal** con la palabra clave principal en un texto de ≤ 5 palabras; se entiende por sí sola en los resultados de búsqueda.
- [ ] **CR-05** Las capturas 2–3 muestran los dos motivos siguientes para instalarla; un beneficio por captura.
- [ ] **CR-06** Interfaz real de la app (App Store 2.3.3); en Play, los textos ocupan ≤ 20% de la imagen; nada de "Download now" ("Descárgala ya"), "#1", "Best" ("Mejor") ni insignias de las tiendas.
- [ ] **CR-07** App Store: capturas para iPhone de 6.9" (1320×2868 / 1290×2796 / 1260×2736) y, si la app funciona en iPad, para iPad de 13" (2064×2752 / 2048×2732); hasta 10 de cada tipo; sin canal alfa.
- [ ] **CR-08** (auto) Play: 2–8 capturas de teléfono, lados de 320–3840 px, lado largo ≤ 2× el corto; ≥ 4 de ≥ 1080 px (9:16 o 16:9) para que la app pueda aparecer destacada; capturas para tablet / Chromebook / Wear si la app es compatible (se muestran por factor de forma).
- [ ] **CR-09** Video (opcional, pruébalo): vista previa de App Store de 15–30 s, solo grabación de pantalla, los primeros 3 s muestran la tarea sin sonido; en Play, enlace de YouTube público / oculto, sin anuncios, lo que cuenta son los primeros 30 s.
- [ ] **CR-10** Las creatividades encajan con el mapa de palabras clave: lo que la gente buscó es lo que muestra la captura 1.

## 6. Páginas personalizadas y experimentos

- [ ] **EXP-01** **Páginas de producto personalizadas** de App Store (custom product pages; hasta 70) para las principales intenciones de búsqueda, cada una con palabras clave asignadas desde el campo de palabras clave aprobado.
- [ ] **EXP-02** **Fichas personalizadas de Play Store** en Google Play (custom store listings; hasta 50) para palabras clave de búsqueda de alto valor / países / usuarios que abandonaron la app.
- [ ] **EXP-03** Siempre un experimento en marcha en el mercado principal: optimización de la página de producto en App Store (product page optimization; ≤ 3 tratamientos, ≤ 90 días) o experimento de ficha de Play Store (store listing experiments; ≤ 2 variantes; el título y el video no se pueden probar).
- [ ] **EXP-04** Cada prueba: una variable, hipótesis escrita, métrica de éxito, ≥ 7 días, y solo se detiene cuando la consola alcanza su nivel de confianza.
- [ ] **EXP-05** Orden de las pruebas según la mejora esperada: icono → captura 1 → textos → orden de las capturas → video.
- [ ] **EXP-06** Resultados registrados (gana / pierde / sin cambios) y variantes ganadoras aplicadas a otros idiomas como pruebas nuevas, no como suposiciones.

## 7. Valoraciones y reseñas

- [ ] **RV-01** Solicitud de reseña nativa dentro de la app (`requestReview` / Play In-App Review API) después de un momento de éxito; nunca al abrir la app, tras un error ni con filtro previo (review gating); sin incentivos.
- [ ] **RV-02** Valoración media ≥ 4.0 en cada país prioritario (Play calcula la valoración por país y factor de forma, y las valoraciones recientes pesan más).
- [ ] **RV-03** Reseñas de 1–3★ respondidas en pocos días y de forma concreta; vuelve a responder cuando se publique la corrección.
- [ ] **RV-04** La queja recurrente principal es conocida y está en la hoja de ruta: los resúmenes de reseñas con IA de ambas tiendas la muestran como titular.
- [ ] **RV-05** Texto de las reseñas analizado cada mes en busca de palabras clave nuevas y peticiones de funciones.

## 8. Calidad y señales técnicas

- [ ] **Q-01** Android vitals de Play por debajo de los umbrales de mal comportamiento (28 días): tasa de fallos percibida por el usuario < 1.09%, ANR < 0.47%, por modelo de teléfono < 8%; wake locks parciales excesivos < 5% de las sesiones.
- [ ] **Q-02** Plan preparado para los umbrales de memoria / bitmap / DEX de Play, que se aplicarán en febrero de 2027.
- [ ] **Q-03** Play: API de destino 36 para apps nuevas / actualizaciones (desde el 2026-08-31); Apple: compilaciones con el SDK de Xcode 26 (desde el 2026-04-28).
- [ ] **Q-04** App actualizada al menos cada 1–3 meses; Novedades describe cambios reales (2.3.12).
- [ ] **Q-05** Tamaño de descarga reducido; sin fallos en el primer arranque ni muro de inicio de sesión antes de aportar valor.
- [ ] **Q-06** Etiqueta de privacidad / Seguridad de los datos y (opcional, App Store) etiquetas de accesibilidad (Accessibility Nutrition Labels) declaradas.

## 9. Políticas — comprobaciones contra rechazos y retiradas

- [ ] **POL-01** Sin afirmaciones engañosas, reseñas falsas, "#1" / "best" ("mejor") no verificables ni precios en el nombre / título (App Store 2.3.1, 2.3.7; política de metadatos de Play).
- [ ] **POL-02** Sin nombres de otras plataformas en los metadatos de App Store ("Android", "Google Play") (2.3.10).
- [ ] **POL-03** Sin marcas registradas de terceros ni nombres que imiten a otras apps (5.2.1; política de suplantación de identidad de Play).
- [ ] **POL-04** "For Kids" / "For Children" ("Para niños") solo en la categoría Niños/Kids (2.3.8).
- [ ] **POL-05** Capturas / vistas previas: la app en uso, no solo la pantalla de presentación o el inicio de sesión (2.3.3, 2.3.4).
- [ ] **POL-06** Todas las traducciones siguen las mismas reglas (Play aplica las políticas por idioma).

## 10. Medir e iterar

- [ ] **M-01** App Store Connect → Analytics: impresiones en la búsqueda de App Store, visitas a la página de producto, conversión, descargas, por país y por página de producto personalizada.
- [ ] **M-02** Play Console → Grow overview / Statistics: adquisición por **término de búsqueda** y fuente de tráfico (Store analysis se retiró en junio de 2026; las métricas de la ficha pasaron a clics de usuarios únicos en julio de 2026 — no compares datos de antes y después de esa fecha).
- [ ] **M-03** Seguimiento de las posiciones de las palabras clave del mapa (herramienta de seguimiento de posiciones, informe de términos de búsqueda de Apple Ads o repetición mensual del autocompletado).
- [ ] **M-04** Cambia un solo grupo de campos a la vez; espera 2–4 semanas antes de juzgar; en App Store, el nombre / subtítulo / palabras clave solo cambian con una versión nueva.
- [ ] **M-05** Cada mes: quita del campo de palabras clave las palabras sin impresiones tras 4–6 semanas, añade las siguientes candidatas y vuelve a revisar la competencia y la estacionalidad.

---

## Plantilla de informe

```markdown
# Auditoría ASO — <App> — <fecha>

Tiendas: <App Store / Google Play> · Idiomas: <lista> · Modo: <auditoría / corrección>

## Puntuación
<superados>/<total> puntos · <n> ❌ · <n> ⚠️ · script: <línea de puntuación de aso_check>

## Tabla de campos
| Tienda | Idioma | Nombre/Título | Subtítulo/Desc. breve | Palabras clave | Descripción |
|---|---|---|---|---|---|
| App Store | en-US | 28/30 ✅ | 30/30 ✅ | 97/100 ✅ | 3120/4000 ✅ |

## Problemas (primero los de mayor impacto)
| ID | Estado | Tienda · idioma · archivo | Evidencia | Corrección (cabe en el límite) |
|---|---|---|---|---|
| AS-06 | ❌ | App Store · en-US · keywords.txt | "tracker" también está en el nombre | sustituir por "routine" (+7 caracteres) |

## Mapa de palabras clave (por idioma prioritario)
| Término | Relevancia | Pos. en autocompletado | Apertura | Campo |

## Próximas 3 acciones
1. …
```

## Fuentes

- Apple: [Búsqueda](https://developer.apple.com/app-store/search/) ·
  [Información sobre versiones de plataforma](https://developer.apple.com/help/app-store-connect/reference/platform-version-information) ·
  [Localizaciones de App Store](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/) ·
  [Directrices de revisión](https://developer.apple.com/app-store/review/guidelines/) ·
  [Especificaciones de capturas de pantalla](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/) ·
  [Páginas de producto personalizadas](https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions/) ·
  [Etiquetas de app](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-tags)
- Google: [Prácticas recomendadas para la ficha](https://support.google.com/googleplay/android-developer/answer/13393723) ·
  [Política de metadatos](https://support.google.com/googleplay/android-developer/answer/9898842) ·
  [Recursos de vista previa](https://support.google.com/googleplay/android-developer/answer/9866151) ·
  [Fichas personalizadas de Play Store](https://support.google.com/googleplay/android-developer/answer/9867158) ·
  [Experimentos de fichas de Play Store](https://support.google.com/googleplay/android-developer/answer/6227309) ·
  [Android vitals](https://developer.android.com/topic/performance/vitals) ·
  [Novedades de Play](https://google.play/business/whats-new/)
- Detalles y fechas de cada tienda: [`references/app-store.md`](../references/app-store.md),
  [`references/google-play.md`](../references/google-play.md),
  [`references/conversion.md`](../references/conversion.md),
  [`references/keyword-research.md`](../references/keyword-research.md),
  [`references/tools.md`](../references/tools.md).
