local _, BD = ...

local L = {}
BD.RegisterLocale("zhCN", L)

-- Number position and font preview
L["Number position"] = "数字位置"
L["X offset"] = "X 偏移"
L["Y offset"] = "Y 偏移"
L["Offsets are saved separately for each number style. Positive X moves right; positive Y moves up. Incoming uses its own position controls."] = "每种数字样式分别保存偏移。X 为正时向右移动；Y 为正时向上移动。受到的伤害使用独立的位置设置。"
L["Hover over a font to preview 12345."] = "将鼠标悬停在字体上即可预览 12345。"
L["Press Ctrl+C to copy the URL."] = "按 Ctrl+C 复制网址。"
L["Open Link"] = "打开链接"

-- Impact number style
L["Impact number style"] = "冲击数字样式"
L["All number styles are available on every supported WoW API."] = "所有数字样式均可用于每一种受支持的 WoW API。"
L["Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."] =
    "冲击样式会在姓名板旁边或上方以冲击效果显示你造成的伤害，然后向上飘动。新命中显示在前层；暴击效果更强，启用后还会在上方闪现“暴击”字样。"
L["Impact style position"] = "冲击样式位置"
L["Damage position"] = "伤害显示位置"
L["Side"] = "侧边"
L["Place Impact damage to the right of the nameplate or centered above it."] = "将冲击样式的伤害数字放在姓名板右侧，或居中显示在姓名板上方。"
L["Impact uses Modern for incoming damage, healing, and miss text, preserving saved Modern motions."] = "冲击样式对受到的伤害、治疗和未命中文字使用现代样式，并保留已保存的现代样式运动设置。"
L["Pick a motion for each hit type in Modern. Classic and Impact use their own damage animations."] = "在现代样式中，可为每种命中类型选择运动效果。经典样式和冲击样式各自使用专属的伤害动画。"
L["Switch to Modern number style to customize these motions."] = "切换至现代数字样式，即可自定义这些运动效果。"
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. All number styles remain available on every API."] =
    "底部的紧凑预览包含混合、普通命中、暴击和未命中示例。所有数字样式均可用于每一种 API。"

-- Titles / meta
L["PlateSCT is in Beta"] = "PlateSCT 正处于测试阶段"
L["This addon is in Beta mode. Inaccuracies and errors may show up. Please report such issues on the addon's page."] = "本插件仍处于测试阶段，可能出现显示不准确或报错的情况。请在插件页面反馈这些问题。"
L["Addon page"] = "插件页面"
L["Select the URL below, copy it, then paste it in your browser."] = "选中下方的网址并复制，然后粘贴到浏览器中。"
L["Click to open the addon page URL."] = "点击查看插件页面网址。"
L["/platesct  ·  ESC to close"] = "/platesct  ·  按 ESC 关闭"
L["PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."] = "PlateSCT 使用独立的设置窗口。\n\n在聊天框输入 /platesct，或点击下方按钮。"
L["Open PlateSCT"] = "打开 PlateSCT"
L["Target something to preview test numbers."] = "选中一个目标，即可预览测试数字。"
L["Meter probe"] = "伤害统计探测"
L["Click the box, Ctrl+A, then Ctrl+C, and paste it in chat."] = "点击文本框，按 Ctrl+A，再按 Ctrl+C，然后粘贴到聊天框中。"

-- Pages
L["General"] = "常规"
L["Display"] = "显示"
L["Damage"] = "伤害"
L["Tools"] = "工具"
L["Tools & Preview"] = "工具与预览"
L["What's new?"] = "更新内容"
L["Choose whose damage and which nameplates to show."] = "选择显示谁造成的伤害，以及在哪些姓名板上显示。"
L["Control how numbers look and how they animate."] = "设置数字的外观和动画效果。"
L["Hide small hits so the big numbers stay readable."] = "隐藏较小的伤害，让大数字更易读。"
L["Hide small hits and play sounds on big crits."] = "隐藏较小的伤害，并在高额暴击时播放音效。"
L["Preview numbers and maintain your setup."] = "预览数字并维护你的设置。"
L["Recent changes in PlateSCT."] = "PlateSCT 的近期更新。"
L["Version 1.1.4"] = "版本 1.1.4"
L["NEW"] = "新增"
L["IMPROVED"] = "改进"
L["Outgoing healing on the recipient's nameplate. Enable Show healing under General (off by default). Friendly nameplates must be on in the game."] =
    "在受治疗者的姓名板上显示你施放的治疗。在“常规”中启用“显示治疗”（默认关闭）。游戏内必须开启友方姓名板。"
L["Scroll speed slider - numbers travel faster; fade still follows Display duration."] = "滚动速度滑块可加快数字的移动速度；淡出时间仍由显示时长决定。"
L["Font picker - game fonts, plus SharedMedia fonts when another addon provides them."] = "字体选择器提供游戏字体；其他插件加载 SharedMedia 后，还可使用其提供的字体。"
L["Font size up to 48, Scroll offset up to 120 px, Display duration up to 4 seconds."] = "字号最高可设为 48，滚动距离最高为 120 px，显示时长最长为 4 秒。"
L["Larger fonts spread out more in Modern number style so hits overlap less."] = "现代数字样式会为较大的字体留出更多间距，减少数字重叠。"

