local _, BD = ...

local L = {}
BD.RegisterLocale("esES", L)

-- Number position and font preview
L["Number position"] = "Posición de los números"
L["X offset"] = "Desplazamiento X"
L["Y offset"] = "Desplazamiento Y"
L["Offsets are saved separately for each number style. Positive X moves right; positive Y moves up. Incoming uses its own position controls."] = "Los desplazamientos se guardan por separado para cada estilo de números. X positivo mueve a la derecha; Y positivo mueve hacia arriba. El daño recibido tiene sus propios controles de posición."
L["Hover over a font to preview 12345."] = "Pasa el cursor sobre una fuente para ver una vista previa de 12345."
L["Press Ctrl+C to copy the URL."] = "Pulsa Ctrl+C para copiar la URL."
L["Open Link"] = "Abrir enlace"

-- Translation feedback
L["This translation was generated with AI. If you find inconsistent terminology or incorrect wording, please report it through GitHub Issues. Thank you for your help! Translation contributors will be credited."] =
    "Esta traducción se ha generado con IA. Si encuentras términos incoherentes o una redacción incorrecta, comunícalo a través de GitHub Issues. ¡Gracias por tu ayuda! Se dará crédito a quienes contribuyan a la traducción."

L["Impact number style"] = "Estilo de números Impact"
L["All number styles are available on every supported WoW API."] = "Todos los estilos de números están disponibles en cada API de WoW compatible."
L["Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."] = "Impact lanza el daño infligido al lado o encima de la placa de nombre y luego lo hace subir. Los golpes nuevos aparecen delante; los críticos aumentan de tamaño y CRÍTICO parpadea encima si está activado."
L["Impact style position"] = "Posición del estilo Impact"
L["Damage position"] = "Posición del daño"
L["Side"] = "Lateral"
L["Place Impact damage to the right of the nameplate or centered above it."] = "Coloca el daño Impact a la derecha de la placa de nombre o centrado encima."
L["Impact uses Modern for incoming damage, healing, and miss text, preserving saved Modern motions."] = "Impact usa Moderno para el daño recibido, la sanación y los fallos, conservando los movimientos Moderno guardados."
L["Pick a motion for each hit type in Modern. Classic and Impact use their own damage animations."] = "Elige un movimiento por tipo de golpe en Moderno. Clásico y Impact usan sus propias animaciones de daño."
L["Switch to Modern number style to customize these motions."] = "Cambia al estilo de números Moderno para personalizar estos movimientos."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. All number styles remain available on every API."] = "La vista previa inferior incluye ejemplos mixtos, normales, críticos y fallidos. Todos los estilos de números siguen disponibles en cada API."

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
L["Tools & Preview"] = "Herramientas y vista previa"
L["What's new?"] = "Novedades"
L["Choose whose damage and which nameplates to show."] =
    "Elige qué daño y qué placas de nombre mostrar."
L["Control how numbers look and how they animate."] =
    "Controla el aspecto y la animación de los números."
L["Hide small hits so the big numbers stay readable."] =
    "Oculta los golpes pequeños para que los números grandes sigan legibles."
L["Preview numbers and maintain your setup."] =
    "Previsualiza números y mantén tu configuración."
L["Recent changes in PlateSCT."] = "Cambios recientes en PlateSCT."
L["Version 1.1.4"] = "Versión 1.1.4"
L["NEW"] = "NUEVO"
L["IMPROVED"] = "MEJORADO"
L["Outgoing healing on the recipient's nameplate. Enable Show healing under General (off by default). Friendly nameplates must be on in the game."] =
    "Sanación saliente en la placa del receptor. Activa Mostrar sanación en General (desactivado por defecto). Placas amistosas activadas en el juego."
L["Scroll speed slider - numbers travel faster; fade still follows Display duration."] =
    "Velocidad de desplazamiento - los números se mueven más rápido; el desvanecido sigue la duración."
L["Font picker - game fonts, plus SharedMedia fonts when another addon provides them."] =
    "Selector de fuente - fuentes del juego, más SharedMedia cuando otro addon las proporciona."
