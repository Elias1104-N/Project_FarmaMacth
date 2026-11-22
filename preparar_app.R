# ============================================================================
# Proyecto 4 · Preparar los datos y las imágenes de FarmaMatch (prototipo)
# ----------------------------------------------------------------------------
# Se ejecuta UNA vez, después de las fases 2 a 7, desde la carpeta proyecto4:
#     source("preparar_app.R")
# Lee los .rds de data/ y escribe en app/:
#   - app/datos_app.rds          todo lo que la app necesita (precalculado)
#   - app/recomendaciones.json   las mismas recomendaciones en JSON (puente R → app)
#   - app/www/img/<Material>.svg una ilustración por producto
# ============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(jsonlite)
})

dir.create("app/www/img", recursive = TRUE, showWarnings = FALSE)

catalogo <- readRDS("data/catalogo.rds")
datos    <- readRDS("data/datos_unidos.rds")
fase3    <- readRDS("data/matriz_usuario_producto.rds")
fase4    <- readRDS("data/similitud_productos.rds")
fase6    <- readRDS("data/recomendaciones_usuario.rds")

X       <- fase3$user_item
S       <- fase4$S_final
comunes <- fase4$comunes

# ---------------------------------------------------------------------------
# 1. Categoría terapéutica aproximada (por palabras clave de la descripción)
#    No es una clasificación oficial: sirve para dar color y contexto en la app.
# ---------------------------------------------------------------------------
reglas_categoria <- list(
  "Veterinario"               = c("\\bVET\\b", "HORSE"),
  "Confitería"                = c("TROLLI", "GLOWWORMS", "CLASSIC BEARS"),
  "Diabetes"                  = c("TIRAS", "LANCETA", "GLUCOMETRO", "GLUCOQUICK", "INSULINA",
                                  "METGLITAL", "DIAMOND", "DIMOND", "GLUVID", "BRAZALETE",
                                  "METFORMINA", "G-MET", "G\\.MET", "PREDIAL", "NORBORAL",
                                  "NANOPASS"),
  "Salud femenina"            = c("VAGINAL", "OVULO", "OVUL", "ILANA", "ISBELA", "YAEL", "EVINET",
                                  "G-TABS", "GTAB", "SAFORELLE", "ADELLA", "ALACTIN"),
  "Salud mental y neurología" = c("SERTRALINA", "QUETIAPINA", "KETIAN", "ZOPICLONA", "ZOLPIDEM",
                                  "ISPERIN", "PROLANZ", "MOXETIN", "ALZIT", "NEURACT",
                                  "VERTIGEN", "SULBUTIAMINA"),
  "Ojos"                      = c("OFT", "LAGRI", "TEARSOFT"),
  "Nutrición infantil"        = c("NOVAMIL"),
  "Respiratorio y alergia"    = c("\\bTOS\\b", "KLEAR", "ALERCET", "LORATADINA", "NASAL", "BRONER",
                                  "LEVOCETIRIZINA", "FEXOFENADINA", "FLUXAL"),
  "Dolor e inflamación"       = c("DOLOFEN", "DICLOFEN", "MELOXICAM", "NAPROXENO", "TRAMADOL",
                                  "KEPROFEN", "IBUPROFENO", "ACETAMINOFEN", "INDOMETACINA",
                                  "FLEXURE", "CARPRODYL", "NYTAX", "NIMESULIDA", "ACETAMINOFEM", "GLUCOSAMINA",
                                  "BETAMETASO", "DEXAMETASONA", "BETADUO"),
  "Infecciones"               = c("ZITRIM", "PAMOX", "BIANOS", "CLORANFENICOL", "METRONIF",
                                  "METROZIN", "NITAZOXANIDA", "RIFAMICINA", "IFAXIM",
                                  "CLINDAMICINA", "VALTROIS", "GENTAMICINA", "FLUCONAZOL",
                                  "FLUNAZOL", "VIGIA", "OTOSEC", "AZITROMICINA", "CLARITROMICINA",
                                  "ERITROMICINA", "RIFAMPICINA", "METRONIDAZOL"),
  "Piel"                      = c("CLOTRIMAZOL", "NISTATINA", "OXIDO DE ZINC", "DRYDERMA",
                                  "ISOFACE", "ISOTRETINOINA", "MINOXIDIL", "CREMA", "UNGU", "POMADA",
                                  "FOLISTER"),
  "Corazón y metabolismo"     = c("ATOVAROL", "ATORVASTATINA", "VARTERAL", "VALSARTAN",
                                  "CARDIOSOL", "GEMFIBROZILO", "FENOVAS", "LIPOTIC", "EPACOR",
                                  "LEVOTIROXINA", "CROMUS", "ROSUVASTATINA", "EZETIMIBA", "ENALAPRIL",
                                  "ATEPLAX", "ORLISTAT"),
  "Digestivo"                 = c("LANSOPEP", "ESOMEPRAZOL", "REFLUYET", "DIGESTA", "ENITRAX",
                                  "PROXIGEL", "BONFIBRA", "MUVETT", "PREVENTIA PROBIOTICOS",
                                  "OMEPRAZOL", "PANTOPRAZOL", "TRIMEBUTINA", "BIOFLOR"),
  "Vitaminas y suplementos"   = c("VITAMINA", "GUMIVIT", "LEMOVIT", "B-VIT", "POLIVIT", "MULTIVIT",
                                  "OMEGA", "EPAX", "VITYBELL", "PREVENTIA", "DEFEROL", "GINKGO",
                                  "NUTRIGEL", "FORTZINK", "PEDIAVIT", "GESTAVIT", "BACALAO",
                                  "PLENIV", "DELISOY", "MINERALES", "ZINC", "MAGNESIO", "CALCIO",
                                  "COLAGENO", "AQUASOL", "VIT D3", "COMPLEJO B", "BENEXOL", "GUMMY",
                                  "LIFERTRON", "GESTAFER", "CITRAGEL", "EPAPURE", "CALCITRIOL"),
  "Cuidado y dispositivos"    = c("TAPA BOCAS", "TAPABOCAS", "PROTEKTA", "TERMOMETRO",
                                  "TENSI", "AGUJA", "TEST COVID", "BASCULA")
)

