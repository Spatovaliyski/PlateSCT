local _, BD = ...

local L = {}
BD.RegisterLocale("ptBR", L)

-- Number position and font preview
L["Number position"] = "Posição dos números"
L["X offset"] = "Deslocamento X"
L["Y offset"] = "Deslocamento Y"
L["Offsets are saved separately for each number style. Positive X moves right; positive Y moves up. Incoming uses its own position controls."] = "Os deslocamentos são salvos separadamente para cada estilo de números. X positivo move para a direita; Y positivo move para cima. O dano recebido tem seus próprios controles de posição."
L["Hover over a font to preview 12345."] = "Passe o cursor sobre uma fonte para ver uma prévia de 12345."
L["Press Ctrl+C to copy the URL."] = "Pressione Ctrl+C para copiar a URL."
L["Open Link"] = "Abrir link"

-- Translation feedback
L["This translation was generated with AI. If you find inconsistent terminology or incorrect wording, please report it through GitHub Issues. Thank you for your help! Translation contributors will be credited."] =
    "Esta tradução foi gerada com IA. Se encontrar termos inconsistentes ou uma redação incorreta, informe pelo GitHub Issues. Agradecemos pela ajuda! Os colaboradores da tradução receberão os devidos créditos."

L["Impact number style"] = "Estilo de números Impact"
L["All number styles are available on every supported WoW API."] = "Todos os estilos de números estão disponíveis em cada API de WoW compatível."
L["Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."] = "Impact lança o dano causado ao lado ou acima da placa de identificação e depois o faz subir. Novos acertos aparecem à frente; críticos aumentam de tamanho e CRÍTICO pisca acima quando ativado."
L["Impact style position"] = "Posição do estilo Impact"
L["Damage position"] = "Posição do dano"
L["Side"] = "Lado"
L["Place Impact damage to the right of the nameplate or centered above it."] = "Posiciona o dano Impact à direita da placa de identificação ou centralizado acima dela."
L["Impact uses Modern for incoming damage, healing, and miss text, preserving saved Modern motions."] = "Impact usa Moderno para dano recebido, cura e erros, preservando os movimentos Moderno salvos."
L["Pick a motion for each hit type in Modern. Classic and Impact use their own damage animations."] = "Escolha um movimento por tipo de golpe em Moderno. Clássico e Impact usam suas próprias animações de dano."
L["Switch to Modern number style to customize these motions."] = "Mude para o estilo de números Moderno para personalizar esses movimentos."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. All number styles remain available on every API."] = "A prévia compacta inferior inclui exemplos mistos, normais, críticos e erros. Todos os estilos de números continuam disponíveis em cada API."

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
L["Tools & Preview"] = "Ferramentas e prévia"
L["What's new?"] = "Novidades"
L["Choose whose damage and which nameplates to show."] =
    "Escolha cujo dano e quais placas de nome mostrar."
L["Control how numbers look and how they animate."] =
    "Controle a aparência e a animação dos números."
L["Hide small hits so the big numbers stay readable."] =
    "Oculte golpes pequenos para que os números grandes continuem legíveis."
L["Preview numbers and maintain your setup."] =
    "Pré-visualize números e mantenha sua configuração."
L["Recent changes in PlateSCT."] = "Mudanças recentes no PlateSCT."
L["Version 1.1.4"] = "Versão 1.1.4"
L["NEW"] = "NOVO"
L["IMPROVED"] = "MELHORADO"
L["Outgoing healing on the recipient's nameplate. Enable Show healing under General (off by default). Friendly nameplates must be on in the game."] =
    "Cura de saída na placa do destinatário. Ative Mostrar cura em Geral (desligado por padrão). Placas amigáveis ativas no jogo."
L["Scroll speed slider - numbers travel faster; fade still follows Display duration."] =
    "Velocidade da rolagem - os números se movem mais rápido; o fade ainda segue a duração."
L["Font picker - game fonts, plus SharedMedia fonts when another addon provides them."] =
    "Seletor de fonte - fontes do jogo, mais SharedMedia quando outro addon as fornece."
L["Font size up to 48, Scroll offset up to 120 px, Display duration up to 4 seconds."] =
    "Tamanho da fonte até 48, deslocamento até 120 px, duração até 4 segundos."