L["Font size up to 48, Scroll offset up to 120 px, Display duration up to 4 seconds."] =
    "Tamaño de fuente hasta 48, desplazamiento hasta 120 px, duración hasta 4 segundos."
L["Larger fonts spread out more in Modern number style so hits overlap less."] =
    "Las fuentes grandes se separan más en estilo Moderno, menos solapamiento."

L["Combat text"] = "Texto de combate"
L["Enable PlateSCT"] = "Activar PlateSCT"
L["Show floating damage numbers on nameplates."] =
    "Muestra números de daño flotantes en las placas de nombre."
L["Hide Blizzard floating combat text"] = "Ocultar el texto de combate flotante de Blizzard"
L["Turns off default in-world damage numbers."] =
    "Desactiva los números de daño predeterminados del mundo."
L["Show minimap button"] = "Mostrar botón del minimapa"
L["Show the PlateSCT icon on the minimap. Click it to open settings."] =
    "Muestra el icono de PlateSCT en el minimapa. Haz clic para abrir la configuración."
L["Click to open settings."] = "Haz clic para abrir la configuración."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "Las placas de nombre enemigas están desactivadas. PlateSCT las necesita para mostrar números.\nPulsa V (predeterminado) o actívalas en Interfaz → Juego → Nombres."
L["Who to show"] = "Qué mostrar"

-- What's new: less clutter
L["Less clutter"] = "Menos desorden"
L["Dim or hide numbers on enemies you are not targeting, show crits only, shrink small hits, and ignore chosen spells. Find them on the Combat page."] =
    "Atenúa u oculta los números en enemigos que no son tu objetivo, muestra solo críticos, encoge los golpes pequeños e ignora hechizos elegidos. En la página Combate."


-- Ignored spells
L["Ignored spells"] = "Hechizos ignorados"
L["Ignore these spells"] = "Ignorar estos hechizos"
L["Spell names or IDs, separated by commas. Their hits, crits, and misses are not shown."] =
    "Nombres o ID de hechizos, separados por comas. Sus golpes, críticos y fallos no se muestran."
L["Example: Auto Attack, 133."] = "Ejemplo: Ataque automático, 133."
L["Example: Auto Attack, 133. Modern API knows the spell only in Personal - experimental mode."] =
    "Ejemplo: Ataque automático, 133. La API Modern solo conoce el hechizo en el modo Personal - experimental."


-- Shrink small hits
L["Shrink small hits"] = "Encoger golpes pequeños"
L["Show hits well below your recent average smaller instead of hiding them."] =
    "Muestra más pequeños los golpes muy por debajo de tu media reciente en lugar de ocultarlos."
L["Small hit below"] = "Golpe pequeño bajo"
L["%s of average"] = "%s de la media"


-- Crits only
L["Crits only"] = "Solo críticos"
L["Show only critical hits. Normal hits and heals are hidden; miss text such as Immune still shows."] =
    "Muestra solo los golpes críticos. Los golpes normales y las sanaciones se ocultan; los textos de fallo como Inmune se siguen mostrando."


-- Off-target numbers
L["Show"] = "Mostrar"
L["Dim"] = "Atenuar"
L["Hide"] = "Ocultar"
L["Other nameplates"] = "Otras placas de nombre"
L["How numbers look on enemies you are not targeting. Dim makes them smaller and fainter so your target stands out."] =
    "Cómo se ven los números en enemigos que no tienes como objetivo. Atenuar los hace más pequeños y tenues para que tu objetivo destaque."
L["Only Engaged nameplates mode shows numbers on enemies you are not targeting. Change it under Modern API → Damage mode."] =
    "Solo el modo Placas en combate muestra números en enemigos que no son tu objetivo. Cámbialo en API moderna → Modo de daño."
L["Off-target size"] = "Tamaño fuera del objetivo"
L["Off-target opacity"] = "Opacidad fuera del objetivo"

