local _, BD = ...

local L = {}
BD.RegisterLocale("koKR", L)

-- Number position and font preview
L["Number position"] = "숫자 위치"
L["X offset"] = "X 오프셋"
L["Y offset"] = "Y 오프셋"
L["Offsets are saved separately for each number style. Positive X moves right; positive Y moves up. Incoming uses its own position controls."] = "오프셋은 숫자 스타일별로 따로 저장됩니다. X가 양수이면 오른쪽으로, Y가 양수이면 위로 이동합니다. 받는 피해는 별도의 위치 설정을 사용합니다."
L["Hover over a font to preview 12345."] = "글꼴 위에 마우스를 올리면 12345를 미리 볼 수 있습니다."
L["Press Ctrl+C to copy the URL."] = "Ctrl+C를 눌러 URL을 복사하세요."
L["Open Link"] = "링크 열기"

-- Impact number style
L["Impact number style"] = "임팩트 숫자 스타일"
L["All number styles are available on every supported WoW API."] = "모든 숫자 스타일은 지원되는 모든 WoW API에서 사용할 수 있습니다."
L["Impact slams outgoing damage beside or above the nameplate, then floats up. New hits layer in front; crits amplify and CRITICAL flashes above when enabled."] =
    "임팩트 스타일은 내가 준 피해를 이름표 옆이나 위에 충격 효과로 표시한 뒤 위로 띄웁니다. 새 피해 숫자는 앞쪽에 표시되고, 치명타 효과는 더 크게 나타납니다. 해당 옵션을 켜면 위에 '치명타' 문구도 깜박입니다."
L["Impact style position"] = "임팩트 스타일 위치"
L["Damage position"] = "피해 표시 위치"
L["Side"] = "옆"
L["Place Impact damage to the right of the nameplate or centered above it."] = "임팩트 피해 숫자를 이름표 오른쪽이나 이름표 위 중앙에 표시합니다."
L["Impact uses Modern for incoming damage, healing, and miss text, preserving saved Modern motions."] =
    "임팩트 스타일은 받는 피해, 치유, 빗나감 문구에 모던 스타일을 사용하며, 저장된 모던 스타일의 움직임 설정을 유지합니다."
L["Pick a motion for each hit type in Modern. Classic and Impact use their own damage animations."] =
    "모던 스타일에서는 적중 유형별로 움직임을 선택할 수 있습니다. 클래식과 임팩트 스타일은 각각 전용 피해 애니메이션을 사용합니다."
L["Switch to Modern number style to customize these motions."] = "이 움직임을 변경하려면 모던 숫자 스타일로 전환하세요."
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. All number styles remain available on every API."] =
    "하단의 작은 미리 보기에는 혼합, 일반 적중, 치명타, 빗나감 예시가 표시됩니다. 모든 숫자 스타일은 모든 API에서 사용할 수 있습니다."

-- Titles / meta
L["PlateSCT is in Beta"] = "PlateSCT는 베타 버전입니다"
L["This addon is in Beta mode. Inaccuracies and errors may show up. Please report such issues on the addon's page."] =
    "이 애드온은 베타 버전입니다. 표시가 부정확하거나 오류가 발생할 수 있습니다. 문제가 있으면 애드온 페이지에 알려 주세요."
L["Addon page"] = "애드온 페이지"
L["Select the URL below, copy it, then paste it in your browser."] = "아래 주소를 선택하여 복사한 뒤 브라우저에 붙여 넣으세요."
L["Click to open the addon page URL."] = "클릭하면 애드온 페이지 주소를 볼 수 있습니다."
L["/platesct  ·  ESC to close"] = "/platesct  ·  ESC로 닫기"
L["PlateSCT uses its own settings window.\n\nType /platesct in chat, or click the button below."] =
    "PlateSCT는 자체 설정 창을 사용합니다.\n\n대화창에 /platesct를 입력하거나 아래 버튼을 클릭하세요."
L["Open PlateSCT"] = "PlateSCT 열기"
L["Target something to preview test numbers."] = "대상을 선택하면 테스트 숫자를 미리 볼 수 있습니다."
L["Meter probe"] = "피해량 측정기 점검"
L["Click the box, Ctrl+A, then Ctrl+C, and paste it in chat."] = "텍스트 상자를 클릭하고 Ctrl+A, Ctrl+C를 차례로 누른 뒤 대화창에 붙여 넣으세요."

-- Pages
L["General"] = "일반"
L["Display"] = "표시"
L["Damage"] = "피해"
L["Tools"] = "도구"
L["Tools & Preview"] = "도구 및 미리 보기"
L["What's new?"] = "업데이트 내용"
L["Choose whose damage and which nameplates to show."] = "누가 준 피해를 어떤 이름표에 표시할지 선택합니다."
L["Control how numbers look and how they animate."] = "숫자의 모양과 애니메이션을 설정합니다."
L["Hide small hits so the big numbers stay readable."] = "작은 피해를 숨겨 큰 숫자를 쉽게 읽을 수 있게 합니다."
L["Hide small hits and play sounds on big crits."] = "작은 피해를 숨기고 큰 치명타가 발생하면 효과음을 재생합니다."
L["Preview numbers and maintain your setup."] = "숫자를 미리 보고 설정을 관리합니다."
L["Recent changes in PlateSCT."] = "PlateSCT의 최근 변경 사항입니다."
L["Version 1.1.4"] = "버전 1.1.4"
L["NEW"] = "신규"
L["IMPROVED"] = "개선"
L["Outgoing healing on the recipient's nameplate. Enable Show healing under General (off by default). Friendly nameplates must be on in the game."] =
    "내가 시전한 치유를 대상의 이름표에 표시합니다. 일반에서 '치유 표시'를 켜세요(기본값: 꺼짐). 게임에서 아군 이름표도 켜야 합니다."
L["Scroll speed slider - numbers travel faster; fade still follows Display duration."] = "스크롤 속도 슬라이더로 숫자의 이동 속도를 높일 수 있습니다. 사라지는 시간은 표시 시간 설정을 따릅니다."
L["Font picker - game fonts, plus SharedMedia fonts when another addon provides them."] =
    "글꼴 선택기에서 게임 글꼴을 선택할 수 있습니다. 다른 애드온이 SharedMedia를 제공하면 해당 글꼴도 사용할 수 있습니다."
