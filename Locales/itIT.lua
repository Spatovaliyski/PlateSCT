local _, BD = ...

local L = {}
BD.RegisterLocale("itIT", L)

-- Number position and font preview
L["Number position"] = "Posizione dei numeri"
L["X offset"] = "Scostamento X"
L["Y offset"] = "Scostamento Y"
L["Offsets are saved separately for each number style. Positive X moves right; positive Y moves up. Incoming uses its own position controls."] = "Gli scostamenti vengono salvati separatamente per ogni stile dei numeri. X positivo sposta a destra; Y positivo sposta verso l'alto. I danni subiti hanno controlli di posizione dedicati."
L["Hover over a font to preview 12345."] = "Passa il cursore su un carattere per vedere un'anteprima di 12345."
L["Press Ctrl+C to copy the URL."] = "Premi Ctrl+C per copiare l'URL."
L["Open Link"] = "Apri link"

-- Translation feedback
L["This translation was generated with AI. If you find inconsistent terminology or incorrect wording, please report it through GitHub Issues. Thank you for your help! Translation contributors will be credited."] =
    "Questa traduzione è stata generata con l'IA. Se trovi termini incoerenti o formulazioni errate, segnalali tramite GitHub Issues. Grazie per l'aiuto! I collaboratori alla traduzione saranno citati nei ringraziamenti."

L["Impact number style"] = "Stile dei numeri Impact"
L["All number styles are available on every supported WoW API."] = "Tutti gli stili dei numeri sono disponibili su ogni API WoW supportata."
L["Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."] = "Impact scaglia il danno inflitto accanto o sopra la barra del nome, poi lo fa salire. I nuovi colpi appaiono davanti; i critici si ingrandiscono e CRITICO lampeggia sopra se attivato."
L["Impact style position"] = "Posizione dello stile Impact"
L["Damage position"] = "Posizione del danno"
L["Side"] = "Lato"
L["Place Impact damage to the right of the nameplate or centered above it."] = "Posiziona il danno Impact a destra della barra del nome o centrato sopra di essa."
L["Impact uses Modern for incoming damage, healing, and miss text, preserving saved Modern motions."] = "Impact usa Moderno per il danno ricevuto, le cure e i colpi mancati, mantenendo i movimenti Moderno salvati."
L["Pick a motion for each hit type in Modern. Classic and Impact use their own damage animations."] = "Scegli un movimento per ogni tipo di colpo in Moderno. Classico e Impact usano animazioni di danno proprie."
L["Switch to Modern number style to customize these motions."] = "Passa allo stile dei numeri Moderno per personalizzare questi movimenti."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. All number styles remain available on every API."] = "L'anteprima compatta in basso include esempi misti, normali, critici e mancati. Tutti gli stili dei numeri restano disponibili su ogni API."

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
L["What's new?"] = "Novità"
L["Choose whose damage and which nameplates to show."] =
    "Scegli quali danni e quali barre del nome mostrare."
L["Control how numbers look and how they animate."] =
    "Controlla aspetto e animazione dei numeri."
L["Hide small hits so the big numbers stay readable."] =
    "Nascondi i colpi piccoli così i numeri grandi restano leggibili."
L["Preview numbers and maintain your setup."] =
    "Anteprima dei numeri e gestione della configurazione."
L["Recent changes in PlateSCT."] = "Modifiche recenti in PlateSCT."
L["Version 1.1.4"] = "Versione 1.1.4"
L["NEW"] = "NUOVO"
L["IMPROVED"] = "MIGLIORATO"
L["Outgoing healing on the recipient's nameplate. Enable Show healing under General (off by default). Friendly nameplates must be on in the game."] =
    "Cure in uscita sulla barra del destinatario. Attiva Mostra cure in Generale (disattivato di default). Barre amichevoli attive nel gioco."
L["Scroll speed slider - numbers travel faster; fade still follows Display duration."] =
    "Velocità scorrimento - i numeri si muovono più in fretta; lo sfumato segue ancora la durata."
L["Font picker - game fonts, plus SharedMedia fonts when another addon provides them."] =
    "Selezione carattere - caratteri di gioco e SharedMedia se un altro addon li fornisce."
L["Font size up to 48, Scroll offset up to 120 px, Display duration up to 4 seconds."] =
    "Dimensione carattere fino a 48, scostamento fino a 120 px, durata fino a 4 secondi."
L["Larger fonts spread out more in Modern number style so hits overlap less."] =
    "Caratteri più grandi più distanziati nello stile Moderno, meno sovrapposizioni."

