local _, BD = ...

local L = {}
BD.RegisterLocale("ruRU", L)

-- Number position and font preview
L["Number position"] = "Положение чисел"
L["X offset"] = "Смещение по X"
L["Y offset"] = "Смещение по Y"
L["Offsets are saved separately for each number style. Positive X moves right; positive Y moves up. Incoming uses its own position controls."] = "Смещения сохраняются отдельно для каждого стиля чисел. Положительное X сдвигает вправо, положительное Y — вверх. Для входящего урона используются отдельные настройки положения."
L["Hover over a font to preview 12345."] = "Наведите указатель на шрифт, чтобы увидеть пример 12345."
L["Press Ctrl+C to copy the URL."] = "Нажмите Ctrl+C, чтобы скопировать URL."
L["Open Link"] = "Открыть ссылку"

-- Translation feedback
L["This translation was generated with AI. If you find inconsistent terminology or incorrect wording, please report it through GitHub Issues. Thank you for your help! Translation contributors will be credited."] =
    "Этот перевод создан с помощью ИИ. Если вы заметите несогласованные термины или некорректные формулировки, сообщите об этом через GitHub Issues. Спасибо за помощь! Участники перевода будут указаны в благодарностях."

L["Impact number style"] = "Стиль чисел Impact"
L["All number styles are available on every supported WoW API."] = "Все стили чисел доступны на каждом поддерживаемом API WoW."
L["Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."] = "Impact резко выводит исходящий урон сбоку или над индикатором имени, затем поднимает его вверх. Новые попадания появляются спереди; криты увеличиваются, а КРИТ мигает сверху, если включён."
L["Impact style position"] = "Положение стиля Impact"
L["Damage position"] = "Положение урона"
L["Side"] = "Сбоку"
L["Place Impact damage to the right of the nameplate or centered above it."] = "Размещает урон Impact справа от индикатора имени или по центру над ним."
L["Impact uses Modern for incoming damage, healing, and miss text, preserving saved Modern motions."] = "Для входящего урона, лечения и промахов Impact использует Современный стиль с сохранёнными настройками движения."
L["Pick a motion for each hit type in Modern. Classic and Impact use their own damage animations."] = "Выберите движение для каждого типа попадания в Современном стиле. Классический и Impact используют собственные анимации урона."
L["Switch to Modern number style to customize these motions."] = "Переключитесь на Современный стиль чисел, чтобы настроить эти движения."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. All number styles remain available on every API."] = "Компактный предпросмотр внизу показывает обычные и критические попадания, промахи и смешанные примеры. Все стили чисел доступны на каждом API."

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
L["Tools & Preview"] = "Инструменты и просмотр"
L["What's new?"] = "Что нового?"
L["Choose whose damage and which nameplates to show."] =
    "Выберите чей урон и какие индикаторы здоровья показывать."
L["Control how numbers look and how they animate."] =
    "Настройте внешний вид и анимацию чисел."
L["Hide small hits so the big numbers stay readable."] =
    "Скрывайте мелкие удары, чтобы крупные числа оставались читаемыми."
L["Preview numbers and maintain your setup."] =
    "Просматривайте числа и управляйте настройками."
L["Recent changes in PlateSCT."] = "Недавние изменения в PlateSCT."
L["Version 1.1.4"] = "Версия 1.1.4"
L["NEW"] = "НОВОЕ"
L["IMPROVED"] = "УЛУЧШЕНО"
L["Outgoing healing on the recipient's nameplate. Enable Show healing under General (off by default). Friendly nameplates must be on in the game."] =
    "Исходящее исцеление на индикаторе получателя. Включите «Показывать исцеление» в «Общие» (по умолчанию выкл.). Дружественные индикаторы должны быть включены."
L["Scroll speed slider - numbers travel faster; fade still follows Display duration."] =
    "Скорость прокрутки - числа движутся быстрее; затухание по-прежнему следует длительности показа."
L["Font picker - game fonts, plus SharedMedia fonts when another addon provides them."] =
    "Выбор шрифта - игровые шрифты и SharedMedia, если их даёт другой аддон."
L["Font size up to 48, Scroll offset up to 120 px, Display duration up to 4 seconds."] =
    "Размер шрифта до 48, смещение до 120 пкс, длительность до 4 секунд."
