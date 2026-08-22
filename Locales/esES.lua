local _, BD = ...

local L = {}
BD.RegisterLocale("esES", L)

L["PlateSCT is in Beta"] = "PlateSCT está en beta"
L["This addon is in Beta mode. Inaccuracies and errors may show up. Please report such issues on the addon's page."] =
    "Este addon está en modo beta. Pueden aparecer imprecisiones y errores. Informa de estos problemas en la página del addon."
L["Reset PlateSCT settings to defaults?"] = "¿Restablecer la configuración de PlateSCT a los valores predeterminados?"
L["Addon page"] = "Página del addon"
L["Select the URL below, copy it, then paste it in your browser."] =
    "Selecciona la URL de abajo, cópiala y pégala en tu navegador."
L["Click to open the addon page URL."] = "Haz clic para abrir la URL de la página del addon."
L["/platesct  ·  ESC to close"] = "/platesct  ·  ESC para cerrar"
L["PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."] =
    "PlateSCT usa su propia ventana de configuración.\n\nEscribe /platesct en el chat o haz clic en el botón de abajo."
L["Open PlateSCT"] = "Abrir PlateSCT"
L["Target something to preview test numbers."] = "Selecciona un objetivo para previsualizar números de prueba."
L["Meter probe"] = "Sonda del medidor"
L["Click the box, Ctrl+A, then Ctrl+C, and paste it in chat."] =
    "Haz clic en el cuadro, Ctrl+A, luego Ctrl+C, y pégalo en el chat."

L["General"] = "General"
L["Display"] = "Visualización"
L["Damage"] = "Daño"
L["Tools"] = "Herramientas"
L["Choose whose damage and which nameplates to show."] =
    "Elige qué daño y qué placas de nombre mostrar."
L["Control how numbers look and how they animate."] =
    "Controla el aspecto y la animación de los números."
L["Hide small hits so the big numbers stay readable."] =
    "Oculta los golpes pequeños para que los números grandes sigan legibles."
L["Preview numbers and maintain your setup."] =
    "Previsualiza números y mantén tu configuración."

L["Combat text"] = "Texto de combate"
L["Enable PlateSCT"] = "Activar PlateSCT"
L["Show floating damage numbers on nameplates."] =
    "Muestra números de daño flotantes en las placas de nombre."
L["Hide Blizzard floating combat text"] = "Ocultar el texto de combate flotante de Blizzard"
L["Turns off default in-world damage numbers."] =
    "Desactiva los números de daño predeterminados del mundo."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "Las placas de nombre enemigas están desactivadas. PlateSCT las necesita para mostrar números.\nPulsa V (predeterminado) o actívalas en Interfaz → Juego → Nombres."
L["Who to show"] = "Qué mostrar"
L["Only my damage"] = "Solo mi daño"
L["Show hits on your current target when you recently cast or auto-attacked. Midnight cannot prove who dealt the hit in a group."] =
    "Muestra golpes en tu objetivo actual cuando has lanzado o atacado automáticamente hace poco. Midnight no puede demostrar quién asestó el golpe en grupo."
L["Target"] = "Objetivo"
L["Best effort on your current target. Other players hitting the same mob can still show up. Off-target cleave and DoTs are not shown."] =
    "Mejor esfuerzo en tu objetivo actual. Otros jugadores que golpeen al mismo monstruo pueden aparecer. El cleave fuera de objetivo y los DoTs no se muestran."
L["All engaged nameplates"] = "Todas las placas de nombre en combate"
L["Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."] =
    "Muestra cada golpe en cada placa de nombre hostil visible. Es el modo Midnight preciso; incluye daño de todas las fuentes."
L["Available when Only my damage is off. Use this to see numbers on every enemy plate."] =
    "Disponible cuando «Solo mi daño» está desactivado. Úsalo para ver números en cada placa enemiga."
L["Include pet damage"] = "Incluir daño de mascota"
L["In Only my damage mode, also treat a recent pet cast as your hit."] =
    "En el modo «Solo mi daño», también trata un hechizo reciente de la mascota como tu golpe."

L["Number style"] = "Estilo de números"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "Moderno se desplaza hacia arriba desde la placa con un pequeño efecto de crítico. Classic mantiene el crecer y asentar, pegado a la placa."
L["Modern"] = "Moderno"
L["Classic"] = "Classic"
L["Color by damage school"] = "Colorear por escuela de daño"
L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."] =
    "Tiñe los números por escuela (fuego naranja, escarcha azul, etc.). Desactivado mantiene el amarillo predeterminado."
L["Show spell icon"] = "Mostrar icono del hechizo"
L["Display the spell's icon to the left of the damage number. Uses your last cast or auto-attack."] =
    "Muestra el icono del hechizo a la izquierda del número de daño. Usa tu último hechizo o autoataque."
L["Uses your last spell in Only my damage mode. Left of the number."] =
    "Usa tu último hechizo en el modo «Solo mi daño». A la izquierda del número."
L["Text style"] = "Estilo de texto"
L["Abbreviate numbers"] = "Abreviar números"
L["Display large numbers as 214k or 1.2M."] = "Muestra números grandes como 214k o 1.2M."
L["Animation"] = "Animación"
L["Font size"] = "Tamaño de fuente"
L["Scroll offset"] = "Desplazamiento vertical"
L["Display duration"] = "Duración de visualización"
L["Recommended"] = "Recomendado"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1fs"

L["Minimum damage threshold"] = "Umbral mínimo de daño"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "Los golpes por debajo de esta cantidad se ocultan. Escribe 50k o 2m. Pon 0 para mostrar todo."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Admite sufijos k/m, p. ej. 20k o 2m. El daño por debajo no se mostrará."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "En bandas y Mítica+ algunos valores son secretos, así que el umbral oculta esos golpes visualmente en lugar de omitirlos."

L["Preview"] = "Vista previa"
L["Target an enemy, then spawn sample numbers on its nameplate."] =
    "Selecciona un enemigo y genera números de ejemplo en su placa de nombre."
L["Test on Target"] = "Probar en el objetivo"
L["Show sample damage numbers on your target."] = "Muestra números de daño de ejemplo en tu objetivo."
L["Maintenance"] = "Mantenimiento"
L["Debug mode"] = "Modo depuración"
L["Print combat events to chat for troubleshooting."] =
    "Imprime eventos de combate en el chat para solucionar problemas."
L["Dump meter now"] = "Volcar medidor ahora"
L["Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."] =
    "Abre una captura copiable de los campos de C_DamageMeter. Úsalo en combate mientras golpeas un objetivo."
L["Reset Defaults"] = "Restablecer"
L["Restore every PlateSCT setting to its default."] =
    "Restaura todos los ajustes de PlateSCT a sus valores predeterminados."

-- Language
L["Language"] = "Idioma"
L["Choose the language used by PlateSCT panels and messages."] =
    "Elige el idioma de los paneles y mensajes de PlateSCT."
L["Auto (game client)"] = "Auto (cliente del juego)"