L["Combat text"] = "Testo di combattimento"
L["Enable PlateSCT"] = "Abilita PlateSCT"
L["Show floating damage numbers on nameplates."] =
    "Mostra numeri di danno fluttuanti sulle barre del nome."
L["Hide Blizzard floating combat text"] = "Nascondi il testo di combattimento fluttuante di Blizzard"
L["Turns off default in-world damage numbers."] =
    "Disattiva i numeri di danno predefiniti nel mondo."
L["Show minimap button"] = "Mostra pulsante minimappa"
L["Show the PlateSCT icon on the minimap. Click it to open settings."] =
    "Mostra l'icona di PlateSCT sulla minimappa. Clicca per aprire le impostazioni."
L["Click to open settings."] = "Clicca per aprire le impostazioni."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "Le barre del nome nemiche sono disattivate. PlateSCT ne ha bisogno per mostrare i numeri.\nPremi V (predefinito) o attivale in Interfaccia → Gioco → Nomi."
L["Who to show"] = "Cosa mostrare"

-- What's new: less clutter
L["Less clutter"] = "Meno disordine"
L["Dim or hide numbers on enemies you are not targeting, show crits only, shrink small hits, and ignore chosen spells. Find them on the Combat page."] =
    "Attenua o nascondi i numeri sui nemici non bersagliati, mostra solo i critici, rimpicciolisci i colpi piccoli e ignora incantesimi scelti. Nella pagina Combattimento."


-- Ignored spells
L["Ignored spells"] = "Incantesimi ignorati"
L["Ignore these spells"] = "Ignora questi incantesimi"
L["Spell names or IDs, separated by commas. Their hits, crits, and misses are not shown."] =
    "Nomi o ID degli incantesimi, separati da virgole. I loro colpi, critici e mancati non vengono mostrati."
L["Example: Auto Attack, 133."] = "Esempio: Attacco automatico, 133."
L["Example: Auto Attack, 133. Modern API knows the spell only in Personal - experimental mode."] =
    "Esempio: Attacco automatico, 133. L'API Modern conosce l'incantesimo solo in modalità Personale - sperimentale."


-- Shrink small hits
L["Shrink small hits"] = "Rimpicciolisci i colpi piccoli"
L["Show hits well below your recent average smaller instead of hiding them."] =
    "Mostra più piccoli i colpi molto sotto la tua media recente invece di nasconderli."
L["Small hit below"] = "Colpo piccolo sotto"
L["%s of average"] = "%s della media"


-- Crits only
L["Crits only"] = "Solo critici"
L["Show only critical hits. Normal hits and heals are hidden; miss text such as Immune still shows."] =
    "Mostra solo i colpi critici. Colpi normali e cure vengono nascosti; i testi di mancato come Immune restano visibili."


-- Off-target numbers
L["Show"] = "Mostra"
L["Dim"] = "Attenua"
L["Hide"] = "Nascondi"
L["Other nameplates"] = "Altre barre del nome"
L["How numbers look on enemies you are not targeting. Dim makes them smaller and fainter so your target stands out."] =
    "Aspetto dei numeri sui nemici che non stai bersagliando. Attenua li rende più piccoli e tenui, così il tuo bersaglio risalta."
L["Only Engaged nameplates mode shows numbers on enemies you are not targeting. Change it under Modern API → Damage mode."] =
    "Solo la modalità Barre in combattimento mostra numeri sui nemici che non stai bersagliando. Cambiala in API moderna → Modalità danni."
L["Off-target size"] = "Dimensione fuori bersaglio"
L["Off-target opacity"] = "Opacità fuori bersaglio"

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
L["Healing"] = "Cure"
L["Show healing"] = "Mostra cure"
L["Show your outgoing heals on the recipient's nameplate. Friendly nameplates must be enabled in the game."] =
    "Mostra le tue cure in uscita sulla barra del nome del destinatario. Le barre amichevoli devono essere attivate nel gioco."
L["Uses the same size, motion, duration, icons, and threshold as damage. Skips heals on you."] =
    "Usa le stesse dimensioni, movimento, durata, icone e soglia del danno. Ignora le cure su di te."

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
L["Font"] = "Carattere"
L["Font size"] = "Dimensione carattere"
L["Scroll offset"] = "Scostamento scorrimento"
L["Scroll speed"] = "Velocità scorrimento"
L["%d%%"] = "%d%%"
L["Display duration"] = "Durata visualizzazione"
L["Game default"] = "Predefinito del gioco"
L["Friz Quadrata"] = "Friz Quadrata"
L["Arial Narrow"] = "Arial Narrow"
L["Skurri"] = "Skurri"
L["Morpheus"] = "Morpheus"
L["Game fonts, plus SharedMedia fonts when that library is loaded by another addon."] =
    "Caratteri del gioco, più i caratteri SharedMedia quando quella libreria è caricata da un altro addon."