L["Larger fonts spread out more in Modern number style so hits overlap less."] =
    "Крупные шрифты сильнее разводятся в современном стиле, меньше наложений."

L["Combat text"] = "Текст боя"
L["Enable PlateSCT"] = "Включить PlateSCT"
L["Show floating damage numbers on nameplates."] =
    "Показывать всплывающие числа урона на индикаторах."
L["Hide Blizzard floating combat text"] = "Скрыть всплывающий боевой текст Blizzard"
L["Turns off default in-world damage numbers."] =
    "Отключает стандартные числа урона в мире."
L["Show minimap button"] = "Показать кнопку у миникарты"
L["Show the PlateSCT icon on the minimap. Click it to open settings."] =
    "Показывает значок PlateSCT на миникарте. Нажмите, чтобы открыть настройки."
L["Click to open settings."] = "Нажмите, чтобы открыть настройки."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "Индикаторы врагов выключены. PlateSCT нужны они, чтобы показывать числа.\nНажмите V (по умолчанию) или включите их в Интерфейс → Игра → Имена."
L["Who to show"] = "Что показывать"

-- What's new: less clutter
L["Less clutter"] = "Меньше лишнего"
L["Dim or hide numbers on enemies you are not targeting, show crits only, shrink small hits, and ignore chosen spells. Find them on the Combat page."] =
    "Приглушайте или скрывайте числа на врагах, которые не являются целью, показывайте только криты, уменьшайте слабые удары и игнорируйте выбранные заклинания. На странице «Бой»."


-- Ignored spells
L["Ignored spells"] = "Игнорируемые заклинания"
L["Ignore these spells"] = "Игнорировать заклинания"
L["Spell names or IDs, separated by commas. Their hits, crits, and misses are not shown."] =
    "Названия или ID заклинаний через запятую. Их удары, криты и промахи не показываются."
L["Example: Auto Attack, 133."] = "Пример: Автоматическая атака, 133."
L["Example: Auto Attack, 133. Modern API knows the spell only in Personal - experimental mode."] =
    "Пример: Автоматическая атака, 133. Modern API знает заклинание только в режиме «Личный - экспериментальный»."


-- Shrink small hits
L["Shrink small hits"] = "Уменьшать слабые удары"
L["Show hits well below your recent average smaller instead of hiding them."] =
    "Показывать удары намного ниже вашего недавнего среднего уменьшенными, а не скрывать их."
L["Small hit below"] = "Слабый удар ниже"
L["%s of average"] = "%s от среднего"


-- Crits only
L["Crits only"] = "Только критические"
L["Show only critical hits. Normal hits and heals are hidden; miss text such as Immune still shows."] =
    "Показывать только критические удары. Обычные удары и исцеление скрываются; тексты промахов вроде «Невосприимчив» остаются."


-- Off-target numbers
L["Show"] = "Показывать"
L["Dim"] = "Приглушить"
L["Hide"] = "Скрыть"
L["Other nameplates"] = "Другие индикаторы"
L["How numbers look on enemies you are not targeting. Dim makes them smaller and fainter so your target stands out."] =
    "Как выглядят числа на врагах, которые не являются вашей целью. «Приглушить» делает их меньше и бледнее, чтобы цель выделялась."
L["Off-target size"] = "Размер вне цели"
L["Off-target opacity"] = "Непрозрачность вне цели"

L["Only my damage"] = "Только мой урон"
L["Show hits on your current target when you recently cast or auto-attacked. Midnight cannot prove who dealt the hit in a group."] =
    "Показывает удары по текущей цели, если вы недавно произнесли заклинание или автоатаковали. Midnight не может доказать, кто нанёс удар в группе."
L["Experimental"] = "Экспериментально"
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
L["Healing"] = "Исцеление"
L["Show healing"] = "Показывать исцеление"
L["Show your outgoing heals on the recipient's nameplate. Friendly nameplates must be enabled in the game."] =
    "Показывает ваше исходящее исцеление на индикаторе получателя. Дружественные индикаторы должны быть включены в игре."
L["Uses the same size, motion, duration, icons, and threshold as damage. Skips heals on you."] =
    "Использует тот же размер, движение, длительность, иконки и порог, что и урон. Пропускает исцеление на вас."