L["Font size up to 48, Scroll offset up to 120 px, Display duration up to 4 seconds."] = "글꼴 크기는 최대 48, 스크롤 거리는 최대 120 px, 표시 시간은 최대 4초까지 설정할 수 있습니다."
L["Larger fonts spread out more in Modern number style so hits overlap less."] = "모던 숫자 스타일에서는 글꼴이 클수록 숫자 사이의 간격을 넓혀 겹침을 줄입니다."

-- Sound effects
L["Sound effects"] = "효과음"
L["Outgoing critical hits play a sound when damage is above the threshold you type. Huge crit takes priority over the normal crit sound."] =
    "내가 준 치명타 피해가 입력한 기준값보다 높으면 효과음을 재생합니다. 큰 치명타 효과음은 일반 치명타 효과음보다 우선합니다."
L["Crit sound"] = "치명타 효과음"
L["Enable crit sound"] = "치명타 효과음 사용"
L["Play a sound when an outgoing critical hit is above the damage threshold."] = "내가 준 치명타 피해가 피해 기준값보다 높으면 효과음을 재생합니다."
L["Huge crit sound"] = "큰 치명타 효과음"
L["Enable huge crit sound"] = "큰 치명타 효과음 사용"
L["Play a louder sound when an outgoing critical hit is above the huge damage threshold."] = "내가 준 치명타 피해가 큰 피해 기준값보다 높으면 더 큰 소리의 효과음을 재생합니다."
L["Damage threshold to play sound. Type 5k or 50k."] = "효과음을 재생할 피해 기준값입니다. 5k 또는 50k를 입력할 수 있습니다."
L["Supports k/m suffixes, e.g. 20k or 2m."] = "k/m 접미사를 사용할 수 있습니다. 예: 20k 또는 2m."
L["Supports k/m suffixes, e.g. 20k or 2m. The critical strike damage must be higher than this value."] =
    "k/m 접미사를 사용할 수 있습니다. 예: 20k 또는 2m. 치명타 피해가 이 값보다 높아야 합니다."
L["Play"] = "재생"
L["Preview this sound effect."] = "이 효과음을 미리 들어 봅니다."
L["Channel"] = "소리 채널"
L["Which game sound channel plays this effect."] = "이 효과음을 재생할 게임 소리 채널을 선택합니다."
L["Dialog"] = "대사"
L["SFX"] = "효과음"
L["Ambience"] = "환경음"
L["Music"] = "음악"

-- General
L["Combat text"] = "전투 메시지"
L["Enable PlateSCT"] = "PlateSCT 사용"
L["Show floating damage numbers on nameplates."] = "이름표에 떠오르는 피해 숫자를 표시합니다."
L["Hide Blizzard floating combat text"] = "블리자드 전투 메시지 숨기기"
L["Turns off default in-world damage numbers."] = "게임에서 기본으로 표시하는 피해 숫자를 끕니다."
L["Show minimap button"] = "미니맵 버튼 표시"
L["Show the PlateSCT icon on the minimap. Click it to open settings."] = "미니맵에 PlateSCT 아이콘을 표시합니다. 클릭하면 설정을 엽니다."
L["Click to open settings."] = "클릭하면 설정을 엽니다."
L["Enemy nameplates are turned off. PlateSCT needs them to show numbers.\nPress V (default) or enable them under Interface → Game → Names."] =
    "적 이름표가 꺼져 있습니다. PlateSCT가 숫자를 표시하려면 이름표가 필요합니다.\nV 키(기본값)를 누르거나 인터페이스 → 게임 → 이름에서 켜세요."
L["Who to show"] = "표시할 피해 출처"

-- What's new: less clutter
L["Less clutter"] = "더 깔끔한 화면"
L["Dim or hide numbers on enemies you are not targeting, show crits only, shrink small hits, and ignore chosen spells. Find them on the Combat page."] =
    "대상이 아닌 적의 숫자를 흐리게 하거나 숨기고, 치명타만 표시하고, 작은 적중을 축소하고, 선택한 주문을 무시할 수 있습니다. 전투 페이지에서 설정하세요."


-- Ignored spells
L["Ignored spells"] = "무시할 주문"
L["Ignore these spells"] = "이 주문 무시"
L["Spell names or IDs, separated by commas. Their hits, crits, and misses are not shown."] =
    "주문 이름 또는 ID를 쉼표로 구분해 입력합니다. 해당 주문의 적중, 치명타, 빗나감은 표시되지 않습니다."
L["Example: Auto Attack, 133."] = "예: 자동 공격, 133."
L["Example: Auto Attack, 133. Modern API knows the spell only in Personal - experimental mode."] =
    "예: 자동 공격, 133. 모던 API는 개인 피해 - 실험 기능 모드에서만 주문을 알 수 있습니다."


-- Shrink small hits
L["Shrink small hits"] = "작은 적중 축소"
L["Show hits well below your recent average smaller instead of hiding them."] =
    "최근 평균보다 훨씬 낮은 적중을 숨기는 대신 작게 표시합니다."
L["Small hit below"] = "작은 적중 기준"
L["%s of average"] = "평균의 %s"


-- Crits only
L["Crits only"] = "치명타만"
L["Show only critical hits. Normal hits and heals are hidden; miss text such as Immune still shows."] =
    "치명타만 표시합니다. 일반 적중과 치유는 숨겨지며, 면역 같은 빗나감 문구는 계속 표시됩니다."


-- Off-target numbers
L["Show"] = "표시"
L["Dim"] = "흐리게"
L["Hide"] = "숨기기"
L["Other nameplates"] = "다른 이름표"
L["How numbers look on enemies you are not targeting. Dim makes them smaller and fainter so your target stands out."] =
    "대상으로 지정하지 않은 적에게 표시되는 숫자의 모양입니다. 흐리게는 숫자를 더 작고 옅게 만들어 현재 대상이 돋보이게 합니다."
L["Off-target size"] = "대상 외 크기"
L["Off-target opacity"] = "대상 외 불투명도"

