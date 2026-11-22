# Proyecto 4 · Sistema de recomendación para un marketplace farmacéutico

Estadística Industrial 2026-II. Recomendador de productos para un marketplace farmacéutico
construido en R con las facturas de Procaps (2013–2022), a partir del tutorial de Ander Fernández,
más un prototipo web, **FarmaMatch**, que un comprador sin conocimientos técnicos puede usar.

* Cuando un comprador **mira un producto**: ¿qué otros productos mostrarle? → recomendador
  **ítem–ítem**.
* Cuando un comprador **entra a la tienda**: ¿qué recomendarle? → recomendador
  **usuario–usuario**.
* ¿Funciona mejor que mostrar lo más vendido? → **evaluación temporal** contra esa línea base.

---

## Contenido

```
(raíz del repositorio)
├── README.md                  este archivo
├── proyecto4.Rproj            abre el proyecto en RStudio (activa renv solo)
├── renv.lock                  versiones exactas de todos los paquetes
├── .Rprofile, renv/           arranque de renv (no se editan)
├── .gitignore                 lo que NO se sube a GitHub (datos, paquetes instalados)
├── archive.zip                ← LO PONES TÚ: Book-Crossing de Kaggle (Fase 1)
├── data/
│   ├── pro2.csv               ← LO PONES TÚ: detalle de facturas
│   └── cab.csv                ← LO PONES TÚ: cabecera de facturas
├── proyecto4_completo.Rmd     entregable 1: las fases 1 a 7 en un solo documento
├── fase1_tutorial.Rmd … fase7_evaluacion.Rmd   cada fase por separado
├── preparar_app.R             exporta los resultados de R para la aplicación
├── app/                       entregable 3: la aplicación FarmaMatch (Shiny)
├── capturas/                  capturas de la aplicación y la mascota Dr. Pildo
├── informe/                   entregable 2: informe técnico (7 páginas)
├── PROMPTS.md                 entregable 3: prompts de la app, la mascota y las imágenes
├── proyecto4_completo.html    entregable 1 ya generado (con R 4.3.3)
└── bitacora_ia.md             entregable 4: bitácora de uso de IA
```