-- Sound effects
L["Sound effects"] = "音效"
L["Outgoing critical hits play a sound when damage is above the threshold you type. Huge crit takes priority over the normal crit sound."] =
    "你造成的暴击伤害高于输入的阈值时，会播放音效。高额暴击音效优先于普通暴击音效。"
L["Crit sound"] = "暴击音效"
L["Enable crit sound"] = "启用暴击音效"
L["Play a sound when an outgoing critical hit is above the damage threshold."] = "你造成的暴击伤害高于伤害阈值时，播放音效。"
L["Huge crit sound"] = "高额暴击音效"
L["Enable huge crit sound"] = "启用高额暴击音效"
L["Play a louder sound when an outgoing critical hit is above the huge damage threshold."] = "你造成的暴击伤害高于高额伤害阈值时，播放更响亮的音效。"
L["Damage threshold to play sound. Type 5k or 50k."] = "触发音效的伤害阈值，可输入 5k 或 50k。"
L["Supports k/m suffixes, e.g. 20k or 2m."] = "支持 k/m 后缀，例如 20k 或 2m。"
L["Supports k/m suffixes, e.g. 20k or 2m. The critical strike damage must be higher than this value."] = "支持 k/m 后缀，例如 20k 或 2m。暴击伤害必须高于此值。"
L["Play"] = "播放"
L["Preview this sound effect."] = "试听此音效。"
L["Channel"] = "声道"
L["Which game sound channel plays this effect."] = "选择播放此音效的游戏声道。"
L["Dialog"] = "对话"
L["SFX"] = "音效"
L["Ambience"] = "环境"
L["Music"] = "音乐"

-- General
L["Combat text"] = "战斗文字"
L["Enable PlateSCT"] = "启用 PlateSCT"
L["Show floating damage numbers on nameplates."] = "在姓名板上显示浮动伤害数字。"
L["Hide Blizzard floating combat text"] = "隐藏暴雪浮动战斗文字"
L["Turns off default in-world damage numbers."] = "关闭游戏默认的场景伤害数字。"
L["Show minimap button"] = "显示小地图按钮"
L["Show the PlateSCT icon on the minimap. Click it to open settings."] = "在小地图上显示 PlateSCT 图标，点击即可打开设置。"
L["Click to open settings."] = "点击打开设置。"
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "敌方姓名板已关闭。PlateSCT 需要姓名板才能显示数字。\n按 V（默认按键），或在“界面 → 游戏 → 名称”中启用。"
L["Who to show"] = "显示来源"

-- What's new: less clutter
L["Less clutter"] = "更少杂乱"
L["Dim or hide numbers on enemies you are not targeting, show crits only, shrink small hits, and ignore chosen spells. Find them on the Combat page."] =
    "淡化或隐藏非目标敌人身上的数字、仅显示暴击、缩小小额命中并忽略指定法术。见“战斗”页面。"


-- Ignored spells
L["Ignored spells"] = "忽略的法术"
L["Ignore these spells"] = "忽略这些法术"
L["Spell names or IDs, separated by commas. Their hits, crits, and misses are not shown."] =
    "法术名称或 ID，用逗号分隔。这些法术的命中、暴击和未命中都不会显示。"
L["Example: Auto Attack, 133."] = "示例：自动攻击, 133。"
L["Example: Auto Attack, 133. Modern API knows the spell only in Personal - experimental mode."] =
    "示例：自动攻击, 133。现代 API 仅在“个人伤害 - 实验性”模式下能识别法术。"


-- Shrink small hits
L["Shrink small hits"] = "缩小小额命中"
L["Show hits well below your recent average smaller instead of hiding them."] =
    "将明显低于你近期平均值的命中缩小显示，而不是隐藏。"
L["Small hit below"] = "小额命中阈值"
L["%s of average"] = "平均值的 %s"


-- Crits only
L["Crits only"] = "仅显示暴击"
L["Show only critical hits. Normal hits and heals are hidden; miss text such as Immune still shows."] =
    "仅显示暴击。普通命中和治疗会被隐藏；“免疫”等未命中文字仍会显示。"


-- Off-target numbers
L["Show"] = "显示"
L["Dim"] = "淡化"
L["Hide"] = "隐藏"
L["Other nameplates"] = "其他姓名板"
L["How numbers look on enemies you are not targeting. Dim makes them smaller and fainter so your target stands out."] =
    "非当前目标敌人身上的数字显示方式。“淡化”会让它们更小更淡，使当前目标更突出。"
L["Off-target size"] = "非目标大小"
L["Off-target opacity"] = "非目标不透明度"

L["Only my damage"] = "仅显示我的伤害"
L["Show hits when a recent cast or auto-attack matches the nameplate. Midnight cannot prove who dealt the hit in a group."] =
    "近期施法或自动攻击与姓名板匹配时，显示该次命中。Midnight 在队伍中无法确认是谁造成了伤害。"