L["Only my damage"] = "내가 준 피해만 표시"
L["Show hits when a recent cast or auto-attack matches the nameplate. Midnight cannot prove who dealt the hit in a group."] =
    "최근 시전이나 자동 공격이 해당 이름표와 일치하면 피해를 표시합니다. Midnight에서는 파티 내 피해를 누가 주었는지 확인할 수 없습니다."
L["Experimental"] = "실험 기능"
L["Best effort: matches your casts to nameplates by destination and timing. Dest-matched cleave can show. Other players on the same target can still appear. Mythic+ uses the Dungeon profile."] =
    "최대한 추정: 피격 대상과 발생 시간을 기준으로 내 시전과 이름표의 피해를 연결합니다. 대상이 일치하는 여러 대상 공격도 표시될 수 있습니다. 같은 대상을 공격한 다른 플레이어의 피해가 섞일 수 있습니다. 신화 쐐기돌 던전에서는 던전 프로필을 사용합니다."
L["All engaged nameplates"] = "교전 중인 모든 적의 이름표"
L["Show every hit on every visible hostile nameplate. This is the accurate Midnight mode; it includes damage from every source."] =
    "보이는 모든 적 이름표의 모든 피해를 표시합니다. Midnight에서 피해를 정확하게 표시하는 모드이며, 모든 출처의 피해가 포함됩니다."
L["Available when Only my damage is off. Use this to see numbers on every enemy plate."] = "'내가 준 피해만 표시'를 끄면 사용할 수 있습니다. 모든 적 이름표에 숫자를 표시하려면 이 옵션을 사용하세요."
L["Include pet damage"] = "소환수 피해 포함"
L["In Only my damage mode, also treat a recent pet cast as your hit."] = "'내가 준 피해만 표시' 모드에서는 최근 소환수의 시전과 연결된 피해도 내 피해로 처리합니다."
L["Also show damage from your pet and guardians on nameplates."] = "소환수와 수호자가 준 피해도 이름표에 표시합니다."
L["Shows your damage on hostile nameplates. Source is read from the combat log."] = "적 이름표에 내가 준 피해를 표시합니다. 피해 출처는 전투 기록에서 읽습니다."
L["Display the spell's icon next to the damage number. Uses the spell from the combat log."] = "피해 숫자 옆에 주문 아이콘을 표시합니다. 전투 기록의 주문 정보를 사용합니다."
L["Healing"] = "치유"
L["Show healing"] = "치유 표시"
L["Show your outgoing heals on the recipient's nameplate. Friendly nameplates must be enabled in the game."] = "내가 시전한 치유를 대상의 이름표에 표시합니다. 게임에서 아군 이름표를 켜야 합니다."
L["Uses the same size, motion, duration, icons, and threshold as damage. Skips heals on you."] =
    "치유는 피해와 같은 크기, 움직임, 표시 시간, 아이콘, 기준값을 사용합니다. 자신에게 한 치유는 표시하지 않습니다."
L["Attribution profiles"] = "피해 출처 추정 프로필"
L["How strict PlateSCT is when guessing which hits are yours. Auto-switch follows the instance type."] = "내 피해를 추정할 때 적용할 엄격도를 설정합니다. 자동 전환은 인스턴스 유형을 따릅니다."
L["Current profile"] = "현재 프로필"
L["Auto-switch by instance"] = "인스턴스별 자동 전환"
L["Pick Open world, Dungeon, Raid, Battleground, or Arena settings from the zone you are in."] = "현재 지역에 따라 야외, 던전, 공격대, 전장 또는 투기장 설정을 선택합니다."
L["Manual strictness"] = "수동 엄격도"
L["Used when Auto-switch is off."] = "자동 전환을 끄면 사용합니다."
L["Open world"] = "야외"
L["Dungeon"] = "던전"
L["Raid"] = "공격대"
L["Battleground"] = "전장"
L["Arena"] = "투기장"
L["Loose"] = "느슨함"
L["Balanced"] = "균형"
L["Strict"] = "엄격"
L["Very Strict"] = "매우 엄격"
L["Loose: longer windows, more numbers."] = "느슨함: 판정 시간 범위가 길어 더 많은 숫자를 표시합니다."
L["Balanced: medium windows and cleave hits."] = "균형: 중간 길이의 판정 시간 범위를 사용하며 여러 대상 공격도 포함합니다."
L["Strict: short windows, fewer foreign hits."] = "엄격: 판정 시간 범위가 짧아 다른 플레이어의 피해가 덜 섞입니다."
L["Very Strict: shortest windows, destination required, one hit per cast."] = "매우 엄격: 판정 시간 범위가 가장 짧으며, 대상이 일치해야 하고 시전당 한 번의 피해만 표시합니다."
L["Active: %s (%s)"] = "사용 중: %s (%s)"
L["Recommended"] = "권장"
L["Damage schools"] = "피해 계열"
L["Damage Schools"] = "피해 계열"
L["Filter by damage school"] = "피해 계열별 필터"
L["Show damage from schools checked below. Same-school hits from other players can still appear. Secret or unreadable schools are always shown."] =
    "아래에서 선택한 계열의 피해를 표시합니다. 다른 플레이어가 준 같은 계열의 피해도 표시될 수 있습니다. 계열 정보가 제한되거나 읽을 수 없는 피해는 항상 표시합니다."
L["Use Recommended (%s)"] = "권장 계열 사용 (%s)"
L["Use the schools your class typically deals."] = "내 직업이 주로 사용하는 피해 계열을 적용합니다."
L["Physical"] = "물리"
L["Holy"] = "신성"
L["Fire"] = "화염"
L["Nature"] = "자연"
L["Frost"] = "냉기"
L["Shadow"] = "암흑"
L["Arcane"] = "비전"

-- Display
L["Number style"] = "숫자 스타일"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, newest hit takes center, and older numbers snap aside."] =
    "모던 스타일은 이름표에서 위로 올라가며, 치명타일 때 살짝 확대됩니다. 클래식 스타일은 커졌다가 줄어드는 효과를 유지합니다. 가장 최근 피해는 중앙에 표시되고, 이전 숫자는 옆으로 이동합니다."
