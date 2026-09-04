local _, BD = ...

local L = {}
BD.RegisterLocale("itIT", L)

L["PlateSCT is in Beta"] = "PlateSCT è in beta"
L["This addon is in Beta mode. Inaccuracies and errors may show up. Please report such issues on the addon's page."] =
    "Questo addon è in modalità beta. Possono comparire imprecisioni ed errori. Segnala tali problemi sulla pagina dell'addon."
L["Reset PlateSCT settings to defaults?"] = "Ripristinare le impostazioni di PlateSCT ai valori predefiniti?"
L["Addon page"] = "Pagina dell'addon"
L["Select the URL below, copy it, then paste it in your browser."] =
    "Seleziona l'URL qui sotto, copiala e incollala nel browser."
L["Click to open the addon page URL."] = "Fai clic per aprire l'URL della pagina dell'addon."
L["/platesct  ·  ESC to close"] = "/platesct  ·  ESC per chiudere"
L["PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."] =
    "PlateSCT usa una propria finestra delle impostazioni.\n\nDigita /platesct in chat oppure fai clic sul pulsante qui sotto."
L["Open PlateSCT"] = "Apri PlateSCT"
L["Target something to preview test numbers."] = "Seleziona un bersaglio per anteprima dei numeri di prova."
L["Meter probe"] = "Sonda del misuratore"
L["Click the box, Ctrl+A, then Ctrl+C, and paste it in chat."] =
    "Fai clic sulla casella, Ctrl+A, poi Ctrl+C, e incolla in chat."

L["General"] = "Generale"
L["Display"] = "Visualizzazione"
L["Damage"] = "Danni"
L["Tools"] = "Strumenti"
L["Tools & Preview"] = "Strumenti e anteprima"
L["Choose whose damage and which nameplates to show."] =
    "Scegli quali danni e quali barre del nome mostrare."
L["Control how numbers look and how they animate."] =
    "Controlla aspetto e animazione dei numeri."
L["Hide small hits so the big numbers stay readable."] =
    "Nascondi i colpi piccoli così i numeri grandi restano leggibili."
L["Preview numbers and maintain your setup."] =
    "Anteprima dei numeri e gestione della configurazione."

L["Combat text"] = "Testo di combattimento"
L["Enable PlateSCT"] = "Abilita PlateSCT"
L["Show floating damage numbers on nameplates."] =
    "Mostra numeri di danno fluttuanti sulle barre del nome."
L["Hide Blizzard floating combat text"] = "Nascondi il testo di combattimento fluttuante di Blizzard"
L["Turns off default in-world damage numbers."] =
    "Disattiva i numeri di danno predefiniti nel mondo."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "Le barre del nome nemiche sono disattivate. PlateSCT ne ha bisogno per mostrare i numeri.\nPremi V (predefinito) o attivale in Interfaccia → Gioco → Nomi."
L["Who to show"] = "Cosa mostrare"
L["Only my damage"] = "Solo i miei danni"
L["Show hits on your current target when you recently cast or auto-attacked. Midnight cannot prove who dealt the hit in a group."] =
    "Mostra i colpi sul bersaglio attuale quando hai lanciato o auto-attaccato di recente. Midnight non può dimostrare chi ha inflitto il colpo in gruppo."
L["Experimental"] = "Sperimentale"
L["Best effort on your current target. Other players hitting the same mob can still show up. Off-target cleave and DoTs are not shown."] =
    "Miglior tentativo sul bersaglio attuale. Altri giocatori che colpiscono lo stesso mob possono comunque apparire. Cleave fuori bersaglio e DoT non vengono mostrati."
L["All engaged nameplates"] = "Tutte le barre del nome impegnate"
L["Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."] =
    "Mostra ogni colpo su ogni barra del nome ostile visibile. È la modalità Midnight accurata; include danni da ogni fonte."
L["Available when Only my damage is off. Use this to see numbers on every enemy plate."] =
    "Disponibile quando «Solo i miei danni» è disattivato. Usalo per vedere i numeri su ogni barra nemica."
L["Include pet damage"] = "Includi danni del famiglio"
L["In Only my damage mode, also treat a recent pet cast as your hit."] =
    "Nella modalità «Solo i miei danni», tratta anche un lancio recente del famiglio come tuo colpo."

