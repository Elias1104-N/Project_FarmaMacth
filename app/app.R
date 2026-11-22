# ============================================================================
# FarmaMatch · prototipo del recomendador farmacéutico (Proyecto 4)
# Con Dr. Pildo, la mascota que presenta las recomendaciones.
# ----------------------------------------------------------------------------
# Abrir este archivo en RStudio y pulsar "Run App".
# Necesita app/datos_app.rds y app/www/img/, que crea preparar_app.R.
# ============================================================================

library(shiny)
library(bslib)
library(dplyr)
source("mascota.R", local = TRUE)

d <- readRDS("datos_app.rds")
productos   <- d$productos
colores     <- d$colores
info        <- split(productos, productos$Material)
rec_item    <- split(d$rec_item, d$rec_item$Material_base)
rec_usuario <- split(d$rec_usuario, d$rec_usuario$colaborador)
historial   <- split(d$historial, d$historial$colaborador)
compradores <- d$compradores
info_comprador <- split(compradores, compradores$colaborador)

top_ventas <- productos %>% arrange(desc(unidades))
formas <- c(caja = "Caja", frasco = "Frasco", liquido = "Jarabe o líquido", gotero = "Gotas",
            tubo = "Tubo (crema o ungüento)", lata = "Lata o tarro", sobres = "Sobres",
            gomitas = "Gomas o empaque individual", spray = "Spray o aerosol",
            ampolla = "Inyectable", glucometro = "Control de glucosa", mascarilla = "Tapabocas",
            termometro = "Dispositivo")

# ---------------------------------------------------------------------------
# Utilidades de presentación
# ---------------------------------------------------------------------------
fmt <- function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE, trim = TRUE)
nombre_bonito <- function(m) info[[m]]$nombre_corto
img <- function(m, clase = "img") tags$img(src = paste0("img/", m, ".svg"), class = clase,
                                           alt = info[[m]]$description, loading = "lazy")
pildora_cat <- function(cat) span(class = "pill",
  style = sprintf("--c:%s", colores[[cat]]), span(class = "dot"), cat)
ir_a <- function(m) sprintf("Shiny.setInputValue('ir_producto','%s',{priority:'event'})", m)

nivel_afinidad <- function(s) {
  if (s >= 0.5) list(txt = "Muy alta", n = 4)
  else if (s >= 0.35) list(txt = "Alta", n = 3)
  else if (s >= 0.2) list(txt = "Media", n = 2)
  else list(txt = "Baja", n = 1)
}
barras <- function(n) span(class = "barras", lapply(1:4, function(i)
  span(class = if (i <= n) "b on" else "b")))

meses <- c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")
fecha_corta <- function(f) paste(meses[as.integer(format(f, "%m"))], format(f, "%Y"))

tarjeta_producto <- function(m, cuerpo = NULL, pie = NULL, favorito = FALSE) {
  p <- info[[m]]
  div(class = paste("card-prod", if (favorito) "favorito"), onclick = ir_a(m), tabindex = 0, role = "button",
      `aria-label` = paste("Ver productos similares a", p$nombre_corto),
      div(class = "card-img", img(m),
          if (favorito) span(class = "sello", icon("paw"), "Favorito de Dr. Pildo")),
      div(class = "card-body2",
          pildora_cat(p$categoria),
          h4(class = "card-title2", p$nombre_corto),
          cuerpo),
      if (!is.null(pie)) div(class = "card-pie", pie))
}

# opciones de los buscadores (con color de categoría para el menú)
opciones_productos <- productos %>%
  transmute(value = Material, label = nombre_corto, cat = categoria, color = color,
            compradores = compradores)
opciones_compradores <- compradores %>%
  transmute(value = colaborador,
            label = paste0("Comprador ", colaborador),
            detalle = paste0(productos, " productos · cliente desde ", format(desde, "%Y")))

render_prod <- I("{
  option: function(item, escape) {
        return '<div class=\"opt\"><span class=\"dot\" style=\"width:34px;height:34px;border-radius:8px;background:url(img/' + escape(item.value) + '.svg) center/contain no-repeat\"></span>' +
           '<span class=\"opt-txt\">' + escape(item.label) + '</span>' +
           '<span class=\"opt-cat\">' + escape(item.cat) + '</span></div>';
  },
  item: function(item, escape) {
    return '<div><span class=\"dot\" style=\"background:' + item.color + '\"></span>' + escape(item.label) + '</div>';
  }
}")
render_comp <- I("{
  option: function(item, escape) {
    return '<div class=\"opt\"><span class=\"opt-txt\">' + escape(item.label) + '</span>' +
           '<span class=\"opt-cat\">' + escape(item.detalle) + '</span></div>';
  }
}")

