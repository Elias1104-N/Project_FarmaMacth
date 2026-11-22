# Bitácora de uso de IA · Proyecto 4

**Herramienta:** Claude (Anthropic), usado como asistente en un proyecto de la aplicación de
Claude, en español. Todo el trabajo se hizo en una sola conversación por etapas, del 21 de
noviembre de 2026 en adelante. **No se usó ninguna otra IA** ni generador de imágenes: las
imágenes de los productos y la mascota son dibujos vectoriales (SVG) escritos como código R por
Claude.

**Forma de trabajo acordada:** una etapa a la vez. Claude escribía el R Markdown de la fase, lo
ejecutaba con los datos reales y mostraba el resultado; el equipo lo revisaba, lo generaba en su
propio computador y confirmaba antes de seguir. El análisis es responsabilidad del equipo: cada
decisión de la tabla de abajo quedó justificada con datos dentro del Rmd correspondiente.

> **Para el equipo:** la fila «Verificación del equipo» separa lo que revisó el equipo de lo que
> revisó la IA. 

---

## 1. Registro por etapa

### Etapa 1 · Fase 2: lectura y unión de los datos

| | |
|---|---|
| **Prompt** | «quiero hacer este proyecto, por favor, lo vamos haciendo paso a paso» (con el enunciado `Proyecto4.pdf`, el tutorial `recbooks.Rmd`, `pro2.csv` y `cab.csv`) |
| **Qué hizo la IA** | Propuso el plan de nueve etapas (`plan.md`) y escribió `fase2_datos.Rmd`: lectura en Latin-1 con punto de miles, verificaciones de la clave, `left_join` muchos a uno, catálogo con un nombre por producto y resumen descriptivo. |
| **Qué se aceptó** | El tipo de join y las verificaciones (496.375 filas antes y después, 0 sin comprador, 306 cabeceras sin detalle). |
| **Qué se corrigió y por qué** | `read_csv2` con `grouping_mark = "."` fallaba porque readr exige que el decimal sea distinto: se añadió `decimal_mark = ","`. Las tildes salían como `<U+00ED>` al generar el HTML: se generó con la configuración regional UTF-8. Se detectaron 51 códigos con dos descripciones y se decidió usar la más frecuente. |
| **Verificación del equipo** | **Equipo:** generó `fase2_datos.Rmd` en su computador antes de seguir y, al final, todo el proyecto con `proyecto4_completo.Rmd` sin errores. **IA:** revisó que la unión conserve las 496.375 filas, que ninguna quede sin comprador y que haya 306 cabeceras sin detalle. El equipo comparó en su HTML el número de filas, compradores y productos con los de esta tabla. |

### Etapa 2 · Fase 1: reproducir el tutorial con Kaggle

| | |
|---|---|
| **Prompt** | (se subió `archive.zip` de Kaggle) y luego: «lo de corregir los tres errores del código» |
| **Qué hizo la IA** | `fase1_tutorial.Rmd` comentado línea a línea, con la tabla de diferencias entre el archivo original y el de Kaggle. Encontró dos errores reales y los demostró con datos. |
| **Qué se aceptó** | Los dos errores: `recomendar()` unía la calificación por el libro recomendado y no por el leído (8 de 8 candidatos ya leídos), e `item_recommendation()` buscaba en `rownames` en vez de `colnames` (42.151 NaN y tabla vacía). |
| **Qué se corrigió y por qué** | El equipo pidió ver el código original al lado del corregido: se añadió una comparación en dos columnas. La IA aclaró que el tercer punto, `top_n(10000)`, no es un error sino una nota de interpretación (deja solo las calificaciones de 10), y así quedó marcado. Al armar el Rmd completo se cambió la lectura por posición (`files[1]`, `files[2]`...) por lectura por nombre, porque en la carpeta `data/` también están los archivos de la farmacia. |
| **Verificación del equipo** | **Equipo:** subió `archive.zip` de Kaggle, pidió ver el código original al lado del corregido y, en su computador, encontró el error al leer `archive.zip`/`Books.csv`, que se corrigió. Después la Fase 1 corrió completa. **IA:** demostró los dos errores con datos (8 de 8 candidatos ya leídos; 42.151 NaN). |