L["Experimental"] = "实验性"
L["Best effort: matches your casts to nameplates by destination and timing. Dest-matched cleave can show. Other players on the same target can still appear. Mythic+ uses the Dungeon profile."] =
    "尽力匹配：根据目标和时间，将你的施法与姓名板上的命中相匹配。与目标匹配的顺劈伤害也可能显示。同一目标上其他玩家的伤害仍可能出现。史诗钥石地下城使用地下城配置。"
L["All engaged nameplates"] = "所有交战中的姓名板"
L["Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."] =
    "显示所有可见敌方姓名板上的每一次命中。这是 Midnight 中可准确显示伤害的模式，包含所有来源的伤害。"
L["Available when Only my damage is off. Use this to see numbers on every enemy plate."] = "关闭“仅显示我的伤害”后可用。使用此选项可在所有敌方姓名板上显示数字。"
L["Include pet damage"] = "包含宠物伤害"
L["In Only my damage mode, also treat a recent pet cast as your hit."] = "在“仅显示我的伤害”模式下，也将近期宠物施法匹配到的命中视为你的伤害。"
L["Also show damage from your pet and guardians on nameplates."] = "同时在姓名板上显示你的宠物和守护者造成的伤害。"
L["Shows your damage on hostile nameplates. Source is read from the combat log."] = "在敌方姓名板上显示你造成的伤害。伤害来源直接读取自战斗日志。"
L["Display the spell's icon next to the damage number. Uses the spell from the combat log."] = "在伤害数字旁显示法术图标，法术信息来自战斗日志。"
L["Healing"] = "治疗"
L["Show healing"] = "显示治疗"
L["Show your outgoing heals on the recipient's nameplate. Friendly nameplates must be enabled in the game."] = "在受治疗者的姓名板上显示你施放的治疗。游戏内必须开启友方姓名板。"
L["Uses the same size, motion, duration, icons, and threshold as damage. Skips heals on you."] = "治疗使用与伤害相同的大小、运动效果、时长、图标和阈值。不显示施放在你自己身上的治疗。"
L["Attribution profiles"] = "伤害归属配置"
L["How strict PlateSCT is when guessing which hits are yours. Auto-switch follows the instance type."] = "设置 PlateSCT 判断哪些命中属于你时的严格程度。自动切换会根据副本类型选择配置。"
L["Current profile"] = "当前配置"
L["Auto-switch by instance"] = "按副本自动切换"
L["Pick Open world, Dungeon, Raid, Battleground, or Arena settings from the zone you are in."] = "根据所在区域，选择野外、地下城、团队副本、战场或竞技场配置。"
L["Manual strictness"] = "手动严格程度"
L["Used when Auto-switch is off."] = "关闭自动切换时使用。"
L["Open world"] = "野外"
L["Dungeon"] = "地下城"
L["Raid"] = "团队副本"
L["Battleground"] = "战场"
L["Arena"] = "竞技场"
L["Loose"] = "宽松"
L["Balanced"] = "均衡"
L["Strict"] = "严格"
L["Very Strict"] = "非常严格"
L["Loose: longer windows, more numbers."] = "宽松：匹配时间窗口较长，显示更多数字。"
L["Balanced: medium windows and cleave hits."] = "均衡：使用中等匹配时间窗口，并允许顺劈命中。"
L["Strict: short windows, fewer foreign hits."] = "严格：匹配时间窗口较短，减少混入其他玩家的命中。"
L["Very Strict: shortest windows, destination required, one hit per cast."] = "非常严格：匹配时间窗口最短，必须匹配目标，每次施法仅显示一次命中。"
L["Active: %s (%s)"] = "当前启用：%s（%s）"
L["Recommended"] = "推荐"
L["Damage schools"] = "伤害类型"
L["Damage Schools"] = "伤害类型"
L["Filter by damage school"] = "按伤害类型过滤"
L["Show damage from schools checked below. Same-school hits from other players can still appear. Secret or unreadable schools are always shown."] =
    "显示下方勾选的伤害类型。同类型的其他玩家伤害仍可能出现。类型受限或无法读取的伤害始终显示。"
L["Use Recommended (%s)"] = "使用推荐类型（%s）"
L["Use the schools your class typically deals."] = "使用你的职业通常造成的伤害类型。"
L["Physical"] = "物理"
L["Holy"] = "神圣"
L["Fire"] = "火焰"
L["Nature"] = "自然"
L["Frost"] = "冰霜"
L["Shadow"] = "暗影"
L["Arcane"] = "奥术"

-- Display
L["Number style"] = "数字样式"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, newest hit takes center, and older numbers snap aside."] =
    "现代样式的数字从姓名板向上飘动，暴击时有轻微弹出效果。经典样式先放大再回落；最新的命中占据中央，旧数字移向两侧。"