asignar <- function(texto, reglas, defecto) {
  texto <- toupper(iconv(texto, to = "ASCII//TRANSLIT"))
  for (nombre in names(reglas)) {
    if (any(sapply(reglas[[nombre]], function(p) grepl(p, texto, perl = TRUE)))) return(nombre)
  }
  defecto
}

colores <- c(
  "Vitaminas y suplementos" = "#E39B2D", "Dolor e inflamación" = "#E0634F",
  "Piel" = "#5FA37A", "Salud femenina" = "#C2588F", "Ojos" = "#3E9BC2",
  "Respiratorio y alergia" = "#4E7FE0", "Diabetes" = "#1F9C93",
  "Corazón y metabolismo" = "#B23A54", "Infecciones" = "#7D5BC4",
  "Digestivo" = "#C98A3B", "Nutrición infantil" = "#E58C73",
  "Cuidado y dispositivos" = "#5E7186", "Veterinario" = "#8A6A55",
  "Salud mental y neurología" = "#5A6FB0", "Confitería" = "#E86FA6", "Otros" = "#7E8A97")

# ---------------------------------------------------------------------------
# 2. Forma farmacéutica (para dibujar la imagen con fidelidad a la presentación)
# ---------------------------------------------------------------------------
reglas_forma <- list(
  "termometro"  = c("TERMOMETRO", "TENSI", "BASCULA", "TEST COVID"),
  "glucometro"  = c("TIRAS", "LANCETA", "GLUCOMETRO", "MEDIDOR", "AGUJA", "BRAZALETE"),
  "mascarilla"  = c("TAPA BOCAS", "TAPABOCAS", "PROTEKTA"),
  "spray"       = c("AEROSOL", "SPRAY"),
  "ampolla"     = c("\\bINY", "\\bAMP", "JERINGA"),
  "lata"        = c("\\bLATA", "TARRO", "DELISOY"),
  "sobres"      = c("SOBRE", "\\bSOB\\b"),
  "gomitas"     = c("GOMAS", "\\bGTS\\b", "MINIPACK", "BOLSA", "TROLLI", "\\bHB\\b", "GUMIVIT"),
  "gotero"      = c("\\bOFT", "GOTAS", "\\bGOT\\b", "GOTx"),
  "tubo"        = c("CREMA", "UNGU", "POMADA", "\\bTUBO", "TUBx", "\\bGEL\\b"),
  "liquido"     = c("\\bJBE", "JARABE", "\\bSUSP?\\b", "LOCION", "LOTION", "\\bSOL\\b", "mL",
                    "\\bml\\b", "\\bML\\b"),
  "frasco"      = c("\\bFCO", "FRASCO"),
  "caja"        = c(".")
)