L["Only my damage"] = "Solo mi daño"
L["Show hits on your current target when you recently cast or auto-attacked. Midnight cannot prove who dealt the hit in a group."] =
    "Muestra golpes en tu objetivo actual cuando has lanzado o atacado automáticamente hace poco. Midnight no puede demostrar quién asestó el golpe en grupo."
L["Experimental"] = "Experimental"
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
L["Healing"] = "Sanación"
L["Show healing"] = "Mostrar sanación"
L["Show your outgoing heals on the recipient's nameplate. Friendly nameplates must be enabled in the game."] =
    "Muestra tus sanaciones salientes en la placa de nombre del receptor. Las placas amistosas deben estar activadas en el juego."
L["Uses the same size, motion, duration, icons, and threshold as damage. Skips heals on you."] =
    "Usa el mismo tamaño, movimiento, duración, iconos y umbral que el daño. Omite sanaciones sobre ti."

L["Number style"] = "Estilo de números"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "Moderno se desplaza hacia arriba desde la placa con un pequeño efecto de crítico. Classic mantiene el crecer y asentar, pegado a la placa."
L["Modern"] = "Moderno"
L["Classic"] = "Classic"
L["Show live preview"] = "Mostrar vista previa en vivo"
L["Show sample hits, crits, and misses beside this window."] =
    "Muestra golpes, críticos y fallos de ejemplo junto a esta ventana."
L["Hide live preview"] = "Ocultar vista previa en vivo"
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
L["Display large numbers as 214k or 1.2M. Disables thousand separators."] =
    "Muestra números grandes como 214k o 1.2M. Desactiva los separadores de miles."
L["Thousand separators"] = "Separadores de miles"
L["Group digits by thousands."] = "Agrupa dígitos por miles."
L["Unavailable while Abbreviate numbers is on."] = "No disponible mientras «Abreviar números» está activo."
L["Off"] = "Desactivado"
L["Comma (10,000)"] = "Coma (10,000)"
L["Dot (10.000)"] = "Punto (10.000)"
L["Animation"] = "Animación"
L["Font"] = "Fuente"
L["Font size"] = "Tamaño de fuente"
L["Scroll offset"] = "Desplazamiento vertical"
L["Scroll speed"] = "Velocidad de desplazamiento"
L["%d%%"] = "%d %%"
L["Display duration"] = "Duración de visualización"
L["Game default"] = "Predeterminada del juego"
L["Friz Quadrata"] = "Friz Quadrata"
L["Arial Narrow"] = "Arial Narrow"
L["Skurri"] = "Skurri"
L["Morpheus"] = "Morpheus"
L["Game fonts, plus SharedMedia fonts when that library is loaded by another addon."] =
    "Fuentes del juego, más fuentes SharedMedia cuando esa biblioteca la carga otro addon."
L["Only fonts inside the WoW folder can load. SharedMedia fonts appear when another addon provides them."] =
    "Solo pueden cargarse fuentes dentro de la carpeta de WoW. Las fuentes SharedMedia aparecen cuando otro addon las proporciona."
L["Recommended"] = "Recomendado"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1fs"
L["%.1fx"] = "%.1fx"
L["Show CRITICAL"] = "Mostrar CRÍTICO"
L["Show CRITICAL on critical hits. Impact saves its own choice, enabled by default."] =
    "Muestra CRÍTICO en los golpes críticos. Impact guarda su propia opción, activada por defecto."
L["CRITICAL"] = "CRÍTICO"

L["Minimum damage threshold"] = "Umbral mínimo de daño"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "Los golpes por debajo de esta cantidad se ocultan. Escribe 50k o 2m. Pon 0 para mostrar todo."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Admite sufijos k/m, p. ej. 20k o 2m. El daño por debajo no se mostrará."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "En bandas y Mítica+ algunos valores son secretos, así que el umbral oculta esos golpes visualmente en lugar de omitirlos."

-- Combine hits
L["Combine hits"] = "Combinar golpes"
L["Combine rapid hits"] = "Combinar golpes rápidos"
L["Add hits that land in quick succession on the same nameplate into one number instead of stacking many."] =
    "Suma los golpes que impactan en la misma placa de nombre en rápida sucesión en un solo número en lugar de apilar muchos."