L["Modern"] = "现代样式"
L["Classic"] = "经典样式"
L["Show live preview"] = "显示实时预览"
L["Show sample hits, crits, and misses beside this window."] = "在此窗口旁显示普通命中、暴击和未命中示例。"
L["Hide live preview"] = "隐藏实时预览"
L["Color by damage school"] = "按伤害类型着色"
L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."] = "按伤害类型设置数字颜色，例如火焰为橙色、冰霜为蓝色。关闭后使用默认黄色。"
L["Show spell icon"] = "显示法术图标"
L["Display the spell's icon next to the damage number. Uses the matched cast or auto-attack."] = "在伤害数字旁显示法术图标，使用匹配到的施法或自动攻击。"
L["Uses your matched spell in Only my damage mode. Position is set below."] = "在“仅显示我的伤害”模式下，使用匹配到的法术。可在下方设置图标位置。"
L["Icon position"] = "图标位置"
L["Left"] = "左侧"
L["Right"] = "右侧"
L["Top"] = "上方"
L["Bottom"] = "下方"
L["Text style"] = "文字样式"
L["Abbreviate numbers"] = "缩写数字"

-- What's new: labels and colors
L["Labels and colors"] = "标签与颜色"
L["Spell names next to numbers, a text outline choice, custom hit, crit, and miss colors, and a separate auto-attack motion."] =
    "数字旁显示法术名称、可选文字描边、自定义命中/暴击/未命中颜色，以及独立的自动攻击运动效果。"


-- Auto-attack motion
L["Same as normal hits"] = "与普通命中相同"
L["Auto-attacks"] = "自动攻击"
L["Motion used for your normal auto-attack hits, so melee swings can move differently from spells. Auto-attack crits use the Critical hits motion."] =
    "你的普通自动攻击命中所使用的运动效果，让近战挥击与法术区分开。自动攻击暴击使用暴击的运动效果。"


-- Spell label
L["Label"] = "标签"
L["Name"] = "名称"
L["Icon"] = "图标"
L["Icon and name"] = "图标和名称"
L["Spell label"] = "法术标签"
L["Show spell label"] = "显示法术标签"
L["Show which spell dealt each hit. Uses the matched cast or auto-attack."] =
    "显示每次命中来自哪个法术。使用匹配到的施法或自动攻击。"
L["Show which spell dealt each hit. Uses the spell from the combat log."] =
    "显示每次命中来自哪个法术。使用战斗日志中的法术。"
L["Show the spell's icon, its name, or both."] = "显示法术图标、法术名称，或两者都显示。"
L["Enable Show spell label to choose the label."] = "开启“显示法术标签”后才能选择标签。"
L["Name position"] = "名称位置"
L["Where the spell name sits relative to the number."] = "法术名称相对于数字的位置。"
L["Name size"] = "名称大小"
L["Shorten long names"] = "缩短长名称"
L["After %d characters"] = "超过 %d 个字符"
L["The Name label has no icon to place."] = "“名称”标签没有可放置的图标。"
L["Enable Show spell label to choose its position."] = "开启“显示法术标签”后才能选择位置。"


-- Custom colors
L["Custom colors"] = "自定义颜色"
L["Pick your own colors for normal hits, crits, and miss text instead of the default yellow."] =
    "为普通命中、暴击和未命中文字选择自己的颜色，替代默认黄色。"
L["Turn off Color by damage school to pick custom colors."] = "关闭“按伤害类型着色”后才能选择自定义颜色。"
L["Color of normal damage numbers."] = "普通伤害数字的颜色。"
L["Color of critical hit numbers."] = "暴击数字的颜色。"
L["Miss text"] = "未命中文字"
L["Color of Miss, Dodge, Immune, and similar text."] = "未命中、躲闪、免疫等文字的颜色。"


-- Outline
L["Outline"] = "描边"
L["Number style default"] = "数字样式默认"
L["None"] = "无"
L["Thin"] = "细"
L["Thick"] = "粗"
L["Text outline. Number style default uses each style's own outline: thick for Classic, thin for Modern and Impact."] =
    "文字描边。“数字样式默认”使用各样式自带的描边：经典样式为粗描边，现代样式和 Impact 为细描边。"

L["Display large numbers as 214k or 1.2M."] = "将大数字显示为 214k 或 1.2M。"
L["Display large numbers as 214k or 1.2M. Disables thousand separators."] = "将大数字显示为 214k 或 1.2M。启用后会关闭千位分隔符。"
L["Thousand separators"] = "千位分隔符"
L["Group digits by thousands."] = "每三位数字为一组。"
L["Unavailable while Abbreviate numbers is on."] = "启用“缩写数字”时不可用。"
L["Off"] = "关闭"
L["Comma (10,000)"] = "逗号（10,000）"
L["Dot (10.000)"] = "句点（10.000）"
L["Animation"] = "动画"
L["Font"] = "字体"
L["Font size"] = "字号"
L["Scroll offset"] = "滚动距离"
L["Scroll speed"] = "滚动速度"
L["%d%%"] = "%d%%"
L["Display duration"] = "显示时长"
L["Game default"] = "游戏默认"
L["Friz Quadrata"] = "Friz Quadrata"
L["Arial Narrow"] = "Arial Narrow"
L["Skurri"] = "Skurri"
L["Morpheus"] = "Morpheus"
L["Game fonts, plus SharedMedia fonts when that library is loaded by another addon."] = "提供游戏字体；其他插件加载 SharedMedia 库后，还可使用其提供的字体。"
L["Only fonts inside the WoW folder can load. SharedMedia fonts appear when another addon provides them."] =
    "只能加载 WoW 文件夹中的字体。其他插件提供 SharedMedia 字体时，这些字体会出现在列表中。"