L["Number style"] = "Стиль чисел"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "Современный поднимается от индикатора с небольшим эффектом крита. Classic сохраняет рост и оседание рядом с индикатором."
L["Modern"] = "Современный"
L["Classic"] = "Classic"
L["Show live preview"] = "Показывать живой просмотр"
L["Show sample hits, crits, and misses beside this window."] =
    "Показывает примеры ударов, критов и промахов рядом с этим окном."
L["Hide live preview"] = "Скрыть живой просмотр"
L["Color by damage school"] = "Цвет по школе урона"
L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."] =
    "Окрашивает числа по школе (огонь - оранжевый, лёд - синий и т. д.). Выкл. оставляет жёлтый по умолчанию."
L["Show spell icon"] = "Показывать иконку заклинания"
L["Display the spell's icon to the left of the damage number. Uses your last cast or auto-attack."] =
    "Показывает иконку заклинания слева от числа урона. Использует последнее заклинание или автоатаку."
L["Uses your last spell in Only my damage mode. Left of the number."] =
    "Использует ваше последнее заклинание в режиме «Только мой урон». Слева от числа."
L["Text style"] = "Стиль текста"
L["Abbreviate numbers"] = "Сокращать числа"
L["Display large numbers as 214k or 1.2M."] = "Показывает большие числа как 214k или 1.2M."
L["Display large numbers as 214k or 1.2M. Disables thousand separators."] =
    "Показывает большие числа как 214k или 1.2M. Отключает разделители тысяч."
L["Thousand separators"] = "Разделители тысяч"
L["Group digits by thousands."] = "Группирует цифры по тысячам."
L["Unavailable while Abbreviate numbers is on."] = "Недоступно, пока включено «Сокращать числа»."
L["Off"] = "Выкл."
L["Comma (10,000)"] = "Запятая (10,000)"
L["Dot (10.000)"] = "Точка (10.000)"
L["Animation"] = "Анимация"
L["Font"] = "Шрифт"
L["Font size"] = "Размер шрифта"
L["Scroll offset"] = "Смещение прокрутки"
L["Scroll speed"] = "Скорость прокрутки"
L["%d%%"] = "%d%%"
L["Display duration"] = "Длительность показа"
L["Game default"] = "Игровой по умолчанию"
L["Friz Quadrata"] = "Friz Quadrata"
L["Arial Narrow"] = "Arial Narrow"
L["Skurri"] = "Skurri"
L["Morpheus"] = "Morpheus"
L["Game fonts, plus SharedMedia fonts when that library is loaded by another addon."] =
    "Игровые шрифты, плюс шрифты SharedMedia, если эту библиотеку загрузил другой аддон."
L["Only fonts inside the WoW folder can load. SharedMedia fonts appear when another addon provides them."] =
    "Загружаются только шрифты из папки WoW. Шрифты SharedMedia появляются, когда их предоставляет другой аддон."
L["Recommended"] = "Рекомендуется"
L["%d px"] = "%d пкс"
L["%.1fs"] = "%.1fс"
L["%.1fx"] = "%.1fx"
L["Show CRITICAL"] = "Показывать КРИТ"
L["Show CRITICAL on critical hits. Impact saves its own choice, enabled by default."] =
    "Показывает КРИТ при критических ударах. Для Impact настройка сохраняется отдельно и включена по умолчанию."
L["CRITICAL"] = "КРИТ"

L["Minimum damage threshold"] = "Минимальный порог урона"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] =
    "Удары ниже этого значения скрываются. Введите 50k или 2m. 0 показывает всё."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] =
    "Поддерживает суффиксы k/m, напр. 20k или 2m. Урон ниже не отображается."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "В рейдах и Эпохальном+ некоторые значения секретны, поэтому порог скрывает эти удары визуально, а не пропускает их."

-- Combine hits
L["Combine hits"] = "Объединение ударов"
L["Combine rapid hits"] = "Объединять быстрые удары"
L["Add hits that land in quick succession on the same nameplate into one number instead of stacking many."] =
    "Складывает удары, быстро попадающие по одному индикатору, в одно число вместо множества отдельных."
L["Combine"] = "Объединять"
L["Same spell"] = "Одно заклинание"
L["All hits"] = "Все удары"
L["Same spell keeps each spell's number separate. All hits merges every hit on the target; its icon shows the spell that did the most damage."] =
    "«Одно заклинание» показывает число каждого заклинания отдельно. «Все удары» объединяет все удары по цели; иконка показывает заклинание, нанёсшее больше всего урона."