L["Modern"] = "모던 스타일"
L["Classic"] = "클래식 스타일"
L["Show live preview"] = "실시간 미리 보기 표시"
L["Show sample hits, crits, and misses beside this window."] = "이 창 옆에 일반 적중, 치명타, 빗나감 예시를 표시합니다."
L["Hide live preview"] = "실시간 미리 보기 숨기기"
L["Color by damage school"] = "피해 계열별 색상"
L["Tint numbers by school (fire orange, frost blue, and so on). Off keeps the default yellow."] = "피해 계열에 따라 숫자 색상을 지정합니다(화염은 주황색, 냉기는 파란색 등). 끄면 기본 노란색을 사용합니다."
L["Show spell icon"] = "주문 아이콘 표시"
L["Display the spell's icon next to the damage number. Uses the matched cast or auto-attack."] = "피해 숫자 옆에 주문 아이콘을 표시합니다. 연결된 시전이나 자동 공격을 사용합니다."
L["Uses your matched spell in Only my damage mode. Position is set below."] = "'내가 준 피해만 표시' 모드에서는 연결된 주문을 사용합니다. 아이콘 위치는 아래에서 설정합니다."
L["Icon position"] = "아이콘 위치"
L["Left"] = "왼쪽"
L["Right"] = "오른쪽"
L["Top"] = "위"
L["Bottom"] = "아래"
L["Text style"] = "글자 스타일"
L["Abbreviate numbers"] = "숫자 축약"

-- What's new: labels and colors
L["Labels and colors"] = "표시와 색상"
L["Spell names next to numbers, a text outline choice, custom hit, crit, and miss colors, and a separate auto-attack motion."] =
    "숫자 옆 주문 이름, 글자 외곽선 선택, 적중·치명타·빗나감 사용자 지정 색상, 그리고 자동 공격 전용 움직임을 추가했습니다."


-- Auto-attack motion
L["Same as normal hits"] = "일반 적중과 동일"
L["Auto-attacks"] = "자동 공격"
L["Motion used for your normal auto-attack hits, so melee swings can move differently from spells. Auto-attack crits use the Critical hits motion."] =
    "일반 자동 공격 적중에 쓰는 움직임으로, 근접 공격을 주문과 다르게 움직이게 합니다. 자동 공격 치명타는 치명타 움직임을 사용합니다."


-- Spell label
L["Label"] = "표시 방식"
L["Name"] = "이름"
L["Icon"] = "아이콘"
L["Icon and name"] = "아이콘과 이름"
L["Spell label"] = "주문 표시"
L["Show spell label"] = "주문 표시 사용"
L["Show which spell dealt each hit. Uses the matched cast or auto-attack."] =
    "각 적중을 어떤 주문이 냈는지 표시합니다. 연결된 시전이나 자동 공격을 사용합니다."
L["Show which spell dealt each hit. Uses the spell from the combat log."] =
    "각 적중을 어떤 주문이 냈는지 표시합니다. 전투 기록의 주문을 사용합니다."
L["Show the spell's icon, its name, or both."] = "주문 아이콘, 주문 이름 또는 둘 다를 표시합니다."
L["Enable Show spell label to choose the label."] = "표시 방식을 고르려면 주문 표시 사용을 켜세요."
L["Name position"] = "이름 위치"
L["Where the spell name sits relative to the number."] = "숫자를 기준으로 한 주문 이름의 위치입니다."
L["Name size"] = "이름 크기"
L["Shorten long names"] = "긴 이름 줄이기"
L["After %d characters"] = "%d자 이후"
L["The Name label has no icon to place."] = "이름 표시에는 배치할 아이콘이 없습니다."
L["Enable Show spell label to choose its position."] = "위치를 고르려면 주문 표시 사용을 켜세요."


-- Custom colors
L["Custom colors"] = "사용자 지정 색상"
L["Pick your own colors for normal hits, crits, and miss text instead of the default yellow."] =
    "기본 노란색 대신 일반 적중, 치명타, 빗나감 문구의 색상을 직접 고릅니다."
L["Turn off Color by damage school to pick custom colors."] = "사용자 지정 색상을 고르려면 피해 계열별 색상을 끄세요."
L["Color of normal damage numbers."] = "일반 피해 숫자의 색상입니다."
L["Color of critical hit numbers."] = "치명타 숫자의 색상입니다."
L["Miss text"] = "빗나감 문구"
L["Color of Miss, Dodge, Immune, and similar text."] = "빗나감, 회피, 면역 등 문구의 색상입니다."


-- Outline
L["Outline"] = "외곽선"
L["Number style default"] = "숫자 스타일 기본값"
L["None"] = "없음"
L["Thin"] = "얇게"
L["Thick"] = "두껍게"
L["Text outline. Number style default uses each style's own outline: thick for Classic, thin for Modern and Impact."] =
    "글자 외곽선입니다. 숫자 스타일 기본값은 각 스타일의 외곽선을 사용합니다. 클래식 스타일은 두껍게, 모던 스타일과 Impact는 얇게 표시됩니다."

L["Display large numbers as 214k or 1.2M."] = "큰 숫자를 214k 또는 1.2M으로 표시합니다."
L["Display large numbers as 214k or 1.2M. Disables thousand separators."] = "큰 숫자를 214k 또는 1.2M으로 표시합니다. 사용하면 천 단위 구분 기호는 꺼집니다."
L["Thousand separators"] = "천 단위 구분 기호"
L["Group digits by thousands."] = "숫자를 세 자리씩 구분합니다."
L["Unavailable while Abbreviate numbers is on."] = "'숫자 축약'을 켜면 사용할 수 없습니다."
L["Off"] = "꺼짐"
L["Comma (10,000)"] = "쉼표 (10,000)"
L["Dot (10.000)"] = "마침표 (10.000)"
L["Animation"] = "애니메이션"
L["Font"] = "글꼴"
L["Font size"] = "글꼴 크기"
L["Scroll offset"] = "스크롤 거리"
L["Scroll speed"] = "스크롤 속도"
L["%d%%"] = "%d%%"
L["Display duration"] = "표시 시간"
L["Game default"] = "게임 기본값"
L["Friz Quadrata"] = "Friz Quadrata"
L["Arial Narrow"] = "Arial Narrow"
L["Skurri"] = "Skurri"
L["Morpheus"] = "Morpheus"
L["Game fonts, plus SharedMedia fonts when that library is loaded by another addon."] = "게임 글꼴을 사용할 수 있습니다. 다른 애드온이 SharedMedia 라이브러리를 불러오면 해당 글꼴도 사용할 수 있습니다."
L["Only fonts inside the WoW folder can load. SharedMedia fonts appear when another addon provides them."] =
    "WoW 폴더 안에 있는 글꼴만 불러올 수 있습니다. 다른 애드온이 SharedMedia 글꼴을 제공하면 목록에 표시됩니다."