L["%d px"] = "%d px"
L["%.1fs"] = "%.1f秒"
L["%.1fx"] = "%.1fx"
L["Motion (Modern)"] = "运动效果（现代样式）"
L["Pick a motion for each hit type. Classic number style ignores these and keeps its own animation."] = "为每种命中类型选择运动效果。经典数字样式不使用这些设置，而是保留专属动画。"
L["Classic uses its own animation. Switch to Modern to customize motion."] = "经典样式使用专属动画。切换至现代样式，即可自定义运动效果。"
L["Normal hits"] = "普通命中"
L["Critical hits"] = "暴击"
L["Miss / Parry / Dodge"] = "未命中 / 招架 / 闪躲"
L["Motion used for normal damage numbers."] = "普通伤害数字使用的运动效果。"
L["Motion used for critical hits."] = "暴击使用的运动效果。"
L["Motion used for miss, parry, dodge, and similar outcomes."] = "未命中、招架、闪躲等结果使用的运动效果。"
L["Vertical Up"] = "垂直向上"
L["Classic Slap"] = "经典弹出"
L["Fountain"] = "喷泉"
L["Rainfall"] = "雨落"
L["Vertical Down"] = "垂直向下"
L["Motion used for critical hits. Classic Slap uses the Classic grow-and-settle pow."] = "暴击使用的运动效果。“经典弹出”采用经典样式先放大再回落的动画。"
L["Show CRITICAL"] = "显示“暴击”字样"
L["Show CRITICAL on critical hits. Impact saves its own choice, enabled by default."] = "暴击时显示“暴击”字样。冲击样式单独保存此选项，默认启用。"
L["CRITICAL"] = "暴击"

-- Incoming
L["Incoming"] = "受到的伤害"
L["Show incoming hits"] = "显示受到的伤害"
L["Show damage you take near your character. Independent of Only my damage."] = "在角色附近显示你受到的伤害。不受“仅显示我的伤害”选项影响，也不受最低伤害阈值限制。"
L["Uses your personal nameplate when available; otherwise floats near screen center."] = "优先使用个人姓名板；不可用时，数字会在屏幕中央附近飘动。"
L["Uses your personal nameplate when available; otherwise sits on your unit frame."] = "优先使用个人姓名板；不可用时，数字会在屏幕中央附近飘动。"
L["Incoming X"] = "受伤数字 X 偏移"
L["Incoming Y"] = "受伤数字 Y 偏移"

-- Damage
L["Minimum damage threshold"] = "最低伤害阈值"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] = "隐藏低于此数值的伤害。可输入 50k 或 2m。设为 0 则显示所有伤害。"
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] = "支持 k/m 后缀，例如 20k 或 2m。低于此值的伤害不会显示。"
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "在团队副本和史诗钥石地下城中，部分伤害数值受限，因此阈值过滤会从视觉上隐藏这些命中，而不是跳过处理。"

-- Combine hits
L["Combine hits"] = "合并命中"
L["Combine rapid hits"] = "合并快速命中"
L["Add hits that land in quick succession on the same nameplate into one number instead of stacking many."] =
    "将短时间内连续落在同一姓名板上的命中合并为一个数字，而不是堆叠多个数字。"
L["Combine"] = "合并方式"
L["Same spell"] = "同一法术"
L["All hits"] = "全部命中"
L["Same spell keeps each spell's number separate. All hits merges every hit on the target; its icon shows the spell that did the most damage."] =
    "“同一法术”会让每个法术的数字分开显示。“全部命中”会合并目标身上的所有命中，图标显示造成伤害最多的法术。"
L["Combine window"] = "合并时间窗口"
L["%.2fs"] = "%.2f秒"
L["Show hit count"] = "显示命中次数"
L["Show how many hits were combined, e.g. 37,200 (3). With spell icons on, the count sits on the icon."] =
    "显示合并了多少次命中，例如 37,200 (3)。开启法术图标时，次数显示在图标上。"
L["%s (%d)"] = "%s (%d)"
L["Crits, normal hits, and heals combine separately."] = "暴击、普通命中和治疗会分别合并。"
L["Crits, normal hits, and heals combine separately. Secret amounts cannot be added, so those hits still show individually."] =
    "暴击、普通命中和治疗会分别合并。部分数值受限，无法相加，因此这些命中仍会单独显示。"

-- Tools
L["Preview"] = "预览"
L["Updates live as you change options."] = "修改选项时，预览会实时更新。"
L["Target an enemy, then spawn sample numbers on its nameplate."] = "选中一个敌人，然后在其姓名板上生成示例数字。"
L["Test on Target"] = "在目标上测试"
L["Show sample damage numbers on your target."] = "在当前目标上显示示例伤害数字。"
L["Debug mode"] = "调试模式"

