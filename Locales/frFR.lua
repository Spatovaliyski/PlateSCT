local _, BD = ...

local L = {}
BD.RegisterLocale("frFR", L)

-- Number position and font preview
L["Number position"] = "Position des nombres"
L["X offset"] = "Décalage X"
L["Y offset"] = "Décalage Y"
L["Offsets are saved separately for each number style. Positive X moves right; positive Y moves up. Incoming uses its own position controls."] = "Les décalages sont enregistrés séparément pour chaque style de nombres. X positif déplace vers la droite ; Y positif vers le haut. Les dégâts subis ont leurs propres réglages de position."
L["Hover over a font to preview 12345."] = "Survolez une police pour afficher un aperçu de 12345."
L["Press Ctrl+C to copy the URL."] = "Appuyez sur Ctrl+C pour copier l'URL."
L["Open Link"] = "Ouvrir le lien"

-- Translation feedback
L["This translation was generated with AI. If you find inconsistent terminology or incorrect wording, please report it through GitHub Issues. Thank you for your help! Translation contributors will be credited."] =
    "Cette traduction a été générée par IA. Si vous trouvez des termes incohérents ou des formulations incorrectes, veuillez les signaler via GitHub Issues. Merci pour votre aide ! Les contributeurs à la traduction seront crédités."

L["Impact number style"] = "Style des nombres Impact"
L["All number styles are available on every supported WoW API."] = "Tous les styles de nombres sont disponibles sur chaque API WoW prise en charge."
L["Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."] = "Impact projette les dégâts infligés à côté ou au-dessus de la plaque de nom, puis les fait monter. Les nouveaux coups passent devant ; les critiques grossissent et CRITIQUE clignote au-dessus si activé."
L["Impact style position"] = "Position du style Impact"
L["Damage position"] = "Position des dégâts"
L["Side"] = "Côté"
L["Place Impact damage to the right of the nameplate or centered above it."] = "Place les dégâts Impact à droite de la plaque de nom ou centrés au-dessus."
L["Impact uses Modern for incoming damage, healing, and miss text, preserving saved Modern motions."] = "Impact utilise le style Moderne pour les dégâts reçus, les soins et les attaques ratées, en conservant les mouvements Moderne enregistrés."
L["Pick a motion for each hit type in Modern. Classic and Impact use their own damage animations."] = "Choisissez un mouvement par type de coup en style Moderne. Classique et Impact utilisent leurs propres animations de dégâts."
L["Switch to Modern number style to customize these motions."] = "Passez au style des nombres Moderne pour personnaliser ces mouvements."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. All number styles remain available on every API."] = "L'aperçu compact en bas comprend des exemples mixtes, normaux, critiques et ratés. Tous les styles de nombres restent disponibles sur chaque API."

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
L["What's new?"] = "Nouveautés"
L["Choose whose damage and which nameplates to show."] =
    "Choisissez les dégâts et les barres de nom à afficher."
L["Control how numbers look and how they animate."] =
    "Contrôlez l'apparence et l'animation des nombres."
L["Hide small hits so the big numbers stay readable."] =
    "Masquez les petits coups pour garder les gros nombres lisibles."
L["Preview numbers and maintain your setup."] =
    "Prévisualisez les nombres et gérez votre configuration."
L["Recent changes in PlateSCT."] = "Changements récents dans PlateSCT."
L["Version 1.1.4"] = "Version 1.1.4"
L["NEW"] = "NOUVEAU"
L["IMPROVED"] = "AMÉLIORÉ"
L["Outgoing healing on the recipient's nameplate. Enable Show healing under General (off by default). Friendly nameplates must be on in the game."] =
    "Soins sortants sur la barre de nom du destinataire. Activez Afficher les soins sous Général (désactivé par défaut). Barres amicales requises dans le jeu."
L["Scroll speed slider - numbers travel faster; fade still follows Display duration."] =
    "Vitesse de défilement - les nombres vont plus vite ; le fondu suit toujours la durée d'affichage."
L["Font picker - game fonts, plus SharedMedia fonts when another addon provides them."] =
    "Sélecteur de police - polices du jeu, plus SharedMedia si un autre addon les fournit."
