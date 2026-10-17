local _, BD = ...

local L = {}
BD.RegisterLocale("deDE", L)

-- Number position and font preview
L["Number position"] = "Zahlenposition"
L["X offset"] = "X-Versatz"
L["Y offset"] = "Y-Versatz"
L["Offsets are saved separately for each number style. Positive X moves right; positive Y moves up. Incoming uses its own position controls."] = "Der Versatz wird für jeden Zahlenstil separat gespeichert. Positives X verschiebt nach rechts, positives Y nach oben. Eingehender Schaden hat eigene Positionsregler."
L["Hover over a font to preview 12345."] = "Bewege den Mauszeiger über eine Schriftart, um eine Vorschau von 12345 zu sehen."
L["Press Ctrl+C to copy the URL."] = "Drücke Strg+C, um die URL zu kopieren."
L["Open Link"] = "Link öffnen"

-- Translation feedback
L["This translation was generated with AI. If you find inconsistent terminology or incorrect wording, please report it through GitHub Issues. Thank you for your help! Translation contributors will be credited."] =
    "Diese Übersetzung wurde mit KI erstellt. Wenn dir uneinheitliche Begriffe oder falsche Formulierungen auffallen, melde sie bitte über GitHub Issues. Vielen Dank für deine Hilfe! Mitwirkende an der Übersetzung werden namentlich erwähnt."

L["Impact number style"] = "Impact-Zahlenstil"
L["All number styles are available on every supported WoW API."] = "Alle Zahlenstile sind auf jeder unterstützten WoW-API verfügbar."
L["Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."] = "Impact schleudert verursachten Schaden neben oder über die Namensplakette und lässt ihn dann aufsteigen. Neue Treffer liegen vorne; kritische Treffer werden größer und KRITISCH blinkt darüber, wenn aktiviert."
L["Impact style position"] = "Position des Impact-Stils"
L["Damage position"] = "Schadensposition"
L["Side"] = "Seite"
L["Place Impact damage to the right of the nameplate or centered above it."] = "Platziert Impact-Schaden rechts neben der Namensplakette oder mittig darüber."
L["Impact uses Modern for incoming damage, healing, and miss text, preserving saved Modern motions."] = "Impact verwendet Modern für eingehenden Schaden, Heilung und verfehlte Angriffe. Gespeicherte Modern-Bewegungen bleiben erhalten."
L["Pick a motion for each hit type in Modern. Classic and Impact use their own damage animations."] = "Wähle im Modern-Stil eine Bewegung je Treffertyp. Classic und Impact verwenden eigene Schadensanimationen."
L["Switch to Modern number style to customize these motions."] = "Wechsle zum Modern-Zahlenstil, um diese Bewegungen anzupassen."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. All number styles remain available on every API."] = "Die kompakte Vorschau unten zeigt gemischte, normale, kritische und verfehlte Treffer. Alle Zahlenstile bleiben auf jeder API verfügbar."

L["PlateSCT is in Beta"] = "PlateSCT ist in der Beta"
L["This addon is in Beta mode. Inaccuracies and errors may show up. Please report such issues on the addon's page."] =
    "Dieses Addon befindet sich im Beta-Modus. Ungenauigkeiten und Fehler können auftreten. Bitte meldet solche Probleme auf der Addon-Seite."
L["Reset PlateSCT settings to defaults?"] = "PlateSCT-Einstellungen auf Standard zurücksetzen?"
L["Addon page"] = "Addon-Seite"
L["Select the URL below, copy it, then paste it in your browser."] =
    "Markiert die URL unten, kopiert sie und fügt sie in eurem Browser ein."
L["Click to open the addon page URL."] = "Klicken, um die Addon-Seiten-URL zu öffnen."
L["/platesct  ·  ESC to close"] = "/platesct  ·  ESC zum Schließen"
L["PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."] =
    "PlateSCT verwendet ein eigenes Einstellungsfenster.\n\nTippt /platesct im Chat oder klickt auf die Schaltfläche unten."
