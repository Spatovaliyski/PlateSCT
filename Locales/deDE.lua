local _, BD = ...

local L = {}
BD.RegisterLocale("deDE", L)

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
L["Choose whose damage and which nameplates to show."] =
    "Wählt, wessen Schaden und welche Namensplaketten angezeigt werden."
L["Control how numbers look and how they animate."] =
    "Steuert Aussehen und Animation der Zahlen."
L["Hide small hits so the big numbers stay readable."] =
    "Blendet kleine Treffer aus, damit große Zahlen lesbar bleiben."
L["Preview numbers and maintain your setup."] =
    "Zahlen vorschauen und eure Einstellungen pflegen."

L["Combat text"] = "Kampftext"
L["Enable PlateSCT"] = "PlateSCT aktivieren"
L["Show floating damage numbers on nameplates."] =
    "Zeigt schwebende Schadenszahlen auf Namensplaketten."
L["Hide Blizzard floating combat text"] = "Blizzard-Schwebe-Kampftext ausblenden"
L["Turns off default in-world damage numbers."] =
    "Deaktiviert die standardmäßigen Schadenszahlen in der Welt."
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

L["Number style"] = "Zahlenstil"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "Modern scrollt von der Namensplakette nach oben mit einem kleinen Krit-Effekt. Classic behält das Wachsen-und-Setzen, nah an der Plakette."
L["Modern"] = "Modern"
L["Classic"] = "Classic"
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
L["Display large numbers as 214k or 1.2M."] = "Zeigt große Zahlen als 214k oder 1,2M."
L["Animation"] = "Animation"
L["Font size"] = "Schriftgröße"
L["Scroll offset"] = "Scroll-Versatz"
L["Display duration"] = "Anzeigedauer"
L["Recommended"] = "Empfohlen"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1fs"

L["Minimum damage threshold"] = "Mindest-Schadensschwelle"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "Treffer unter diesem Wert werden ausgeblendet. Tippt 50k oder 2m. 0 zeigt alles."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Unterstützt k/m-Suffixe, z. B. 20k oder 2m. Schaden darunter wird nicht angezeigt."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "In Schlachtzügen und Mythisch+ sind manche Werte geheim, daher blendet die Schwelle diese Treffer optisch aus statt sie zu überspringen."

L["Preview"] = "Vorschau"
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