L["Font size up to 48, Scroll offset up to 120 px, Display duration up to 4 seconds."] =
    "Taille de police jusqu'à 48, décalage jusqu'à 120 px, durée jusqu'à 4 secondes."
L["Larger fonts spread out more in Modern number style so hits overlap less."] =
    "Les grandes polices s'espacent davantage en style Moderne, moins de chevauchement."

L["Combat text"] = "Texte de combat"
L["Enable PlateSCT"] = "Activer PlateSCT"
L["Show floating damage numbers on nameplates."] =
    "Affiche les nombres de dégâts flottants sur les barres de nom."
L["Hide Blizzard floating combat text"] = "Masquer le texte de combat flottant de Blizzard"
L["Turns off default in-world damage numbers."] =
    "Désactive les nombres de dégâts par défaut dans le monde."
L["Show minimap button"] = "Afficher le bouton de la minicarte"
L["Show the PlateSCT icon on the minimap. Click it to open settings."] =
    "Affiche l'icône PlateSCT sur la minicarte. Cliquez pour ouvrir les réglages."
L["Click to open settings."] = "Cliquez pour ouvrir les réglages."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "Les barres de nom ennemies sont désactivées. PlateSCT en a besoin pour afficher les nombres.\nAppuyez sur V (par défaut) ou activez-les dans Interface → Jeu → Noms."
L["Who to show"] = "Qui afficher"

-- What's new: less clutter
L["Less clutter"] = "Moins d'encombrement"
L["Dim or hide numbers on enemies you are not targeting, show crits only, shrink small hits, and ignore chosen spells. Find them on the Combat page."] =
    "Atténuez ou masquez les nombres sur les ennemis non ciblés, affichez uniquement les critiques, réduisez les petits coups et ignorez des sorts choisis. Sur la page Combat."


-- Ignored spells
L["Ignored spells"] = "Sorts ignorés"
L["Ignore these spells"] = "Ignorer ces sorts"
L["Spell names or IDs, separated by commas. Their hits, crits, and misses are not shown."] =
    "Noms ou identifiants de sorts, séparés par des virgules. Leurs coups, critiques et échecs ne sont pas affichés."
L["Example: Auto Attack, 133."] = "Exemple : Attaque automatique, 133."
L["Example: Auto Attack, 133. Modern API knows the spell only in Personal - experimental mode."] =
    "Exemple : Attaque automatique, 133. L'API Modern ne connaît le sort qu'en mode Personnel - expérimental."


-- Shrink small hits
L["Shrink small hits"] = "Réduire les petits coups"
L["Show hits well below your recent average smaller instead of hiding them."] =
    "Affiche en plus petit les coups nettement inférieurs à votre moyenne récente au lieu de les masquer."
L["Small hit below"] = "Petit coup sous"
L["%s of average"] = "%s de la moyenne"


-- Crits only
L["Crits only"] = "Critiques uniquement"
L["Show only critical hits. Normal hits and heals are hidden; miss text such as Immune still shows."] =
    "Affiche uniquement les coups critiques. Les coups normaux et les soins sont masqués ; les textes d'échec comme Insensible restent affichés."


-- Off-target numbers
L["Show"] = "Afficher"
L["Dim"] = "Atténuer"
L["Hide"] = "Masquer"
L["Other nameplates"] = "Autres barres de nom"
L["How numbers look on enemies you are not targeting. Dim makes them smaller and fainter so your target stands out."] =
    "Apparence des nombres sur les ennemis que vous ne ciblez pas. Atténuer les rend plus petits et plus pâles pour faire ressortir votre cible."
L["Off-target size"] = "Taille hors cible"
L["Off-target opacity"] = "Opacité hors cible"

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
L["Healing"] = "Soins"
L["Show healing"] = "Afficher les soins"
L["Show your outgoing heals on the recipient's nameplate. Friendly nameplates must be enabled in the game."] =
    "Affiche vos soins sortants sur la barre de nom du destinataire. Les barres de nom amicales doivent être activées dans le jeu."