L["%d px"] = "%d px"
L["%.1fs"] = "%.1f초"
L["%.1fx"] = "%.1fx"
L["Motion (Modern)"] = "움직임 (모던 스타일)"
L["Pick a motion for each hit type. Classic number style ignores these and keeps its own animation."] =
    "적중 유형별로 움직임을 선택합니다. 클래식 숫자 스타일은 이 설정을 적용하지 않고 전용 애니메이션을 유지합니다."
L["Classic uses its own animation. Switch to Modern to customize motion."] = "클래식 스타일은 전용 애니메이션을 사용합니다. 움직임을 변경하려면 모던 스타일로 전환하세요."
L["Normal hits"] = "일반 적중"
L["Critical hits"] = "치명타"
L["Miss / Parry / Dodge"] = "빗나감 / 무기 막기 / 회피"
L["Motion used for normal damage numbers."] = "일반 피해 숫자에 사용할 움직임입니다."
L["Motion used for critical hits."] = "치명타에 사용할 움직임입니다."
L["Motion used for miss, parry, dodge, and similar outcomes."] = "빗나감, 무기 막기, 회피 등의 결과에 사용할 움직임입니다."
L["Vertical Up"] = "수직 상승"
L["Classic Slap"] = "클래식 확대 효과"
L["Fountain"] = "분수"
L["Rainfall"] = "빗줄기"
L["Vertical Down"] = "수직 하강"
L["Motion used for critical hits. Classic Slap uses the Classic grow-and-settle pow."] = "치명타에 사용할 움직임입니다. '클래식 확대 효과'는 클래식 스타일의 커졌다가 줄어드는 효과를 사용합니다."
L["Show CRITICAL"] = "'치명타' 문구 표시"
L["Show CRITICAL on critical hits. Impact saves its own choice, enabled by default."] = "치명타가 발생하면 '치명타' 문구를 표시합니다. 임팩트 스타일은 이 옵션을 별도로 저장하며 기본으로 켜져 있습니다."
L["CRITICAL"] = "치명타"

-- Incoming
L["Incoming"] = "받는 피해"
L["Show incoming hits"] = "받는 피해 표시"
L["Show damage you take near your character. Independent of Only my damage."] = "내가 받는 피해를 캐릭터 주변에 표시합니다. '내가 준 피해만 표시'와 별도로 작동하며 최소 피해 기준값을 적용하지 않습니다."
L["Uses your personal nameplate when available; otherwise floats near screen center."] = "개인 이름표를 사용할 수 있으면 해당 위치에 표시하고, 그렇지 않으면 화면 중앙 근처에 띄웁니다."
L["Uses your personal nameplate when available; otherwise sits on your unit frame."] = "개인 이름표를 사용할 수 있으면 해당 위치에 표시하고, 그렇지 않으면 화면 중앙 근처에 띄웁니다."
L["Incoming X"] = "받는 피해 X 위치"
L["Incoming Y"] = "받는 피해 Y 위치"

-- Damage
L["Minimum damage threshold"] = "최소 피해 기준값"
L["Hits below this amount are hidden. Type 50k or 2m. Set to 0 to show everything."] = "이 수치보다 작은 피해는 숨깁니다. 50k 또는 2m를 입력할 수 있습니다. 0으로 설정하면 모두 표시합니다."
L["Supports k/m suffixes, e.g. 20k or 2m. Damage below this value will not be displayed."] = "k/m 접미사를 사용할 수 있습니다. 예: 20k 또는 2m. 이 값보다 작은 피해는 표시하지 않습니다."
L["In raids and Mythic+ some amounts are secret, so the threshold hides those hits visually instead of skipping them."] =
    "공격대와 신화 쐐기돌 던전에서는 일부 피해량의 읽기가 제한됩니다. 이런 피해는 처리를 건너뛰는 대신 화면에서 숨기는 방식으로 기준값을 적용합니다."

-- Combine hits
L["Combine hits"] = "적중 합치기"
L["Combine rapid hits"] = "빠른 적중 합치기"
L["Add hits that land in quick succession on the same nameplate into one number instead of stacking many."] =
    "같은 이름표에 짧은 간격으로 들어온 적중을 여러 개 쌓는 대신 하나의 숫자로 합칩니다."
L["Combine"] = "합치기 방식"
L["Same spell"] = "같은 주문"
L["All hits"] = "모든 적중"
L["Same spell keeps each spell's number separate. All hits merges every hit on the target; its icon shows the spell that did the most damage."] =
    "같은 주문은 주문별 숫자를 따로 표시합니다. 모든 적중은 대상에 대한 모든 적중을 합치며, 아이콘은 가장 많은 피해를 준 주문을 표시합니다."
L["Combine window"] = "합치기 시간"
L["%.2fs"] = "%.2f초"
L["Show hit count"] = "적중 횟수 표시"
L["Show how many hits were combined, e.g. 37,200 (3). With spell icons on, the count sits on the icon."] =
    "합쳐진 적중 횟수를 표시합니다. 예: 37,200 (3). 주문 아이콘을 켜면 횟수가 아이콘 위에 표시됩니다."
L["%s (%d)"] = "%s (%d)"
L["Crits, normal hits, and heals combine separately."] = "치명타, 일반 적중, 치유는 각각 따로 합쳐집니다."
L["Crits, normal hits, and heals combine separately. Secret amounts cannot be added, so those hits still show individually."] =
    "치명타, 일반 적중, 치유는 각각 따로 합쳐집니다. 일부 피해량은 읽기가 제한되어 더할 수 없으므로 해당 적중은 계속 따로 표시됩니다."

-- Tools
L["Preview"] = "미리 보기"
L["Updates live as you change options."] = "옵션을 변경하면 즉시 갱신됩니다."
L["Target an enemy, then spawn sample numbers on its nameplate."] = "적을 대상으로 선택한 뒤 이름표에 예시 숫자를 표시합니다."
L["Test on Target"] = "대상에서 테스트"
L["Show sample damage numbers on your target."] = "현재 대상에 예시 피해 숫자를 표시합니다."
L["Debug mode"] = "디버그 모드"