L["Open PlateSCT"] = "PlateSCT öffnen"
L["Target something to preview test numbers."] = "Wählt ein Ziel aus, um Testzahlen anzuzeigen."
L["Meter probe"] = "Meter-Sonde"
L["Click the box, Ctrl+A, then Ctrl+C, and paste it in chat."] =
    "Klickt in das Feld, Strg+A, dann Strg+C, und fügt es im Chat ein."

L["General"] = "Allgemein"
L["Display"] = "Anzeige"
L["Damage"] = "Schaden"
L["Tools"] = "Werkzeuge"
L["Tools & Preview"] = "Werkzeuge & Vorschau"
L["What's new?"] = "Neuigkeiten"
L["Choose whose damage and which nameplates to show."] =
    "Wählt, wessen Schaden und welche Namensplaketten angezeigt werden."
L["Control how numbers look and how they animate."] =
    "Steuert Aussehen und Animation der Zahlen."
L["Hide small hits so the big numbers stay readable."] =
    "Blendet kleine Treffer aus, damit große Zahlen lesbar bleiben."
L["Preview numbers and maintain your setup."] =
    "Zahlen vorschauen und eure Einstellungen pflegen."
L["Recent changes in PlateSCT."] = "Aktuelle Änderungen in PlateSCT."
L["Version 1.1.4"] = "Version 1.1.4"
L["NEW"] = "NEU"
L["IMPROVED"] = "VERBESSERT"
L["Outgoing healing on the recipient's nameplate. Enable Show healing under General (off by default). Friendly nameplates must be on in the game."] =
    "Ausgehende Heilung auf der Namensplakette des Empfängers. „Heilung anzeigen“ unter Allgemein aktivieren (standardmäßig aus). Freundliche Namensplaketten müssen im Spiel an sein."
L["Scroll speed slider - numbers travel faster; fade still follows Display duration."] =
    "Scroll-Geschwindigkeit - Zahlen bewegen sich schneller; Ausblenden folgt weiter der Anzeigedauer."
L["Font picker - game fonts, plus SharedMedia fonts when another addon provides them."] =
    "Schriftauswahl - Spielschriften plus SharedMedia, wenn ein anderes Addon sie bereitstellt."
L["Font size up to 48, Scroll offset up to 120 px, Display duration up to 4 seconds."] =
    "Schriftgröße bis 48, Scroll-Versatz bis 120 px, Anzeigedauer bis 4 Sekunden."
L["Larger fonts spread out more in Modern number style so hits overlap less."] =
    "Größere Schriften verteilen sich im modernen Zahlenstil stärker, weniger Überlappung."

L["Combat text"] = "Kampftext"
L["Enable PlateSCT"] = "PlateSCT aktivieren"
L["Show floating damage numbers on nameplates."] =
    "Zeigt schwebende Schadenszahlen auf Namensplaketten."
L["Hide Blizzard floating combat text"] = "Blizzard-Schwebe-Kampftext ausblenden"
L["Turns off default in-world damage numbers."] =
    "Deaktiviert die standardmäßigen Schadenszahlen in der Welt."
L["Show minimap button"] = "Minikarten-Schaltfläche anzeigen"
L["Show the PlateSCT icon on the minimap. Click it to open settings."] =
    "Zeigt das PlateSCT-Symbol auf der Minikarte. Klicken zum Öffnen der Einstellungen."
L["Click to open settings."] = "Klicken, um die Einstellungen zu öffnen."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "Feindliche Namensplaketten sind deaktiviert. PlateSCT braucht sie, um Zahlen anzuzeigen.\nDrückt V (Standard) oder aktiviert sie unter Interface → Spiel → Namen."
L["Who to show"] = "Wen anzeigen"
L["Only my damage"] = "Nur mein Schaden"
L["Show hits on your current target when you recently cast or auto-attacked. Midnight cannot prove who dealt the hit in a group."] =
    "Zeigt Treffer auf eurem aktuellen Ziel, wenn ihr kürzlich gezaubert oder auto-angegriffen habt. Midnight kann in einer Gruppe nicht beweisen, wer den Treffer verursacht hat."