-- Personal splash
L["Only Engaged nameplates mode, or Personal with Show splash from my casts, shows numbers on enemies you are not targeting. Change it under Modern API → Damage mode."] =
    "只有“交战中的姓名板”模式，或开启“显示我施法的溅射伤害”的个人模式，会在非目标敌人身上显示数字。请在“现代 API”→“伤害模式”中更改。"
L["Show splash from my casts"] = "显示我施法的溅射伤害"
L["In Personal mode, also show hits on other enemies that land right after your cast hits its target, with the same damage school, on enemies you have threat on."] =
    "在个人模式下，也显示你的法术命中目标后紧接着落在其他敌人身上、伤害类型相同、且你在其仇恨列表中的命中。"
L["Choose Personal - experimental to show splash from your casts."] =
    "选择“个人伤害 - 实验性”后才能显示你施法的溅射伤害。"
L["Splash is best effort: another player's same-school hit in that split second can still appear. DoT ticks spread to other enemies and unreadable damage schools are not shown."] =
    "溅射为尽力匹配：同一瞬间其他玩家相同类型的命中仍可能出现。扩散到其他敌人的持续伤害跳数和无法读取的伤害类型不会显示。"

L["Print combat events to chat for troubleshooting."] = "将战斗事件输出到聊天框，便于排查问题。"
L["Dump meter now"] = "立即导出伤害统计"
L["Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."] = "打开 C_DamageMeter 字段的可复制快照。请在战斗中攻击目标时使用。"

-- Language
L["Language"] = "语言"
L["Choose the language used by PlateSCT panels and messages."] = "选择 PlateSCT 面板和消息使用的语言。"
L["Auto"] = "自动"

-- Settings redesign
L["A new WoW-inspired settings window with clear sections, searchable controls, and gentle animations."] = "全新的设置窗口采用 WoW 风格，分区清晰，支持搜索设置，并带有柔和的动画。"
L["Animate settings"] = "启用设置窗口动画"
L["Appearance"] = "外观"
L["Appearance only · Test on Target checks gameplay size."] = "仅预览外观 · 使用“在目标上测试”检查实际游戏中的大小。"
L["Appearance preview"] = "外观预览"
L["Attribution"] = "伤害归属"
L["Attribution limitations"] = "伤害归属限制"
L["Audio cues for outgoing critical hits."] = "为你造成的暴击提供声音提示。"
L["Both number styles are available on every supported WoW API."] = "两种数字样式均可用于每一种受支持的 WoW API。"
L["Choose Personal - experimental under Modern API → Damage mode to use pet matching."] = "在“现代 API → 伤害模式”中选择“个人伤害 - 实验性”，即可使用宠物伤害匹配。"
L["Choose Personal - experimental under Modern API → Damage mode to use spell icons."] = "在“现代 API → 伤害模式”中选择“个人伤害 - 实验性”，即可使用法术图标。"
L["Choose the combat text you want to see."] = "选择想要显示的战斗文字。"
L["Choose whose damage to display under Modern API → Damage mode. Personal mode is experimental."] = "在“现代 API → 伤害模式”中选择显示谁造成的伤害。个人伤害模式仍处于实验阶段。"
L["Classic API - Era/TBC/Wrath/MoP"] = "经典 API - Era/TBC/Wrath/MoP"
L["Classic clients read damage ownership and spells directly from the combat log. Modern attribution and school-filter options do not apply."] =
    "使用经典 API 的客户端直接从战斗日志读取伤害归属和法术信息。现代 API 的伤害归属与伤害类型过滤选项不适用。"
L["Classic number style"] = "经典数字样式"
L["Classic number style uses its own animation. Switch to Modern number style to customize motion."] = "经典数字样式使用专属动画。切换至现代数字样式，即可自定义运动效果。"
L["Close"] = "关闭"
L["Combat"] = "战斗"
L["Crit"] = "暴击"
L["Current target"] = "当前目标"
L["Current target: all-source numbers on your target. Engaged nameplates: all-source numbers on engaged enemies."] =
    "当前目标：显示当前目标受到的所有来源伤害。交战中的姓名板：显示交战敌人受到的所有来源伤害。"
L["Damage meter probe is available. Capture a snapshot while hitting a target."] = "伤害统计探测可用。请在攻击目标时采集快照。"
L["Damage mode"] = "伤害模式"

-- Profiles and welcome
L["Default"] = "默认"
L["Clean and minimal: numbers on your target in classic yellow. Every option at its default."] =
    "简洁朴素：在目标身上以经典黄色显示数字。所有选项保持默认。"
L["Extended"] = "扩展"
L["Spell icons and short names, school colors, abbreviated numbers, combined rapid hits, fainter cleave on other enemies, and livelier motion."] =
    "法术图标与短名称、伤害类型颜色、缩写数字、合并快速命中、其他敌人身上更淡的溅射伤害，以及更生动的运动效果。"