L["Combine"] = "Combinar"
L["Same spell"] = "Mismo hechizo"
L["All hits"] = "Todos los golpes"
L["Same spell keeps each spell's number separate. All hits merges every hit on the target; its icon shows the spell that did the most damage."] =
    "Mismo hechizo mantiene separado el número de cada hechizo. Todos los golpes combina cada golpe sobre el objetivo; su icono muestra el hechizo que más daño hizo."
L["Combine window"] = "Ventana de combinación"
L["%.2fs"] = "%.2fs"
L["Show hit count"] = "Mostrar número de golpes"
L["Show how many hits were combined, e.g. 37,200 (3). With spell icons on, the count sits on the icon."] =
    "Muestra cuántos golpes se combinaron, p. ej. 37.200 (3). Con los iconos de hechizo activados, el número aparece sobre el icono."
L["%s (%d)"] = "%s (%d)"
L["Crits, normal hits, and heals combine separately."] = "Los críticos, los golpes normales y las sanaciones se combinan por separado."
L["Crits, normal hits, and heals combine separately. Secret amounts cannot be added, so those hits still show individually."] =
    "Los críticos, los golpes normales y las sanaciones se combinan por separado. Los valores secretos no se pueden sumar, así que esos golpes se siguen mostrando por separado."

L["Preview"] = "Vista previa"
L["Updates live as you change options."] = "Se actualiza en vivo al cambiar opciones."
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
L["Auto"] = "Auto"

-- Settings redesign
L["Animate settings"] = "Animar ajustes"
L["Appearance"] = "Apariencia"
L["Appearance only · Test on Target checks gameplay size."] = "Solo apariencia · Probar en objetivo comprueba el tamaño en juego."
L["Appearance preview"] = "Vista previa de apariencia"
L["Attribution"] = "Atribución"
L["Attribution limitations"] = "Límites de atribución"
L["Audio cues for outgoing critical hits."] = "Avisos sonoros para tus golpes críticos."
L["Both number styles are available on every supported WoW API."] = "Ambos estilos de números están disponibles en todas las API de WoW compatibles."
L["Classic API - Era/TBC/Wrath/MoP"] = "API Classic - Era/TBC/Wrath/MoP"
L["Classic number style"] = "Estilo de números Classic"
L["Close"] = "Cerrar"
L["Combat"] = "Combate"
L["Current target"] = "Objetivo actual"
L["Damage mode"] = "Modo de daño"
L["Damage threshold"] = "Umbral de daño"
L["Diagnostics"] = "Diagnóstico"
L["Engaged nameplates"] = "Placas en combate"
L["Existing features"] = "Funciones existentes"
L["Find a setting"] = "Buscar un ajuste"
L["Fonts, colors, numbers, and spell icons."] = "Fuentes, colores, números e iconos de hechizos."
L["Help & Settings"] = "Ayuda y ajustes"
L["Hide preview"] = "Ocultar vista previa"
L["Instance profiles"] = "Perfiles de estancia"
L["Meter probe requires Modern API - Midnight & Forever."] = "El diagnóstico del medidor requiere la API moderna - Midnight y Forever."
L["Midnight & Forever damage modes and attribution."] = "Modos de daño y atribución de Midnight y Forever."
L["Modern API"] = "API moderna"
L["Modern API - Midnight & Forever"] = "API moderna - Midnight y Forever"
L["Modern number style"] = "Estilo de números moderno"
L["Modern number style motion"] = "Movimiento del estilo de números moderno"
L["No matching settings"] = "No se encontraron ajustes"
L["Number formatting"] = "Formato de números"
L["Number style, timing, and movement."] = "Estilo de números, duración y movimiento."
L["Personal - experimental"] = "Personal - experimental"
L["Play crit sound"] = "Reproducir sonido crítico"
L["Play huge crit sound"] = "Reproducir sonido de gran crítico"
L["Preferences"] = "Preferencias"
L["Preferences, API information, and diagnostics."] = "Preferencias, información de la API y diagnóstico."
L["Preview scale: %d%%"] = "Escala de vista previa: %d%%"
L["Replay"] = "Repetir"
L["Schools"] = "Escuelas"
L["Settings redesign"] = "Rediseño de ajustes"
L["Settings window"] = "Ventana de ajustes"
L["Show preview"] = "Mostrar vista previa"
L["Sounds"] = "Sonidos"
L["Spell icons"] = "Iconos de hechizos"
L["Text size"] = "Tamaño del texto"
L["Timing and movement"] = "Duración y movimiento"
L["Training dummy"] = "Muñeco de entrenamiento"
L["Unsupported client - combat text unavailable"] = "Cliente no compatible - texto de combate no disponible"
L["Your WoW API"] = "Tu API de WoW"
L["Mixed"] = "Mixto"
L["Hit"] = "Golpe"
L["Crit"] = "Crítico"
L["Miss"] = "Fallo"