L["Experimental"] = "Experimentell"
L["Best effort on your current target. Other players hitting the same mob can still show up. Off-target cleave and DoTs are not shown."] =
    "Beste Näherung auf eurem aktuellen Ziel. Andere Spieler, die denselben Mob treffen, können trotzdem erscheinen. Cleave neben dem Ziel und DoTs werden nicht angezeigt."
L["All engaged nameplates"] = "Alle aktiven Namensplaketten"
L["Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."] =
    "Zeigt jeden Treffer auf jeder sichtbaren feindlichen Namensplakette. Das ist der genaue Midnight-Modus; er enthält Schaden aus jeder Quelle."
L["Available when Only my damage is off. Use this to see numbers on every enemy plate."] =
    "Verfügbar, wenn „Nur mein Schaden“ aus ist. Damit seht ihr Zahlen auf jeder feindlichen Plakette."
L["Include pet damage"] = "Begleiterschaden einbeziehen"
L["In Only my damage mode, also treat a recent pet cast as your hit."] =
    "Im Modus „Nur mein Schaden“ einen kürzlichen Begleiterzauber ebenfalls als euren Treffer werten."
L["Healing"] = "Heilung"
L["Show healing"] = "Heilung anzeigen"
L["Show your outgoing heals on the recipient's nameplate. Friendly nameplates must be enabled in the game."] =
    "Zeigt eure ausgehenden Heilungen auf der Namensplakette des Empfängers. Freundliche Namensplaketten müssen im Spiel aktiviert sein."
L["Uses the same size, motion, duration, icons, and threshold as damage. Skips heals on you."] =
    "Nutzt dieselbe Größe, Bewegung, Dauer, Symbole und Schwelle wie Schaden. Überspringt Heilungen auf euch."

L["Number style"] = "Zahlenstil"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "Modern scrollt von der Namensplakette nach oben mit einem kleinen Krit-Effekt. Classic behält das Wachsen-und-Setzen, nah an der Plakette."
L["Modern"] = "Modern"
L["Classic"] = "Classic"
L["Show live preview"] = "Live-Vorschau anzeigen"
L["Show sample hits, crits, and misses beside this window."] =
    "Zeigt Beispieltreffer, Krits und Verfehlen neben diesem Fenster."
L["Hide live preview"] = "Live-Vorschau ausblenden"
L["Color by damage school"] = "Nach Schadensschule einfärben"
L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."] =
    "Färbt Zahlen nach Schule (Feuer orange, Frost blau usw.). Aus behält das Standardgelb."
L["Show spell icon"] = "Zauber-Symbol anzeigen"
L["Display the spell's icon to the left of the damage number. Uses your last cast or auto-attack."] =
    "Zeigt das Zaubersymbol links neben der Schadenszahl. Nutzt euren letzten Zauber oder Autoangriff."
L["Uses your last spell in Only my damage mode. Left of the number."] =
    "Nutzt euren letzten Zauber im Modus „Nur mein Schaden“. Links neben der Zahl."
L["Text style"] = "Textstil"
L["Abbreviate numbers"] = "Zahlen abkürzen"

-- What's new: labels and colors
L["Labels and colors"] = "Beschriftungen und Farben"
L["Spell names next to numbers, a text outline choice, custom hit, crit, and miss colors, and a separate auto-attack motion."] =
    "Zaubernamen neben den Zahlen, wählbare Textkontur, eigene Farben für Treffer, kritische Treffer und Fehltexte sowie eigene Bewegung für automatische Angriffe."


-- Auto-attack motion
L["Same as normal hits"] = "Wie normale Treffer"
L["Auto-attacks"] = "Automatische Angriffe"
L["Motion used for your normal auto-attack hits, so melee swings can move differently from spells. Auto-attack crits use the Critical hits motion."] =
    "Bewegung für normale Treffer eures automatischen Angriffs, damit sich Nahkampfschläge von Zaubern unterscheiden. Kritische automatische Angriffe nutzen die Bewegung für kritische Treffer."


