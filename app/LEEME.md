# FarmaMatch · prototipo del recomendador

## Cómo abrirla en RStudio
1. Instala los paquetes una sola vez:
   `install.packages(c("shiny", "bslib", "dplyr", "jsonlite"))`
2. Abre `app/app.R` en RStudio y pulsa **Run App** (arriba a la derecha del editor).
   También funciona con `shiny::runApp("app")` desde la carpeta proyecto4.

## Si cambias algo en las fases
Desde la carpeta proyecto4, ejecuta `source("preparar_app.R")`. Vuelve a crear
`app/datos_app.rds`, `app/recomendaciones.json` y las 732 imágenes de `app/www/img/`.

## Contenido
- `app.R`: la aplicación (vista producto, vista comprador y "¿Cómo funciona?").
- `www/estilo.css`: el diseño.
- `www/img/`: una ilustración SVG por producto, dibujada por código según la presentación
  (caja, frasco, tubo, gotero, lata, sobres, spray, inyectable...). Usa el nombre tal como
  aparece en las facturas; no reproduce logos ni empaques reales.
- `datos_app.rds`: recomendaciones precalculadas (por eso la app responde de inmediato).
- `recomendaciones.json`: las mismas recomendaciones exportadas desde R.

Las tipografías (Fredoka y Nunito) se cargan de Google Fonts; sin internet la app
funciona igual con tipografías del sistema.

## Dr. Pildo
- `mascota.R`: la mascota original de FarmaMatch (un cachorro farmacéutico con gafas y bata),
  dibujada en SVG para este proyecto. Presenta las recomendaciones con globos de diálogo.
