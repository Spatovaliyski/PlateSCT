local _, BD = ...

local L = {}
BD.RegisterLocale("ruRU", L)

L["PlateSCT is in Beta"] = "PlateSCT в бета-версии"
L["This addon is in Beta mode. Inaccuracies and errors may show up. Please report such issues on the addon's page."] =
    "Аддон в режиме бета. Возможны неточности и ошибки. Пожалуйста, сообщайте о них на странице аддона."
L["Reset PlateSCT settings to defaults?"] = "Сбросить настройки PlateSCT по умолчанию?"
L["Addon page"] = "Страница аддона"
L["Select the URL below, copy it, then paste it in your browser."] =
    "Выделите URL ниже, скопируйте и вставьте в браузер."
L["Click to open the addon page URL."] = "Нажмите, чтобы открыть URL страницы аддона."
L["/platesct  ·  ESC to close"] = "/platesct  ·  ESC чтобы закрыть"
L["PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."] =
    "PlateSCT использует собственное окно настроек.\n\nВведите /platesct в чат или нажмите кнопку ниже."
L["Open PlateSCT"] = "Открыть PlateSCT"
L["Target something to preview test numbers."] = "Выберите цель, чтобы показать тестовые числа."
L["Meter probe"] = "Зонд счётчика"
L["Click the box, Ctrl+A, then Ctrl+C, and paste it in chat."] =
    "Щёлкните по полю, Ctrl+A, затем Ctrl+C и вставьте в чат."

L["General"] = "Общие"
L["Display"] = "Отображение"
L["Damage"] = "Урон"
L["Tools"] = "Инструменты"
L["Choose whose damage and which nameplates to show."] =
    "Выберите чей урон и какие индикаторы здоровья показывать."
L["Control how numbers look and how they animate."] =
    "Настройте внешний вид и анимацию чисел."
L["Hide small hits so the big numbers stay readable."] =
    "Скрывайте мелкие удары, чтобы крупные числа оставались читаемыми."
L["Preview numbers and maintain your setup."] =
    "Просматривайте числа и управляйте настройками."

L["Combat text"] = "Текст боя"
L["Enable PlateSCT"] = "Включить PlateSCT"
L["Show floating damage numbers on nameplates."] =
    "Показывать всплывающие числа урона на индикаторах."
L["Hide Blizzard floating combat text"] = "Скрыть всплывающий боевой текст Blizzard"
L["Turns off default in-world damage numbers."] =
    "Отключает стандартные числа урона в мире."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "Индикаторы врагов выключены. PlateSCT нужны они, чтобы показывать числа.\nНажмите V (по умолчанию) или включите их в Интерфейс → Игра → Имена."
L["Who to show"] = "Что показывать"
L["Only my damage"] = "Только мой урон"
L["Show hits on your current target when you recently cast or auto-attacked. Midnight cannot prove who dealt the hit in a group."] =
    "Показывает удары по текущей цели, если вы недавно произнесли заклинание или автоатаковали. Midnight не может доказать, кто нанёс удар в группе."
L["Target"] = "Цель"
L["Best effort on your current target. Other players hitting the same mob can still show up. Off-target cleave and DoTs are not shown."] =
    "Наилучшая попытка по текущей цели. Удары других игроков по тому же мобу всё ещё могут отображаться. Клив мимо цели и DoT не показываются."
L["All engaged nameplates"] = "Все активные индикаторы"
L["Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."] =
    "Показывает каждый удар на каждом видимом враждебном индикаторе. Точный режим Midnight; включает урон из всех источников."
L["Available when Only my damage is off. Use this to see numbers on every enemy plate."] =
    "Доступно, когда «Только мой урон» выключен. Используйте, чтобы видеть числа на каждом вражеском индикаторе."
L["Include pet damage"] = "Учитывать урон питомца"
L["In Only my damage mode, also treat a recent pet cast as your hit."] =
    "В режиме «Только мой урон» также считать недавнее заклинание питомца вашим ударом."

L["Number style"] = "Стиль чисел"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "Современный поднимается от индикатора с небольшим эффектом крита. Classic сохраняет рост и оседание рядом с индикатором."
L["Modern"] = "Современный"
L["Classic"] = "Classic"
L["Color by damage school"] = "Цвет по школе урона"
L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."] =
    "Окрашивает числа по школе (огонь — оранжевый, лёд — синий и т. д.). Выкл. оставляет жёлтый по умолчанию."
L["Show spell icon"] = "Показывать иконку заклинания"
L["Display the spell's icon to the left of the damage number. Uses your last cast or auto-attack."] =
    "Показывает иконку заклинания слева от числа урона. Использует последнее заклинание или автоатаку."
L["Uses your last spell in Only my damage mode. Left of the number."] =
    "Использует ваше последнее заклинание в режиме «Только мой урон». Слева от числа."
L["Text style"] = "Стиль текста"
L["Abbreviate numbers"] = "Сокращать числа"
L["Display large numbers as 214k or 1.2M."] = "Показывает большие числа как 214k или 1.2M."
L["Animation"] = "Анимация"
L["Font size"] = "Размер шрифта"
L["Scroll offset"] = "Смещение прокрутки"
L["Display duration"] = "Длительность показа"
L["Recommended"] = "Рекомендуется"
L["%d px"] = "%d пкс"
L["%.1fs"] = "%.1fс"

L["Minimum damage threshold"] = "Минимальный порог урона"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "Удары ниже этого значения скрываются. Введите 50k или 2m. 0 показывает всё."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Поддерживает суффиксы k/m, напр. 20k или 2m. Урон ниже не отображается."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "В рейдах и Эпохальном+ некоторые значения секретны, поэтому порог скрывает эти удары визуально, а не пропускает их."

L["Preview"] = "Просмотр"
L["Target an enemy, then spawn sample numbers on its nameplate."] =
    "Выберите врага и создайте примеры чисел на его индикаторе."
L["Test on Target"] = "Тест на цели"
L["Show sample damage numbers on your target."] = "Показывает примеры чисел урона на вашей цели."
L["Maintenance"] = "Обслуживание"
L["Debug mode"] = "Режим отладки"
L["Print combat events to chat for troubleshooting."] =
    "Выводит события боя в чат для диагностики."
L["Dump meter now"] = "Дамп счётчика"
L["Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."] =
    "Открывает копируемый снимок полей C_DamageMeter. Используйте в бою, пока бьёте цель."
L["Reset Defaults"] = "Сбросить"
L["Restore every PlateSCT setting to its default."] =
    "Восстанавливает все настройки PlateSCT по умолчанию."

-- Language
L["Language"] = "Язык"
L["Choose the language used by PlateSCT panels and messages."] =
    "Выберите язык панелей и сообщений PlateSCT."
L["Auto (game client)"] = "Авто (клиент игры)"