L["Only fonts inside the WoW folder can load. SharedMedia fonts appear when another addon provides them."] =
    "Si possono caricare solo i caratteri nella cartella di WoW. I caratteri SharedMedia compaiono quando un altro addon li fornisce."
L["Recommended"] = "Consigliato"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1fs"
L["%.1fx"] = "%.1fx"
L["Show CRITICAL"] = "Mostra CRITICO"
L["Show CRITICAL on critical hits. Impact saves its own choice, enabled by default."] =
    "Mostra CRITICO sui colpi critici. Impact salva una scelta separata, attiva per impostazione predefinita."
L["CRITICAL"] = "CRITICO"

L["Minimum damage threshold"] = "Soglia minima di danno"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "I colpi sotto questo importo sono nascosti. Digita 50k o 2m. Imposta 0 per mostrare tutto."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Supporta i suffissi k/m, es. 20k o 2m. Il danno sotto questo valore non verrà mostrato."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "In incursioni e Mitica+ alcuni valori sono segreti, quindi la soglia nasconde quei colpi visivamente invece di saltarli."

-- Combine hits
L["Combine hits"] = "Unisci colpi"
L["Combine rapid hits"] = "Unisci colpi rapidi"
L["Add hits that land in quick succession on the same nameplate into one number instead of stacking many."] =
    "Somma i colpi che arrivano in rapida successione sulla stessa barra del nome in un unico numero invece di impilarne molti."
L["Combine"] = "Unisci"
L["Same spell"] = "Stesso incantesimo"
L["All hits"] = "Tutti i colpi"
L["Same spell keeps each spell's number separate. All hits merges every hit on the target; its icon shows the spell that did the most damage."] =
    "Stesso incantesimo tiene separato il numero di ogni incantesimo. Tutti i colpi unisce ogni colpo sul bersaglio; la sua icona mostra l'incantesimo che ha inflitto più danni."
L["Combine window"] = "Finestra di unione"
L["%.2fs"] = "%.2fs"
L["Show hit count"] = "Mostra numero di colpi"
L["Show how many hits were combined, e.g. 37,200 (3). With spell icons on, the count sits on the icon."] =
    "Mostra quanti colpi sono stati uniti, ad es. 37.200 (3). Con le icone degli incantesimi attive, il numero appare sull'icona."
L["%s (%d)"] = "%s (%d)"
L["Crits, normal hits, and heals combine separately."] = "Critici, colpi normali e cure vengono uniti separatamente."
L["Crits, normal hits, and heals combine separately. Secret amounts cannot be added, so those hits still show individually."] =
    "Critici, colpi normali e cure vengono uniti separatamente. I valori segreti non possono essere sommati, quindi quei colpi vengono ancora mostrati singolarmente."

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