L["Uses the same size, motion, duration, icons, and threshold as damage. Skips heals on you."] =
    "Utilise la même taille, le même mouvement, la même durée, les mêmes icônes et le même seuil que les dégâts. Ignore les soins sur vous."

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
L["Font"] = "Police"
L["Font size"] = "Taille de police"
L["Scroll offset"] = "Décalage du défilement"
L["Scroll speed"] = "Vitesse de défilement"
L["%d%%"] = "%d %%"
L["Display duration"] = "Durée d'affichage"
L["Game default"] = "Par défaut du jeu"
L["Friz Quadrata"] = "Friz Quadrata"
L["Arial Narrow"] = "Arial Narrow"
L["Skurri"] = "Skurri"
L["Morpheus"] = "Morpheus"
L["Game fonts, plus SharedMedia fonts when that library is loaded by another addon."] =
    "Polices du jeu, plus les polices SharedMedia lorsque cette bibliothèque est chargée par un autre addon."
L["Only fonts inside the WoW folder can load. SharedMedia fonts appear when another addon provides them."] =
    "Seules les polices du dossier WoW peuvent être chargées. Les polices SharedMedia apparaissent lorsqu'un autre addon les fournit."
L["Recommended"] = "Recommandé"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1fs"
L["%.1fx"] = "%.1fx"
L["Show CRITICAL"] = "Afficher CRITIQUE"
L["Show CRITICAL on critical hits. Impact saves its own choice, enabled by default."] =
    "Affiche CRITIQUE lors des coups critiques. Impact mémorise son propre choix, activé par défaut."
L["CRITICAL"] = "CRITIQUE"

L["Minimum damage threshold"] = "Seuil minimum de dégâts"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "Les coups en dessous de ce montant sont masqués. Tapez 50k ou 2m. Mettez 0 pour tout afficher."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Prend en charge les suffixes k/m, par ex. 20k ou 2m. Les dégâts en dessous ne seront pas affichés."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "En raids et Mythique+, certains montants sont secrets, donc le seuil masque ces coups visuellement au lieu de les ignorer."

-- Combine hits
L["Combine hits"] = "Regrouper les coups"
L["Combine rapid hits"] = "Regrouper les coups rapides"
L["Add hits that land in quick succession on the same nameplate into one number instead of stacking many."] =
    "Additionne les coups qui touchent la même barre de nom en succession rapide en un seul nombre au lieu d'en empiler plusieurs."
L["Combine"] = "Regrouper"
L["Same spell"] = "Même sort"
L["All hits"] = "Tous les coups"
L["Same spell keeps each spell's number separate. All hits merges every hit on the target; its icon shows the spell that did the most damage."] =
    "Même sort garde un nombre séparé pour chaque sort. Tous les coups regroupe chaque coup sur la cible ; son icône montre le sort qui a infligé le plus de dégâts."
L["Combine window"] = "Fenêtre de regroupement"
L["%.2fs"] = "%.2fs"
L["Show hit count"] = "Afficher le nombre de coups"
L["Show how many hits were combined, e.g. 37,200 (3). With spell icons on, the count sits on the icon."] =
    "Indique combien de coups ont été regroupés, par ex. 37 200 (3). Avec les icônes de sort, le nombre s'affiche sur l'icône."
L["%s (%d)"] = "%s (%d)"
L["Crits, normal hits, and heals combine separately."] = "Les critiques, les coups normaux et les soins sont regroupés séparément."
L["Crits, normal hits, and heals combine separately. Secret amounts cannot be added, so those hits still show individually."] =
    "Les critiques, les coups normaux et les soins sont regroupés séparément. Les montants secrets ne peuvent pas être additionnés, ces coups restent donc affichés individuellement."

L["Preview"] = "Aperçu"
L["Updates live as you change options."] = "Se met à jour en direct quand vous changez les options."
L["Target an enemy, then spawn sample numbers on its nameplate."] =
    "Ciblez un ennemi, puis générez des nombres d'exemple sur sa barre de nom."
L["Test on Target"] = "Tester sur la cible"
L["Show sample damage numbers on your target."] = "Affiche des nombres de dégâts d'exemple sur votre cible."
L["Maintenance"] = "Maintenance"
L["Debug mode"] = "Mode débogage"