-- Spell label
L["Label"] = "Beschriftung"
L["Top"] = "Oben"
L["Bottom"] = "Unten"
L["Name"] = "Name"
L["Left"] = "Links"
L["Icon"] = "Symbol"
L["Right"] = "Rechts"
L["Icon and name"] = "Symbol und Name"
L["Spell label"] = "Zauberbeschriftung"
L["Show spell label"] = "Zauberbeschriftung anzeigen"
L["Show which spell dealt each hit. Uses the matched cast or auto-attack."] =
    "Zeigt, welcher Zauber jeden Treffer verursacht hat. Nutzt den zugeordneten Zauber oder den automatischen Angriff."
L["Show which spell dealt each hit. Uses the spell from the combat log."] =
    "Zeigt, welcher Zauber jeden Treffer verursacht hat. Nutzt den Zauber aus dem Kampflog."
L["Show the spell's icon, its name, or both."] = "Zeigt das Symbol des Zaubers, seinen Namen oder beides."
L["Enable Show spell label to choose the label."] = "Aktiviert „Zauberbeschriftung anzeigen“, um die Beschriftung zu wählen."
L["Name position"] = "Namensposition"
L["Where the spell name sits relative to the number."] = "Wo der Zaubername relativ zur Zahl steht."
L["Name size"] = "Namensgröße"
L["Shorten long names"] = "Lange Namen kürzen"
L["After %d characters"] = "Nach %d Zeichen"
L["The Name label has no icon to place."] = "Die Beschriftung „Name“ hat kein Symbol zum Platzieren."
L["Enable Show spell label to choose its position."] = "Aktiviert „Zauberbeschriftung anzeigen“, um die Position zu wählen."


-- Custom colors
L["Normal hits"] = "Normale Treffer"
L["Custom colors"] = "Eigene Farben"
L["Pick your own colors for normal hits, crits, and miss text instead of the default yellow."] =
    "Wählt eigene Farben für normale Treffer, kritische Treffer und Fehltexte statt des Standard-Gelbs."
L["Turn off Color by damage school to pick custom colors."] = "Deaktiviert „Nach Schadensschule einfärben“, um eigene Farben zu wählen."
L["Color of normal damage numbers."] = "Farbe normaler Schadenszahlen."
L["Critical hits"] = "Kritische Treffer"
L["Color of critical hit numbers."] = "Farbe kritischer Trefferzahlen."
L["Miss text"] = "Fehltext"
L["Color of Miss, Dodge, Immune, and similar text."] = "Farbe von Verfehlt, Ausgewichen, Immun und ähnlichen Texten."


-- Outline
L["Outline"] = "Kontur"
L["Number style default"] = "Zahlenstil-Standard"
L["None"] = "Keine"
L["Thin"] = "Dünn"
L["Thick"] = "Dick"
L["Text outline. Number style default uses each style's own outline: thick for Classic, thin for Modern and Impact."] =
    "Textkontur. Zahlenstil-Standard nutzt die Kontur des jeweiligen Stils: dick für Classic, dünn für Modern und Impact."

L["Display large numbers as 214k or 1.2M."] = "Zeigt große Zahlen als 214k oder 1,2M."
L["Display large numbers as 214k or 1.2M. Disables thousand separators."] =
    "Zeigt große Zahlen als 214k oder 1,2M. Deaktiviert Tausendertrennzeichen."
L["Thousand separators"] = "Tausendertrennzeichen"
L["Group digits by thousands."] = "Gruppiert Ziffern in Tausendern."
L["Unavailable while Abbreviate numbers is on."] = "Nicht verfügbar, solange „Zahlen abkürzen“ aktiv ist."
L["Off"] = "Aus"
L["Comma (10,000)"] = "Komma (10,000)"
L["Dot (10.000)"] = "Punkt (10.000)"
L["Animation"] = "Animation"
L["Font"] = "Schriftart"
L["Font size"] = "Schriftgröße"
L["Scroll offset"] = "Scroll-Versatz"
L["Scroll speed"] = "Scroll-Geschwindigkeit"
L["%d%%"] = "%d %%"
L["Display duration"] = "Anzeigedauer"
L["Game default"] = "Spielstandard"
L["Friz Quadrata"] = "Friz Quadrata"
L["Arial Narrow"] = "Arial Narrow"
L["Skurri"] = "Skurri"
L["Morpheus"] = "Morpheus"
L["Game fonts, plus SharedMedia fonts when that library is loaded by another addon."] =
    "Schriftarten des Spiels sowie SharedMedia-Schriften, wenn diese Bibliothek von einem anderen Addon geladen ist."