L["Apply the %s profile? This replaces all PlateSCT settings except the language."] =
    "应用“%s”配置？这会替换除语言外的所有 PlateSCT 设置。"
L["Profiles"] = "配置"
L["Show welcome screen"] = "显示欢迎界面"
L["Open the first-install welcome and profile choice again."] = "再次打开首次安装时的欢迎界面和配置选择。"
L["A profile replaces all settings except the language. Default restores every setting; Extended adds spell icons and names, school colors, combined hits, and fainter cleave."] =
    "配置会替换除语言外的所有设置。“默认”恢复所有设置；“扩展”增加法术图标与名称、伤害类型颜色、合并命中以及更淡的溅射伤害。"
L["Apply %s profile"] = "应用“%s”配置"
L["%s profile applied. Type /psct to customize it."] = "已应用“%s”配置。输入 /psct 进行自定义。"
L["Welcome to PlateSCT"] = "欢迎使用 PlateSCT"
L["PlateSCT puts your damage numbers on enemy nameplates, so every hit shows up right where it landed."] =
    "PlateSCT 会把你的伤害数字显示在敌人的姓名板上，让每次命中都出现在它落下的位置。"
L["It keeps busy fights readable: rapid hits combine, small hits fade back, and crits stand out."] =
    "让激烈的战斗依然清晰：快速命中会合并，小额命中退居次要，暴击格外醒目。"
L["It works on Midnight and on Classic clients, within each game version's combat rules."] =
    "它适用于 Midnight 和经典客户端，并遵守各游戏版本的战斗规则。"
L["Note: Blizzard's new addon rules hide who dealt each hit, so some numbers can be credited to the wrong source or missed."] =
    "注意：暴雪新的插件规则隐藏了每次命中的来源，因此部分数字可能被归到错误的来源或被遗漏。"
L["Choose a starting profile. You can change every setting later."] =
    "选择一个初始配置。之后可以随时修改任何设置。"
L["Open settings instead"] = "改为打开设置"
L["Keep the Default profile and open the settings window."] = "保留默认配置并打开设置窗口。"

L["Damage threshold"] = "伤害阈值"
L["Diagnostics"] = "诊断"
L["Enable Auto-switch by instance to edit the instance profiles."] = "启用“按副本自动切换”后，即可编辑副本配置。"
L["Enable Filter by damage school to choose allowed schools."] = "启用“按伤害类型过滤”后，即可选择允许显示的类型。"
L["Enable Show incoming hits to adjust its position."] = "启用“显示受到的伤害”后，即可调整其位置。"
L["Enable Show spell icon to choose its position."] = "启用“显示法术图标”后，即可选择图标位置。"
L["Enable crit sound to adjust its threshold and channel."] = "启用暴击音效后，即可调整其阈值和声道。"
L["Enable huge crit sound to adjust its threshold and channel."] = "启用高额暴击音效后，即可调整其阈值和声道。"
L["Engaged nameplates"] = "交战中的姓名板"
L["Existing features"] = "现有功能"
L["Find a setting"] = "搜索设置"
L["Fonts, colors, numbers, and spell icons."] = "字体、颜色、数字和法术图标。"
L["Help & Settings"] = "帮助与设置"
L["Hide preview"] = "隐藏预览"
L["Hit"] = "普通命中"
L["Instance profiles"] = "副本配置"
L["Meter probe requires Modern API - Midnight & Forever."] = "伤害统计探测需要现代 API - Midnight 与 Forever。"
L["Midnight & Forever damage modes and attribution."] = "Midnight 与 Forever 的伤害模式和伤害归属设置。"
L["Miss"] = "未命中"
L["Mixed"] = "混合"
L["Modern API"] = "现代 API"
L["Modern API options now have their own page. Damage mode combines Only my damage and All engaged nameplates without changing saved preferences."] =
    "现代 API 选项现在拥有独立页面。伤害模式整合了“仅显示我的伤害”和“所有交战中的姓名板”，且不改变已保存的偏好设置。"
L["Modern API - Midnight & Forever"] = "现代 API - Midnight 与 Forever"
L["Modern API: unreadable damage amounts cannot trigger threshold sounds."] = "现代 API：无法读取的伤害数值不能触发阈值音效。"
L["Modern clients restrict combat information. Personal mode estimates ownership; all-source modes display target or engaged-nameplate damage."] =
    "使用现代 API 的客户端会限制战斗信息。个人伤害模式会估算伤害归属；所有来源模式会显示当前目标或交战中的姓名板上的伤害。"
L["Modern number style"] = "现代数字样式"
L["Modern number style motion"] = "现代数字样式运动效果"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "现代样式的数字从姓名板向上飘动，暴击时有轻微弹出效果。经典样式先放大再回落，数字紧凑地排列在姓名板附近。"
L["No matching settings"] = "没有匹配的设置"
L["Number formatting"] = "数字格式"
L["Number style, timing, and movement."] = "数字样式、时间和运动效果。"
L["Outgoing healing, incoming damage, font selection, scroll speed, school colors, spell icons, and critical-hit sounds remain available."] =
    "治疗输出、受到的伤害、字体选择、滚动速度、伤害类型颜色、法术图标和暴击音效仍可使用。"
