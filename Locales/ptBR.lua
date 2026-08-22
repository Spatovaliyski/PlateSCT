local _, BD = ...

local L = {}
BD.RegisterLocale("ptBR", L)

L["PlateSCT is in Beta"] = "PlateSCT está em beta"
L["This addon is in Beta mode. Inaccuracies and errors may show up. Please report such issues on the addon's page."] =
    "Este addon está em modo beta. Imprecisões e erros podem aparecer. Relate esses problemas na página do addon."
L["Reset PlateSCT settings to defaults?"] = "Redefinir as configurações do PlateSCT para o padrão?"
L["Addon page"] = "Página do addon"
L["Select the URL below, copy it, then paste it in your browser."] =
    "Selecione o URL abaixo, copie e cole no seu navegador."
L["Click to open the addon page URL."] = "Clique para abrir o URL da página do addon."
L["/platesct  ·  ESC to close"] = "/platesct  ·  ESC para fechar"
L["PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."] =
    "PlateSCT usa sua própria janela de configurações.\n\nDigite /platesct no chat ou clique no botão abaixo."
L["Open PlateSCT"] = "Abrir PlateSCT"
L["Target something to preview test numbers."] = "Selecione um alvo para pré-visualizar números de teste."
L["Meter probe"] = "Sonda do medidor"
L["Click the box, Ctrl+A, then Ctrl+C, and paste it in chat."] =
    "Clique na caixa, Ctrl+A, depois Ctrl+C, e cole no chat."

L["General"] = "Geral"
L["Display"] = "Exibição"
L["Damage"] = "Dano"
L["Tools"] = "Ferramentas"
L["Choose whose damage and which nameplates to show."] =
    "Escolha cujo dano e quais placas de nome mostrar."
L["Control how numbers look and how they animate."] =
    "Controle a aparência e a animação dos números."
L["Hide small hits so the big numbers stay readable."] =
    "Oculte golpes pequenos para que os números grandes continuem legíveis."
L["Preview numbers and maintain your setup."] =
    "Pré-visualize números e mantenha sua configuração."

L["Combat text"] = "Texto de combate"
L["Enable PlateSCT"] = "Ativar PlateSCT"
L["Show floating damage numbers on nameplates."] =
    "Mostra números de dano flutuantes nas placas de nome."
L["Hide Blizzard floating combat text"] = "Ocultar texto de combate flutuante da Blizzard"
L["Turns off default in-world damage numbers."] =
    "Desativa os números de dano padrão do mundo."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "As placas de nome inimigas estão desativadas. PlateSCT precisa delas para mostrar números.\nPressione V (padrão) ou ative-as em Interface → Jogo → Nomes."
L["Who to show"] = "O que mostrar"
L["Only my damage"] = "Apenas meu dano"
L["Show hits on your current target when you recently cast or auto-attacked. Midnight cannot prove who dealt the hit in a group."] =
    "Mostra golpes no seu alvo atual quando você lançou ou autoatacou recentemente. Midnight não consegue provar quem causou o golpe em grupo."
L["Target"] = "Alvo"
L["Best effort on your current target. Other players hitting the same mob can still show up. Off-target cleave and DoTs are not shown."] =
    "Melhor esforço no seu alvo atual. Outros jogadores atingindo o mesmo mob ainda podem aparecer. Cleave fora do alvo e DoTs não são mostrados."
L["All engaged nameplates"] = "Todas as placas de nome engajadas"
L["Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."] =
    "Mostra cada golpe em cada placa de nome hostil visível. Este é o modo Midnight preciso; inclui dano de todas as fontes."
L["Available when Only my damage is off. Use this to see numbers on every enemy plate."] =
    "Disponível quando «Apenas meu dano» está desligado. Use para ver números em cada placa inimiga."
L["Include pet damage"] = "Incluir dano do ajudante"
L["In Only my damage mode, also treat a recent pet cast as your hit."] =
    "No modo «Apenas meu dano», também trate um lançamento recente do ajudante como seu golpe."

L["Number style"] = "Estilo dos números"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "Moderno sobe a partir da placa com um pequeno efeito de crítico. Classic mantém o crescer e assentar, perto da placa."
L["Modern"] = "Moderno"
L["Classic"] = "Classic"
L["Color by damage school"] = "Colorir por escola de dano"
L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."] =
    "Tinge os números por escola (fogo laranja, gelo azul, etc.). Desligado mantém o amarelo padrão."
L["Show spell icon"] = "Mostrar ícone do feitiço"
L["Display the spell's icon to the left of the damage number. Uses your last cast or auto-attack."] =
    "Mostra o ícone do feitiço à esquerda do número de dano. Usa seu último lançamento ou autoataque."
L["Uses your last spell in Only my damage mode. Left of the number."] =
    "Usa seu último feitiço no modo «Apenas meu dano». À esquerda do número."
L["Text style"] = "Estilo do texto"
L["Abbreviate numbers"] = "Abreviar números"
L["Display large numbers as 214k or 1.2M."] = "Exibe números grandes como 214k ou 1.2M."
L["Animation"] = "Animação"
L["Font size"] = "Tamanho da fonte"
L["Scroll offset"] = "Deslocamento da rolagem"
L["Display duration"] = "Duração da exibição"
L["Recommended"] = "Recomendado"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1fs"

L["Minimum damage threshold"] = "Limite mínimo de dano"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "Golpes abaixo deste valor são ocultados. Digite 50k ou 2m. Defina 0 para mostrar tudo."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Suporta sufixos k/m, ex.: 20k ou 2m. Dano abaixo deste valor não será exibido."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "Em raids e Mítica+ alguns valores são secretos, então o limite oculta esses golpes visualmente em vez de ignorá-los."

L["Preview"] = "Prévia"
L["Target an enemy, then spawn sample numbers on its nameplate."] =
    "Selecione um inimigo e gere números de exemplo na placa de nome."
L["Test on Target"] = "Testar no alvo"
L["Show sample damage numbers on your target."] = "Mostra números de dano de exemplo no seu alvo."
L["Maintenance"] = "Manutenção"
L["Debug mode"] = "Modo de depuração"
L["Print combat events to chat for troubleshooting."] =
    "Imprime eventos de combate no chat para diagnóstico."
L["Dump meter now"] = "Despejar medidor agora"
L["Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."] =
    "Abre um snapshot copiável dos campos de C_DamageMeter. Use em combate enquanto atinge um alvo."
L["Reset Defaults"] = "Redefinir"
L["Restore every PlateSCT setting to its default."] =
    "Restaura todas as configurações do PlateSCT para o padrão."

-- Language
L["Language"] = "Idioma"
L["Choose the language used by PlateSCT panels and messages."] =
    "Escolha o idioma dos painéis e mensagens do PlateSCT."
L["Auto (game client)"] = "Auto (cliente do jogo)"