-- Personal splash
L["Only Engaged nameplates mode, or Personal with Show splash from my casts, shows numbers on enemies you are not targeting. Change it under Modern API → Damage mode."] =
    "대상이 아닌 적에게 숫자를 표시하는 것은 교전 중인 적의 이름표 모드, 또는 내 주문의 광역 피해 표시를 켠 개인 모드뿐입니다. 모던 API → 피해 모드에서 변경하세요."
L["Show splash from my casts"] = "내 주문의 광역 피해 표시"
L["In Personal mode, also show hits on other enemies that land right after your cast hits its target, with the same damage school, on enemies you have threat on."] =
    "개인 모드에서 주문이 대상에 적중한 직후 다른 적에게 들어온 같은 피해 계열의 적중도, 위협 수준이 있는 적이라면 표시합니다."
L["Choose Personal - experimental to show splash from your casts."] =
    "주문의 광역 피해를 표시하려면 개인 피해 - 실험 기능을 선택하세요."
L["Splash is best effort: another player's same-school hit in that split second can still appear. DoT ticks spread to other enemies and unreadable damage schools are not shown."] =
    "광역 피해는 최선의 추정입니다. 같은 순간 다른 플레이어의 같은 계열 적중이 표시될 수 있습니다. 다른 적에게 퍼진 지속 피해와 읽을 수 없는 피해 계열은 표시되지 않습니다."

L["Print combat events to chat for troubleshooting."] = "문제 해결을 위해 전투 이벤트를 대화창에 출력합니다."
L["Dump meter now"] = "측정기 정보 내보내기"
L["Open a copyable snapshot of C_DamageMeter fields. Use this in combat while hitting a target."] = "복사할 수 있는 C_DamageMeter 필드의 스냅샷을 엽니다. 전투 중 대상을 공격하면서 사용하세요."

-- Language
L["Language"] = "언어"
L["Choose the language used by PlateSCT panels and messages."] = "PlateSCT 패널과 메시지에 사용할 언어를 선택합니다."
L["Auto"] = "자동"

-- Settings redesign
L["A new WoW-inspired settings window with clear sections, searchable controls, and gentle animations."] =
    "WoW 분위기의 새로운 설정 창입니다. 항목별 구분, 설정 검색, 부드러운 애니메이션을 제공합니다."
L["Animate settings"] = "설정 창 애니메이션 사용"
L["Appearance"] = "외형"
L["Appearance only · Test on Target checks gameplay size."] = "외형만 미리 표시 · 실제 크기는 '대상에서 테스트'로 확인하세요."
L["Appearance preview"] = "외형 미리 보기"
L["Attribution"] = "피해 출처 추정"
L["Attribution limitations"] = "피해 출처 추정의 한계"
L["Audio cues for outgoing critical hits."] = "내가 준 치명타 피해에 소리로 알림을 제공합니다."
L["Both number styles are available on every supported WoW API."] = "두 숫자 스타일은 지원되는 모든 WoW API에서 사용할 수 있습니다."
L["Choose Personal - experimental under Modern API → Damage mode to use pet matching."] = "소환수 피해 연결을 사용하려면 모던 API → 피해 모드에서 '개인 피해 - 실험 기능'을 선택하세요."
L["Choose Personal - experimental under Modern API → Damage mode to use spell icons."] = "주문 아이콘을 사용하려면 모던 API → 피해 모드에서 '개인 피해 - 실험 기능'을 선택하세요."
L["Choose the combat text you want to see."] = "표시할 전투 메시지를 선택합니다."
L["Choose whose damage to display under Modern API → Damage mode. Personal mode is experimental."] = "모던 API → 피해 모드에서 누가 준 피해를 표시할지 선택합니다. 개인 피해 모드는 실험 기능입니다."
L["Classic API - Era/TBC/Wrath/MoP"] = "클래식 API - Era/TBC/Wrath/MoP"
L["Classic clients read damage ownership and spells directly from the combat log. Modern attribution and school-filter options do not apply."] =
    "클래식 API 클라이언트는 전투 기록에서 피해 출처와 주문을 직접 읽습니다. 모던 API의 피해 출처 추정과 피해 계열 필터 옵션은 적용되지 않습니다."
L["Classic number style"] = "클래식 숫자 스타일"
L["Classic number style uses its own animation. Switch to Modern number style to customize motion."] =
    "클래식 숫자 스타일은 전용 애니메이션을 사용합니다. 움직임을 변경하려면 모던 숫자 스타일로 전환하세요."
L["Close"] = "닫기"
L["Combat"] = "전투"
L["Crit"] = "치명타"
L["Current target"] = "현재 대상"
L["Current target: all-source numbers on your target. Engaged nameplates: all-source numbers on engaged enemies."] =
    "현재 대상: 현재 대상이 받은 모든 출처의 피해를 표시합니다. 교전 중인 적의 이름표: 교전 중인 적이 받은 모든 출처의 피해를 표시합니다."
L["Damage meter probe is available. Capture a snapshot while hitting a target."] = "피해량 측정기 점검을 사용할 수 있습니다. 대상을 공격하면서 스냅샷을 수집하세요."
L["Damage mode"] = "피해 모드"

-- Profiles and welcome
L["Default"] = "기본"
L["Clean and minimal: numbers on your target in classic yellow. Every option at its default."] =
    "깔끔하고 간단하게: 대상에 클래식 노란색 숫자를 표시합니다. 모든 옵션이 기본값입니다."
L["Extended"] = "확장"
L["Spell icons and short names, school colors, abbreviated numbers, combined rapid hits, fainter cleave on other enemies, and livelier motion."] =
    "주문 아이콘과 짧은 이름, 피해 계열 색상, 축약 숫자, 빠른 적중 합치기, 다른 적에게 더 옅게 표시되는 광역 피해, 더 생동감 있는 움직임."
L["Apply the %s profile? This replaces all PlateSCT settings except the language."] =
    "%s 프로필을 적용할까요? 언어를 제외한 모든 PlateSCT 설정이 바뀝니다."