forma_de <- function(texto) asignar(texto, reglas_forma, "caja")
tipo_pastilla <- function(texto) {
  t <- toupper(texto)
  if (grepl("\\bCBG\\b|CAPS|CAPSULA|\\bCAP\\b|UNIGEL", t)) "capsula" else "tableta"
}

# ---------------------------------------------------------------------------
# 3. Ilustración SVG de cada producto
#    Dibujo vectorial de la presentación (caja, frasco, tubo...) con el nombre
#    del producto tal como aparece en los datos. No se inventan marcas ni logos.
# ---------------------------------------------------------------------------
xml <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE); x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}
mezclar <- function(col, con = "#FFFFFF", p = 0.85) {           # aclara u oscurece un color
  a <- col2rgb(col); b <- col2rgb(con)
  m <- round(a * (1 - p) + b * p)
  sprintf("#%02X%02X%02X", m[1], m[2], m[3])
}
etiqueta_de <- function(desc) {
  p <- strsplit(trimws(desc), "\\s+")[[1]]
  genericas <- c("VITAMINA", "TIRAS", "ACEITE", "OFERTA", "OB", "PROCAPS", "OXIDO", "TAPA", "VIT")
  e <- if (p[1] %in% genericas && length(p) > 1) paste(p[1], p[2]) else p[1]
  if (nchar(e) > 13) e <- substr(e, 1, 13)
  e
}
detalle_de <- function(desc) {                                  # "x 30", "120 mL", "40 g"...
  m <- regmatches(desc, regexpr("[xX] ?[0-9]+([.,][0-9]+)? ?(UND|UN|CBG|TAB|ml|mL|g|CD|AMPOLLAS)?",
                                desc))
  if (length(m) == 0) "" else gsub("^[xX] ?", "x ", m)
}