### Etapa 3 · Fase 3: preferencia implícita y matriz

| | |
|---|---|
| **Prompt** | «sí, es bueno hacer eso, sigamos» (aceptando comparar las definiciones con y sin un mínimo de compradores en común) |
| **Qué hizo la IA** | Comparó suma, facturas, binaria y log(1 + cantidad): distribución, dispersión (94,98 %), peso del mayor comprador y una validación temporal rápida. |
| **Qué se aceptó** | log(1 + cantidad), porque las cuatro aciertan igual (IC traslapados) y log es más robusta a los mayoristas que la suma; umbral de 5 compradores en común. |
| **Qué se corrigió y por qué** | — |
| **Verificación del equipo** | **Equipo:** aprobó comparar las cuatro definiciones de preferencia y el umbral de 5 compradores en común antes de seguir. **IA:** calculó la dispersión (94,98 %) y la validación temporal con IC. |

### Etapa 4 · Fase 4: coseno

| | |
|---|---|
| **Prompt** | «sí» |
| **Qué hizo la IA** | Función de coseno, validación contra `lsa::cosine` en cinco pares de productos, un par de compradores y la matriz completa; interpretación geométrica de 0,8. |
| **Qué se aceptó** | La función y la matriz precalculada con `crossprod`. |
| **Qué se corrigió y por qué** | En el entorno de la IA no se podía instalar `lsa`, así que su vista previa usó una copia local de `lsa::cosine` y llevaba un aviso. **El equipo generó el documento en su computador con el paquete `lsa` real** para que la validación sea válida. |
| **Verificación del equipo** | **Equipo:** instaló el paquete `lsa` y generó las fases 2 a 4 en su computador. El primer intento falló («no se encuentra `matriz_usuario_producto.rds`») porque la Fase 4 se generó antes que la 2 y la 3. Al generarlas en orden funcionó, y el equipo confirmó que las cuatro fases quedaron unidas. **IA:** comparó su función con `lsa::cosine` (diferencia máxima 2,5 × 10⁻¹⁴). |

### Etapa 5 · Fase 5: ítem–ítem

| | |
|---|---|
| **Prompt** | «sip» |
| **Qué hizo la IA** | `item_recommendation()`, el diagnóstico del sesgo de popularidad, la penalización α y siete casos con criterio farmacéutico. |
| **Qué se aceptó** | α = 0,25 (mismo acierto que el coseno puro, y el top 10 baja de 28,4 % a 3,8 % de las recomendaciones). |
| **Qué se corrigió y por qué** | La primera medición de la cuota del top 10 daba `NaN` porque promediaba por producto incluyendo productos sin recomendaciones: se calculó sobre todas las recomendaciones juntas. Los textos del análisis farmacéutico se reescribieron a partir de las listas reales, porque los primeros no coincidían exactamente con la salida. |
| **Verificación del equipo** | **Equipo:** aprobó α = 0,25 antes de seguir. **IA:** midió el acierto y la cuota del top 10 (28,4 % a 3,8 %) y reescribió los textos farmacéuticos contra las listas reales. |

### Etapa 6 · Fase 6: usuario–usuario

| | |
|---|---|
| **Prompt** | «sigamos» |
| **Qué hizo la IA** | `user_recommendation()`, la verificación de exclusión (un caso y los 5.888 compradores), la grilla de k × umbral y la regla de una por familia. |
| **Qué se aceptó** | k = 50, mínimo 2 vecinos, una por familia. |
| **Qué se corrigió y por qué** | Algunos textos describían la tabla de sensibilidad de forma imprecisa: se corrigieron contra los números. |
| **Verificación del equipo** | **Equipo:** aprobó k = 50, mínimo 2 vecinos y una recomendación por familia. **IA:** verificó que ninguna recomendación sea un producto ya comprado, en un caso y en los 5.888 compradores. |

### Etapa 7 · Fase 7: evaluación