L["Profiles"] = "프로필"
L["Show welcome screen"] = "환영 화면 보기"
L["Open the first-install welcome and profile choice again."] = "처음 설치할 때의 환영 화면과 프로필 선택을 다시 엽니다."
L["A profile replaces all settings except the language. Default restores every setting; Extended adds spell icons and names, school colors, combined hits, and fainter cleave."] =
    "프로필은 언어를 제외한 모든 설정을 바꿉니다. 기본은 모든 설정을 되돌리고, 확장은 주문 아이콘과 이름, 피해 계열 색상, 적중 합치기, 더 옅은 광역 피해를 추가합니다."
L["Apply %s profile"] = "%s 프로필 적용"
L["%s profile applied. Type /psct to customize it."] = "%s 프로필을 적용했습니다. /psct를 입력해 사용자 지정하세요."
L["Welcome to PlateSCT"] = "PlateSCT에 오신 것을 환영합니다"
L["PlateSCT puts your damage numbers on enemy nameplates, so every hit shows up right where it landed."] =
    "PlateSCT는 적의 이름표에 피해 숫자를 표시해, 모든 적중이 맞은 자리에 바로 나타나게 합니다."
L["It keeps busy fights readable: rapid hits combine, small hits fade back, and crits stand out."] =
    "치열한 전투도 읽기 쉽게 유지합니다. 빠른 적중은 합쳐지고, 작은 적중은 뒤로 물러나며, 치명타는 돋보입니다."
L["It works on Midnight and on Classic clients, within each game version's combat rules."] =
    "Midnight와 클래식 클라이언트에서 각 게임 버전의 전투 규칙 안에서 작동합니다."
L["Note: Blizzard's new addon rules hide who dealt each hit, so some numbers can be credited to the wrong source or missed."] =
    "참고: 블리자드의 새 애드온 규칙으로 각 적중을 누가 냈는지 숨겨져, 일부 숫자는 잘못된 출처로 표시되거나 누락될 수 있습니다."
L["Choose a starting profile. You can change every setting later."] =
    "시작 프로필을 고르세요. 모든 설정은 나중에 바꿀 수 있습니다."
L["Open settings instead"] = "대신 설정 열기"
L["Keep the Default profile and open the settings window."] = "기본 프로필을 유지하고 설정 창을 엽니다."

L["Damage threshold"] = "피해 기준값"
L["Diagnostics"] = "진단"
L["Enable Auto-switch by instance to edit the instance profiles."] = "인스턴스 프로필을 수정하려면 '인스턴스별 자동 전환'을 켜세요."
L["Enable Filter by damage school to choose allowed schools."] = "허용할 피해 계열을 선택하려면 '피해 계열별 필터'를 켜세요."
L["Enable Show incoming hits to adjust its position."] = "위치를 조정하려면 '받는 피해 표시'를 켜세요."
L["Enable Show spell icon to choose its position."] = "아이콘 위치를 선택하려면 '주문 아이콘 표시'를 켜세요."
L["Enable crit sound to adjust its threshold and channel."] = "기준값과 소리 채널을 조정하려면 치명타 효과음을 켜세요."
L["Enable huge crit sound to adjust its threshold and channel."] = "기준값과 소리 채널을 조정하려면 큰 치명타 효과음을 켜세요."
L["Engaged nameplates"] = "교전 중인 적의 이름표"
L["Existing features"] = "기존 기능"
L["Find a setting"] = "설정 검색"
L["Fonts, colors, numbers, and spell icons."] = "글꼴, 색상, 숫자, 주문 아이콘을 설정합니다."
L["Help & Settings"] = "도움말 및 설정"
L["Hide preview"] = "미리 보기 숨기기"
L["Hit"] = "일반 적중"
L["Instance profiles"] = "인스턴스 프로필"
L["Meter probe requires Modern API - Midnight & Forever."] = "피해량 측정기 점검에는 모던 API - Midnight 및 Forever가 필요합니다."
L["Midnight & Forever damage modes and attribution."] = "Midnight 및 Forever의 피해 모드와 피해 출처 추정을 설정합니다."
L["Miss"] = "빗나감"
L["Mixed"] = "혼합"
L["Modern API"] = "모던 API"
L["Modern API options now have their own page. Damage mode combines Only my damage and All engaged nameplates without changing saved preferences."] =
    "모던 API 옵션이 별도 페이지로 이동했습니다. 피해 모드는 '내가 준 피해만 표시'와 '교전 중인 모든 적의 이름표' 옵션을 하나로 통합하며, 저장된 설정은 바뀌지 않습니다."
L["Modern API - Midnight & Forever"] = "모던 API - Midnight 및 Forever"
L["Modern API: unreadable damage amounts cannot trigger threshold sounds."] = "모던 API: 읽을 수 없는 피해량은 기준값에 따른 효과음을 재생할 수 없습니다."
L["Modern clients restrict combat information. Personal mode estimates ownership; all-source modes display target or engaged-nameplate damage."] =
    "모던 API 클라이언트는 전투 정보 접근을 제한합니다. 개인 피해 모드는 피해 출처를 추정하며, 모든 출처 모드는 현재 대상이나 교전 중인 적의 이름표에 피해를 표시합니다."
L["Modern number style"] = "모던 숫자 스타일"
L["Modern number style motion"] = "모던 숫자 스타일 움직임"
L["Modern scrolls up from the nameplate with a small crit pop. Classic keeps the grow-and-settle pow, packed close to the plate."] =
    "모던 스타일은 이름표에서 위로 올라가며, 치명타일 때 살짝 확대됩니다. 클래식 스타일은 커졌다가 줄어드는 효과를 유지하며 이름표 가까이에 모여 표시됩니다."
L["No matching settings"] = "일치하는 설정 없음"
L["Number formatting"] = "숫자 형식"
L["Number style, timing, and movement."] = "숫자 스타일, 표시 시간, 움직임을 설정합니다."
L["Outgoing healing, incoming damage, font selection, scroll speed, school colors, spell icons, and critical-hit sounds remain available."] =
    "다른 대상에게 한 치유, 받는 피해, 글꼴 선택, 스크롤 속도, 피해 계열 색상, 주문 아이콘, 치명타 효과음은 계속 사용할 수 있습니다."