L["Larger fonts spread out more in Modern number style so hits overlap less."] =
    "Fontes maiores se espalham mais no estilo Moderno, menos sobreposição."

L["Combat text"] = "Texto de combate"
L["Enable PlateSCT"] = "Ativar PlateSCT"
L["Show floating damage numbers on nameplates."] =
    "Mostra números de dano flutuantes nas placas de nome."
L["Hide Blizzard floating combat text"] = "Ocultar texto de combate flutuante da Blizzard"
L["Turns off default in-world damage numbers."] =
    "Desativa os números de dano padrão do mundo."
L["Show minimap button"] = "Mostrar botão do minimapa"
L["Show the PlateSCT icon on the minimap. Click it to open settings."] =
    "Mostra o ícone do PlateSCT no minimapa. Clique para abrir as configurações."
L["Click to open settings."] = "Clique para abrir as configurações."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "As placas de nome inimigas estão desativadas. PlateSCT precisa delas para mostrar números.\nPressione V (padrão) ou ative-as em Interface → Jogo → Nomes."
L["Who to show"] = "O que mostrar"
L["Only my damage"] = "Apenas meu dano"
L["Show hits on your current target when you recently cast or auto-attacked. Midnight cannot prove who dealt the hit in a group."] =
    "Mostra golpes no seu alvo atual quando você lançou ou autoatacou recentemente. Midnight não consegue provar quem causou o golpe em grupo."
L["Experimental"] = "Experimental"
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
L["Healing"] = "Cura"
L["Show healing"] = "Mostrar cura"
L["Show your outgoing heals on the recipient's nameplate. Friendly nameplates must be enabled in the game."] =
    "Mostra suas curas de saída na placa de nome do destinatário. As placas amigáveis precisam estar ativadas no jogo."
L["Uses the same size, motion, duration, icons, and threshold as damage. Skips heals on you."] =
    "Usa o mesmo tamanho, movimento, duração, ícones e limite do dano. Ignora curas em você."

L["Number style"] = "Estilo dos números"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "Moderno sobe a partir da placa com um pequeno efeito de crítico. Classic mantém o crescer e assentar, perto da placa."
L["Modern"] = "Moderno"
L["Classic"] = "Classic"
L["Show live preview"] = "Mostrar prévia ao vivo"
L["Show sample hits, crits, and misses beside this window."] =
    "Mostra acertos, críticos e erros de exemplo ao lado desta janela."
L["Hide live preview"] = "Ocultar prévia ao vivo"
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
L["Display large numbers as 214k or 1.2M. Disables thousand separators."] =
    "Exibe números grandes como 214k ou 1.2M. Desativa os separadores de milhar."
L["Thousand separators"] = "Separadores de milhar"
L["Group digits by thousands."] = "Agrupa dígitos por milhares."
L["Unavailable while Abbreviate numbers is on."] = "Indisponível enquanto «Abreviar números» estiver ativo."
L["Off"] = "Desligado"
L["Comma (10,000)"] = "Vírgula (10,000)"
L["Dot (10.000)"] = "Ponto (10.000)"
L["Animation"] = "Animação"
L["Font"] = "Fonte"
L["Font size"] = "Tamanho da fonte"
L["Scroll offset"] = "Deslocamento da rolagem"
L["Scroll speed"] = "Velocidade da rolagem"
L["Display duration"] = "Duração da exibição"
L["Game default"] = "Padrão do jogo"
L["Friz Quadrata"] = "Friz Quadrata"
L["Arial Narrow"] = "Arial Narrow"
L["Skurri"] = "Skurri"
L["Morpheus"] = "Morpheus"
L["Game fonts, plus SharedMedia fonts when that library is loaded by another addon."] =
    "Fontes do jogo, mais fontes SharedMedia quando essa biblioteca é carregada por outro addon."
L["Only fonts inside the WoW folder can load. SharedMedia fonts appear when another addon provides them."] =
    "Só fontes dentro da pasta do WoW podem ser carregadas. Fontes SharedMedia aparecem quando outro addon as fornece."
L["Recommended"] = "Recomendado"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1fs"
L["%.1fx"] = "%.1fx"
L["Show CRITICAL"] = "Mostrar CRÍTICO"
L["Show CRITICAL on critical hits. Impact saves its own choice, enabled by default."] =
    "Mostra CRÍTICO nos acertos críticos. Impact salva sua própria opção, ativada por padrão."