L["Personal matches recent casts. Current target and Engaged nameplates show damage from all sources."] = "个人伤害模式会匹配近期施法。当前目标和交战中的姓名板模式会显示所有来源的伤害。"
L["Personal - experimental"] = "个人伤害 - 实验性"
L["Personal - experimental: best-effort matching by destination and timing. Other players' hits on the same target can appear."] =
    "个人伤害 - 实验性：根据目标和时间尽力匹配伤害。同一目标上其他玩家的命中也可能显示。"
L["Pet matching and spell icons require Personal mode. Choose their appearance and visibility under Combat and Appearance."] =
    "宠物伤害匹配和法术图标需要个人伤害模式。可在“战斗”和“外观”中设置它们的显示和外观。"
L["Place the spell icon beside, above, or below the number."] = "将法术图标放在数字旁边、上方或下方。"
L["PlateSCT needs enemy nameplates. Press V (default) or enable them in the game's nameplate settings."] = "PlateSCT 需要敌方姓名板。按 V（默认按键），或在游戏的姓名板设置中启用。"
L["Play crit sound"] = "播放暴击音效"
L["Play huge crit sound"] = "播放高额暴击音效"
L["Preferences"] = "偏好设置"
L["Preferences, API information, and diagnostics."] = "偏好设置、API 信息和诊断。"
L["Preview scale: %d%%"] = "预览缩放：%d%%"
L["Profiles affect Personal mode. They cannot prove who dealt a hit on Modern API."] = "这些配置仅影响个人伤害模式，无法在现代 API 下确认是谁造成了伤害。"
L["Replay"] = "重播"
L["Schools"] = "伤害类型"
L["Settings redesign"] = "设置界面改版"
L["Settings window"] = "设置窗口"
L["Show damage you take near your character. Independent of the outgoing damage mode."] = "在角色附近显示你受到的伤害，不受造成伤害的显示模式影响。"
L["Show preview"] = "显示预览"
L["Show sample hits, crits, and misses in the bottom preview drawer."] = "在底部预览区显示普通命中、暴击和未命中示例。"
L["Show sample hits, crits, and misses inside this window."] = "在此窗口内显示普通命中、暴击和未命中示例。"
L["Sounds"] = "音效"
L["Spell icons"] = "法术图标"
L["Spell icons use matched casts in Personal mode; Modern API cannot identify a spell for every hit."] = "个人伤害模式根据匹配到的施法显示法术图标；现代 API 无法识别每一次命中对应的法术。"
L["Spell icons use the spell from the combat log."] = "法术图标使用战斗日志中的法术信息。"
L["Text size"] = "文字大小"
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. Both number styles remain available on every API."] =
    "底部的紧凑预览包含混合、普通命中、暴击和未命中示例。两种数字样式均可用于每一种 API。"
L["The preview shows appearance only. It does not prove attribution or simulate damage filtering."] = "预览仅展示外观，不能验证伤害归属，也不会模拟伤害过滤。"
L["This client does not expose the damage meter API. A snapshot can still report which fields are unavailable."] = "此客户端未提供伤害统计 API。快照仍可报告哪些字段不可用。"
L["Timing and movement"] = "时间与运动"
L["Training dummy"] = "训练假人"
L["Turn off Auto-switch by instance to choose manual strictness."] = "关闭“按副本自动切换”后，即可手动选择严格程度。"
L["Unreadable amounts cannot trigger threshold sounds. Unreadable damage schools are always allowed by the school filter."] =
    "无法读取的数值不能触发阈值音效。伤害类型过滤始终允许无法读取类型的伤害。"
L["Unsupported client - combat text unavailable"] = "不支持此客户端 - 战斗文字不可用"
L["Use gentle fades and row reveals in this settings window. Combat animation is unaffected."] = "在设置窗口中使用柔和的淡入淡出和逐行显示动画，不影响战斗动画。"
L["Your WoW API"] = "当前 WoW API"

-- Translation feedback
L["This translation was generated with AI. If you find inconsistent terminology or incorrect wording, please report it through GitHub Issues. Thank you for your help! Translation contributors will be credited."] =
    "此翻译由 AI 生成。如果发现术语不一致或措辞不准确，请通过 GitHub Issues 反馈。感谢你的帮助！翻译贡献者将获得署名致谢。"

-- What's new: combine hits
L["Rapid hits on the same nameplate can merge into one growing number with a hit count. Turn it on under Combat → Combine hits."] =
    "同一姓名板上的快速命中可合并为一个不断增长的数字，并显示命中次数。在“战斗”→“合并命中”中开启。"

-- Reduce clutter
L["Reduce clutter"] = "减少杂乱"

-- Combine hits: merge pop
L["Pop on each merge"] = "每次合并时弹跳"
L["Briefly enlarge the number every time another hit merges into it. Turn off for a calmer display."] =
    "每当有新的命中合并进来时短暂放大数字。关闭可获得更平静的显示。"