L["Only fonts inside the WoW folder can load. SharedMedia fonts appear when another addon provides them."] =
    "Nur Schriften im WoW-Ordner können geladen werden. SharedMedia-Schriften erscheinen, wenn ein anderes Addon sie bereitstellt."
L["Recommended"] = "Empfohlen"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1fs"
L["%.1fx"] = "%.1fx"
L["Show CRITICAL"] = "KRITISCH anzeigen"
L["Show CRITICAL on critical hits. Impact saves its own choice, enabled by default."] =
    "Zeigt KRITISCH bei kritischen Treffern. Impact speichert eine eigene Auswahl, die standardmäßig aktiviert ist."
L["CRITICAL"] = "KRITISCH"

L["Minimum damage threshold"] = "Mindest-Schadensschwelle"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "Treffer unter diesem Wert werden ausgeblendet. Tippt 50k oder 2m. 0 zeigt alles."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Unterstützt k/m-Suffixe, z. B. 20k oder 2m. Schaden darunter wird nicht angezeigt."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "In Schlachtzügen und Mythisch+ sind manche Werte geheim, daher blendet die Schwelle diese Treffer optisch aus statt sie zu überspringen."

-- Combine hits
L["Combine hits"] = "Treffer zusammenfassen"
L["Combine rapid hits"] = "Schnelle Treffer zusammenfassen"
L["Add hits that land in quick succession on the same nameplate into one number instead of stacking many."] =
    "Fasst Treffer, die kurz nacheinander auf derselben Namensplakette landen, zu einer Zahl zusammen, statt viele zu stapeln."
L["Combine"] = "Zusammenfassen"
L["Same spell"] = "Gleicher Zauber"
L["All hits"] = "Alle Treffer"
L["Same spell keeps each spell's number separate. All hits merges every hit on the target; its icon shows the spell that did the most damage."] =
    "Gleicher Zauber hält die Zahl jedes Zaubers getrennt. Alle Treffer fasst jeden Treffer auf dem Ziel zusammen; das Symbol zeigt den Zauber mit dem meisten Schaden."
L["Combine window"] = "Zeitfenster"
L["%.2fs"] = "%.2fs"
L["Show hit count"] = "Trefferanzahl anzeigen"
L["Show how many hits were combined, e.g. 37,200 (3). With spell icons on, the count sits on the icon."] =
    "Zeigt, wie viele Treffer zusammengefasst wurden, z. B. 37.200 (3). Mit Zauber-Symbolen steht die Anzahl auf dem Symbol."
L["%s (%d)"] = "%s (%d)"
L["Crits, normal hits, and heals combine separately."] = "Kritische Treffer, normale Treffer und Heilungen werden getrennt zusammengefasst."
L["Crits, normal hits, and heals combine separately. Secret amounts cannot be added, so those hits still show individually."] =
    "Kritische Treffer, normale Treffer und Heilungen werden getrennt zusammengefasst. Geheime Werte lassen sich nicht addieren, daher erscheinen diese Treffer weiterhin einzeln."

L["Preview"] = "Vorschau"
L["Updates live as you change options."] = "Aktualisiert sich live bei Optionsänderungen."
L["Target an enemy, then spawn sample numbers on its nameplate."] =
    "Wählt einen Feind und erzeugt Beispielzahlen auf seiner Namensplakette."
L["Test on Target"] = "Am Ziel testen"
L["Show sample damage numbers on your target."] = "Zeigt Beispiel-Schadenszahlen auf eurem Ziel."
L["Maintenance"] = "Wartung"
L["Debug mode"] = "Debug-Modus"
L["Print combat events to chat for troubleshooting."] =
    "Gibt Kampfereignisse zum Troubleshooting im Chat aus."
L["Dump meter now"] = "Meter jetzt dumpen"
L["Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."] =
    "Öffnet eine kopierbare Momentaufnahme der C_DamageMeter-Felder. Im Kampf nutzen, während ihr ein Ziel trefft."