L["CRITICAL"] = "CRÍTICO"

L["Minimum damage threshold"] = "Limite mínimo de dano"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "Golpes abaixo deste valor são ocultados. Digite 50k ou 2m. Defina 0 para mostrar tudo."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Suporta sufixos k/m, ex.: 20k ou 2m. Dano abaixo deste valor não será exibido."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "Em raids e Mítica+ alguns valores são secretos, então o limite oculta esses golpes visualmente em vez de ignorá-los."

-- Combine hits
L["Combine hits"] = "Combinar golpes"
L["Combine rapid hits"] = "Combinar golpes rápidos"
L["Add hits that land in quick succession on the same nameplate into one number instead of stacking many."] =
    "Soma os golpes que atingem a mesma placa de nome em rápida sucessão em um único número, em vez de empilhar vários."
L["Combine"] = "Combinar"
L["Same spell"] = "Mesmo feitiço"
L["All hits"] = "Todos os golpes"
L["Same spell keeps each spell's number separate. All hits merges every hit on the target; its icon shows the spell that did the most damage."] =
    "Mesmo feitiço mantém o número de cada feitiço separado. Todos os golpes combina cada golpe no alvo; o ícone mostra o feitiço que causou mais dano."
L["Combine window"] = "Janela de combinação"
L["%.2fs"] = "%.2fs"
L["Show hit count"] = "Mostrar número de golpes"
L["Show how many hits were combined, e.g. 37,200 (3). With spell icons on, the count sits on the icon."] =
    "Mostra quantos golpes foram combinados, ex.: 37.200 (3). Com os ícones de feitiço ativados, o número aparece no ícone."
L["%s (%d)"] = "%s (%d)"
L["Crits, normal hits, and heals combine separately."] = "Críticos, golpes normais e curas são combinados separadamente."
L["Crits, normal hits, and heals combine separately. Secret amounts cannot be added, so those hits still show individually."] =
    "Críticos, golpes normais e curas são combinados separadamente. Valores secretos não podem ser somados, então esses golpes continuam aparecendo individualmente."

L["Preview"] = "Prévia"
L["Updates live as you change options."] = "Atualiza ao vivo conforme você muda as opções."
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
L["Auto"] = "Auto"

-- Settings redesign
L["Animate settings"] = "Animar configurações"
L["Appearance"] = "Aparência"
L["Appearance only · Test on Target checks gameplay size."] = "Apenas aparência · Testar no alvo verifica o tamanho no jogo."
L["Appearance preview"] = "Prévia da aparência"
L["Attribution"] = "Atribuição"
L["Attribution limitations"] = "Limitações da atribuição"
L["Audio cues for outgoing critical hits."] = "Alertas sonoros para seus acertos críticos."
L["Both number styles are available on every supported WoW API."] = "Os dois estilos de números estão disponíveis em todas as APIs do WoW compatíveis."
L["Classic API - Era/TBC/Wrath/MoP"] = "API Classic - Era/TBC/Wrath/MoP"
L["Classic number style"] = "Estilo de números Classic"
L["Close"] = "Fechar"
L["Combat"] = "Combate"
L["Current target"] = "Alvo atual"
L["Damage mode"] = "Modo de dano"
L["Damage threshold"] = "Limite de dano"
L["Diagnostics"] = "Diagnóstico"
L["Engaged nameplates"] = "Placas em combate"
L["Existing features"] = "Recursos existentes"
L["Find a setting"] = "Buscar configuração"
L["Fonts, colors, numbers, and spell icons."] = "Fontes, cores, números e ícones de feitiços."
L["Help & Settings"] = "Ajuda e configurações"
L["Hide preview"] = "Ocultar prévia"
L["Instance profiles"] = "Perfis de instância"
L["Meter probe requires Modern API - Midnight & Forever."] = "A sonda do medidor requer a API moderna - Midnight e Forever."
L["Midnight & Forever damage modes and attribution."] = "Modos de dano e atribuição de Midnight e Forever."
L["Modern API"] = "API moderna"
L["Modern API - Midnight & Forever"] = "API moderna - Midnight e Forever"
L["Modern number style"] = "Estilo de números moderno"
L["Modern number style motion"] = "Movimento do estilo de números moderno"
L["No matching settings"] = "Nenhuma configuração encontrada"
L["Number formatting"] = "Formato dos números"
L["Number style, timing, and movement."] = "Estilo dos números, duração e movimento."
L["Personal - experimental"] = "Pessoal - experimental"
L["Play crit sound"] = "Reproduzir som de crítico"
L["Play huge crit sound"] = "Reproduzir som de crítico enorme"
L["Preferences"] = "Preferências"
L["Preferences, API information, and diagnostics."] = "Preferências, informações da API e diagnóstico."
L["Preview scale: %d%%"] = "Escala da prévia: %d%%"
L["Replay"] = "Repetir"
L["Schools"] = "Escolas"
L["Settings redesign"] = "Novo visual das configurações"
L["Settings window"] = "Janela de configurações"
L["Show preview"] = "Mostrar prévia"
L["Sounds"] = "Sons"
L["Spell icons"] = "Ícones de feitiços"
L["Text size"] = "Tamanho do texto"
L["Timing and movement"] = "Duração e movimento"
L["Training dummy"] = "Boneco de treino"
L["Unsupported client - combat text unavailable"] = "Cliente incompatível - texto de combate indisponível"
L["Your WoW API"] = "Sua API do WoW"
L["Mixed"] = "Misto"
L["Hit"] = "Acerto"
L["Crit"] = "Crítico"
L["Miss"] = "Erro"