svg_producto <- function(desc, categoria, id = "p") {
  col   <- colores[[categoria]]
  osc   <- mezclar(col, "#1B1B1B", 0.30)
  muyosc<- mezclar(col, "#1B1B1B", 0.50)
  claro <- mezclar(col, "#FFFFFF", 0.88)
  medio <- mezclar(col, "#FFFFFF", 0.55)
  luz   <- mezclar(col, "#FFFFFF", 0.30)
  forma <- forma_de(desc)
  lab   <- xml(etiqueta_de(desc))
  det   <- xml(detalle_de(desc))
  fs    <- if (nchar(lab) > 10) 11 else if (nchar(lab) > 7) 13 else 15
  g     <- function(n) paste0(id, n)                       # ids únicos por imagen

  defs <- sprintf(paste0(
    '<defs>',
    '<linearGradient id="%s" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="%s"/></linearGradient>',
    '<linearGradient id="%s" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="%s"/><stop offset=".55" stop-color="%s"/><stop offset="1" stop-color="%s"/></linearGradient>',
    '<linearGradient id="%s" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="%s"/><stop offset="1" stop-color="%s"/></linearGradient>',
    '<linearGradient id="%s" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#fff" stop-opacity=".75"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></linearGradient>',
    '<radialGradient id="%s"><stop offset="0" stop-color="#000" stop-opacity=".22"/><stop offset="1" stop-color="#000" stop-opacity="0"/></radialGradient>',
    '</defs>'),
    g("bg"), claro, g("cu"), luz, col, osc, g("cv"), luz, osc, g("br"), g("so"))
  cu <- sprintf("url(#%s)", g("cu")); cv <- sprintf("url(#%s)", g("cv"))
  br <- sprintf("url(#%s)", g("br"))

  destello <- function(x, y, s = 1, o = .9) sprintf(
    '<path transform="translate(%s %s) scale(%s)" d="M0 -7 C1 -1 1 -1 7 0 C1 1 1 1 0 7 C-1 1 -1 1 -7 0 C-1 -1 -1 -1 0 -7z" fill="#fff" opacity="%s"/>',
    x, y, s, o)
  fondo <- paste0(
    sprintf('<rect width="240" height="180" rx="22" fill="url(#%s)"/>', g("bg")),
    sprintf('<circle cx="200" cy="30" r="52" fill="%s" opacity=".35"/>', medio),
    sprintf('<circle cx="30" cy="165" r="44" fill="%s" opacity=".30"/>', medio),
    sprintf('<path d="M26 34 h6 v-6 h6 v6 h6 v6 h-6 v6 h-6 v-6 h-6z" fill="%s" opacity=".35"/>', col),
    destello(212, 140, 1, .95), destello(42, 64, .7, .85), destello(196, 82, .5, .8),
    sprintf('<ellipse cx="122" cy="156" rx="78" ry="10" fill="url(#%s)"/>', g("so")))

  ajustar <- function(w, tam) min(tam, floor((w - 8) / (nchar(lab) * 0.64)))
  etiqueta <- function(x, y, w, h = 32, tam = fs) {
    tam <- ajustar(w, tam)
    sprintf(paste0(
      '<rect x="%d" y="%d" width="%d" height="%d" rx="7" fill="#fff"/>',
      '<rect x="%d" y="%d" width="%d" height="4" rx="2" fill="%s" opacity=".55"/>',
      '<text x="%d" y="%d" text-anchor="middle" font-family="Trebuchet MS,Verdana,Arial,sans-serif" ',
      'font-weight="700" font-size="%d" fill="%s">%s</text>'),
      x, y, w, h, x + 6, y + h - 7, w - 12, col,
      x + w %/% 2, y + h %/% 2 + tam %/% 3, tam, muyosc, lab)
  }
  texto_det <- function(x, y, colr = "#fff") if (det == "") "" else sprintf(
    '<text x="%d" y="%d" text-anchor="middle" font-family="Trebuchet MS,Verdana,Arial" font-size="10.5" font-weight="700" fill="%s" opacity=".9">%s</text>',
    x, y, colr, det)

  pastillas <- if (tipo_pastilla(desc) == "capsula") {
    paste0(
      '<g transform="translate(176,134) rotate(-20)"><ellipse rx="15" ry="9" fill="#F6BE3B" stroke="#D08F14" stroke-width="1.5"/><ellipse cx="-5" cy="-3.5" rx="5" ry="2.4" fill="#fff" opacity=".7"/></g>',
      '<g transform="translate(154,146) rotate(15)"><ellipse rx="15" ry="9" fill="#F6BE3B" stroke="#D08F14" stroke-width="1.5"/><ellipse cx="-5" cy="-3.5" rx="5" ry="2.4" fill="#fff" opacity=".7"/></g>')
  } else {
    paste0(
      '<g transform="translate(176,134)"><circle r="12" fill="#fff" stroke="#CDD3DB" stroke-width="2"/><path d="M-9 0 h18" stroke="#CDD3DB" stroke-width="1.6"/><ellipse cx="-4" cy="-5" rx="4" ry="2" fill="#EEF1F5"/></g>',
      '<g transform="translate(154,148)"><circle r="12" fill="#fff" stroke="#CDD3DB" stroke-width="2"/><path d="M-9 0 h18" stroke="#CDD3DB" stroke-width="1.6"/><ellipse cx="-4" cy="-5" rx="4" ry="2" fill="#EEF1F5"/></g>')
  }

  cuerpo <- switch(forma,
    caja = paste0(
      sprintf('<polygon points="60,48 74,36 184,36 170,48" fill="%s"/>', luz),
      sprintf('<polygon points="170,48 184,36 184,134 170,146" fill="%s"/>', muyosc),
      sprintf('<rect x="60" y="48" width="110" height="98" rx="4" fill="%s"/>', cu),
      sprintf('<rect x="60" y="48" width="110" height="98" rx="4" fill="%s" opacity=".35"/>', br),
      sprintf('<rect x="60" y="124" width="110" height="8" fill="%s" opacity=".45"/>', muyosc),
      '<rect x="66" y="54" width="10" height="64" rx="5" fill="#fff" opacity=".28"/>',
      etiqueta(70, 64, 90),
      texto_det(115, 113), pastillas),
    frasco = paste0(
      sprintf('<rect x="90" y="26" width="60" height="24" rx="6" fill="%s"/>', cv),
      sprintf('<path d="M90 34 h60" stroke="%s" stroke-width="2" opacity=".5"/><path d="M90 40 h60" stroke="%s" stroke-width="2" opacity=".5"/>', muyosc, muyosc),
      sprintf('<rect x="78" y="48" width="84" height="104" rx="18" fill="%s"/>', cu),
      '<rect x="86" y="56" width="10" height="84" rx="5" fill="#fff" opacity=".35"/>',
      etiqueta(84, 78, 72),
      texto_det(120, 130), pastillas),
    liquido = paste0(
      sprintf('<rect x="100" y="18" width="40" height="22" rx="5" fill="%s"/>', cv),
      sprintf('<path d="M104 40 h32 v10 q28 8 28 32 v58 q0 12 -12 12 h-64 q-12 0 -12 -12 v-58 q0 -24 28 -32z" fill="%s"/>', cu),
      '<path d="M86 74 q2 -14 14 -20" stroke="#fff" stroke-width="7" stroke-linecap="round" opacity=".35" fill="none"/>',
      '<rect x="84" y="82" width="7" height="50" rx="3.5" fill="#fff" opacity=".3"/>',
      etiqueta(84, 86, 72),
      texto_det(120, 136),
      '<path d="M174 116 h28 l-4 34 h-20z" fill="#fff" opacity=".9" stroke="#D7DCE3" stroke-width="1.5"/>',
      sprintf('<path d="M176 130 h24 l-2 18 h-20z" fill="%s" opacity=".7"/>', col)),
    gotero = paste0(
      sprintf('<path d="M113 8 q7 -6 14 0 l-1 26 h-12z" fill="%s"/>', muyosc),
      sprintf('<rect x="102" y="32" width="36" height="20" rx="5" fill="%s"/>', cv),
      sprintf('<rect x="92" y="50" width="56" height="100" rx="14" fill="%s"/>', cu),
      '<rect x="98" y="58" width="7" height="80" rx="3.5" fill="#fff" opacity=".35"/>',
      etiqueta(96, 84, 48, 30, min(fs, 10)),
      '<path d="M178 88 q12 16 0 26 q-12 -10 0 -26z" fill="#6EC6EA"/><ellipse cx="175" cy="104" rx="2.5" ry="4" fill="#fff" opacity=".7"/>',
      '<path d="M196 112 q8 11 0 17 q-8 -6 0 -17z" fill="#6EC6EA" opacity=".75"/>'),
    tubo = paste0(
      sprintf('<path d="M38 70 h124 l28 12 v22 l-28 12 h-124z" fill="%s"/>', cv),
      sprintf('<rect x="188" y="80" width="24" height="26" rx="4" fill="%s"/>', muyosc),
      '<path d="M192 84 v18 M198 84 v18 M204 84 v18" stroke="#fff" stroke-width="1.5" opacity=".3"/>',
      sprintf('<path d="M38 64 v58 l-10 -5 v-48z" fill="%s"/>', muyosc),
      '<path d="M44 75 h114" stroke="#fff" stroke-width="4" stroke-linecap="round" opacity=".4"/>',
      etiqueta(58, 79, 96, 28),
      texto_det(106, 136, osc)),
    lata = paste0(
      sprintf('<rect x="68" y="50" width="104" height="96" fill="%s"/>', cu),
      sprintf('<ellipse cx="120" cy="146" rx="52" ry="11" fill="%s"/>', osc),
      sprintf('<ellipse cx="120" cy="50" rx="52" ry="11" fill="%s"/>', luz),
      sprintf('<ellipse cx="120" cy="45" rx="52" ry="11" fill="%s"/>', muyosc),
      sprintf('<ellipse cx="120" cy="43" rx="44" ry="7" fill="%s" opacity=".6"/>', osc),
      '<rect x="76" y="60" width="10" height="78" rx="5" fill="#fff" opacity=".3"/>',
      etiqueta(78, 78, 84),
      texto_det(120, 130)),
    sobres = paste0(
      sprintf('<g transform="rotate(-12 86 96)"><rect x="50" y="46" width="72" height="98" rx="6" fill="%s"/></g>', medio),
      sprintf('<g transform="rotate(10 156 96)"><rect x="120" y="46" width="72" height="98" rx="6" fill="%s"/></g>', osc),
      sprintf('<rect x="82" y="38" width="76" height="108" rx="6" fill="%s"/>', cu),
      '<path d="M82 50 h76" stroke="#fff" stroke-dasharray="4 3" stroke-width="1.5" opacity=".8"/>',
      '<rect x="88" y="56" width="8" height="80" rx="4" fill="#fff" opacity=".3"/>',
      etiqueta(90, 78, 60, 30, min(fs, 11))),
    gomitas = paste0(
      sprintf('<path d="M68 42 h104 l10 108 q0 6 -6 6 h-112 q-6 0 -6 -6z" fill="%s"/>', cu),
      sprintf('<rect x="68" y="34" width="104" height="12" rx="3" fill="%s"/>', muyosc),
      '<path d="M70 40 h100" stroke="#fff" stroke-dasharray="3 3" opacity=".6"/>',
      '<rect x="90" y="96" width="60" height="44" rx="20" fill="#fff" opacity=".92"/>',
      '<circle cx="104" cy="114" r="8" fill="#F46B6B"/><circle cx="120" cy="122" r="8" fill="#F6BE3B"/>',
      '<circle cx="136" cy="112" r="8" fill="#6CC47C"/><circle cx="119" cy="105" r="6.5" fill="#F592B8"/>',
      '<circle cx="101" cy="111" r="2" fill="#fff" opacity=".7"/><circle cx="133" cy="109" r="2" fill="#fff" opacity=".7"/>',
      etiqueta(80, 56, 80, 30)),
    spray = paste0(
      sprintf('<rect x="96" y="18" width="48" height="16" rx="5" fill="%s"/>', muyosc),
      '<rect x="140" y="22" width="18" height="6" rx="3" fill="#A9B3BE"/>',
      sprintf('<rect x="90" y="32" width="60" height="12" rx="4" fill="%s"/>', medio),
      sprintf('<rect x="86" y="42" width="68" height="108" rx="16" fill="%s"/>', cu),
      '<rect x="93" y="50" width="8" height="88" rx="4" fill="#fff" opacity=".35"/>',
      etiqueta(92, 80, 56, 30, min(fs, 12)),
      '<circle cx="170" cy="24" r="3.5" fill="#A9B3BE" opacity=".6"/><circle cx="182" cy="19" r="2.8" fill="#A9B3BE" opacity=".45"/><circle cx="180" cy="31" r="2.2" fill="#A9B3BE" opacity=".4"/>'),
    ampolla = paste0(
      paste(sapply(c(76, 110, 144), function(x) sprintf(paste0(
        '<rect x="%d" y="62" width="24" height="74" rx="9" fill="#fff" stroke="%s" stroke-width="1.5"/>',
        '<rect x="%d" y="42" width="12" height="24" rx="5" fill="#fff" stroke="%s" stroke-width="1.5"/>',
        '<rect x="%d" y="90" width="24" height="46" rx="9" fill="%s" opacity=".85"/>',
        '<rect x="%d" y="68" width="4" height="60" rx="2" fill="#fff" opacity=".8"/>'),
        x, medio, x + 6, medio, x, col, x + 4)), collapse = ""),
      sprintf('<rect x="66" y="138" width="112" height="18" rx="5" fill="%s"/>', cv),
      sprintf('<text x="122" y="151" text-anchor="middle" font-family="Trebuchet MS,Verdana,Arial" font-weight="700" font-size="%d" fill="#fff">%s</text>', ajustar(110, 11), lab)),
    glucometro = paste0(
      sprintf('<rect x="68" y="30" width="78" height="120" rx="22" fill="%s"/>', cu),
      '<rect x="78" y="42" width="58" height="42" rx="8" fill="#EAF6F4"/>',
      sprintf('<text x="107" y="70" text-anchor="middle" font-family="Courier New,monospace" font-weight="700" font-size="15" fill="%s">mg/dL</text>', muyosc),
      '<circle cx="93" cy="104" r="8" fill="#fff" opacity=".85"/><circle cx="121" cy="104" r="8" fill="#fff" opacity=".85"/>',
      '<rect x="74" y="36" width="8" height="100" rx="4" fill="#fff" opacity=".25"/>',
      '<rect x="98" y="146" width="20" height="20" rx="2" fill="#FAFAFA" stroke="#CDD3DB"/>',
      sprintf('<rect x="154" y="66" width="50" height="76" rx="8" fill="%s"/>', cv),
      sprintf('<text x="179" y="108" text-anchor="middle" font-family="Trebuchet MS,Verdana,Arial" font-weight="700" font-size="%d" fill="#fff">%s</text>', ajustar(52, 10), lab)),
    mascarilla = paste0(
      '<path d="M50 78 q-24 4 -20 26 q4 18 24 13" fill="none" stroke="#A9B3BE" stroke-width="3.5"/>',
      '<path d="M190 78 q24 4 20 26 q-4 18 -24 13" fill="none" stroke="#A9B3BE" stroke-width="3.5"/>',
      sprintf('<path d="M50 64 q70 -20 140 0 v56 q-70 30 -140 0z" fill="%s"/>', medio),
      sprintf('<path d="M54 82 q66 -12 132 0 M54 98 q66 -12 132 0 M54 114 q66 -8 132 0" stroke="%s" stroke-width="2.2" fill="none" opacity=".55"/>', col),
      '<path d="M60 70 q60 -14 120 0" stroke="#fff" stroke-width="4" opacity=".5" fill="none"/>',
      sprintf('<rect x="78" y="136" width="84" height="22" rx="6" fill="%s"/>', cv),
      sprintf('<text x="120" y="151" text-anchor="middle" font-family="Trebuchet MS,Verdana,Arial" font-weight="700" font-size="%d" fill="#fff">%s</text>', ajustar(84, 11), lab)),
    termometro = paste0(
      sprintf('<rect x="54" y="78" width="136" height="28" rx="14" fill="%s"/>', cu),
      '<rect x="64" y="85" width="58" height="14" rx="4" fill="#EAF6F4"/>',
      sprintf('<text x="93" y="96" text-anchor="middle" font-family="Courier New,monospace" font-weight="700" font-size="11" fill="%s">36.5°</text>', muyosc),
      '<rect x="188" y="87" width="22" height="10" rx="5" fill="#CDD3DB"/>',
      '<path d="M66 82 h110" stroke="#fff" stroke-width="3" stroke-linecap="round" opacity=".35"/>',
      sprintf('<text x="122" y="136" text-anchor="middle" font-family="Trebuchet MS,Verdana,Arial" font-weight="700" font-size="13" fill="%s">%s</text>', muyosc, lab))
  )

  paste0('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 180" role="img" aria-label="',
         xml(desc), '">', defs, fondo, cuerpo, '</svg>')
}