L["Reset Defaults"] = "Standard zurücksetzen"
L["Restore every PlateSCT setting to its default."] =
    "Setzt alle PlateSCT-Einstellungen auf den Standard zurück."

-- Language
L["Language"] = "Sprache"
L["Choose the language used by PlateSCT panels and messages."] =
    "Wählt die Sprache für PlateSCT-Fenster und Meldungen."
L["Auto"] = "Auto"

-- Settings redesign
L["Animate settings"] = "Einstellungen animieren"
L["Appearance"] = "Aussehen"
L["Appearance only · Test on Target checks gameplay size."] = "Nur Aussehen · Test am Ziel zeigt die Größe im Spiel."
L["Appearance preview"] = "Aussehensvorschau"
L["Attribution"] = "Zuordnung"
L["Attribution limitations"] = "Grenzen der Zuordnung"
L["Audio cues for outgoing critical hits."] = "Töne für ausgehende kritische Treffer."
L["Both number styles are available on every supported WoW API."] = "Beide Zahlenstile sind mit jeder unterstützten WoW-API verfügbar."
L["Classic API - Era/TBC/Wrath/MoP"] = "Classic-API - Era/TBC/Wrath/MoP"
L["Classic number style"] = "Classic-Zahlenstil"
L["Close"] = "Schließen"
L["Combat"] = "Kampf"
L["Current target"] = "Aktuelles Ziel"
L["Damage mode"] = "Schadensmodus"
L["Damage threshold"] = "Schadensschwelle"
L["Diagnostics"] = "Diagnose"
L["Engaged nameplates"] = "Namensplaketten im Kampf"
L["Existing features"] = "Bestehende Funktionen"
L["Find a setting"] = "Einstellung suchen"
L["Fonts, colors, numbers, and spell icons."] = "Schriften, Farben, Zahlen und Zaubersymbole."
L["Help & Settings"] = "Hilfe & Einstellungen"
L["Hide preview"] = "Vorschau ausblenden"
L["Instance profiles"] = "Instanzprofile"
L["Meter probe requires Modern API - Midnight & Forever."] = "Die Messdaten-Diagnose benötigt die moderne API - Midnight & Forever."
L["Midnight & Forever damage modes and attribution."] = "Schadensmodi und Zuordnung für Midnight & Forever."
L["Modern API"] = "Moderne API"
L["Modern API - Midnight & Forever"] = "Moderne API - Midnight & Forever"
L["Modern number style"] = "Moderner Zahlenstil"
L["Modern number style motion"] = "Bewegung des modernen Zahlenstils"
L["No matching settings"] = "Keine passenden Einstellungen"
L["Number formatting"] = "Zahlenformat"
L["Number style, timing, and movement."] = "Zahlenstil, Zeitverhalten und Bewegung."
L["Personal - experimental"] = "Persönlich - experimentell"
L["Play crit sound"] = "Kritischen Ton abspielen"
L["Play huge crit sound"] = "Ton für hohen kritischen Treffer abspielen"
L["Preferences"] = "Voreinstellungen"
L["Preferences, API information, and diagnostics."] = "Voreinstellungen, API-Informationen und Diagnose."
L["Preview scale: %d%%"] = "Vorschauskalierung: %d%%"
L["Replay"] = "Erneut abspielen"
L["Schools"] = "Schulen"
L["Settings redesign"] = "Neue Einstellungsoberfläche"
L["Settings window"] = "Einstellungsfenster"
L["Show preview"] = "Vorschau anzeigen"
L["Sounds"] = "Klänge"
L["Spell icons"] = "Zaubersymbole"
L["Text size"] = "Textgröße"
L["Timing and movement"] = "Zeitverhalten und Bewegung"
L["Training dummy"] = "Trainingsattrappe"
L["Unsupported client - combat text unavailable"] = "Nicht unterstützter Client - Kampftext nicht verfügbar"
L["Your WoW API"] = "Deine WoW-API"
L["Mixed"] = "Gemischt"
L["Hit"] = "Treffer"
L["Crit"] = "Kritisch"
L["Miss"] = "Verfehlt"