L["Combine window"] = "Окно объединения"
L["%.2fs"] = "%.2fс"
L["Show hit count"] = "Показывать число ударов"
L["Show how many hits were combined, e.g. 37,200 (3). With spell icons on, the count sits on the icon."] =
    "Показывает, сколько ударов объединено, например 37 200 (3). С иконками заклинаний число отображается на иконке."
L["%s (%d)"] = "%s (%d)"
L["Crits, normal hits, and heals combine separately."] = "Критические удары, обычные удары и исцеление объединяются отдельно."
L["Crits, normal hits, and heals combine separately. Secret amounts cannot be added, so those hits still show individually."] =
    "Критические удары, обычные удары и исцеление объединяются отдельно. Секретные значения нельзя сложить, поэтому такие удары по-прежнему показываются по отдельности."

L["Preview"] = "Просмотр"
L["Updates live as you change options."] = "Обновляется сразу при изменении настроек."
L["Target an enemy, then spawn sample numbers on its nameplate."] =
    "Выберите врага и создайте примеры чисел на его индикаторе."
L["Test on Target"] = "Тест на цели"
L["Show sample damage numbers on your target."] = "Показывает примеры чисел урона на вашей цели."
L["Maintenance"] = "Обслуживание"
L["Debug mode"] = "Режим отладки"

-- Personal splash
L["Only Engaged nameplates mode, or Personal with Show splash from my casts, shows numbers on enemies you are not targeting. Change it under Modern API → Damage mode."] =
    "Числа на врагах, которые не являются вашей целью, показывают только режим «Индикаторы в бою» или «Личный» с параметром «Показывать задевающий урон моих заклинаний». Измените это в разделе Современный API → Режим урона."
L["Show splash from my casts"] = "Показывать задевающий урон моих заклинаний"
L["In Personal mode, also show hits on other enemies that land right after your cast hits its target, with the same damage school, on enemies you have threat on."] =
    "В личном режиме также показывать удары по другим врагам сразу после попадания вашего заклинания в цель, той же школы урона и по врагам, у которых есть ваша угроза."
L["Choose Personal - experimental to show splash from your casts."] =
    "Выберите «Личный - экспериментальный», чтобы видеть задевающий урон своих заклинаний."
L["Splash is best effort: another player's same-school hit in that split second can still appear. DoT ticks spread to other enemies and unreadable damage schools are not shown."] =
    "Задевающий урон определяется приблизительно: удар другого игрока той же школы в то же мгновение всё ещё может появиться. Тики периодического урона на других врагах и нечитаемые школы урона не показываются."

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
L["Auto"] = "Авто"

-- Settings redesign
L["Animate settings"] = "Анимация настроек"
L["Appearance"] = "Внешний вид"
L["Appearance only · Test on Target checks gameplay size."] = "Только внешний вид · Проверка на цели показывает размер в игре."
L["Appearance preview"] = "Предпросмотр внешнего вида"
L["Attribution"] = "Определение источника"
L["Attribution limitations"] = "Ограничения определения источника"
L["Audio cues for outgoing critical hits."] = "Звуковые сигналы для ваших критических попаданий."
L["Both number styles are available on every supported WoW API."] = "Оба стиля чисел доступны во всех поддерживаемых API WoW."
L["Classic API - Era/TBC/Wrath/MoP"] = "API Classic - Era/TBC/Wrath/MoP"
L["Classic number style"] = "Стиль чисел Classic"
L["Close"] = "Закрыть"
L["Combat"] = "Бой"
L["Current target"] = "Текущая цель"
L["Damage mode"] = "Режим урона"
L["Damage threshold"] = "Порог урона"
L["Diagnostics"] = "Диагностика"
L["Engaged nameplates"] = "Индикаторы в бою"
L["Existing features"] = "Существующие функции"
L["Find a setting"] = "Найти настройку"
L["Fonts, colors, numbers, and spell icons."] = "Шрифты, цвета, числа и значки заклинаний."
L["Help & Settings"] = "Справка и настройки"
L["Hide preview"] = "Скрыть предпросмотр"
L["Instance profiles"] = "Профили подземелий"
L["Meter probe requires Modern API - Midnight & Forever."] = "Диагностика счётчика требует современный API - Midnight и Forever."
L["Midnight & Forever damage modes and attribution."] = "Режимы урона и определение источника в Midnight и Forever."
L["Modern API"] = "Современный API"
L["Modern API - Midnight & Forever"] = "Современный API - Midnight и Forever"
L["Modern number style"] = "Современный стиль чисел"
L["Modern number style motion"] = "Движение современного стиля чисел"
L["No matching settings"] = "Настройки не найдены"
L["Number formatting"] = "Формат чисел"
L["Number style, timing, and movement."] = "Стиль чисел, время и движение."
L["Personal - experimental"] = "Личный - экспериментальный"
L["Play crit sound"] = "Звук критического попадания"
L["Play huge crit sound"] = "Звук мощного критического попадания"
L["Preferences"] = "Предпочтения"
L["Preferences, API information, and diagnostics."] = "Предпочтения, сведения об API и диагностика."
L["Preview scale: %d%%"] = "Масштаб предпросмотра: %d%%"
L["Replay"] = "Повторить"
L["Schools"] = "Школы"
L["Settings redesign"] = "Новый интерфейс настроек"
L["Settings window"] = "Окно настроек"
L["Show preview"] = "Показать предпросмотр"
L["Sounds"] = "Звуки"
L["Spell icons"] = "Значки заклинаний"
L["Text size"] = "Размер текста"
L["Timing and movement"] = "Время и движение"
L["Training dummy"] = "Тренировочный манекен"
L["Unsupported client - combat text unavailable"] = "Неподдерживаемый клиент - боевой текст недоступен"
L["Your WoW API"] = "Ваш API WoW"
L["Mixed"] = "Смешанный"
L["Hit"] = "Попадание"
L["Crit"] = "Критическое"
L["Miss"] = "Промах"