L["Number style"] = "Stile dei numeri"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "Moderno scorre verso l'alto dalla barra del nome con un piccolo effetto critico. Classic mantiene la crescita e l'assestamento, vicino alla barra."
L["Modern"] = "Moderno"
L["Classic"] = "Classic"
L["Show live preview"] = "Mostra anteprima in tempo reale"
L["Show sample hits, crits, and misses beside this window."] =
    "Mostra esempi di colpi, critici e mancati accanto a questa finestra."
L["Hide live preview"] = "Nascondi anteprima in tempo reale"
L["Color by damage school"] = "Colore per scuola di danno"
L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."] =
    "Colora i numeri per scuola (fuoco arancione, gelo blu, ecc.). Disattivato mantiene il giallo predefinito."
L["Show spell icon"] = "Mostra icona dell'incantesimo"
L["Display the spell's icon to the left of the damage number. Uses your last cast or auto-attack."] =
    "Mostra l'icona dell'incantesimo a sinistra del numero di danno. Usa l'ultimo lancio o auto-attacco."
L["Uses your last spell in Only my damage mode. Left of the number."] =
    "Usa il tuo ultimo incantesimo in modalità «Solo i miei danni». A sinistra del numero."
L["Text style"] = "Stile del testo"
L["Abbreviate numbers"] = "Abbrevia i numeri"
L["Display large numbers as 214k or 1.2M."] = "Mostra i numeri grandi come 214k o 1.2M."
L["Display large numbers as 214k or 1.2M. Disables thousand separators."] =
    "Mostra i numeri grandi come 214k o 1.2M. Disattiva i separatori delle migliaia."
L["Thousand separators"] = "Separatori delle migliaia"
L["Group digits by thousands."] = "Raggruppa le cifre per migliaia."
L["Unavailable while Abbreviate numbers is on."] = "Non disponibile se «Abbrevia i numeri» è attivo."
L["Off"] = "Disattivato"
L["Comma (10,000)"] = "Virgola (10,000)"
L["Dot (10.000)"] = "Punto (10.000)"
L["Animation"] = "Animazione"
L["Font size"] = "Dimensione carattere"
L["Scroll offset"] = "Scostamento scorrimento"
L["Display duration"] = "Durata visualizzazione"
L["Recommended"] = "Consigliato"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1fs"
L["Show CRITICAL"] = "Mostra CRITICO"
L["Show the word CRITICAL in small caps next to critical hit numbers."] =
    "Mostra la parola CRITICO in maiuscoletto accanto ai colpi critici."
L["CRITICAL"] = "CRITICO"

L["Minimum damage threshold"] = "Soglia minima di danno"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "I colpi sotto questo importo sono nascosti. Digita 50k o 2m. Imposta 0 per mostrare tutto."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Supporta i suffissi k/m, es. 20k o 2m. Il danno sotto questo valore non verrà mostrato."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "In incursioni e Mitica+ alcuni valori sono segreti, quindi la soglia nasconde quei colpi visivamente invece di saltarli."

L["Preview"] = "Anteprima"
L["Updates live as you change options."] = "Si aggiorna in tempo reale quando cambi le opzioni."
L["Target an enemy, then spawn sample numbers on its nameplate."] =
    "Seleziona un nemico, poi genera numeri di esempio sulla sua barra del nome."
L["Test on Target"] = "Prova sul bersaglio"
L["Show sample damage numbers on your target."] = "Mostra numeri di danno di esempio sul bersaglio."
L["Maintenance"] = "Manutenzione"
L["Debug mode"] = "Modalità debug"
L["Print combat events to chat for troubleshooting."] =
    "Stampa gli eventi di combattimento in chat per la diagnostica."
L["Dump meter now"] = "Dump del misuratore"
L["Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."] =
    "Apre uno snapshot copiabile dei campi C_DamageMeter. Usalo in combattimento mentre colpisci un bersaglio."
L["Reset Defaults"] = "Ripristina"
L["Restore every PlateSCT setting to its default."] =
    "Ripristina tutte le impostazioni di PlateSCT ai valori predefiniti."

-- Language
L["Language"] = "Lingua"
L["Choose the language used by PlateSCT panels and messages."] =
    "Scegli la lingua dei pannelli e dei messaggi di PlateSCT."
L["Auto"] = "Auto"