# ---------------------------------------------------------------------------
# 4. Catálogo enriquecido
# ---------------------------------------------------------------------------
genericas <- c("VITAMINA", "TIRAS", "ACEITE", "OFERTA", "PROTEKTA")
productos <- catalogo %>%
  mutate(categoria = sapply(description, asignar, reglas = reglas_categoria, defecto = "Otros"),
         forma     = sapply(description, forma_de),
         familia   = sapply(strsplit(description, "\\s+"), function(p)
                       if (p[1] %in% genericas && length(p) > 1) paste(p[1], p[2]) else p[1]),
         color     = unname(colores[categoria])) %>%
  left_join(datos %>% group_by(Material) %>%
              summarise(compradores = n_distinct(colaborador), unidades = sum(cantidad),
                        desde = min(fecha), .groups = "drop"), by = "Material") %>%
  mutate(nombre_corto = tools::toTitleCase(tolower(description)),
         busqueda     = toupper(iconv(description, to = "ASCII//TRANSLIT"))) %>%
  arrange(desc(compradores))

# imágenes
for (i in seq_len(nrow(productos))) {
  writeLines(svg_producto(productos$description[i], productos$categoria[i], paste0("p", productos$Material[i])),
             file.path("app/www/img", paste0(productos$Material[i], ".svg")), useBytes = TRUE)
}

