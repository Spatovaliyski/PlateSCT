local _, BD = ...

local L = {}
BD.RegisterLocale("frFR", L)

L["PlateSCT is in Beta"] = "PlateSCT est en bêta"
L["This addon is in Beta mode. Inaccuracies and errors may show up. Please report such issues on the addon's page."] =
    "Cet addon est en mode bêta. Des imprécisions et des erreurs peuvent apparaître. Merci de signaler ces problèmes sur la page de l'addon."
L["Reset PlateSCT settings to defaults?"] = "Réinitialiser les paramètres de PlateSCT par défaut ?"
L["Addon page"] = "Page de l'addon"
L["Select the URL below, copy it, then paste it in your browser."] =
    "Sélectionnez l'URL ci-dessous, copiez-la, puis collez-la dans votre navigateur."
L["Click to open the addon page URL."] = "Cliquez pour ouvrir l'URL de la page de l'addon."
L["/platesct  ·  ESC to close"] = "/platesct  ·  Échap pour fermer"
L["PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."] =
    "PlateSCT utilise sa propre fenêtre de réglages.\n\nTapez /platesct dans le chat, ou cliquez sur le bouton ci-dessous."
L["Open PlateSCT"] = "Ouvrir PlateSCT"
L["Target something to preview test numbers."] = "Sélectionnez une cible pour prévisualiser les nombres de test."
L["Meter probe"] = "Sonde du compteur"
L["Click the box, Ctrl+A, then Ctrl+C, and paste it in chat."] =
    "Cliquez dans la zone, Ctrl+A, puis Ctrl+C, et collez le texte dans le chat."

L["General"] = "Général"
L["Display"] = "Affichage"
L["Damage"] = "Dégâts"
L["Tools"] = "Outils"
L["Tools & Preview"] = "Outils & Aperçu"
L["Choose whose damage and which nameplates to show."] =
    "Choisissez les dégâts et les barres de nom à afficher."
L["Control how numbers look and how they animate."] =
    "Contrôlez l'apparence et l'animation des nombres."
L["Hide small hits so the big numbers stay readable."] =
    "Masquez les petits coups pour garder les gros nombres lisibles."
L["Preview numbers and maintain your setup."] =
    "Prévisualisez les nombres et gérez votre configuration."

L["Combat text"] = "Texte de combat"
L["Enable PlateSCT"] = "Activer PlateSCT"
L["Show floating damage numbers on nameplates."] =
    "Affiche les nombres de dégâts flottants sur les barres de nom."
L["Hide Blizzard floating combat text"] = "Masquer le texte de combat flottant de Blizzard"
L["Turns off default in-world damage numbers."] =
    "Désactive les nombres de dégâts par défaut dans le monde."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "Les barres de nom ennemies sont désactivées. PlateSCT en a besoin pour afficher les nombres.\nAppuyez sur V (par défaut) ou activez-les dans Interface → Jeu → Noms."
L["Who to show"] = "Qui afficher"
L["Only my damage"] = "Uniquement mes dégâts"
L["Show hits on your current target when you recently cast or auto-attacked. Midnight cannot prove who dealt the hit in a group."] =
    "Affiche les coups sur votre cible actuelle lorsque vous venez de lancer un sort ou d'attaquer automatiquement. Midnight ne peut pas prouver qui a infligé le coup en groupe."
L["Experimental"] = "Expérimental"
L["Best effort on your current target. Other players hitting the same mob can still show up. Off-target cleave and DoTs are not shown."] =
    "Meilleur effort sur votre cible actuelle. Les autres joueurs frappant le même monstre peuvent encore apparaître. Les cleaves hors cible et les DoTs ne sont pas affichés."
L["All engaged nameplates"] = "Toutes les barres de nom engagées"
L["Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."] =
    "Affiche chaque coup sur chaque barre de nom hostile visible. C'est le mode Midnight précis ; il inclut les dégâts de toutes les sources."
L["Available when Only my damage is off. Use this to see numbers on every enemy plate."] =
    "Disponible lorsque « Uniquement mes dégâts » est désactivé. Utilisez ceci pour voir les nombres sur chaque barre ennemie."
L["Include pet damage"] = "Inclure les dégâts du familier"
L["In Only my damage mode, also treat a recent pet cast as your hit."] =
    "En mode « Uniquement mes dégâts », traite aussi un sort récent du familier comme votre coup."