-- Settings explanations
L["A new WoW-inspired settings window with clear sections, searchable controls, and gentle animations."] = "Nueva ventana de ajustes inspirada en WoW, con secciones claras, búsqueda y animaciones suaves."
L["Choose Personal - experimental under Modern API → Damage mode to use pet matching."] = "Elige Personal - experimental en API moderna → Modo de daño para identificar golpes de tu mascota."
L["Choose Personal - experimental under Modern API → Damage mode to use spell icons."] = "Elige Personal - experimental en API moderna → Modo de daño para usar iconos de hechizos."
L["Choose the combat text you want to see."] = "Elige el texto de combate que quieres ver."
L["Choose whose damage to display under Modern API → Damage mode. Personal mode is experimental."] = "Elige de quién mostrar daño en API moderna → Modo de daño. El modo Personal es experimental."
L["Classic clients read damage ownership and spells directly from the combat log. Modern attribution and school-filter options do not apply."] = "Los clientes Classic leen la fuente del daño y los hechizos directamente del registro de combate. La atribución moderna y el filtro de escuelas no se aplican."
L["Classic number style uses its own animation. Switch to Modern number style to customize motion."] = "El estilo de números Classic usa su propia animación. Cambia al estilo moderno para personalizar el movimiento."
L["Current target: all-source numbers on your target. Engaged nameplates: all-source numbers on engaged enemies."] = "Objetivo actual: daño de todas las fuentes en tu objetivo. Placas en combate: daño de todas las fuentes en enemigos en combate."
L["Damage meter probe is available. Capture a snapshot while hitting a target."] = "El diagnóstico del medidor está disponible. Captura una instantánea mientras golpeas a un objetivo."
L["Enable Auto-switch by instance to edit the instance profiles."] = "Activa el cambio automático por estancia para editar sus perfiles."
L["Enable Filter by damage school to choose allowed schools."] = "Activa el filtro por escuela de daño para elegir las escuelas permitidas."
L["Enable Show incoming hits to adjust its position."] = "Activa Mostrar golpes recibidos para ajustar su posición."
L["Enable Show spell icon to choose its position."] = "Activa Mostrar icono del hechizo para elegir su posición."
L["Enable crit sound to adjust its threshold and channel."] = "Activa el sonido crítico para ajustar su umbral y canal."
L["Enable huge crit sound to adjust its threshold and channel."] = "Activa el sonido de gran crítico para ajustar su umbral y canal."
L["Modern API options now have their own page. Damage mode combines Only my damage and All engaged nameplates without changing saved preferences."] = "Las opciones de la API moderna tienen su propia página. Modo de daño combina Solo mi daño y Todas las placas en combate, conservando las preferencias guardadas."
L["Modern API: unreadable damage amounts cannot trigger threshold sounds."] = "API moderna: los valores de daño ilegibles no pueden activar sonidos por umbral."
L["Modern clients restrict combat information. Personal mode estimates ownership; all-source modes display target or engaged-nameplate damage."] = "Los clientes modernos restringen la información de combate. El modo Personal estima la fuente; los otros modos muestran daño de todas las fuentes en el objetivo o enemigos en combate."
L["Outgoing healing, incoming damage, font selection, scroll speed, school colors, spell icons, and critical-hit sounds remain available."] = "Siguen disponibles la sanación realizada, el daño recibido, las fuentes, la velocidad, los colores por escuela, los iconos y los sonidos críticos."
L["Personal matches recent casts. Current target and Engaged nameplates show damage from all sources."] = "Personal relaciona lanzamientos recientes. Objetivo actual y Placas en combate muestran daño de todas las fuentes."
L["Personal - experimental: best-effort matching by destination and timing. Other players' hits on the same target can appear."] = "Personal - experimental: asociación aproximada por destino y tiempo. Pueden aparecer golpes de otros jugadores en el mismo objetivo."
L["Pet matching and spell icons require Personal mode. Choose their appearance and visibility under Combat and Appearance."] = "La asociación de mascotas y los iconos requieren el modo Personal. Ajusta su visibilidad y aspecto en Combate y Apariencia."
L["Place the spell icon beside, above, or below the number."] = "Coloca el icono junto al número, encima o debajo."
L["PlateSCT needs enemy nameplates. Press V (default) or enable them in the game's nameplate settings."] = "PlateSCT necesita placas de nombre enemigas. Pulsa V (por defecto) o actívalas en los ajustes del juego."
L["Profiles affect Personal mode. They cannot prove who dealt a hit on Modern API."] = "Los perfiles afectan al modo Personal. No pueden confirmar quién causó un golpe con la API moderna."
L["Show damage you take near your character. Independent of the outgoing damage mode."] = "Muestra el daño recibido cerca de tu personaje, independientemente del modo de daño realizado."
L["Show sample hits, crits, and misses in the bottom preview drawer."] = "Muestra golpes, críticos y fallos de ejemplo en el panel inferior de vista previa."
L["Show sample hits, crits, and misses inside this window."] = "Muestra golpes, críticos y fallos de ejemplo dentro de esta ventana."
L["Spell icons use matched casts in Personal mode; Modern API cannot identify a spell for every hit."] = "Los iconos usan lanzamientos asociados en Personal; la API moderna no puede identificar un hechizo para cada golpe."
L["Spell icons use the spell from the combat log."] = "Los iconos usan el hechizo del registro de combate."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. Both number styles remain available on every API."] = "La vista previa inferior incluye Mixto, Golpe, Crítico y Fallo. Ambos estilos siguen disponibles en todas las API."
L["The preview shows appearance only. It does not prove attribution or simulate damage filtering."] = "La vista previa solo muestra la apariencia. No confirma la atribución ni simula el filtrado de daño."
L["This client does not expose the damage meter API. A snapshot can still report which fields are unavailable."] = "Este cliente no ofrece la API del medidor de daño. Una instantánea aún puede indicar qué campos no están disponibles."
L["Turn off Auto-switch by instance to choose manual strictness."] = "Desactiva el cambio automático por estancia para elegir la rigurosidad manualmente."
L["Unreadable amounts cannot trigger threshold sounds. Unreadable damage schools are always allowed by the school filter."] = "Los valores ilegibles no activan sonidos por umbral. Las escuelas ilegibles siempre pasan el filtro."
L["Use gentle fades and row reveals in this settings window. Combat animation is unaffected."] = "Usa transiciones suaves y animaciones de filas en los ajustes. La animación de combate no cambia."

-- What's new: combine hits
L["Rapid hits on the same nameplate can merge into one growing number with a hit count. Turn it on under Combat → Combine hits."] =
    "Los golpes rápidos en la misma placa de nombre pueden combinarse en un solo número creciente con el número de golpes. Actívalo en Combate → Combinar golpes."

-- Reduce clutter
L["Reduce clutter"] = "Reducir el desorden"

-- Combine hits: merge pop
L["Pop on each merge"] = "Rebote en cada combinación"
L["Briefly enlarge the number every time another hit merges into it. Turn off for a calmer display."] =
    "Agranda brevemente el número cada vez que se le suma otro golpe. Desactívalo para una visualización más tranquila."