-- Settings explanations
L["A new WoW-inspired settings window with clear sections, searchable controls, and gentle animations."] = "Nova janela de configurações inspirada no WoW, com seções claras, busca e animações suaves."
L["Choose Personal - experimental under Modern API → Damage mode to use pet matching."] = "Escolha Pessoal - experimental em API moderna → Modo de dano para associar os golpes do ajudante."
L["Choose Personal - experimental under Modern API → Damage mode to use spell icons."] = "Escolha Pessoal - experimental em API moderna → Modo de dano para usar ícones de feitiços."
L["Choose the combat text you want to see."] = "Escolha o texto de combate que deseja ver."
L["Choose whose damage to display under Modern API → Damage mode. Personal mode is experimental."] = "Escolha de quem mostrar dano em API moderna → Modo de dano. O modo Pessoal é experimental."
L["Classic clients read damage ownership and spells directly from the combat log. Modern attribution and school-filter options do not apply."] = "Os clientes Classic leem a origem do dano e os feitiços diretamente do registro de combate. A atribuição moderna e o filtro de escolas não se aplicam."
L["Classic number style uses its own animation. Switch to Modern number style to customize motion."] = "O estilo de números Classic usa sua própria animação. Mude para o estilo moderno para personalizar o movimento."
L["Current target: all-source numbers on your target. Engaged nameplates: all-source numbers on engaged enemies."] = "Alvo atual: dano de todas as fontes no seu alvo. Placas em combate: dano de todas as fontes nos inimigos em combate."
L["Damage meter probe is available. Capture a snapshot while hitting a target."] = "A sonda do medidor está disponível. Capture um relatório enquanto ataca um alvo."
L["Enable Auto-switch by instance to edit the instance profiles."] = "Ative a troca automática por instância para editar os perfis."
L["Enable Filter by damage school to choose allowed schools."] = "Ative o filtro por escola de dano para escolher as escolas permitidas."
L["Enable Show incoming hits to adjust its position."] = "Ative Mostrar acertos recebidos para ajustar a posição."
L["Enable Show spell icon to choose its position."] = "Ative Mostrar ícone do feitiço para escolher sua posição."
L["Enable crit sound to adjust its threshold and channel."] = "Ative o som de crítico para ajustar o limite e o canal."
L["Enable huge crit sound to adjust its threshold and channel."] = "Ative o som de crítico enorme para ajustar o limite e o canal."
L["Modern API options now have their own page. Damage mode combines Only my damage and All engaged nameplates without changing saved preferences."] = "As opções da API moderna têm sua própria página. Modo de dano combina Apenas meu dano e Todas as placas em combate, preservando as preferências salvas."
L["Modern API: unreadable damage amounts cannot trigger threshold sounds."] = "API moderna: valores de dano ilegíveis não podem ativar sons por limite."
L["Modern clients restrict combat information. Personal mode estimates ownership; all-source modes display target or engaged-nameplate damage."] = "Os clientes modernos restringem os dados de combate. Pessoal estima a origem; os outros modos mostram dano de todas as fontes no alvo ou nos inimigos em combate."
L["Outgoing healing, incoming damage, font selection, scroll speed, school colors, spell icons, and critical-hit sounds remain available."] = "Continuam disponíveis cura realizada, dano recebido, fontes, velocidade, cores por escola, ícones de feitiços e sons de críticos."
L["Personal matches recent casts. Current target and Engaged nameplates show damage from all sources."] = "Pessoal associa lançamentos recentes. Alvo atual e Placas em combate mostram dano de todas as fontes."
L["Personal - experimental: best-effort matching by destination and timing. Other players' hits on the same target can appear."] = "Pessoal - experimental: associação aproximada por alvo e momento. Golpes de outros jogadores no mesmo alvo podem aparecer."
L["Pet matching and spell icons require Personal mode. Choose their appearance and visibility under Combat and Appearance."] = "A associação do ajudante e os ícones exigem o modo Pessoal. Ajuste aparência e visibilidade em Combate e Aparência."
L["Place the spell icon beside, above, or below the number."] = "Posicione o ícone ao lado, acima ou abaixo do número."
L["PlateSCT needs enemy nameplates. Press V (default) or enable them in the game's nameplate settings."] = "PlateSCT precisa das placas de nome inimigas. Pressione V (padrão) ou ative-as nas configurações do jogo."
L["Profiles affect Personal mode. They cannot prove who dealt a hit on Modern API."] = "Os perfis afetam Pessoal. Não podem comprovar quem causou um golpe na API moderna."
L["Show damage you take near your character. Independent of the outgoing damage mode."] = "Mostra o dano recebido perto do personagem, independentemente do modo de dano causado."
L["Show sample hits, crits, and misses in the bottom preview drawer."] = "Mostra exemplos de acertos, críticos e erros no painel inferior da prévia."
L["Show sample hits, crits, and misses inside this window."] = "Mostra exemplos de acertos, críticos e erros dentro desta janela."
L["Spell icons use matched casts in Personal mode; Modern API cannot identify a spell for every hit."] = "Os ícones usam lançamentos associados em Pessoal; a API moderna não identifica o feitiço de cada golpe."
L["Spell icons use the spell from the combat log."] = "Os ícones usam o feitiço do registro de combate."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. Both number styles remain available on every API."] = "A prévia inferior compacta inclui Misto, Acerto, Crítico e Erro. Os dois estilos continuam disponíveis em todas as APIs."
L["The preview shows appearance only. It does not prove attribution or simulate damage filtering."] = "A prévia mostra apenas a aparência. Não comprova a atribuição nem simula a filtragem de dano."
L["This client does not expose the damage meter API. A snapshot can still report which fields are unavailable."] = "Este cliente não oferece a API do medidor de dano. Um relatório ainda pode indicar quais campos estão indisponíveis."
L["Turn off Auto-switch by instance to choose manual strictness."] = "Desative a troca automática por instância para escolher a rigidez manualmente."
L["Unreadable amounts cannot trigger threshold sounds. Unreadable damage schools are always allowed by the school filter."] = "Valores ilegíveis não ativam sons por limite. Escolas ilegíveis sempre passam pelo filtro."
L["Use gentle fades and row reveals in this settings window. Combat animation is unaffected."] = "Usa transições suaves e animações de linhas nas configurações. A animação de combate não muda."

-- What's new: combine hits
L["Rapid hits on the same nameplate can merge into one growing number with a hit count. Turn it on under Combat → Combine hits."] =
    "Golpes rápidos na mesma placa de nome podem se combinar em um único número crescente com a contagem de golpes. Ative em Combate → Combinar golpes."

-- Reduce clutter
L["Reduce clutter"] = "Reduzir a poluição visual"

-- Combine hits: merge pop
L["Pop on each merge"] = "Pulsar a cada combinação"
L["Briefly enlarge the number every time another hit merges into it. Turn off for a calmer display."] =
    "Aumenta brevemente o número sempre que outro golpe é somado a ele. Desative para uma exibição mais calma."