L["Number style"] = "Style des nombres"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "Moderne fait défiler vers le haut depuis la barre de nom avec un petit effet de critique. Classic conserve le grossissement puis le tassement, proche de la barre."
L["Modern"] = "Moderne"
L["Classic"] = "Classic"
L["Show live preview"] = "Afficher l'aperçu en direct"
L["Show sample hits, crits, and misses beside this window."] =
    "Affiche des exemples de coups, critiques et échecs à côté de cette fenêtre."
L["Hide live preview"] = "Masquer l'aperçu en direct"
L["Color by damage school"] = "Couleur selon l'école de dégâts"
L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."] =
    "Teinte les nombres selon l'école (feu orange, givre bleu, etc.). Désactivé conserve le jaune par défaut."
L["Show spell icon"] = "Afficher l'icône du sort"
L["Display the spell's icon to the left of the damage number. Uses your last cast or auto-attack."] =
    "Affiche l'icône du sort à gauche du nombre de dégâts. Utilise votre dernier sort ou auto-attaque."
L["Uses your last spell in Only my damage mode. Left of the number."] =
    "Utilise votre dernier sort en mode « Uniquement mes dégâts ». À gauche du nombre."
L["Text style"] = "Style du texte"
L["Abbreviate numbers"] = "Abréger les nombres"
L["Display large numbers as 214k or 1.2M."] = "Affiche les grands nombres comme 214k ou 1,2M."
L["Display large numbers as 214k or 1.2M. Disables thousand separators."] =
    "Affiche les grands nombres comme 214k ou 1,2M. Désactive les séparateurs de milliers."
L["Thousand separators"] = "Séparateurs de milliers"
L["Group digits by thousands."] = "Groupe les chiffres par milliers."
L["Unavailable while Abbreviate numbers is on."] = "Indisponible tant que « Abréger les nombres » est activé."
L["Off"] = "Désactivé"
L["Comma (10,000)"] = "Virgule (10,000)"
L["Dot (10.000)"] = "Point (10.000)"
L["Animation"] = "Animation"
L["Font size"] = "Taille de police"
L["Scroll offset"] = "Décalage du défilement"
L["Display duration"] = "Durée d'affichage"
L["Recommended"] = "Recommandé"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1fs"
L["Show CRITICAL"] = "Afficher CRITIQUE"
L["Show the word CRITICAL in small caps next to critical hit numbers."] =
    "Affiche le mot CRITIQUE en petites capitales à côté des coups critiques."
L["CRITICAL"] = "CRITIQUE"

L["Minimum damage threshold"] = "Seuil minimum de dégâts"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "Les coups en dessous de ce montant sont masqués. Tapez 50k ou 2m. Mettez 0 pour tout afficher."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Prend en charge les suffixes k/m, par ex. 20k ou 2m. Les dégâts en dessous ne seront pas affichés."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "En raids et Mythique+, certains montants sont secrets, donc le seuil masque ces coups visuellement au lieu de les ignorer."

L["Preview"] = "Aperçu"
L["Updates live as you change options."] = "Se met à jour en direct quand vous changez les options."
L["Target an enemy, then spawn sample numbers on its nameplate."] =
    "Ciblez un ennemi, puis générez des nombres d'exemple sur sa barre de nom."
L["Test on Target"] = "Tester sur la cible"
L["Show sample damage numbers on your target."] = "Affiche des nombres de dégâts d'exemple sur votre cible."
L["Maintenance"] = "Maintenance"
L["Debug mode"] = "Mode débogage"
L["Print combat events to chat for troubleshooting."] =
    "Affiche les événements de combat dans le chat pour le dépannage."
L["Dump meter now"] = "Dumper le compteur"
L["Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."] =
    "Ouvre un instantané copiable des champs C_DamageMeter. À utiliser en combat en frappant une cible."
L["Reset Defaults"] = "Réinitialiser"
L["Restore every PlateSCT setting to its default."] =
    "Restaure tous les paramètres de PlateSCT par défaut."

-- Language
L["Language"] = "Langue"
L["Choose the language used by PlateSCT panels and messages."] =
    "Choisissez la langue utilisée par les panneaux et messages de PlateSCT."
L["Auto"] = "Auto"