-- Settings redesign
L["Animate settings"] = "Anima le impostazioni"
L["Appearance"] = "Aspetto"
L["Appearance only · Test on Target checks gameplay size."] = "Solo aspetto · Prova sul bersaglio verifica le dimensioni in gioco."
L["Appearance preview"] = "Anteprima dell'aspetto"
L["Attribution"] = "Attribuzione"
L["Attribution limitations"] = "Limiti dell'attribuzione"
L["Audio cues for outgoing critical hits."] = "Avvisi sonori per i tuoi colpi critici."
L["Both number styles are available on every supported WoW API."] = "Entrambi gli stili dei numeri sono disponibili con tutte le API di WoW supportate."
L["Classic API - Era/TBC/Wrath/MoP"] = "API Classic - Era/TBC/Wrath/MoP"
L["Classic number style"] = "Stile numeri Classic"
L["Close"] = "Chiudi"
L["Combat"] = "Combattimento"
L["Current target"] = "Bersaglio attuale"
L["Damage mode"] = "Modalità danni"
L["Damage threshold"] = "Soglia danni"
L["Diagnostics"] = "Diagnostica"
L["Engaged nameplates"] = "Barre in combattimento"
L["Existing features"] = "Funzioni esistenti"
L["Find a setting"] = "Cerca un'impostazione"
L["Fonts, colors, numbers, and spell icons."] = "Caratteri, colori, numeri e icone degli incantesimi."
L["Help & Settings"] = "Aiuto e impostazioni"
L["Hide preview"] = "Nascondi anteprima"
L["Instance profiles"] = "Profili delle istanze"
L["Meter probe requires Modern API - Midnight & Forever."] = "La diagnostica del contatore richiede l'API moderna - Midnight e Forever."
L["Midnight & Forever damage modes and attribution."] = "Modalità danni e attribuzione per Midnight e Forever."
L["Modern API"] = "API moderna"
L["Modern API - Midnight & Forever"] = "API moderna - Midnight e Forever"
L["Modern number style"] = "Stile numeri moderno"
L["Modern number style motion"] = "Movimento dello stile numeri moderno"
L["No matching settings"] = "Nessuna impostazione trovata"
L["Number formatting"] = "Formato dei numeri"
L["Number style, timing, and movement."] = "Stile dei numeri, durata e movimento."
L["Personal - experimental"] = "Personale - sperimentale"
L["Play crit sound"] = "Riproduci suono critico"
L["Play huge crit sound"] = "Riproduci suono di critico potente"
L["Preferences"] = "Preferenze"
L["Preferences, API information, and diagnostics."] = "Preferenze, informazioni sull'API e diagnostica."
L["Preview scale: %d%%"] = "Scala anteprima: %d%%"
L["Replay"] = "Ripeti"
L["Schools"] = "Scuole"
L["Settings redesign"] = "Nuova interfaccia delle impostazioni"
L["Settings window"] = "Finestra delle impostazioni"
L["Show preview"] = "Mostra anteprima"
L["Sounds"] = "Suoni"
L["Spell icons"] = "Icone degli incantesimi"
L["Text size"] = "Dimensione del testo"
L["Timing and movement"] = "Durata e movimento"
L["Training dummy"] = "Manichino d'addestramento"
L["Unsupported client - combat text unavailable"] = "Client non supportato - testo di combattimento non disponibile"
L["Your WoW API"] = "La tua API di WoW"
L["Mixed"] = "Misto"
L["Hit"] = "Colpo"
L["Crit"] = "Critico"
L["Miss"] = "Mancato"