# ---------------------------------------------------------------------------
# 5. Recomendaciones ítem–ítem (Fase 5: coseno con α = 0,25), 20 por producto
#    La app separa "otras presentaciones" (misma familia) del resto.
# ---------------------------------------------------------------------------
n_compradores <- colSums(X > 0)
rec_item <- bind_rows(lapply(colnames(S), function(p) {
  s <- S[, p]
  ok <- names(s)[s > 0 & names(s) != p]
  if (length(ok) == 0) return(NULL)
  puntaje <- s[ok] / n_compradores[ok]^0.25
  top <- head(ok[order(puntaje, decreasing = TRUE)], 20)
  tibble(Material_base = p, Material = top, similitud = unname(s[top]),
         en_comun = unname(comunes[top, p]))
})) %>%
  group_by(Material_base) %>% mutate(puesto = row_number()) %>% ungroup()

# ---------------------------------------------------------------------------
# 6. Recomendaciones usuario–usuario (Fase 6) e historiales
# ---------------------------------------------------------------------------
rec_usuario <- fase6$recomendaciones %>%
  select(colaborador, puesto, Material, n_vecinos, puntaje, explicacion)

historial <- fase6$historial %>%
  select(colaborador, Material, unidades, facturas, ultima_compra)

compradores <- datos %>%
  group_by(colaborador) %>%
  summarise(facturas = n_distinct(invoice), productos = n_distinct(Material),
            unidades = sum(cantidad), desde = min(fecha), hasta = max(fecha),
            .groups = "drop") %>%
  arrange(desc(facturas))

# ---------------------------------------------------------------------------
# 7. Guardar
# ---------------------------------------------------------------------------
saveRDS(list(productos = productos, rec_item = rec_item, rec_usuario = rec_usuario,
             historial = historial, compradores = compradores, colores = colores,
             k = fase6$k, min_vecinos = fase6$min_vecinos,
             generado = Sys.time()),
        "app/datos_app.rds")

write_json(list(
  productos = productos %>% select(Material, description, categoria, forma, compradores),
  recomendaciones_producto = rec_item,
  recomendaciones_comprador = rec_usuario),
  "app/recomendaciones.json", auto_unbox = TRUE, digits = 4)

cat("Listo:", nrow(productos), "productos,", n_distinct(rec_usuario$colaborador),
    "compradores y", length(list.files("app/www/img")), "imágenes en app/\n")