# ---------------------------------------------------------------------------
# Interfaz
# ---------------------------------------------------------------------------
ui <- page_fluid(
  theme = bs_theme(version = 5, bg = "#FFF9F2", fg = "#23312D", primary = "#1F8A72",
                   base_font = font_collection("Nunito", "Segoe UI", "Helvetica", "Arial", "sans-serif"),
                   heading_font = font_collection("Fredoka", "Nunito", "Segoe UI", "sans-serif")),
  title = "FarmaMatch · recomendaciones para farmacias",
  tags$head(
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
    tags$link(rel = "stylesheet",
              href = "https://fonts.googleapis.com/css2?family=Fredoka:wght@500;600;700&family=Nunito:wght@400;600;700;800&display=swap"),
    tags$link(rel = "stylesheet", href = "estilo.css"),
    tags$script(HTML("
      $(document).on('keydown', '.card-prod', function(e){ if(e.key==='Enter'){ $(this).click(); } });
      Shiny.addCustomMessageHandler('arriba', function(x){ window.scrollTo({top:0, behavior:'smooth'}); });
      Shiny.addCustomMessageHandler('tab_activo', function(v){
        $('.menu .tab').removeClass('activo');
        $('#ir_' + v).addClass('activo');
      });
    "))
  ),

  # ---- cabecera ----
  div(class = "cabecera",
      div(class = "marca",
          div(class = "logo-pildo", mascota("guino", "logo-svg")),
          div(h1(HTML("Farma<span>Match</span>")),
              p("Lo que tu farmacia necesita, según 250.748 facturas reales"))),
      div(class = "menu",
          actionLink("ir_productos",   span("Explorar productos"),   class = "tab activo"),
          actionLink("ir_compradores", span("Para un comprador"),    class = "tab"),
          actionLink("ir_como",        span("¿Cómo funciona?"),      class = "tab"))),

  navset_hidden(id = "vista",

    # ======================= VISTA PRODUCTO =======================
    nav_panel_hidden("productos",
      div(class = "buscador con-pildo",
          div(class = "buscador-txt",
          h2("¿Qué producto estás mirando?"),
          p(class = "sub", "Escribe parte del nombre: vitamina, clotrimazol, jarabe, tiras…"),
          selectizeInput("producto", NULL, choices = NULL, width = "100%",
                         options = list(placeholder = "Buscar un producto por su nombre",
                                        maxOptions = 40, render = render_prod, dropdownParent = "body",
                                        searchField = c("label", "cat")))),
          div(class = "buscador-pildo", mascota("feliz"))),
      uiOutput("vista_producto")),

    # ======================= VISTA COMPRADOR =======================
    nav_panel_hidden("compradores",
      div(class = "buscador",
          h2("Recomendaciones para un comprador"),
          p(class = "sub", "Elige un comprador para ver lo que ya compra y lo que le recomendamos."),
          div(class = "fila-buscar",
              selectizeInput("comprador", NULL, choices = NULL, width = "100%",
                             options = list(placeholder = "Buscar por código de comprador",
                                            maxOptions = 30, render = render_comp, dropdownParent = "body")),
              actionButton("azar", "Sorpréndeme", class = "btn-azar",
                           icon = icon("shuffle", lib = "font-awesome")))),
      uiOutput("vista_comprador")),

    # ======================= CÓMO FUNCIONA =======================
    nav_panel_hidden("como", uiOutput("vista_como"))
  ),

  div(class = "pie", "FarmaMatch · Proyecto 4 · Estadística Industrial 2026-II · Datos de facturación 2013–2022. ",
      "Las imágenes son ilustraciones de la presentación de cada producto, no fotografías. ",
      "Dr. Pildo es una mascota original creada para este proyecto.")
)

# ---------------------------------------------------------------------------
# Servidor
# ---------------------------------------------------------------------------
server <- function(input, output, session) {

  updateSelectizeInput(session, "producto", choices = opciones_productos, server = TRUE,
                       selected = character(0))
  updateSelectizeInput(session, "comprador", choices = opciones_compradores, server = TRUE,
                       selected = character(0))

  # ---- navegación ----
  cambiar_vista <- function(v) {
    nav_select("vista", v)
    session$sendCustomMessage("arriba", TRUE)
    session$sendCustomMessage("tab_activo", v)
  }
  observeEvent(input$ir_productos,   cambiar_vista("productos"))
  observeEvent(input$ir_compradores, cambiar_vista("compradores"))
  observeEvent(input$ir_como,        cambiar_vista("como"))

  observeEvent(input$ir_producto, {
    updateSelectizeInput(session, "producto", choices = opciones_productos, server = TRUE,
                         selected = input$ir_producto)
    cambiar_vista("productos")
  })
  observeEvent(input$ir_comprador, {
    updateSelectizeInput(session, "comprador", choices = opciones_compradores, server = TRUE,
                         selected = input$ir_comprador)
    cambiar_vista("compradores")
  })
  observeEvent(input$azar, {
    cl <- sample(compradores$colaborador[compradores$productos >= 8], 1)
    updateSelectizeInput(session, "comprador", choices = opciones_compradores, server = TRUE,
                         selected = cl)
  })

  # ---------------- VISTA PRODUCTO ----------------
  output$vista_producto <- renderUI({
    m <- input$producto
    if (is.null(m) || m == "" || is.null(info[[m]])) return(inicio_productos())
    p <- info[[m]]
    recs <- rec_item[[m]]

    cabecera <- div(class = "hero",
      div(class = "hero-img", img(m)),
      div(class = "hero-info",
          pildora_cat(p$categoria),
          h2(p$nombre_corto),
          div(class = "chips",
              span(class = "chip", icon("prescription-bottle-medical"), formas[[p$forma]]),
              span(class = "chip", icon("file-medical"),
                   if (identical(p$`formula medica`, "SI")) "Requiere fórmula médica" else "Venta libre"),
              span(class = "chip", icon("receipt"), paste0("IVA ", p$IVA, " %"))),
          div(class = "stats",
              div(span(class = "num", fmt(p$compradores)), span("compradores")),
              div(span(class = "num", fmt(p$unidades)), span("unidades vendidas")),
              div(span(class = "num", format(p$desde, "%Y")), span("primera venta")))))

    if (is.null(recs) || nrow(recs) == 0) {
      alternativa <- top_ventas %>% filter(categoria == p$categoria, Material != m) %>% head(4)
      if (nrow(alternativa) == 0) alternativa <- top_ventas %>% filter(Material != m) %>% head(4)
      return(tagList(cabecera,
        dice(expresion = "pensando", clase = "pildo-aviso",
             "Mmm… a este producto lo han pedido muy pocos compradores, así que todavía no tengo pistas suficientes para recomendar con confianza. Mientras tanto, te muestro los más pedidos de ",
             tolower(p$categoria), "."),
        div(class = "grid", lapply(alternativa$Material, function(a) tarjeta_producto(a,
            p(class = "expl", "Uno de los más vendidos en ", tolower(info[[a]]$categoria), ".")))) ))
    }

    misma <- recs$Material[sapply(recs$Material, function(x) info[[x]]$familia) == p$familia]
    otras <- recs %>% filter(!Material %in% misma) %>% head(8)
    pres  <- recs %>% filter(Material %in% misma) %>% head(6)

    top1 <- otras[1, ]
    globo <- dice(expresion = "feliz",
      HTML(sprintf("¡Guau! Olfateé las compras de los <b>%s</b> compradores de <i>%s</i>. Mi favorito para acompañarlo es <b>%s</b>: lo llevaron <b>%s</b> de ellos.",
                   fmt(p$compradores), p$nombre_corto, info[[top1$Material]]$nombre_corto, fmt(top1$en_comun))))

    tarjetas <- lapply(seq_len(nrow(otras)), function(i) {
      r <- otras[i, ]; a <- nivel_afinidad(r$similitud)
      tarjeta_producto(r$Material, favorito = (i == 1),
        cuerpo = tagList(
          div(class = "afinidad", barras(a$n), span(paste("Afinidad", tolower(a$txt)))),
          p(class = "expl", HTML(sprintf("<b>%s</b> compradores de <i>%s</i> también compraron este producto.",
                                         fmt(r$en_comun), p$nombre_corto)))),
        pie = span("Ver similares", icon("arrow-right")))
    })

    tagList(
      cabecera,
      div(class = "seccion",
          h3("Quienes compran este producto también compran"),
          p(class = "sub", "Ordenado por afinidad: qué tanto coinciden los compradores de ambos productos.")),
      globo,
      div(class = "grid", tarjetas),
      if (length(pres) && nrow(pres) > 0) tagList(
        div(class = "seccion",
            h3("Otras presentaciones de la misma línea"),
            p(class = "sub", "Mismo producto en otro tamaño, concentración o empaque.")),
        div(class = "tira", lapply(pres$Material, function(x)
          div(class = "mini", onclick = ir_a(x), tabindex = 0, role = "button",
              img(x, "mini-img"), span(info[[x]]$nombre_corto)))))
    )
  })

  inicio_productos <- function() {
    destacados <- productos %>% filter(categoria != "Otros") %>%
      group_by(categoria) %>% slice_max(compradores, n = 1, with_ties = FALSE) %>%
      ungroup() %>% arrange(desc(compradores)) %>% head(8)
    tagList(
      dice(expresion = "feliz",
           HTML("¡Hola! Soy <b>Dr. Pildo</b>, el farmacéutico de FarmaMatch. Escribe un producto arriba y te cuento qué más llevan quienes lo compran. ¿No sabes por dónde empezar? Aquí tienes el más pedido de cada categoría.")),
      div(class = "grid", lapply(destacados$Material, function(m) tarjeta_producto(m,
          p(class = "expl", fmt(info[[m]]$compradores), " compradores lo han pedido."),
          pie = span("Ver similares", icon("arrow-right"))))))
  }

  # ---------------- VISTA COMPRADOR ----------------
  output$vista_comprador <- renderUI({
    cl <- input$comprador
    if (is.null(cl) || cl == "" || is.null(info_comprador[[cl]])) {
      ejemplos <- compradores %>% filter(productos >= 15, productos <= 40) %>% slice(c(1, 50, 200, 600))
      return(tagList(
        dice(expresion = "guino",
             HTML("Elige un comprador y revisaré su historial para encontrar lo que <b>todavía no ha pedido</b>. Puedes empezar con uno de estos o pulsar «Sorpréndeme».")),
        div(class = "grid grid-comp", lapply(ejemplos$colaborador, function(x) {
          cmp <- info_comprador[[x]]
          div(class = "card-comp", onclick = sprintf("Shiny.setInputValue('ir_comprador','%s',{priority:'event'})", x),
              tabindex = 0, role = "button",
              div(class = "avatar", substr(x, nchar(x) - 1, nchar(x))),
              div(h4(paste("Comprador", x)),
                  p(fmt(cmp$facturas), " facturas · ", cmp$productos, " productos · desde ",
                    format(cmp$desde, "%Y"))))
        }))))
    }

    cmp  <- info_comprador[[cl]]
    hist <- historial[[cl]] %>% arrange(desc(ultima_compra))
    recs <- rec_usuario[[cl]]
    hist$categoria <- sapply(hist$Material, function(x) info[[x]]$categoria)
    cats <- sort(table(hist$categoria), decreasing = TRUE)
    favorita <- names(cats)[1]

    barra_cats <- div(class = "barra-cats", lapply(names(cats), function(cn)
      span(style = sprintf("flex:%d;background:%s", cats[[cn]], colores[[cn]]),
           title = paste0(cn, ": ", cats[[cn]], " productos"))))

    perfil <- div(class = "perfil",
      div(class = "avatar grande", substr(cl, nchar(cl) - 1, nchar(cl))),
      div(class = "perfil-info",
          h2(paste("Comprador", cl)),
          p(class = "sub", "Cliente desde ", fecha_corta(cmp$desde), " · última compra ", fecha_corta(cmp$hasta)),
          div(class = "stats",
              div(span(class = "num", fmt(cmp$facturas)), span("facturas")),
              div(span(class = "num", cmp$productos), span("productos distintos")),
              div(span(class = "num", fmt(cmp$unidades)), span("unidades")),
              div(span(class = "num fav", favorita), span("categoría favorita")))))

    lista_hist <- div(class = "historial",
      lapply(seq_len(nrow(hist)), function(i) {
        h <- hist[i, ]
        div(class = "fila-hist", onclick = ir_a(h$Material), tabindex = 0, role = "button",
            img(h$Material, "hist-img"),
            div(class = "hist-txt", span(class = "hist-nombre", info[[h$Material]]$nombre_corto),
                span(class = "hist-meta", h$unidades, if (h$unidades == 1) " unidad" else " unidades",
                     " · última vez en ", fecha_corta(h$ultima_compra))))
      }))

    tarjetas <- if (is.null(recs) || nrow(recs) == 0) {
      div(class = "aviso", icon("circle-info"), "No hay suficientes compradores parecidos para recomendar.")
    } else div(class = "grid grid-2", lapply(seq_len(nrow(recs)), function(i) {
      r <- recs[i, ]
      tarjeta_producto(r$Material, favorito = (i == 1),
        cuerpo = tagList(
          div(class = "afinidad",
              barras(if (r$n_vecinos >= 20) 4 else if (r$n_vecinos >= 12) 3 else if (r$n_vecinos >= 6) 2 else 1),
              span(if (r$n_vecinos >= 20) "Recomendación fuerte" else if (r$n_vecinos >= 12)
                     "Buena coincidencia" else if (r$n_vecinos >= 6) "Coincidencia media" else "Coincidencia baja")),
          p(class = "expl", HTML(sprintf(
            "Lo compraron <b>%s de los %s</b> compradores con compras más parecidas a las de este comprador, que todavía no lo ha pedido.",
            r$n_vecinos, d$k)))),
        pie = span("Ver producto", icon("arrow-right")))
    }))

    tagList(
      perfil,
      div(class = "dos-col",
          div(class = "col-hist",
              h3("Lo que ya compra"),
              p(class = "sub", nrow(hist), " productos, del más reciente al más antiguo"),
              barra_cats,
              lista_hist),
          div(class = "col-recs",
              dice(expresion = "feliz", clase = "pildo-compacto",
                   HTML(sprintf("Busqué a los <b>%s compradores</b> con compras más parecidas a las de este cliente y encontré <b>%s productos</b> que ellos llevan y este cliente todavía no ha pedido. ¡Ninguno repetido!",
                                d$k, if (is.null(recs)) 0 else nrow(recs)))),
              h3("Le recomendamos"),
              div(class = "garantia", icon("circle-check"),
                  "Ninguno de estos productos está en su historial de compras."),
              tarjetas)))
  })

  # ---------------- CÓMO FUNCIONA ----------------
  output$vista_como <- renderUI({
    div(class = "como",
      dice(expresion = "guino", HTML("Te explico mi truco: <b>no adivino</b>. Miro qué compran juntas miles de farmacias y busco patrones. Así de simple… ¡y así de olfateado!")),
      h2("¿Cómo elige FarmaMatch qué recomendar?"),
      div(class = "pasos",
        div(class = "paso", span(class = "n", "1"), h4("Mira quién compra qué"),
            p("Revisamos 250.748 facturas de 5.888 compradores entre 2013 y 2022. Cada comprador tiene una lista de productos y de cuánto ha comprado de cada uno.")),
        div(class = "paso", span(class = "n", "2"), h4("Busca coincidencias"),
            p("Dos productos se parecen cuando los compran las mismas personas. Dos compradores se parecen cuando compran los mismos productos.")),
        div(class = "paso", span(class = "n", "3"), h4("Recomienda lo que falta"),
            p("A un comprador le mostramos lo que compran sus 50 compradores más parecidos y él todavía no tiene. Nunca le recomendamos algo que ya compró."))),
      h3("¿Funciona mejor que mostrar lo más vendido?"),
      p(class = "sub", "Lo probamos con datos reales: aprendimos con las compras hasta 2020 y miramos qué compraron por primera vez en 2021 y 2022."),
      div(class = "metricas",
        div(class = "metrica", span(class = "grande", "65,6 %"),
            span("de los compradores compró al menos uno de los 10 productos que les recomendamos")),
        div(class = "metrica base", span(class = "grande", "62,5 %"),
            span("con la lista fija de los 10 más vendidos")),
        div(class = "metrica", span(class = "grande", "263"),
            span("productos distintos recomendados, frente a solo 76 de la lista de más vendidos"))),
      p(class = "nota", "La diferencia es estadísticamente significativa (prueba de McNemar, p < 0,001). ",
        "Dr. Pildo es una mascota original dibujada en SVG para este proyecto. ",
        "Las imágenes son ilustraciones generadas por código según la presentación de cada producto (caja, frasco, tubo, gotero…); ",
        "muestran el nombre tal como aparece en las facturas y no reproducen logos ni empaques reales. ",
        "Las categorías son aproximadas, asignadas por palabras clave del nombre."))
  })
}

shinyApp(ui, server)