-- Settings explanations
L["A new WoW-inspired settings window with clear sections, searchable controls, and gentle animations."] = "Новое окно настроек в стиле WoW с понятными разделами, поиском и плавной анимацией."
L["Choose Personal - experimental under Modern API → Damage mode to use pet matching."] = "Выберите Личный - экспериментальный в Современный API → Режим урона для сопоставления ударов питомца."
L["Choose Personal - experimental under Modern API → Damage mode to use spell icons."] = "Выберите Личный - экспериментальный в Современный API → Режим урона для значков заклинаний."
L["Choose the combat text you want to see."] = "Выберите отображаемый боевой текст."
L["Choose whose damage to display under Modern API → Damage mode. Personal mode is experimental."] = "Выберите источник отображаемого урона в Современный API → Режим урона. Личный режим экспериментальный."
L["Classic clients read damage ownership and spells directly from the combat log. Modern attribution and school-filter options do not apply."] = "Клиенты Classic читают источник урона и заклинания из журнала боя. Настройки современного определения источника и фильтра школ здесь не применяются."
L["Classic number style uses its own animation. Switch to Modern number style to customize motion."] = "Стиль чисел Classic использует свою анимацию. Для настройки движения выберите современный стиль чисел."
L["Current target: all-source numbers on your target. Engaged nameplates: all-source numbers on engaged enemies."] = "Текущая цель: урон от всех источников на вашей цели. Индикаторы в бою: урон от всех источников на участвующих в бою врагах."
L["Damage meter probe is available. Capture a snapshot while hitting a target."] = "Диагностика счётчика доступна. Создайте снимок, нанося удары цели."
L["Enable Auto-switch by instance to edit the instance profiles."] = "Включите автоматическое переключение по подземелью для изменения профилей."
L["Enable Filter by damage school to choose allowed schools."] = "Включите фильтр по школе урона, чтобы выбрать разрешённые школы."
L["Enable Show incoming hits to adjust its position."] = "Включите отображение входящих попаданий, чтобы изменить их положение."
L["Enable Show spell icon to choose its position."] = "Включите значок заклинания, чтобы выбрать его положение."
L["Enable crit sound to adjust its threshold and channel."] = "Включите звук критического попадания для настройки порога и канала."
L["Enable huge crit sound to adjust its threshold and channel."] = "Включите звук мощного критического попадания для настройки порога и канала."
L["Modern API options now have their own page. Damage mode combines Only my damage and All engaged nameplates without changing saved preferences."] = "Настройки современного API теперь на отдельной странице. Режим урона объединяет Только мой урон и Все индикаторы в бою, сохраняя прежние значения."
L["Modern API: unreadable damage amounts cannot trigger threshold sounds."] = "Современный API: недоступные значения урона не могут вызвать звуки по порогу."
L["Modern clients restrict combat information. Personal mode estimates ownership; all-source modes display target or engaged-nameplate damage."] = "Современные клиенты ограничивают боевые данные. Личный режим оценивает источник; другие режимы показывают урон всех источников на цели или индикаторах в бою."
L["Outgoing healing, incoming damage, font selection, scroll speed, school colors, spell icons, and critical-hit sounds remain available."] = "По-прежнему доступны исходящее исцеление, входящий урон, шрифты, скорость движения, цвета школ, значки заклинаний и звуки критических попаданий."
L["Personal matches recent casts. Current target and Engaged nameplates show damage from all sources."] = "Личный сопоставляет недавние заклинания. Текущая цель и Индикаторы в бою показывают урон всех источников."
L["Personal - experimental: best-effort matching by destination and timing. Other players' hits on the same target can appear."] = "Личный - экспериментальный: примерное сопоставление по цели и времени. Могут появляться удары других игроков по той же цели."
L["Pet matching and spell icons require Personal mode. Choose their appearance and visibility under Combat and Appearance."] = "Сопоставление ударов питомца и значки заклинаний требуют Личный режим. Настройте их отображение в разделах Бой и Внешний вид."
L["Place the spell icon beside, above, or below the number."] = "Разместите значок заклинания рядом с числом, над ним или под ним."
L["PlateSCT needs enemy nameplates. Press V (default) or enable them in the game's nameplate settings."] = "PlateSCT нужны индикаторы имён врагов. Нажмите V (по умолчанию) или включите их в настройках игры."
L["Profiles affect Personal mode. They cannot prove who dealt a hit on Modern API."] = "Профили влияют на Личный режим. В современном API они не могут доказать, кто нанёс удар."
L["Show damage you take near your character. Independent of the outgoing damage mode."] = "Показывает полученный урон рядом с персонажем независимо от режима исходящего урона."
L["Show sample hits, crits, and misses in the bottom preview drawer."] = "Показывает примеры попаданий, критических попаданий и промахов в нижней панели предпросмотра."
L["Show sample hits, crits, and misses inside this window."] = "Показывает примеры попаданий, критических попаданий и промахов в этом окне."
L["Spell icons use matched casts in Personal mode; Modern API cannot identify a spell for every hit."] = "Значки используют сопоставленные заклинания в Личном режиме; современный API не определяет заклинание для каждого удара."
L["Spell icons use the spell from the combat log."] = "Значки используют заклинание из журнала боя."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. Both number styles remain available on every API."] = "Компактный нижний предпросмотр содержит Смешанный, Попадание, Критическое и Промах. Оба стиля доступны на всех API."
L["The preview shows appearance only. It does not prove attribution or simulate damage filtering."] = "Предпросмотр показывает только внешний вид. Он не подтверждает источник и не имитирует фильтрацию урона."
L["This client does not expose the damage meter API. A snapshot can still report which fields are unavailable."] = "В этом клиенте нет API счётчика урона. Снимок всё равно может показать, какие поля недоступны."
L["Turn off Auto-switch by instance to choose manual strictness."] = "Отключите автоматическое переключение по подземелью для ручного выбора строгости."
L["Unreadable amounts cannot trigger threshold sounds. Unreadable damage schools are always allowed by the school filter."] = "Недоступные значения не вызывают звуки по порогу. Урон с недоступной школой всегда проходит фильтр."
L["Use gentle fades and row reveals in this settings window. Combat animation is unaffected."] = "Плавное появление окна и строк настроек. Анимация боевых чисел не меняется."

-- What's new: combine hits
L["Rapid hits on the same nameplate can merge into one growing number with a hit count. Turn it on under Combat → Combine hits."] =
    "Быстрые удары по одному индикатору можно объединять в одно растущее число со счётчиком ударов. Включите в разделе «Бой» → «Объединение ударов»."

-- Reduce clutter
L["Reduce clutter"] = "Меньше лишнего"

-- Combine hits: merge pop
L["Pop on each merge"] = "Всплеск при каждом объединении"
L["Briefly enlarge the number every time another hit merges into it. Turn off for a calmer display."] =
    "Ненадолго увеличивать число каждый раз, когда к нему добавляется удар. Отключите для более спокойного отображения."