-- Personal splash
L["Only Engaged nameplates mode, or Personal with Show splash from my casts, shows numbers on enemies you are not targeting. Change it under Modern API → Damage mode."] =
    "Seul le mode Ennemis engagés, ou Personnel avec Afficher les éclaboussures de mes sorts, affiche des nombres sur les ennemis que vous ne ciblez pas. Modifiez-le dans API moderne → Mode de dégâts."
L["Show splash from my casts"] = "Afficher les éclaboussures de mes sorts"
L["In Personal mode, also show hits on other enemies that land right after your cast hits its target, with the same damage school, on enemies you have threat on."] =
    "En mode Personnel, affiche aussi les coups sur d'autres ennemis qui arrivent juste après que votre sort a touché sa cible, de la même école de dégâts, sur les ennemis où vous avez de la menace."
L["Choose Personal - experimental to show splash from your casts."] =
    "Choisissez Personnel - expérimental pour afficher les éclaboussures de vos sorts."
L["Splash is best effort: another player's same-school hit in that split second can still appear. DoT ticks spread to other enemies and unreadable damage schools are not shown."] =
    "Les éclaboussures sont approximatives : un coup d'un autre joueur de la même école au même instant peut encore apparaître. Les dégâts périodiques répartis sur d'autres ennemis et les écoles illisibles ne sont pas affichés."

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

-- Settings redesign
L["Animate settings"] = "Animer les réglages"
L["Appearance"] = "Apparence"
L["Appearance only · Test on Target checks gameplay size."] = "Apparence uniquement · Test sur la cible vérifie la taille en jeu."
L["Appearance preview"] = "Aperçu de l'apparence"
L["Attribution"] = "Attribution"
L["Attribution limitations"] = "Limites de l'attribution"
L["Audio cues for outgoing critical hits."] = "Signaux sonores pour vos coups critiques."
L["Both number styles are available on every supported WoW API."] = "Les deux styles de nombres sont disponibles avec toutes les API WoW prises en charge."
L["Classic API - Era/TBC/Wrath/MoP"] = "API Classic - Era/TBC/Wrath/MoP"
L["Classic number style"] = "Style de nombres Classic"
L["Close"] = "Fermer"
L["Combat"] = "Combat"
L["Current target"] = "Cible actuelle"
L["Damage mode"] = "Mode de dégâts"
L["Damage threshold"] = "Seuil de dégâts"
L["Diagnostics"] = "Diagnostic"
L["Engaged nameplates"] = "Ennemis engagés"
L["Existing features"] = "Fonctionnalités existantes"
L["Find a setting"] = "Rechercher un réglage"
L["Fonts, colors, numbers, and spell icons."] = "Polices, couleurs, nombres et icônes de sorts."
L["Help & Settings"] = "Aide et réglages"
L["Hide preview"] = "Masquer l'aperçu"
L["Instance profiles"] = "Profils d'instance"
L["Meter probe requires Modern API - Midnight & Forever."] = "Le diagnostic du compteur nécessite l'API moderne - Midnight et Forever."
L["Midnight & Forever damage modes and attribution."] = "Modes de dégâts et attribution pour Midnight et Forever."
L["Modern API"] = "API moderne"
L["Modern API - Midnight & Forever"] = "API moderne - Midnight et Forever"
L["Modern number style"] = "Style de nombres moderne"
L["Modern number style motion"] = "Mouvement du style de nombres moderne"
L["No matching settings"] = "Aucun réglage trouvé"
L["Number formatting"] = "Format des nombres"
L["Number style, timing, and movement."] = "Style des nombres, durée et mouvement."
L["Personal - experimental"] = "Personnel - expérimental"
L["Play crit sound"] = "Écouter le son critique"
L["Play huge crit sound"] = "Écouter le son de gros critique"
L["Preferences"] = "Préférences"
L["Preferences, API information, and diagnostics."] = "Préférences, informations sur l'API et diagnostic."
L["Preview scale: %d%%"] = "Échelle de l'aperçu : %d%%"
L["Replay"] = "Rejouer"
L["Schools"] = "Écoles"
L["Settings redesign"] = "Nouvelle interface des réglages"
L["Settings window"] = "Fenêtre des réglages"
L["Show preview"] = "Afficher l'aperçu"
L["Sounds"] = "Sons"
L["Spell icons"] = "Icônes de sorts"
L["Text size"] = "Taille du texte"
L["Timing and movement"] = "Durée et mouvement"
L["Training dummy"] = "Mannequin d'entraînement"
L["Unsupported client - combat text unavailable"] = "Client non pris en charge - texte de combat indisponible"
L["Your WoW API"] = "Votre API WoW"
L["Mixed"] = "Mixte"
L["Hit"] = "Coup"
L["Crit"] = "Critique"
L["Miss"] = "Raté"