| | |
|---|---|
| **Prompt** | «quiero que hagas el recomendador bien bonito, distinto y funcional» y luego «hagamos las pruebas necesarias primero» |
| **Qué hizo la IA** | Por pedido del equipo, la evaluación formal se hizo **antes** del prototipo: partición temporal, hit rate@10 y precision@10 con IC de Wilson y bootstrap, McNemar, Wilcoxon y diversidad. |
| **Qué se aceptó** | La conclusión (todos superan a la base, 2–3 puntos) y la elección de modelos para cada vista de la aplicación. |
| **Qué se corrigió y por qué** | Los valores p muy pequeños se mostraban como 0: se formatearon con `format.pval`. |
| **Verificación del equipo** | **Equipo:** pidió hacer las pruebas antes del prototipo y aceptó la elección de modelos para cada vista de la aplicación. **IA:** calculó hit rate@10 y precision@10 con IC de Wilson y bootstrap, McNemar y Wilcoxon (por ejemplo, base 62,5 % frente a 65,6 %, con McNemar significativo). |

### Etapa 8 · Prototipo FarmaMatch

| | |
|---|---|
| **Prompts** | 1) «quiero que hagas el recomendador bien bonito, distinto y funcional» 2) «sí» (pasar a la app) 3) «cambia el nombre, tipo, recommendapp o algo creativo. Y quiero que el diseño sea más lindo, imagenes de los productos generadas por ti y que puedas, no sé, meter a Snoopy como recomendador» |
| **Qué hizo la IA** | `preparar_app.R` (exporta `datos_app.rds`, `recomendaciones.json` y las 732 imágenes desde los resultados de R) y la app Shiny `app/` con la vista producto, la vista comprador y «¿Cómo funciona?». |
| **Qué se aceptó** | El nombre FarmaMatch, el diseño y la mascota. |
| **Qué se corrigió y por qué** | **Snoopy no se usó**: es un personaje con derechos de autor, y el enunciado pide no inventar ni usar marcas ajenas. La IA creó una mascota original, **Dr. Pildo**. Las imágenes clasificaban la glucosamina como producto de diabetes (por la regla «GLUCO»): se corrigió. Las etiquetas largas se salían del empaque: se ajustaron. Se cambió un texto que asumía el género del comprador. |
| **Verificación del equipo** | **Equipo:** abrió la aplicación y pidió cambios (nombre, diseño, imágenes y Snoopy), aprobó la mascota original Dr. Pildo en lugar de Snoopy y abrió FarmaMatch en su computador. Al probarla encontró que la lista de búsqueda se recortaba dentro de la tarjeta (ver etapa 11). **IA:** revisó las imágenes por forma farmacéutica y corrigió la glucosamina, las etiquetas largas y un texto con género. |

### Etapa 9 · Cierre

| | |
|---|---|
| **Prompt** | «sí» (aprobando el cierre: Rmd único, informe y bitácora) |
| **Qué hizo la IA** | `proyecto4_completo.Rmd`, que ejecuta las siete fases como documentos hijos; `informe/informe.Rmd` (7 páginas); esta bitácora. |
| **Qué se corrigió y por qué** | Al ejecutar todo junto, la Fase 1 leía los archivos por posición y tomaba `cab.csv` como si fuera `Books.csv`: se cambió a lectura por nombre. |
| **Verificación del equipo** | **Equipo:** generó `proyecto4_completo.Rmd` en su computador, y todo corrió bien después de corregir la lectura de la Fase 1. Revisó los entregables contra el enunciado. |

### Etapa 10 · Empaquetado reproducible para GitHub

| | |
|---|---|
| **Prompts** | «podrias generarme el zip del proyecto otra vez pero con un readme explicando todo, ademas de como correr el proyecto en otro pc paso a paso con renv y demas» y el aviso de que el contenido del zip irá a un repositorio creado con GitHub Desktop |
| **Qué hizo la IA** | `README.md`, `renv.lock` (versiones fijas desde una foto de CRAN del 20/11/2026), `proyecto4.Rproj` y `.gitignore` sin datos. Probó todo desde una carpeta vacía: `renv::restore()`, el Knit completo, el informe y la aplicación. |
| **Qué se corrigió y por qué** | La prueba mostró que la Fase 1 llega a unos 8 GB de RAM; se libera la matriz de Gower cuando deja de usarse (baja a unos 7 GB) y el README lo advierte. `cluster` se dejó fuera de `renv.lock` porque viene con R. |
| **Verificación del equipo** | **Equipo:** creó el repositorio con GitHub Desktop, restauró el proyecto con `renv` en su computador (Windows) y lo ejecutó completo, y confirmó que «todo corrió bien». **IA:** hizo la prueba desde una carpeta vacía en Linux con R 4.3.3 (restore, Knit completo de unos 16 min, informe y aplicación). |

