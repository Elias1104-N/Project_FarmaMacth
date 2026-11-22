# ============================================================================
# Dr. Pildo · mascota original de FarmaMatch
# Un cachorro color caramelo con orejas chocolate, gafas redondas, bata de
# farmacéutico y una cápsula en el collar. Dibujado a mano en SVG para este
# proyecto (no está basado en ningún personaje existente).
#   expresion: "feliz" (saluda), "pensando" (pata en el mentón), "guino"
# ============================================================================

mascota <- function(expresion = "feliz", clase = "mascota") {
  caramelo <- "#E7A35F"; caramelo_osc <- "#C98243"; crema <- "#FFF1DC"
  chocolate <- "#7A4A2E"; menta <- "#2BA387"; bata <- "#FFFFFF"; linea <- "#3B2A22"

  ojos <- switch(expresion,
    pensando = '<circle cx="66" cy="70" r="5.5" fill="#3B2A22"/><circle cx="94" cy="70" r="5.5" fill="#3B2A22"/>
                <circle cx="68" cy="67" r="2" fill="#fff"/><circle cx="96" cy="67" r="2" fill="#fff"/>',
    guino    = '<path d="M60 73 q6 -6 12 0" stroke="#3B2A22" stroke-width="3" fill="none" stroke-linecap="round"/>
                <circle cx="94" cy="72" r="6" fill="#3B2A22"/><circle cx="96" cy="69.5" r="2.2" fill="#fff"/>',
               '<circle cx="66" cy="72" r="6" fill="#3B2A22"/><circle cx="94" cy="72" r="6" fill="#3B2A22"/>
                <circle cx="68" cy="69.5" r="2.2" fill="#fff"/><circle cx="96" cy="69.5" r="2.2" fill="#fff"/>')

  boca <- switch(expresion,
    pensando = '<path d="M74 98 q6 -3 12 0" stroke="#3B2A22" stroke-width="2.5" fill="none" stroke-linecap="round"/>',
               '<path d="M70 95 q10 10 20 0" stroke="#3B2A22" stroke-width="2.5" fill="#B9473F" stroke-linecap="round"/>
                <path d="M76 100 q4 6 8 0" fill="#F28B8B"/>')

  pata <- switch(expresion,
    pensando = sprintf('<ellipse cx="96" cy="112" rx="11" ry="9" fill="%s" stroke="%s" stroke-width="1.5"/>
                        <path d="M90 108 v5 M96 107 v6 M102 108 v5" stroke="%s" stroke-width="1.3" opacity=".5"/>', caramelo, caramelo_osc, caramelo_osc),
    sprintf('<g class="pata-saludo"><path d="M118 136 q14 -22 22 -40" stroke="%s" stroke-width="15" stroke-linecap="round" fill="none"/>
             <ellipse cx="141" cy="92" rx="11" ry="10" fill="%s" stroke="%s" stroke-width="1.5"/>
             <path d="M135 88 v5 M141 86 v6 M147 88 v5" stroke="%s" stroke-width="1.3" opacity=".5"/></g>', bata, caramelo, caramelo_osc, caramelo_osc))

  HTML(sprintf('
<svg class="%s" viewBox="0 0 160 190" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Dr. Pildo, la mascota de FarmaMatch">
  <ellipse cx="80" cy="182" rx="46" ry="6" fill="#000" opacity=".10"/>
  <!-- cuerpo con bata -->
  <path d="M36 186 q-4 -48 22 -64 h44 q26 16 22 64z" fill="%s" stroke="#E3E7EA" stroke-width="2"/>
  <path d="M68 122 l12 22 l12 -22" fill="%s"/>
  <path d="M58 122 l22 30 l22 -30" fill="none" stroke="#E3E7EA" stroke-width="2"/>
  <path d="M80 152 v34" stroke="#E3E7EA" stroke-width="2"/>
  <rect x="94" y="156" width="20" height="16" rx="3" fill="none" stroke="#E3E7EA" stroke-width="2"/>
  <path d="M100 152 v10" stroke="%s" stroke-width="3" stroke-linecap="round"/>
  <g transform="translate(55 160)"><rect x="-7" y="-2.5" width="14" height="5" rx="1.5" fill="%s"/><rect x="-2.5" y="-7" width="5" height="14" rx="1.5" fill="%s"/></g>
  %s
  <!-- collar con cápsula -->
  <path d="M56 118 q24 12 48 0" stroke="%s" stroke-width="7" fill="none" stroke-linecap="round"/>
  <g transform="translate(80 128) rotate(-15)"><rect x="-10" y="-5" width="20" height="10" rx="5" fill="#F6BE3B"/><rect x="0" y="-5" width="10" height="10" rx="5" fill="#fff"/><rect x="-1" y="-5" width="2" height="10" fill="#F6BE3B"/></g>
  <!-- orejas -->
  <path d="M42 50 q-22 6 -20 40 q2 18 16 14 q8 -2 8 -20z" fill="%s"/>
  <path d="M118 50 q22 6 20 40 q-2 18 -16 14 q-8 -2 -8 -20z" fill="%s"/>
  <!-- cabeza -->
  <ellipse cx="80" cy="74" rx="40" ry="38" fill="%s"/>
  <path d="M60 40 q20 -14 40 0 q-20 6 -40 0z" fill="%s" opacity=".55"/>
  <ellipse cx="80" cy="92" rx="22" ry="17" fill="%s"/>
  <!-- gafas -->
  <circle cx="66" cy="72" r="12" fill="#fff" fill-opacity=".25" stroke="%s" stroke-width="3"/>
  <circle cx="94" cy="72" r="12" fill="#fff" fill-opacity=".25" stroke="%s" stroke-width="3"/>
  <path d="M78 72 q2 -3 4 0" stroke="%s" stroke-width="3" fill="none"/>
  %s
  <!-- nariz y boca -->
  <ellipse cx="80" cy="85" rx="7" ry="5" fill="%s"/>
  <ellipse cx="78" cy="83.5" rx="2.2" ry="1.3" fill="#fff" opacity=".6"/>
  <path d="M80 90 v4" stroke="#3B2A22" stroke-width="2.2"/>
  %s
  <!-- mejillas -->
  <circle cx="54" cy="90" r="5" fill="#F28B8B" opacity=".45"/><circle cx="106" cy="90" r="5" fill="#F28B8B" opacity=".45"/>
  %s
</svg>', clase, bata, crema, menta, menta, menta,
     "", menta, chocolate, chocolate, caramelo, caramelo_osc, crema,
     menta, menta, menta, ojos, linea, boca, pata))
}

# Mascota + globo de diálogo
dice <- function(..., expresion = "feliz", clase = "") {
  div(class = paste("pildo", clase),
      div(class = "pildo-fig", mascota(expresion)),
      div(class = "globo", span(class = "globo-nombre", "Dr. Pildo"), div(...)))
}