-- Settings explanations
L["A new WoW-inspired settings window with clear sections, searchable controls, and gentle animations."] = "Neues Einstellungsfenster im WoW-Stil mit klaren Abschnitten, einer Suche und dezenten Animationen."
L["Choose Personal - experimental under Modern API → Damage mode to use pet matching."] = "Wähle Persönlich - experimentell unter Moderne API → Schadensmodus, um Begleitertreffer zuzuordnen."
L["Choose Personal - experimental under Modern API → Damage mode to use spell icons."] = "Wähle Persönlich - experimentell unter Moderne API → Schadensmodus, um Zaubersymbole zu nutzen."
L["Choose the combat text you want to see."] = "Wähle den angezeigten Kampftext."
L["Choose whose damage to display under Modern API → Damage mode. Personal mode is experimental."] = "Wähle unter Moderne API → Schadensmodus, wessen Schaden erscheint. Der persönliche Modus ist experimentell."
L["Classic clients read damage ownership and spells directly from the combat log. Modern attribution and school-filter options do not apply."] = "Classic-Clients lesen Schadensquelle und Zauber direkt aus dem Kampflog. Moderne Zuordnung und Schulfilter sind hier nicht nötig."
L["Classic number style uses its own animation. Switch to Modern number style to customize motion."] = "Der Classic-Zahlenstil verwendet eigene Animationen. Wähle den modernen Zahlenstil, um die Bewegung anzupassen."
L["Current target: all-source numbers on your target. Engaged nameplates: all-source numbers on engaged enemies."] = "Aktuelles Ziel: Schaden aller Quellen am Ziel. Namensplaketten im Kampf: Schaden aller Quellen an Gegnern im Kampf."
L["Damage meter probe is available. Capture a snapshot while hitting a target."] = "Die Messdaten-Diagnose ist verfügbar. Erfasse einen Bericht, während du ein Ziel angreifst."
L["Enable Auto-switch by instance to edit the instance profiles."] = "Aktiviere den automatischen Wechsel nach Instanz, um Instanzprofile zu bearbeiten."
L["Enable Filter by damage school to choose allowed schools."] = "Aktiviere den Schadensschulfilter, um erlaubte Schulen zu wählen."
L["Enable Show incoming hits to adjust its position."] = "Aktiviere eingehende Treffer, um deren Position anzupassen."
L["Enable Show spell icon to choose its position."] = "Aktiviere das Zaubersymbol, um seine Position zu wählen."
L["Enable crit sound to adjust its threshold and channel."] = "Aktiviere den kritischen Ton, um Schwelle und Kanal anzupassen."
L["Enable huge crit sound to adjust its threshold and channel."] = "Aktiviere den Ton für hohe kritische Treffer, um Schwelle und Kanal anzupassen."
L["Modern API options now have their own page. Damage mode combines Only my damage and All engaged nameplates without changing saved preferences."] = "Optionen der modernen API haben eine eigene Seite. Schadensmodus fasst Nur mein Schaden und Alle Namensplaketten im Kampf zusammen und behält gespeicherte Werte bei."
L["Modern API: unreadable damage amounts cannot trigger threshold sounds."] = "Moderne API: Nicht lesbare Schadenswerte können keine Schwellwerttöne auslösen."
L["Modern clients restrict combat information. Personal mode estimates ownership; all-source modes display target or engaged-nameplate damage."] = "Moderne Clients beschränken Kampfinformationen. Persönlich schätzt die Quelle; die anderen Modi zeigen Schaden aller Quellen am Ziel oder an Gegnern im Kampf."
L["Outgoing healing, incoming damage, font selection, scroll speed, school colors, spell icons, and critical-hit sounds remain available."] = "Ausgehende Heilung, eingehender Schaden, Schriften, Scrollgeschwindigkeit, Schulfarben, Zaubersymbole und kritische Töne bleiben verfügbar."
L["Personal matches recent casts. Current target and Engaged nameplates show damage from all sources."] = "Persönlich ordnet kürzlich gewirkte Zauber zu. Aktuelles Ziel und Namensplaketten im Kampf zeigen Schaden aller Quellen."
L["Personal - experimental: best-effort matching by destination and timing. Other players' hits on the same target can appear."] = "Persönlich - experimentell: bestmögliche Zuordnung nach Ziel und Zeitpunkt. Treffer anderer Spieler am selben Ziel können erscheinen."
L["Pet matching and spell icons require Personal mode. Choose their appearance and visibility under Combat and Appearance."] = "Begleiterzuordnung und Zaubersymbole benötigen Persönlich. Passe deren Sichtbarkeit und Aussehen unter Kampf und Aussehen an."
L["Place the spell icon beside, above, or below the number."] = "Platziere das Zaubersymbol neben, über oder unter der Zahl."
L["PlateSCT needs enemy nameplates. Press V (default) or enable them in the game's nameplate settings."] = "PlateSCT benötigt gegnerische Namensplaketten. Drücke V (Standard) oder aktiviere sie in den Spieleinstellungen."
L["Profiles affect Personal mode. They cannot prove who dealt a hit on Modern API."] = "Profile beeinflussen Persönlich. Sie können bei der modernen API nicht beweisen, wer einen Treffer verursacht hat."
L["Show damage you take near your character. Independent of the outgoing damage mode."] = "Zeigt erlittenen Schaden nahe deiner Figur, unabhängig vom Modus für ausgehenden Schaden."
L["Show sample hits, crits, and misses in the bottom preview drawer."] = "Zeigt Beispieltreffer, kritische Treffer und Fehlschläge im unteren Vorschaufenster."
L["Show sample hits, crits, and misses inside this window."] = "Zeigt Beispieltreffer, kritische Treffer und Fehlschläge in diesem Fenster."
L["Spell icons use matched casts in Personal mode; Modern API cannot identify a spell for every hit."] = "Zaubersymbole nutzen zugeordnete Zauber in Persönlich; die moderne API kann nicht für jeden Treffer einen Zauber bestimmen."
L["Spell icons use the spell from the combat log."] = "Zaubersymbole verwenden den Zauber aus dem Kampflog."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. Both number styles remain available on every API."] = "Die kompakte untere Vorschau bietet Gemischt, Treffer, Kritisch und Verfehlt. Beide Zahlenstile bleiben mit jeder API verfügbar."
L["The preview shows appearance only. It does not prove attribution or simulate damage filtering."] = "Die Vorschau zeigt nur das Aussehen. Sie beweist keine Zuordnung und simuliert keine Schadensfilter."
L["This client does not expose the damage meter API. A snapshot can still report which fields are unavailable."] = "Dieser Client bietet keine Schadensmesser-API. Ein Bericht kann dennoch zeigen, welche Felder fehlen."
L["Turn off Auto-switch by instance to choose manual strictness."] = "Deaktiviere den automatischen Wechsel nach Instanz, um die Strenge manuell zu wählen."
L["Unreadable amounts cannot trigger threshold sounds. Unreadable damage schools are always allowed by the school filter."] = "Nicht lesbare Werte lösen keine Schwellwerttöne aus. Nicht lesbare Schadensschulen werden vom Filter immer zugelassen."
L["Use gentle fades and row reveals in this settings window. Combat animation is unaffected."] = "Verwendet sanftes Einblenden und Zeilenanimationen im Einstellungsfenster. Kampfanimationen bleiben unverändert."

-- What's new: combine hits
L["Rapid hits on the same nameplate can merge into one growing number with a hit count. Turn it on under Combat → Combine hits."] =
    "Schnelle Treffer auf derselben Namensplakette können zu einer wachsenden Zahl mit Trefferanzahl zusammengefasst werden. Aktiviert es unter Kampf → Treffer zusammenfassen."

-- Reduce clutter
L["Reduce clutter"] = "Weniger Durcheinander"

-- Combine hits: merge pop
L["Pop on each merge"] = "Bei jedem Zusammenfassen aufploppen"
L["Briefly enlarge the number every time another hit merges into it. Turn off for a calmer display."] =
    "Vergrößert die Zahl kurz, wenn ein weiterer Treffer hinzukommt. Ausschalten für eine ruhigere Anzeige."