### Etapa 11 · Ajustes finales: lista de búsqueda y formato del informe

| | |
|---|---|
| **Prompts** | «no aparecen completas las recomendaciones» (con una captura de la lista recortada) y «ahora sigamos con el informe, el cambio no es de contenido o estructura es formato y hoja de presentacion» (con el PDF de un informe anterior como modelo) |
| **Qué hizo la IA** | En `app/app.R` añadió `dropdownParent = "body"` a los dos buscadores para que la lista no se recorte. En el informe creó `reference.docx` con los estilos del modelo, una portada y los títulos de tablas y figuras con ese formato, sin cambiar el contenido. |
| **Qué se corrigió y por qué** | El primer arreglo (solo CSS) funcionaba en la vista previa de la IA, pero en el computador del equipo la lista seguía recortada. Se cambió por `dropdownParent = "body"`, que saca la lista de la tarjeta. En la vista previa del informe, una flecha y una ecuación no se veían bien y se pasaron a texto. |
| **Verificación del equipo** | **Equipo:** encontró el error de la lista y comprobó que el primer arreglo no lo resolvía. **IA:** probó `dropdownParent = "body"` en Chromium con el CSS original, y el informe quedó de 8 páginas con portada. |

---

## 2. Prompts del prototipo y de las imágenes

El enunciado pide los prompts con que se generaron la aplicación y las imágenes. El detalle
completo, con ejemplos de las imágenes, está en [PROMPTS.md](PROMPTS.md). Los prompts del
equipo son los de la etapa 8. A partir de ellos, la IA trabajó con estas especificaciones, que
quedaron escritas como código:

**Aplicación**
- Shiny que corra en RStudio con «Run App», sin servidor externo.
- Vista «producto»: buscar por nombre, no por código; tarjetas con imagen, descripción y una
  explicación en lenguaje sencillo («X compradores de este producto también compraron este»).
  Separar las otras presentaciones del mismo producto.
- Vista «comprador»: historial al lado de las recomendaciones, sin productos ya comprados, con la
  explicación («lo compraron N de los 50 compradores con compras más parecidas»).
- Respuesta inmediata: todo precalculado en R.
- Diseño cálido y amigable, con una mascota que presente las recomendaciones.

**Imágenes de producto (las 732 de `app/www/img/`)**
- Generadas por código (`svg_producto()` en `preparar_app.R`), no por un modelo de imágenes.
- La **forma farmacéutica** sale de la descripción con palabras clave: caja, frasco, líquido,
  gotero, tubo, lata, sobres, gomitas, spray, ampolla, glucómetro, mascarilla o termómetro; y si
  es cápsula o tableta (CBG, CAPS, CAPSULA, UNIGEL = cápsula).
- El **color** sale de una categoría aproximada por palabras clave (17 categorías).
- La **etiqueta** muestra el nombre tal como aparece en las facturas. No se dibujan logos ni
  empaques reales y no se inventan marcas.

**Mascota Dr. Pildo (`app/mascota.R`)**
- Prompt del equipo: «meter a Snoopy como recomendador». Como Snoopy tiene derechos de autor, la
  IA diseñó un personaje original: un cachorro color caramelo con orejas chocolate, gafas
  redondas, bata de farmacéutico y una cápsula en el collar, con tres expresiones (feliz,
  pensando, guiño). No está basado en ningún personaje existente.

---

## 3. Limitaciones del uso de IA que el equipo debe conocer

- La IA escribió casi todo el código. El equipo debe poder explicar cada decisión: están
  justificadas dentro de cada Rmd.
- Las categorías, las formas farmacéuticas y las familias son reglas de palabras clave escritas
  por la IA. Pueden fallar en productos con nombres poco comunes.
- El análisis farmacéutico de los casos de la Fase 5 lo redactó la IA a partir de los
  resultados. No reemplaza el criterio de un químico farmacéutico.