-- Settings explanations
L["A new WoW-inspired settings window with clear sections, searchable controls, and gentle animations."] = "Nuova finestra delle impostazioni in stile WoW, con sezioni chiare, ricerca e animazioni leggere."
L["Choose Personal - experimental under Modern API → Damage mode to use pet matching."] = "Scegli Personale - sperimentale in API moderna → Modalità danni per associare i colpi del famiglio."
L["Choose Personal - experimental under Modern API → Damage mode to use spell icons."] = "Scegli Personale - sperimentale in API moderna → Modalità danni per usare le icone degli incantesimi."
L["Choose the combat text you want to see."] = "Scegli il testo di combattimento da visualizzare."
L["Choose whose damage to display under Modern API → Damage mode. Personal mode is experimental."] = "Scegli di chi mostrare i danni in API moderna → Modalità danni. La modalità Personale è sperimentale."
L["Classic clients read damage ownership and spells directly from the combat log. Modern attribution and school-filter options do not apply."] = "I client Classic leggono la fonte dei danni e gli incantesimi dal registro di combattimento. L'attribuzione moderna e il filtro delle scuole non si applicano."
L["Classic number style uses its own animation. Switch to Modern number style to customize motion."] = "Lo stile numeri Classic usa un'animazione propria. Scegli lo stile moderno per personalizzare il movimento."
L["Current target: all-source numbers on your target. Engaged nameplates: all-source numbers on engaged enemies."] = "Bersaglio attuale: danni da tutte le fonti sul bersaglio. Barre in combattimento: danni da tutte le fonti sui nemici impegnati in combattimento."
L["Damage meter probe is available. Capture a snapshot while hitting a target."] = "La diagnostica del contatore è disponibile. Cattura uno stato mentre attacchi un bersaglio."
L["Enable Auto-switch by instance to edit the instance profiles."] = "Attiva il cambio automatico per istanza per modificarne i profili."
L["Enable Filter by damage school to choose allowed schools."] = "Attiva il filtro per scuola di danno per scegliere le scuole consentite."
L["Enable Show incoming hits to adjust its position."] = "Attiva Mostra colpi subiti per regolarne la posizione."
L["Enable Show spell icon to choose its position."] = "Attiva Mostra icona dell'incantesimo per sceglierne la posizione."
L["Enable crit sound to adjust its threshold and channel."] = "Attiva il suono critico per regolarne soglia e canale."
L["Enable huge crit sound to adjust its threshold and channel."] = "Attiva il suono di critico potente per regolarne soglia e canale."
L["Modern API options now have their own page. Damage mode combines Only my damage and All engaged nameplates without changing saved preferences."] = "Le opzioni dell'API moderna hanno una pagina dedicata. Modalità danni unisce Solo i miei danni e Tutte le barre in combattimento, conservando le preferenze salvate."
L["Modern API: unreadable damage amounts cannot trigger threshold sounds."] = "API moderna: i valori di danno illeggibili non possono attivare i suoni a soglia."
L["Modern clients restrict combat information. Personal mode estimates ownership; all-source modes display target or engaged-nameplate damage."] = "I client moderni limitano i dati di combattimento. Personale stima la fonte; le altre modalità mostrano i danni di tutte le fonti sul bersaglio o sui nemici in combattimento."
L["Outgoing healing, incoming damage, font selection, scroll speed, school colors, spell icons, and critical-hit sounds remain available."] = "Restano disponibili cure effettuate, danni subiti, caratteri, velocità, colori delle scuole, icone e suoni dei critici."
L["Personal matches recent casts. Current target and Engaged nameplates show damage from all sources."] = "Personale associa i lanci recenti. Bersaglio attuale e Barre in combattimento mostrano danni di tutte le fonti."
L["Personal - experimental: best-effort matching by destination and timing. Other players' hits on the same target can appear."] = "Personale - sperimentale: associazione approssimativa per bersaglio e tempo. Possono apparire colpi di altri giocatori sullo stesso bersaglio."
L["Pet matching and spell icons require Personal mode. Choose their appearance and visibility under Combat and Appearance."] = "L'associazione del famiglio e le icone richiedono Personale. Regola visibilità e aspetto in Combattimento e Aspetto."
L["Place the spell icon beside, above, or below the number."] = "Posiziona l'icona accanto, sopra o sotto il numero."
L["PlateSCT needs enemy nameplates. Press V (default) or enable them in the game's nameplate settings."] = "PlateSCT richiede le barre dei nomi nemici. Premi V (predefinito) o attivale nelle impostazioni del gioco."
L["Profiles affect Personal mode. They cannot prove who dealt a hit on Modern API."] = "I profili influenzano Personale. Non possono confermare chi ha colpito con l'API moderna."
L["Show damage you take near your character. Independent of the outgoing damage mode."] = "Mostra i danni subiti vicino al personaggio, indipendentemente dalla modalità dei danni inflitti."
L["Show sample hits, crits, and misses in the bottom preview drawer."] = "Mostra colpi, critici e mancati di esempio nel pannello inferiore dell'anteprima."
L["Show sample hits, crits, and misses inside this window."] = "Mostra colpi, critici e mancati di esempio in questa finestra."
L["Spell icons use matched casts in Personal mode; Modern API cannot identify a spell for every hit."] = "Le icone usano i lanci associati in Personale; l'API moderna non identifica l'incantesimo di ogni colpo."
L["Spell icons use the spell from the combat log."] = "Le icone usano l'incantesimo del registro di combattimento."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. Both number styles remain available on every API."] = "L'anteprima inferiore compatta include Misto, Colpo, Critico e Mancato. Entrambi gli stili restano disponibili con tutte le API."
L["The preview shows appearance only. It does not prove attribution or simulate damage filtering."] = "L'anteprima mostra solo l'aspetto. Non conferma l'attribuzione e non simula i filtri dei danni."
L["This client does not expose the damage meter API. A snapshot can still report which fields are unavailable."] = "Questo client non espone l'API del contatore danni. Un rapporto può comunque indicare i campi non disponibili."
L["Turn off Auto-switch by instance to choose manual strictness."] = "Disattiva il cambio automatico per istanza per scegliere manualmente la severità."
L["Unreadable amounts cannot trigger threshold sounds. Unreadable damage schools are always allowed by the school filter."] = "I valori illeggibili non attivano i suoni a soglia. Le scuole illeggibili sono sempre consentite dal filtro."
L["Use gentle fades and row reveals in this settings window. Combat animation is unaffected."] = "Usa dissolvenze leggere e comparsa delle righe nelle impostazioni. L'animazione in combattimento resta invariata."

-- What's new: combine hits
L["Rapid hits on the same nameplate can merge into one growing number with a hit count. Turn it on under Combat → Combine hits."] =
    "I colpi rapidi sulla stessa barra del nome possono unirsi in un unico numero crescente con il conteggio dei colpi. Attivalo in Combattimento → Unisci colpi."

-- Reduce clutter
L["Reduce clutter"] = "Riduci il disordine"

-- Combine hits: merge pop
L["Pop on each merge"] = "Rimbalzo a ogni unione"
L["Briefly enlarge the number every time another hit merges into it. Turn off for a calmer display."] =
    "Ingrandisce brevemente il numero ogni volta che vi si unisce un altro colpo. Disattiva per una visualizzazione più calma."