Los datos **no** vienen en el zip ni se suben al repositorio (ver
[Datos y GitHub](#datos-y-github)). Hay que copiarlos como se indica en el paso 4.

---

## Cómo correrlo en otro computador, paso a paso

### 1. Instalar R y RStudio

* **R 4.3 o más reciente:** <https://cran.r-project.org>. El proyecto se probó con R 4.3.3; con
  una versión más nueva funciona igual (renv solo muestra un aviso de versión, que se puede
  ignorar).
* **RStudio Desktop:** <https://posit.co/download/rstudio-desktop/>. Trae Pandoc, que hace falta
  para generar los HTML.
* **Solo en Windows y solo si el paso 3 falla compilando paquetes:** instalar
  **Rtools** de la misma versión que R (<https://cran.r-project.org/bin/windows/Rtools/>).
  Normalmente no hace falta, porque los paquetes se descargan ya compilados.

### 2. Descomprimir y abrir el proyecto

1. Consigue los archivos del proyecto de una de estas dos formas:
   * **Desde GitHub:** en GitHub Desktop, *File → Clone repository* y elige el repositorio; o en
     la página del repositorio, *Code → Download ZIP* y descomprímelo.
   * **Desde el zip:** descomprime `proyecto4.zip` dentro de una carpeta vacía. El contenido
     del zip es directamente la raíz del proyecto (no trae una carpeta extra adentro).
2. Haz doble clic en **`proyecto4.Rproj`**. Se abre RStudio con la carpeta del proyecto como
   directorio de trabajo.
3. La primera vez, en la consola aparece algo como:

   ```
   # Bootstrapping renv 1.3.1 ---------------------------------------------------
   ...
   - Project '~/Documents/GitHub/Project FarmaMacth' loaded. [renv 1.3.1]
   - One or more packages recorded in the lockfile are not installed.
   - Use `renv::status()` for more details.
   ```

   Es normal: renv se instaló solo y avisa de que faltan los paquetes del proyecto.

> **¿Qué es renv?** Crea una biblioteca de paquetes **propia del proyecto** (en `renv/library`)
> con las versiones exactas anotadas en `renv.lock`. Así el proyecto corre igual en cualquier
> computador y no toca los paquetes que ya tengas instalados.

### 3. Instalar los paquetes con renv

En la consola de RStudio:

```r
renv::restore()
```

Responde `Y` cuando pregunte si quiere continuar. Instala 99 paquetes (dplyr, tidyr, readr,
ggplot2, lsa, rmarkdown, knitr, shiny, bslib, jsonlite y sus dependencias) desde una **foto
fija de CRAN del 20 de noviembre de 2026** (Posit Package Manager). Por eso, aunque los paquetes
cambien en el futuro, siempre se instalan las mismas versiones. Tarda de 2 a 10 minutos según la
conexión. Se hace **una sola vez**.

Para comprobar que todo quedó bien:

```r
renv::status()
# No issues found -- the project is in a consistent state.
```

`cluster` (Fase 1) no aparece en `renv.lock` a propósito: viene incluido con R, así que se usa
el de tu instalación.

### 4. Copiar los datos

| Archivo | Dónde va | De dónde sale |
|---|---|---|
| `archive.zip` | raíz del proyecto (**sin descomprimir**, junto a los Rmd) | Book-Crossing en Kaggle (trae `Books.csv`, `Ratings.csv`, `Users.csv`) |
| `pro2.csv` | `data/pro2.csv` | Datos de Procaps del curso |
| `cab.csv` | `data/cab.csv` | Datos de Procaps del curso |

Los nombres tienen que ser exactamente esos. La Fase 1 descomprime `archive.zip` dentro de
`data/` por su cuenta.

### 5. Generar el R Markdown completo (entregable 1)

`proyecto4_completo.html` ya viene generado en el zip (se generó en la prueba desde una carpeta
limpia, con los paquetes de `renv.lock` y el `lsa` real). Para generarlo de nuevo en tu
computador, abre **`proyecto4_completo.Rmd`** y pulsa **Knit**. Ejecuta las siete fases en orden y crea
`proyecto4_completo.html`. Tarda unos **16 minutos** (la Fase 6 sola toma unos 9). Por el
camino guarda en `data/` los resultados intermedios (`.rds`) que usan las fases siguientes y la
aplicación.

> **Memoria.** La Fase 1 (el tutorial de libros) llega a usar unos **7 GB de RAM**, porque el
> código del tutorial arma matrices densas de 10.000 libros. Las fases de la farmacia usan menos
> de 1,5 GB. En un computador de 8 GB, cierra el navegador y otros programas antes de hacer Knit.
> Si aun así se queda sin memoria, genera las fases por separado (tabla de abajo): la Fase 1
> sola, reiniciando R antes (*Session → Restart R*), y luego las demás.

**Alternativa, fase por fase.** Cada fase también es un documento independiente. Si se generan
por separado, el orden **importa**, porque cada una lee lo que guardó la anterior:

| Orden | Archivo | Lee de `data/` | Guarda en `data/` | Tiempo |
|---|---|---|---|---|
| 1 | `fase1_tutorial.Rmd` | `archive.zip` (en la raíz) | `Books.csv`, `Ratings.csv`, `Users.csv` | ~2 min |
| 2 | `fase2_datos.Rmd` | `pro2.csv`, `cab.csv` | `datos_unidos.rds`, `catalogo.rds` | <1 min |
| 3 | `fase3_matriz.Rmd` | lo de la Fase 2 | `matriz_usuario_producto.rds` | ~1 min |
| 4 | `fase4_coseno.Rmd` | lo de las Fases 2 y 3 | `similitud_productos.rds` | ~1 min |
| 5 | `fase5_item.Rmd` | lo de las Fases 2 a 4 | `recomendaciones_item.rds` | ~1 min |
| 6 | `fase6_usuario.Rmd` | lo de las Fases 2 y 3 | `recomendaciones_usuario.rds` | ~9 min |
| 7 | `fase7_evaluacion.Rmd` | lo de la Fase 2 | — | ~1 min |

La Fase 1 es independiente de las demás (usa los libros); se puede generar en cualquier momento.

### 6. Abrir la aplicación FarmaMatch (entregable 3)

La aplicación ya trae sus datos precalculados (`app/datos_app.rds` y las 732 imágenes), así que
funciona sin generar nada antes:

* Abre `app/app.R` y pulsa **Run App** (arriba a la derecha del editor), o
* en la consola: `shiny::runApp("app")`.

Si cambias algo en las fases y quieres que la aplicación lo refleje, después del paso 5
ejecuta `source("preparar_app.R")`: vuelve a crear `app/datos_app.rds`,
`app/recomendaciones.json` y las imágenes de `app/www/img/` a partir de los `.rds` de `data/`.

### 7. Generar el informe (entregable 2)

Abre `informe/informe.Rmd` y pulsa **Knit**: crea `informe/informe.docx` (en Word se exporta a
PDF). Ya vienen generados `informe.docx` e `informe.pdf`. Las cifras del informe están escritas
en el texto a partir de los resultados de las fases, así que se genera en segundos.

### Si algo falla

| Síntoma | Solución |
|---|---|
| `there is no package called 'dplyr'` (u otro) | Falta el paso 3: `renv::restore()`. Revisa que abriste el proyecto con `proyecto4.Rproj`. |
| `cannot open file 'data/pro2.csv'` | Los datos no están en `data/` o tienen otro nombre (paso 4). |
| `cannot open zip file 'archive.zip'` | `archive.zip` debe estar en la raíz del proyecto, no dentro de `data/`. |
| `Error ... datos_unidos.rds` en una fase | Se generó una fase sin haber generado las anteriores; sigue el orden del paso 5. |
| `renv::restore()` falla compilando en Windows | Instala Rtools (paso 1) y repite. |
| Tildes raras (`Ã³`) | En RStudio: *Tools → Global Options → Code → Saving → Default text encoding: UTF-8*, y vuelve a abrir el archivo. |
| Aviso «The lockfile was generated with R 4.3.3» | Es solo informativo; se puede ignorar. |
| Quieres empezar de cero | Borra los `.rds` de `data/` y vuelve a generar desde la Fase 2. |

### Reproducibilidad

* **Paquetes:** versiones fijas en `renv.lock`, instaladas desde una foto de CRAN con fecha.
* **Azar:** solo hay tres partes aleatorias y las tres fijan semilla: categorías al azar de los
  libros (`set.seed(1234)`, Fase 1), 200 pares al azar para validar el coseno
  (`set.seed(2026)`, Fase 4) y el bootstrap de los intervalos (`set.seed(2026)`, Fase 7). Lo
  demás es determinista. El botón «comprador al azar» de la aplicación es aleatorio a propósito.
* **Rutas:** todas son relativas a la raíz del proyecto (`data/...`, `app/...`); no hay rutas
  de un computador en particular.
* **Prueba hecha:** se descomprimió el proyecto en una carpeta vacía, con una caché de renv vacía
  y sin paquetes previos, se ejecutó `renv::restore()` y se generaron `proyecto4_completo.Rmd`,
  el informe y la aplicación sin errores (Linux, R 4.3.3). No se probó en Windows ni en Mac; ahí
  renv instala las mismas versiones, compiladas para ese sistema, desde la misma foto de CRAN.

---

## Datos y GitHub

El repositorio **no** incluye los datos, y el `.gitignore` ya los deja fuera para que no se
suban por accidente:

| Archivo | Tamaño | ¿Se sube? | Por qué | Cómo conseguirlo |
|---|---|---|---|---|
| `data/pro2.csv` | 49 MB | No | Son facturas reales de Procaps entregadas para el curso. En un repositorio público quedarían a la vista de cualquiera. | Pedirlo al docente o a un compañero del equipo (está en los materiales del curso). |
| `data/cab.csv` | 11 MB | No | Igual que `pro2.csv`: incluye los códigos de compradores. | Igual que `pro2.csv`. |
| `archive.zip` | 18 MB | No | Es el Book-Crossing de Kaggle; su licencia es de Kaggle y no hace falta redistribuirlo. | Descargarlo de Kaggle (buscar «Book-Crossing dataset»; requiere cuenta gratuita) con el botón *Download*, y dejar el zip tal cual en la raíz del proyecto. |
| `data/*.rds`, `data/Books.csv`… | unos 65 MB | No | Se regeneran al hacer Knit (paso 5). | — |
| `renv/library/` | ~150 MB | No | Son los paquetes instalados; se recrean con `renv::restore()`. | — |

El archivo más grande que sí se sube es `app/recomendaciones.json` (13 MB), muy por debajo del
límite de 100 MB por archivo de GitHub. Todo el repositorio pesa unos 35 MB.

**Ojo con la aplicación.** Se sube completa para que funcione apenas se descarga. No trae las
facturas, pero `app/datos_app.rds` sí contiene, **por código de comprador**, qué productos
compró, cuántas unidades y la fecha de su última compra (es lo que muestra la vista
«comprador»), y `app/recomendaciones.json` las recomendaciones de cada código. Los códigos no tienen nombres, pero siguen siendo datos derivados
de Procaps. Recomendación: **dejen el repositorio privado** y agreguen al docente como
colaborador (*Settings → Collaborators*). Si tiene que ser público, pregunten antes al docente.

**Para subirlo con GitHub Desktop:** descomprime el zip dentro de la carpeta del repositorio,
revisa en la pestaña *Changes* que no aparezcan `pro2.csv`, `cab.csv` ni `archive.zip`, escribe
un mensaje (por ejemplo «Proyecto 4 completo»), pulsa *Commit to main* y luego *Publish
repository* (o *Push origin*). `proyecto4_completo.html` (el entregable 1) ya viene
generado y sí se sube; si vuelves a hacer Knit, se reemplaza y lo subes de nuevo.

---

## Qué se hizo, fase por fase

### Fase 1 · Reproducir el tutorial con Book-Crossing (Kaggle)

El tutorial de Ander Fernández construye tres recomendadores para libros: contenido (distancia
de Gower), ítem–ítem y usuario–usuario (coseno). Lo ejecutamos con la versión de Kaggle,
comentado línea a línea.

* **Cambios por Kaggle:** otros nombres de archivos (`Books.csv`, `Ratings.csv`, `Users.csv`) y
  columnas (`Rating`, sin URL de carátulas); leemos cada archivo por su nombre.
* **Dos errores reales del código**, mostrados con el original al lado del corregido:
  `recomendar()` unía la calificación por el libro recomendado y no por el leído (8 de 8
  candidatos eran libros ya leídos), e `item_recommendation()` buscaba el libro en `rownames`
  cuando está en las columnas (42.151 NaN y una tabla vacía).
* **Nota de interpretación:** `top_n(10000)` no toma 10.000 usuarios sino las calificaciones
  empatadas en el máximo (todas de 10), así que la matriz queda en la práctica binaria.

### Fase 2 · Cargar, limpiar y unir

Lectura en Latin-1 con el punto como separador de miles; `invoice`, `Material` y `colaborador`
como texto. `invoice` es única en la cabecera, así que la unión es de muchos a uno:
`left_join(..., relationship = "many-to-one")`. Resultado: **496.375 filas antes y después**,
0 líneas sin comprador, 306 cabeceras sin detalle. 5.888 compradores, 732 productos, julio 2013 a
marzo 2022. Ventas muy concentradas: 40 productos hacen la mitad de las unidades.

### Fase 3 · Preferencia implícita y matriz usuario–producto

Comparamos suma de cantidad, número de facturas, binaria y **log(1 + cantidad)**. La matriz está
**94,98 % vacía**. Con la suma, 75 productos dependen en más de la mitad de un solo comprador; con
log, 25. En una validación temporal las cuatro aciertan igual (hit rate ≈ 65–66 %), así que
elegimos log por robustez. Se fija un mínimo de **5 compradores en común** para considerar dos
productos similares.

### Fase 4 · Similitud de coseno

Función propia validada contra `lsa::cosine` en 5 pares de productos, un par de compradores y la
matriz completa 732 × 732 (diferencia máxima 2,5e-14). Un coseno de 0,8 es un ángulo de unos 37°:
dos productos que compran casi las mismas personas.

### Fase 5 · Recomendador ítem–ítem

`item_recommendation(producto, n, penalizacion = 0.25)`. Con el coseno puro, 28,4 % de las
recomendaciones eran productos del top 10 de ventas; dividimos el coseno por
(compradores del candidato)^0,25 para ordenar y baja a 3,8 % sin perder acierto. Siete casos de
categorías distintas analizados con criterio farmacéutico (por ejemplo, tiras de glucosa →
lancetas y glucómetro).

### Fase 6 · Recomendador usuario–usuario

`user_recommendation(colaborador, k = 50, min_vecinos = 2, una_por_familia = TRUE)`. Excluye
todo lo que el comprador ya compró, **verificado en los 5.888 compradores** (0 casos). Análisis
de sensibilidad a k (5 a 200) y al umbral (1 a 10): el acierto se estabiliza en k = 50. Una
recomendación por familia de producto para no llenar la lista de presentaciones de lo mismo.

### Fase 7 · Evaluación contra la línea base

Entrenamiento hasta el 31/12/2020, prueba 2021–2022, 2.568 compradores. Línea base: los 10 más
vendidos.

| Modelo | hit rate@10 | precision@10 | Productos distintos |
|---|---|---|---|
| Línea base: 10 más vendidos | 62,5 % | 11,09 % | 76 |
| Ítem–ítem, α = 0,25 | 64,5 % | 12,17 % | 263 |
| Usuario–usuario, k = 50 | 65,6 % | 12,32 % | 166 |

Todos los recomendadores superan a la base de forma **significativa** (McNemar, Wilcoxon,
bootstrap pareado). La mejora es de 2 a 3 puntos, pero la diversidad es mucho mayor.

---

## La aplicación: FarmaMatch

* **Vista «producto»:** se busca un producto por su nombre y aparecen los más parecidos como
  tarjetas con imagen, barra de afinidad y la explicación «X compradores de este producto también
  compraron este». Las otras presentaciones del mismo producto se muestran aparte.
* **Vista «comprador»:** se elige un comprador (o uno al azar) y se ve su historial al lado de sus
  10 recomendaciones, ninguna ya comprada, con la explicación «lo compraron N de los 50
  compradores con compras más parecidas».
* **¿Cómo funciona?:** explica el método y las métricas en lenguaje sencillo.
* **Imágenes:** una ilustración por producto (732), dibujada por código según la forma
  farmacéutica de la descripción (caja, frasco, tubo, gotero, lata, sobres, spray…). Muestra el
  nombre tal como aparece en las facturas: no se inventan marcas ni logos.
* **Dr. Pildo:** mascota original (un cachorro farmacéutico con gafas y bata) que presenta las
  recomendaciones.
* **Rápida:** todo está precalculado en R; la aplicación solo consulta.

Los prompts con que se generaron la aplicación, la mascota y las imágenes están en
[PROMPTS.md](PROMPTS.md).

Archivos: `app/app.R` (la aplicación), `app/mascota.R` (Dr. Pildo), `app/www/estilo.css` (el
diseño), `app/www/img/` (imágenes), `app/datos_app.rds` y `app/recomendaciones.json` (las
recomendaciones exportadas desde R). Las tipografías se cargan de Google Fonts; sin internet se
usan las del sistema.

---

## Uso de IA

El código, la aplicación y las imágenes se hicieron con ayuda de Claude (Anthropic).

* **[PROMPTS.md](PROMPTS.md):** los prompts con que se generaron la aplicación, la mascota
  Dr. Pildo y las imágenes de los productos, y cómo se dibujan (entregable 3).
* **[bitacora_ia.md](bitacora_ia.md):** el registro de todo el proyecto, etapa por etapa: los
  prompts, lo que se aceptó, lo que se corrigió y por qué (entregable 4).

## Referencias

* Ander Fernández, «Cómo programar un sistema de recomendación en R».
* Book-Crossing Dataset (Kaggle).
* Paquetes de R: dplyr, tidyr, readr, ggplot2, cluster, lsa, jsonlite, shiny, bslib, renv.