L["Personal matches recent casts. Current target and Engaged nameplates show damage from all sources."] =
    "개인 피해 모드는 최근 시전과 피해를 연결합니다. 현재 대상과 교전 중인 적의 이름표 모드는 모든 출처의 피해를 표시합니다."
L["Personal - experimental"] = "개인 피해 - 실험 기능"
L["Personal - experimental: best-effort matching by destination and timing. Other players' hits on the same target can appear."] =
    "개인 피해 - 실험 기능: 피격 대상과 발생 시간을 기준으로 최대한 피해 출처를 추정합니다. 같은 대상을 공격한 다른 플레이어의 피해가 표시될 수 있습니다."
L["Pet matching and spell icons require Personal mode. Choose their appearance and visibility under Combat and Appearance."] =
    "소환수 피해 연결과 주문 아이콘에는 개인 피해 모드가 필요합니다. 표시 여부와 외형은 전투 및 외형에서 설정합니다."
L["Place the spell icon beside, above, or below the number."] = "주문 아이콘을 숫자 옆, 위 또는 아래에 표시합니다."
L["PlateSCT needs enemy nameplates. Press V (default) or enable them in the game's nameplate settings."] =
    "PlateSCT에는 적 이름표가 필요합니다. V 키(기본값)를 누르거나 게임의 이름표 설정에서 켜세요."
L["Play crit sound"] = "치명타 효과음 재생"
L["Play huge crit sound"] = "큰 치명타 효과음 재생"
L["Preferences"] = "환경 설정"
L["Preferences, API information, and diagnostics."] = "환경 설정, API 정보, 진단을 확인합니다."
L["Preview scale: %d%%"] = "미리 보기 배율: %d%%"
L["Profiles affect Personal mode. They cannot prove who dealt a hit on Modern API."] = "프로필은 개인 피해 모드에 적용됩니다. 모던 API에서는 누가 피해를 주었는지 확인할 수 없습니다."
L["Replay"] = "다시 재생"
L["Schools"] = "피해 계열"
L["Settings redesign"] = "설정 창 개편"
L["Settings window"] = "설정 창"
L["Show damage you take near your character. Independent of the outgoing damage mode."] = "내가 받는 피해를 캐릭터 주변에 표시합니다. 내가 주는 피해의 표시 모드와 별도로 작동합니다."
L["Show preview"] = "미리 보기 표시"
L["Show sample hits, crits, and misses in the bottom preview drawer."] = "하단 미리 보기 영역에 일반 적중, 치명타, 빗나감 예시를 표시합니다."
L["Show sample hits, crits, and misses inside this window."] = "이 창 안에 일반 적중, 치명타, 빗나감 예시를 표시합니다."
L["Sounds"] = "효과음"
L["Spell icons"] = "주문 아이콘"
L["Spell icons use matched casts in Personal mode; Modern API cannot identify a spell for every hit."] =
    "개인 피해 모드에서는 연결된 시전의 주문 아이콘을 사용합니다. 모던 API는 모든 피해에 해당하는 주문을 식별할 수 없습니다."
L["Spell icons use the spell from the combat log."] = "주문 아이콘은 전투 기록의 주문 정보를 사용합니다."
L["Text size"] = "글자 크기"
L["The compact bottom preview includes Mixed, Hit, Crit, and Miss samples. Both number styles remain available on every API."] =
    "하단의 작은 미리 보기에는 혼합, 일반 적중, 치명타, 빗나감 예시가 표시됩니다. 두 숫자 스타일은 모든 API에서 사용할 수 있습니다."
L["The preview shows appearance only. It does not prove attribution or simulate damage filtering."] = "미리 보기는 외형만 보여 줍니다. 피해 출처 추정을 검증하거나 피해 필터를 시뮬레이션하지 않습니다."
L["This client does not expose the damage meter API. A snapshot can still report which fields are unavailable."] =
    "이 클라이언트에는 피해량 측정기 API가 없습니다. 스냅샷으로 어떤 필드를 사용할 수 없는지 확인할 수 있습니다."
L["Timing and movement"] = "시간 및 움직임"
L["Training dummy"] = "훈련용 허수아비"
L["Turn off Auto-switch by instance to choose manual strictness."] = "엄격도를 직접 선택하려면 '인스턴스별 자동 전환'을 끄세요."
L["Unreadable amounts cannot trigger threshold sounds. Unreadable damage schools are always allowed by the school filter."] =
    "읽을 수 없는 피해량은 기준값에 따른 효과음을 재생할 수 없습니다. 계열을 읽을 수 없는 피해는 계열 필터에서 항상 허용합니다."
L["Unsupported client - combat text unavailable"] = "지원되지 않는 클라이언트 - 전투 메시지 사용 불가"
L["Use gentle fades and row reveals in this settings window. Combat animation is unaffected."] = "설정 창에 부드러운 페이드와 항목 표시 애니메이션을 사용합니다. 전투 애니메이션에는 영향을 주지 않습니다."
L["Your WoW API"] = "내 WoW API"

-- Translation feedback
L["This translation was generated with AI. If you find inconsistent terminology or incorrect wording, please report it through GitHub Issues. Thank you for your help! Translation contributors will be credited."] =
    "이 번역은 AI로 생성되었습니다. 용어가 일관되지 않거나 표현이 부정확한 부분을 발견하면 GitHub Issues에 알려 주세요. 도와주셔서 감사합니다! 번역에 기여하신 분의 이름을 명시해 감사의 뜻을 전하겠습니다."

-- What's new: combine hits
L["Rapid hits on the same nameplate can merge into one growing number with a hit count. Turn it on under Combat → Combine hits."] =
    "같은 이름표에 빠르게 들어온 적중을 하나의 증가하는 숫자와 적중 횟수로 합칠 수 있습니다. 전투 → 적중 합치기에서 켜세요."

-- Reduce clutter
L["Reduce clutter"] = "화면 정리"

-- Combine hits: merge pop
L["Pop on each merge"] = "합칠 때마다 튀어나오기"
L["Briefly enlarge the number every time another hit merges into it. Turn off for a calmer display."] =
    "다른 적중이 합쳐질 때마다 숫자를 잠깐 키웁니다. 더 차분하게 보려면 끄세요."