-- Settings explanations
L["A new WoW-inspired settings window with clear sections, searchable controls, and gentle animations."] = "Nouvelle fenêtre de réglages inspirée de WoW, avec des sections claires, une recherche et des animations discrètes."
L["Choose Personal - experimental under Modern API → Damage mode to use pet matching."] = "Choisissez Personnel - expérimental dans API moderne → Mode de dégâts pour associer les coups de votre familier."
L["Choose Personal - experimental under Modern API → Damage mode to use spell icons."] = "Choisissez Personnel - expérimental dans API moderne → Mode de dégâts pour afficher les icônes de sorts."
L["Choose the combat text you want to see."] = "Choisissez le texte de combat à afficher."
L["Choose whose damage to display under Modern API → Damage mode. Personal mode is experimental."] = "Choisissez les dégâts à afficher dans API moderne → Mode de dégâts. Le mode Personnel est expérimental."
L["Classic clients read damage ownership and spells directly from the combat log. Modern attribution and school-filter options do not apply."] = "Les clients Classic lisent la source des dégâts et les sorts dans le journal de combat. L'attribution moderne et le filtre d'écoles ne s'appliquent pas."
L["Classic number style uses its own animation. Switch to Modern number style to customize motion."] = "Le style de nombres Classic utilise sa propre animation. Choisissez le style de nombres moderne pour personnaliser le mouvement."
L["Current target: all-source numbers on your target. Engaged nameplates: all-source numbers on engaged enemies."] = "Cible actuelle : dégâts de toutes les sources sur votre cible. Ennemis engagés : dégâts de toutes les sources sur les ennemis en combat."
L["Damage meter probe is available. Capture a snapshot while hitting a target."] = "Le diagnostic du compteur est disponible. Capturez un état pendant que vous frappez une cible."
L["Enable Auto-switch by instance to edit the instance profiles."] = "Activez le changement automatique par instance pour modifier les profils d'instance."
L["Enable Filter by damage school to choose allowed schools."] = "Activez le filtre par école de dégâts pour choisir les écoles autorisées."
L["Enable Show incoming hits to adjust its position."] = "Activez l'affichage des coups reçus pour ajuster leur position."
L["Enable Show spell icon to choose its position."] = "Activez l'affichage de l'icône de sort pour choisir sa position."
L["Enable crit sound to adjust its threshold and channel."] = "Activez le son critique pour modifier son seuil et son canal."
L["Enable huge crit sound to adjust its threshold and channel."] = "Activez le son de gros critique pour modifier son seuil et son canal."
L["Modern API options now have their own page. Damage mode combines Only my damage and All engaged nameplates without changing saved preferences."] = "Les options de l'API moderne ont leur propre page. Le mode de dégâts regroupe Seulement mes dégâts et Tous les ennemis engagés, en conservant les préférences enregistrées."
L["Modern API: unreadable damage amounts cannot trigger threshold sounds."] = "API moderne : les montants de dégâts illisibles ne peuvent pas déclencher les sons à seuil."
L["Modern clients restrict combat information. Personal mode estimates ownership; all-source modes display target or engaged-nameplate damage."] = "Les clients modernes restreignent les informations de combat. Le mode Personnel estime la source ; les autres modes affichent les dégâts de toutes les sources sur la cible ou les ennemis engagés."
L["Outgoing healing, incoming damage, font selection, scroll speed, school colors, spell icons, and critical-hit sounds remain available."] = "Les soins prodigués, dégâts reçus, polices, vitesse de défilement, couleurs d'écoles, icônes de sorts et sons critiques restent disponibles."
L["Personal matches recent casts. Current target and Engaged nameplates show damage from all sources."] = "Personnel associe les sorts récents. Cible actuelle et Ennemis engagés montrent les dégâts de toutes les sources."
L["Personal - experimental: best-effort matching by destination and timing. Other players' hits on the same target can appear."] = "Personnel - expérimental : association approximative selon la cible et le moment. Les coups d'autres joueurs sur la même cible peuvent apparaître."
L["Pet matching and spell icons require Personal mode. Choose their appearance and visibility under Combat and Appearance."] = "L'association du familier et les icônes de sorts nécessitent le mode Personnel. Réglez leur affichage dans Combat et Apparence."
L["Place the spell icon beside, above, or below the number."] = "Placez l'icône de sort à côté, au-dessus ou au-dessous du nombre."
L["PlateSCT needs enemy nameplates. Press V (default) or enable them in the game's nameplate settings."] = "PlateSCT nécessite les barres de nom ennemies. Appuyez sur V (par défaut) ou activez-les dans les réglages du jeu."
L["Profiles affect Personal mode. They cannot prove who dealt a hit on Modern API."] = "Les profils affectent le mode Personnel. Ils ne peuvent pas prouver la source d'un coup avec l'API moderne."
L["Show damage you take near your character. Independent of the outgoing damage mode."] = "Affiche les dégâts reçus près du personnage, indépendamment du mode de dégâts infligés."
L["Show sample hits, crits, and misses in the bottom preview drawer."] = "Affiche des coups, critiques et ratés dans le panneau d'aperçu inférieur."
L["Show sample hits, crits, and misses inside this window."] = "Affiche des coups, critiques et ratés dans cette fenêtre."
L["Spell icons use matched casts in Personal mode; Modern API cannot identify a spell for every hit."] = "Les icônes utilisent les sorts associés en mode Personnel ; l'API moderne ne peut pas identifier le sort de chaque coup."
L["Spell icons use the spell from the combat log."] = "Les icônes utilisent le sort du journal de combat."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. Both number styles remain available on every API."] = "L'aperçu inférieur compact propose Mixte, Coup, Critique et Raté. Les deux styles de nombres restent disponibles avec toutes les API."
L["The preview shows appearance only. It does not prove attribution or simulate damage filtering."] = "L'aperçu montre uniquement l'apparence. Il ne prouve pas la source des dégâts et ne simule pas leur filtrage."
L["This client does not expose the damage meter API. A snapshot can still report which fields are unavailable."] = "Ce client n'expose pas l'API du compteur de dégâts. Un état peut néanmoins indiquer les champs indisponibles."
L["Turn off Auto-switch by instance to choose manual strictness."] = "Désactivez le changement automatique par instance pour choisir la rigueur manuellement."
L["Unreadable amounts cannot trigger threshold sounds. Unreadable damage schools are always allowed by the school filter."] = "Les montants illisibles ne déclenchent pas les sons à seuil. Les écoles illisibles sont toujours autorisées par le filtre."
L["Use gentle fades and row reveals in this settings window. Combat animation is unaffected."] = "Anime discrètement cette fenêtre de réglages. L'animation des nombres en combat n'est pas modifiée."

-- What's new: combine hits
L["Rapid hits on the same nameplate can merge into one growing number with a hit count. Turn it on under Combat → Combine hits."] =
    "Les coups rapides sur la même barre de nom peuvent se regrouper en un seul nombre croissant avec le nombre de coups. Activez-le dans Combat → Regrouper les coups."

-- Reduce clutter
L["Reduce clutter"] = "Réduire l'encombrement"

-- Combine hits: merge pop
L["Pop on each merge"] = "Effet de rebond à chaque regroupement"
L["Briefly enlarge the number every time another hit merges into it. Turn off for a calmer display."] =
    "Agrandit brièvement le nombre chaque fois qu'un coup s'y ajoute. Désactivez pour un affichage plus calme."
