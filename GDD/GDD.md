# PLANTS RESCUE

Game Design Document

Gry Komputerowe — Projekt, środa 9:15

## Spis treści

- [1. Informacje ogólne](#1-informacje-ogólne)
  - [1.1. Tytuł](#11-tytuł)
  - [1.2. Gatunek](#12-gatunek)
  - [1.3. Odbiorcy](#13-odbiorcy)
  - [1.4. Platforma i wymagania sprzętowe](#14-platforma-i-wymagania-sprzętowe)
  - [1.5. Monetyzacja (model biznesowy)](#15-monetyzacja)
- [2. Tematyka i osadzenie gry](#2-tematyka-i-osadzenie-gry)
  - [2.1. Lokacje — poziomy (pokoje)](#21-lokacje--poziomy-pokoje)
  - [2.2. Fabuła](#22-fabuła)
    - [2.2.1. Wprowadzenie](#221-wprowadzenie)
    - [2.2.2. Główne wątki fabularne](#222-główne-wątki-fabularne)
  - [2.3. Postaci](#23-postaci)
    - [2.3.1. Bohater — Student](#231-bohater--student)
    - [2.3.2. Rośliny przyjazne (do podlania)](#232-rośliny-przyjazne-do-podlania)
    - [2.3.3. Zmutowane potwory (przeciwnicy)](#233-zmutowane-potwory-przeciwnicy)
    - [2.3.4. Inteligencja NPC (AI przeciwników)](#234-inteligencja-npc-ai-przeciwników)
- [3. Rozgrywka i mechaniki](#3-rozgrywka-i-mechaniki)
  - [3.1. Cele i wyzwania](#31-cele-i-wyzwania)
    - [Cel główny każdego poziomu](#cel-główny-każdego-poziomu)
    - [Mechanika paska nawodnienia](#mechanika-paska-nawodnienia)
    - [System uzbrojenia](#system-uzbrojenia)
  - [3.2. Interakcja i kontrolery](#32-interakcja-i-kontrolery)
- [4. Przebieg gry](#4-przebieg-gry)
  - [4.1. Ekran tytułowy](#41-ekran-tytułowy)
  - [4.2. Intro — list](#42-intro--list)
  - [4.3. Menu, HUD i ekrany pośrednie](#43-menu-hud-i-ekrany-pośrednie)
    - [Menu startowe](#menu-startowe)
    - [HUD (Head-Up Display)](#hud-head-up-display)
    - [Ekran Game Over](#ekran-game-over)
    - [Ekran ukończenia poziomu](#ekran-ukończenia-poziomu)
    - [System tutoriali (toasty)](#system-tutoriali-toasty)
- [5. Zakres projektu](#5-zakres-projektu)
  - [5.1. Zespół 2-osobowy — podział prac](#51-zespół-2-osobowy--podział-prac)
  - [5.2. Harmonogram prac (14 tygodni)](#52-harmonogram-prac-14-tygodni)
- [6. Assety](#6-assety)
  - [6.1. Grafika — sprity, tekstury, animacje](#61-grafika--sprity-tekstury-animacje)
    - [Stany gracza](#stany-gracza)
    - [Stany roślin](#stany-roślin)
    - [Tła i obiekty](#tła-i-obiekty)
    - [UI](#ui)
    - [Narzędzia graficzne](#narzędzia-graficzne)
  - [6.2. Audio](#62-audio)
- [7. Prototyp (Proof of Concept)](#7-prototyp-proof-of-concept)
  - [7.1. Cel prototypu](#71-cel-prototypu)
  - [7.2. Technologie i zasoby startowe](#72-technologie-i-zasoby-startowe)
  - [7.3. Kryteria sukcesu prototypu](#73-kryteria-sukcesu-prototypu)

## 1. Informacje ogólne

### 1.1. Tytuł

Plants Rescue

Podtytuł: Water or Fight

### 1.2. Gatunek

| Kategoria | Opis |
| --- | --- |
| **Gatunek główny** | 2D Top-down Action |
| **Podgatunki** | Casual |
| **Styl graficzny** | Pixel Art 2D, widok z góry |

### 1.3. Odbiorcy

- Młodzi dorośli (18–30 lat)
- Gracze casualowi szukający krótkiej, zabawnej rozrywki
- Fani pixel artu i retro estetyki

### 1.4. Platforma i wymagania sprzętowe

| Parametr | Wartość |
| --- | --- |
| **Platforma docelowa** | PC (Windows) |
| **Silnik** | Godot 4.6 |
| **Renderer** | GL Compatibility (Windows: sterownik D3D12) |
| **Min. RAM** | 4 GB |
| **Min. GPU** | Karta ze wsparciem OpenGL 3.3 / Direct3D 12 |
| **Rozdzielczość** | 1280×720 (skalowalna) |
| **Dysk** | ~200 MB na projekt i assety |
| **OS** | Windows 10+ |
| **Połączenie** | Niewymagane do rozgrywki (build lokalny) |

### 1.5. Monetyzacja

Gra ma charakter edukacyjno-zaliczeniowy — brak modelu komercyjnego.

- Dystrybucja: bezpłatna, udostępniana jako projekt uczelniany
- Brak mikrotransakcji, reklam ani DLC

## 2. Tematyka i osadzenie gry

### 2.1. Lokacje — poziomy (pokoje)

Gra osadzona jest w studenckiej kawalerce / mieszkaniu dzielonym. Każdy pokój to osobny poziom z unikalnym zestawem roślin i wyzwań.

| Poziom | Opis | Status |
| --- | --- | --- |
| **Pokój 1 — Przedpokój (Foyer)** | Tutorial. Gracz czyta list wprowadzający fabułę, poznaje sterowanie (WASD — ruch). Brak wrogów i roślin do podlania. Po prawej stronie znajdują się drzwi prowadzące do salonu — gracz musi do nich podejść i wcisnąć SPACJA/E aby je otworzyć. | ✅ Zaimplementowany |
| **Pokój 2 — Salon (Living Room)** | Główny poziom rozgrywki. 3 rośliny do podlania + 4 wrogie rośliny (EnemyPlant). Gracz uczy się strzelania wodą (PPM), przełączania na kwas (X), ataku nożyczkami (LPM) oraz target-locka (środkowy przycisk myszy). W pokoju znajdują się: lodówka (zgrzewka piwa), apteczka, zgrzewka z butelkami wody. Po wykonaniu wszystkich celów drzwi wyjściowe się odblokowują. Czas przejścia jest mierzony i wyświetlany na ekranie ukończenia. | ✅ Zaimplementowany |
| **Pokój 3 — Kuchnia (Kitchen)** | 4 rośliny + 4 wrogie rośliny + boss **Pnącze gniewu** (BossVine). Pokonanie bossa daje permanentny bonus do zasięgu nożyczek (×1.35). Na poziomie znajduje się druga lodówka, apteczka i zgrzewka z butelkami wody. | ✅ Zaimplementowany |
| **Pokój 4 — Sypialnia (Bedroom)** | 3 rośliny + 4 wrogie rośliny + Grzybek halucynek (Mushroom) jako dodatkowy przeciwnik dystansowy strzelający zarodnikami. Apteczka i zgrzewka z butelkami wody. Wąskie przejścia między łóżkiem, szafą i biurkiem. Pokonanie wszystkich wrogów odblokowuje przejście na balkon. | ✅ Zaimplementowany |
| **Pokój 5 — Pokój gamingowy (Balcony)** | Finałowy poziom. 3 rośliny + 4 wrogie rośliny + boss **Palma kokosowa** (BossPalm, 2 fazy, ataki melee/medium/dalekosiężne kokosami). Ukończenie poziomu kończy całą grę i wyświetla ekran finałowy z czasem przejścia. | ✅ Zaimplementowany |

### 2.2. Fabuła

#### 2.2.1. Wprowadzenie

Zapracowany student informatyki na pierwszym roku studiów magisterskich wraca po dwutygodniowej sesji egzaminacyjnej do swojego mieszkania. W tym czasie całkowicie zapomniał o swoich licznych roślinach doniczkowych. To, co go wita, to armia zeschniętych, rozgniewanych zielonych stworzeń, które mają dość bycia ignorowanymi.

Na parapecie leży konewka, a w szufladzie nożyczki do przycinania. Student musi przejść przez całe mieszkanie, pogodzić się z roślinami lub je pokonać, zanim jego koledzy wrócą z Wyspy Słodowej.

Fabuła jest przekazana graczowi poprzez list, który student znajduje na podłodze po wejściu do przedpokoju. List wyświetla się jako overlay na ekranie — gracz klika przycisk aby kontynuować do rozgrywki.

#### 2.2.2. Główne wątki fabularne

Przejście przez pokoje mieszkania, podlanie przyjaznych roślin i pokonanie zmutowanych potworów. Każdy pokój wymaga spełnienia określonych celów (podlanie roślin + zabicie wrogów), aby otworzyć drzwi do następnego.

### 2.3. Postaci

#### 2.3.1. Bohater — Student

| Cecha | Opis |
| --- | --- |
| **Imię** | „Student" |
| **Wygląd** | Pixel art, student w bluzie z kapturem, jeansach i klapkach z białymi skarpetkami |
| **HP startowe** | 90 (3 pikselowe serduszka po 30 HP każde); po pokonaniu Grzybka halucynek max HP rośnie do 120 (4 serca, +1 serce permanentnie) |
| **Prędkość** | 300 px/s (×1.5 przy aktywnym buffie piwa przez 10 s) |
| **Atak wręcz (nożyczki)** | 20 obrażeń, z animacją i hitboxem kierunkowym; po pokonaniu Pnącza gniewu zasięg rośnie ×1.35 (permanentnie, persystuje między poziomami) |
| **Zbiornik wody** | Pojemność: 100, koszt strzału: 10, regeneracja: napełnianie zgrzewką z butelkami wody (+25 / butelkę, max 6 butelek na zgrzewkę) z cooldownem 1 s |
| **Zbiornik kwasu** | Pojemność: 100, koszt strzału: 10, cooldown po opróżnieniu: 7 s (auto-refill do 100) |
| **Piwo (perk)** | Zbierane z lodówek (zgrzewka 6 sztuk) i podnoszone z ziemi. Aktywowane klawiszem Q — przez 10 s prędkość ruchu ×1.5. Liczba piw persystuje między poziomami. |
| **Apteczka** | Heal +30 HP po interakcji (E / SPACJA), znika po użyciu |
| **Animacje** | idle, run, attack (kierunkowe: right/up/down, flip_h dla left), dying |

#### 2.3.2. Rośliny przyjazne (do podlania)

Rośliny przyjazne (`FriendlyPlant`) — stoją nieruchomo, pasek nawodnienia widoczny nad nimi (0–100%). Rozpoczynają z wygaszonym kolorem (blade/suche). W miarę podlewania jaśnieją (każde trafienie wodą +20). Po osiągnięciu 100% roślina „rozkwita" — animacja flashu + zmiana sprite'a na kwitnącą wersję z delikatną pulsacją.

**Zachowanie pod atakiem (mechanika zepsucia w przeciwnika):**

- Nieuratowana roślina (water < 100): trafienie kwasem lub nożyczkami natychmiast przekształca ją we wrogą roślinę (`EnemyPlant`) — aby nie blokować zaliczenia celu, cel „roślin do podlania" jest zmniejszany, a licznik wrogów do pokonania rosnie o 1.
- Uratowana roślina (rozkwitnięta, water = 100): wymaga 3 trafień nożyczkami/kwasem, aby się zepsuć. Po każdym trafieniu wyświetla dialog („Nie zrobiłam ci krzywdy…", „To mnie boli, zaraz się zezłoszczę…", „Ostrzegałam!!!"), a po trzecim trafieniu (z opóźnieniem 0,6 s) przekształca się we wrogą roślinę.

#### 2.3.3. Zmutowane potwory (przeciwnicy)

W grze zaimplementowane są następujące typy przeciwników:

- **Wroga roślina (`EnemyPlant`)** — podstawowa zmutowana roślina-potwór (scena `enemy_plant.tscn`, skrypt `enemy_plant.gd`). HP: 100, prędkość: 100 px/s, obrażenia: 15 przy kontakcie (co 0,8 s). Stany: idle, pościg (chase), atak kontaktowy (spine_attack), śmierć. Reaguje na obrażenia: czerwony flash + knockback. Nad głową pasek HP. Występuje na wszystkich poziomach bojowych.
- **Grzybek halucynek (Mushroom)** — dystansowy przeciwnik strzelający zarodnikami (spore_projectile). HP: 80, prędkość: 80 px/s, obrażenia od zarodnika: 12, interwał ataku: 1,5 s, prędkość pocisku: 200 px/s. Stany: idle, walk_east/walk_south, attack, die. Występuje w Sypialni.
- **Pnącze gniewu (BossVine)** — szybki boss melee. HP: 100, prędkość: 210 px/s, obrażenia ataku slam: 18, zasięg wyzwalania ataku: 125 px, windup 0,12 s + active 0,18 s + cooldown 0,95 s. Knockback 380. Boss Kuchni. Po pokonaniu permanentny bonus: zasięg nożyczek ×1.35.
- **Grzybek halucynek — boss (BossMushroom)** — boss spowalniający gazem. HP: 100, prędkość: 70 px/s. Aura gazu spowalnia gracza do ×0,55 prędkości i zadaje 6 obrażeń co 0,75 s. Boss Sypialni. Po pokonaniu permanentny bonus: +1 serce (max HP 90 → 120).
- **Palma kokosowa (BossPalm)** — finałowy boss 2-fazowy. HP: 100, faza 2 startuje przy HP ≤ 50 (prędkość rośnie z 125 do 225 px/s, szybszy reload kokosów). Trzy ataki: melee slam (16 dmg, zasięg 85 px), medium leaf whip (12 dmg, zasięg 230 px), dystansowy kokos (CoconutProjectile, 12 dmg, cd 2,8 s → 1,2 s w fazie 2). Boss Pokoju gamingowego.

#### 2.3.4. Inteligencja NPC (AI przeciwników)

**Wroga roślina (`EnemyPlant`)** posiada trzy strefy detekcji (Area2D):

- **Sight** (strefa widzenia) — gdy gracz wejdzie w zasięg, wroga roślina zaczyna go gonić
- **AttackHitbox** (strefa ataku) — gdy gracz jest wystarczająco blisko, wroga roślina zatrzymuje się i atakuje (animacja spine_attack, 15 dmg co 0,8 s)
- Po śmierci — wyłączenie kolizji, animacja die, emisja sygnału `died`

**Grzybek halucynek (Mushroom)** — analogiczne strefy `Sight` + `AttackHitbox`, ale w stanie ataku stoi w miejscu i wystrzeliwuje pocisk-zarodnik (`spore_projectile`) lecący w stronę gracza. Animacje walk_east/walk_south z flip_h, attack, die.

**BossVine** — `Sight` + `AttackHitbox` (włączany wyłącznie podczas okna aktywnego ataku, po 0,12 s windupie). Animowane efekty: trzęsienie podczas windupu, biały flash + czerwony pierścień uderzenia.

**BossMushroom** — `Sight` (pościg) + `GasArea` (tickujące spowolnienie i obrażenia od gazu na graczu). Brak klasycznego hitboxa ataku — szkodzi tylko gazem.

**BossPalm** — `Sight` + dwa hitboxy: `MeleeHitbox` (krótki zasięg) i `MediumHitbox` (średni zasięg leaf whip). Dystansowo dynamicznie spawnuje `CoconutProjectile`. AI wybiera atak w zależności od dystansu do gracza.

Po śmierci każdy z bossów uruchamia tween znikania (`modulate:a → 0`) i emituje sygnał `died`, który `living_room.gd` przechwytuje, aby przyznać trofeum i otworzyć dialog nagrody.

## 3. Rozgrywka i mechaniki

### 3.1. Cele i wyzwania

#### Cel główny każdego poziomu

- Podlej wszystkie rośliny (woda) i pokonaj wszystkich wrogów (kwas/nożyczki) w pokoju
- Po spełnieniu obu warunków drzwi do kolejnego pokoju się odblokowują
- Czas przejścia poziomu jest mierzony i wyświetlany na ekranie ukończenia

#### Mechanika paska nawodnienia

Każda roślina przyjazna posiada pasek nawodnienia (0–100%). Gracz musi uzupełnić go do 100% strzelając wodą. Każde trafienie dodaje +20%. Roślina z pełnym paskiem zmienia wygląd (blade/suche → rozkwitnięta z efektem bloom) i zostaje zaliczona jako uratowana.

#### System uzbrojenia

Gracz dysponuje dwoma równoległymi systemami walki, dostępnymi jednocześnie (bez przełączania przedmiotów):

| Uzbrojenie | Działanie |
| --- | --- |
| **Zbiornik (woda / kwas)** | Broń dystansowa — gracz strzela PPM w kierunku kursora myszy (pocisk liniowy, prędkość 750 px/s, czas życia 1,2 s, cooldown 0,2 s). Przełączanie trybu klawiszem X. **Woda** (niebieski pocisk): służy do podlewania przyjaznych roślin (+20 na trafienie). Trafienie roślinami wodą po pełnym nawodnieniu nic nie zmienia, ale **trafienie kwasem lub nożyczkami w przyjazną roślinę psuje ją we wrogą roślinę (`EnemyPlant`)** (instant dla suchej, 3 trafienia dla rozkwitniętej). **Kwas** (zielony pocisk): zadaje 20 obrażeń wrogim potworom. Zbiornik wody (pojemność 100, koszt 10/strzał) NIE regeneruje się sam — uzupełnia się zgrzewką z butelkami wody (+25 / butelkę). Zbiornik kwasu (pojemność 100, koszt 10/strzał) po opróżnieniu wchodzi w cooldown 7 s, po czym automatycznie uzupełnia się do 100. |
| **Nożyczki** | Atak wręcz LPM z hitboxem kierunkowym — zadaje 20 obrażeń wrogim potworom (wroga roślina, Mushroom, bossy). Podczas ataku gracz jest unieruchomiony. Trafienie przyjaznej rośliny powoduje jej zepsucie (jak wyżej). Po pokonaniu Pnącza gniewu zasięg hitboxa rośnie ×1.35 (permanentnie). |

#### Target lock (auto-celowanie)

Gracz może kliknąć środkowym przyciskiem myszy na wrogu aby zablokować celownik — pociski będą leciały automatycznie w kierunku zaznaczonego celu. Ponowne kliknięcie wyłącza lock. Lock automatycznie się wyłącza, gdy cel zostanie pokonany (sygnał `died`).

#### Pickupy świata (apteczka, butelki wody, piwo)

- **Apteczka (`medkit_pickup`)** — rozmieszczona na każdym poziomie bojowym. Interakcja E/SPACJA → +30 HP (1 serce), znika po użyciu.
- **Zgrzewka z butelkami wody (`water_bottles_pack`)** — na każdym poziomie. Interakcja E/SPACJA → +25 wody, cooldown 1 s, max 6 użyć. Sprite blaknie wraz z ubywającymi butelkami.
- **Lodówka (`fridge`)** — w salonie i kuchni. Pierwsza interakcja spawnuje pickup `beer_pickup` (zgrzewka 6 piw) + okno dialogowe. Interakcja z piwem dodaje 6 sztuk do licznika gracza.
- **Piwo (Q)** — gracz aktywuje buff: prędkość ×1.5 przez 10 s. Jednorazowo można aktywować tylko jeden buff naraz (nie stackuje).
- **Persystencja:** HP, max HP, liczba piw oraz pokonane bossy przechodzą między poziomami przez singleton `GameState` (autoload).

### 3.2. Interakcja i kontrolery

| Akcja | Sterowanie |
| --- | --- |
| **Ruch** | WASD (8-kierunkowy top-down movement) |
| **Atak wręcz (nożyczki)** | LPM (lewy przycisk myszy) |
| **Strzał ze zbiornika (woda/kwas)** | PPM (prawy przycisk myszy) — ciągły ogień przy przytrzymaniu |
| **Przełącz substancję (WATER / ACID)** | X |
| **Target lock (auto-aim na przeciwnika pod kursorem)** | Środkowy przycisk myszy |
| **Interakcja (drzwi / piwo / apteczka / butelki wody / lodówka)** | E / SPACJA |
| **Aktywuj piwo (+50% prędkości na 10 s)** | Q |

## 4. Przebieg gry

### 4.1. Ekran tytułowy

Po uruchomieniu gry wyświetla się menu główne (`main_menu.tscn`):

- Tło: ciemne, pikselowe
- Centrum: animowany tytuł „PLANTS RESCUE" z pulsującą zmianą koloru (zielony ↔ żółty)
- Przyciski: PLAY, Wybór poziomu, Wyjdź z gry; migający hint „Naciśnij ENTER / SPACJA"
- Po obu stronach planszy: animowane kaktusy (lewy + prawy) w pętli walk → co kilka sekund wykonują równoczesny atak — ożywiają scenę i zapowiadają przeciwników
- Po ukończeniu pojedynczego poziomu z trybu „Wybór poziomu" — toast informujący o ukończeniu (pojawia się po powrocie do menu)

### 4.2. Intro — list

Po kliknięciu PLAY gracz trafia do Pokoju 1 (Przedpokój). Na ekranie wyświetla się overlay z listem — wprowadzenie fabularne. Gracz klika przycisk „Kontynuuj" aby zamknąć list, po czym HUD staje się widoczny i sterowanie zostaje odblokowane. Pojawiają się tutoriale (toasty) z podpowiedziami sterownia.

### 4.3. Menu, HUD i ekrany pośrednie

#### Menu startowe

- **PLAY** — uruchamia nową grę od Pokoju 1 (Przedpokój → Salon → Kuchnia → Sypialnia → Pokój gamingowy). Wywołuje `GameState.reset_run()`.
- **Wybór poziomu** — rozpoczyna grę od wybranego poziomu (Salon / Kuchnia / Sypialnia / Pokój gamingowy). Tryb single-level: po ukończeniu pojedynczego pokoju gracz wraca do menu głównego z toastem o ukończeniu.
- **Wyjdź z gry** — zamyka okno gry.

#### HUD (Head-Up Display)

- Lewy górny: ❤❤❤ — pasek HP gracza (pikselowe serca rysowane programowo, każde = 30 HP, częściowe wypełnienie kolumnowe; liczba serc zmienia się dynamicznie: 3 startowo, 4 po pokonaniu Grzybka halucynek)
- Prawy górny: panel zbiornika:
  - 💧 **WODA** — niebieski pasek (ProgressBar) + wartość liczbowa „X / 100" + tag `[AKTYWNA]` gdy woda jest aktywnym trybem
  - 🧪 **KWAS** — zielony pasek (ProgressBar) + status cooldown (`Gotowy` / licznik czasu do odnowienia np. `5.2s`)
  - Wizualne wyciszanie nieaktywnego trybu (zmiana koloru tytułu na brązowy)
- Panel piwa: liczba posiadanych piw + ikona kufla; podczas aktywnego buffu — licznik pozostałego czasu (s)
- Panel trofeów bossów: 3 sloty (Pnącze / Grzybek / Palma). Sloty wygaszone do momentu pokonania bossa, po pokonaniu — kolorowy sprite trofeum + krótki opis bonusu.
- Nad obiektami w świecie:
  - wrogowie: pasek HP (czerwony, zmniejsza się proporcjonalnie)
  - przyjazne rośliny: pasek nawodnienia (niebieski, rośnie z podlewaniem)
  - przyjazne rośliny po ataku: chmurka dialogowa z reakcją
- Cele poziomu: etykiety „Rośliny podlane: X / N" i „Wrogowie pokonani: X / M" (N i M ustalane dynamicznie z liczby dzieci węzłów `Plants` / `Enemies`, korygowane gdy roślina przejdzie w przeciwnika)

#### Ekran Game Over

Wyświetlany po śmierci gracza (HP = 0) z opóźnieniem 1,2 s. Przyciski:

- **Spróbuj ponownie** — restart aktualnego pokoju ze stanem zapisanym na początku poziomu (HP, max HP, woda, kwas, piwa) poprzez `GameState.restore_level_start_stats()`
- **Wróć do menu** — powrót do menu głównego (resetuje run przez `GameState.reset_run()`)

#### Ekran ukończenia poziomu

Wyświetlany po spełnieniu wszystkich celów i przejściu przez drzwi wyjściowe **ostatniego poziomu (Pokój gamingowy)**. Pokazuje całkowity czas przejścia (format MM:SS). Przycisk:

- **Menu** — powrót do menu głównego

Pomiędzy poziomami zamiast ekranu — bezpośrednie przejście do kolejnej sceny (`next_scene_path`). W trybie wyboru poziomu po ukończeniu jednego pokoju gra wraca do menu z toastem („Ukończono poziom: NAZWA").

#### Dialog nagrody za bossa

Po pokonaniu bossa (Pnącze, Grzybek, Palma) wyświetla się dialog overlay z tytułem („TROFEUM!") i opisem zdobytego bonusu. Gracz jest tymczasowo unieruchomiony do zamknięcia dialogu. Bonusy są permanentne i persystują przez `GameState`:

- **Pnącze gniewu** → większy zasięg nożyczek (×1.35)
- **Grzybek halucynek** → +1 serce (max HP +30)
- **Palma kokosowa** → trofeum (zakończenie gry)

#### System tutoriali (toasty)

Komunikaty pojawiające się jako animowane panele (fade-in → wyświetlanie → fade-out). Kolejkowane — wyświetlają się jeden po drugim. Przykłady:

- Przedpokój: „WASD — ruch", „Znajdź drzwi po prawej i wciśnij SPACJA lub E aby je otworzyć"
- Salon (pierwsze podejście, sterowane flagą `show_onboarding_tutorials`): „LPM — strzelaj wodą / Podlej rośliny aby je uratować", „X — przełącz między wodą a kwasem / Kwas rani wrogów", „Prawy przycisk myszy — auto-celowanie w wroga pod kursorem", „Uratuj wszystkie N rośliny i pokonaj M zmutowane potwory"
- Po spełnieniu wszystkich celów: „Wszystko uratowane! Drzwi po prawej są otwarte — ucieknij stąd"
- Kolejne pokoje (Kuchnia, Sypialnia, Pokój gamingowy) — onboarding wyłączony, gracz korzysta z poznanej mechaniki

## 5. Zakres projektu

### 5.1. Zespół 2-osobowy — podział prac

- **Mateusz Gawłowski** — mechaniki, integracja assetów, implementacja UI/HUD
- **Wojciech Tobolski** — pixel art, projektowanie poziomów, audio, balans rozgrywki

### 5.2. Harmonogram prac (14 tygodni)

| Tydz. | Data | Zakres prac |
| --- | --- | --- |
| 1 | Tyg. 1 (02–08.03) | Kickoff: założenia projektu, setup repozytorium Git, konfiguracja projektu w Godot, szkic GDD |
| 2 | Tyg. 2 (09–15.03) | Podstawa gry: ruch gracza (WSAD), animacje kierunkowe, scena główna, kolizje |
| 3 | Tyg. 3 (16–22.03) | Walka wręcz: atak nożyczkami, hitbox gracza kierunkowy, obrażenia i pasek HP przeciwnika |
| 4 | Tyg. 4 (23–29.03) | Strzelanie: pociski liniowe, tryby WATER/ACID, cooldown strzału, przełączanie trybu (X), target lock (PPM) |
| 5 | Tyg. 5 (30.03–05.04) | Zasoby i HUD: pasek wody, pasek kwasu z cooldown/timerem, wskaźnik aktywnej substancji, pikselowe serduszka HP |
| 6 | Tyg. 6 (06–12.04) | HP gracza i AI: 3 serca (90 HP), animacja śmierci gracza, wroga roślina (EnemyPlant) z AI (pościg + atak 15 dmg + knockback), przyjazna roślina z podlewaniem 0–100% i efektem bloom |
| 7 | Tyg. 7 (13–19.04) | Room/Level Manager: system drzwi (lock/unlock/open), warunki ukończenia pokoju (podlanie + zabicie), przejścia między scenami, ekran ukończenia z czasem, system Game Over |
| 8 | Tyg. 8 (20–26.04) | Menu główne: ekran tytułowy z animowanym kaktusem, intro (letter overlay), system tutoriali (toasty), regeneracja zbiorników (auto-refill wody po opróżnieniu, cooldown kwasu) |
| 9 | Tyg. 9 (27.04–03.05) | Projektowanie Pokoju 1 (Przedpokój — tutorial) i Pokoju 2 (Salon — pełna rozgrywka), layout, rozmieszczenie roślin i wrogów, playtest |
| 10 | Tyg. 10 (04–10.05) | Nowy typ przeciwnika: Grzybek halucynek (Mushroom) z dystansowym atakiem zarodników, balans obrażeń i prędkości, dodatkowe assety pixel art |
| 11 | Tyg. 11 (11–17.05) | Projektowanie poziomów 3–4 (Kuchnia, Sypialnia): layout, meble, przeszkody, rozmieszczenie wrogów/roślin, playtest i poprawki kolizji |
| 12 | Tyg. 12 (18–24.05) | Bossy: Pnącze gniewu (Kuchnia), Grzybek halucynek (Sypialnia), Palma kokosowa 2-fazowa (Pokój gamingowy) + kokosy. System nagród za bossów (zasięg nożyczek, +1 serce, trofeum) i `GameState` jako singleton persystujący stan |
| 13 | Tyg. 13 (25–31.05) | Pickupy świata: apteczka (+30 HP), zgrzewka z butelkami wody (+25/użycie), lodówka + piwo (Q, buff prędkości); UI panelu piw i trofeów; dialog nagrody za bossa; tryb wyboru pojedynczego poziomu |
| 14 | Tyg. 14 (01–07.06) | Finalizacja: redesign map pokoi, sprite'y bossów, mechanika zepsucia roślin w przeciwników, playtest balansu, optymalizacja, build release, dokumentacja końcowa (GDD v4.0) |

## 6. Assety

Wszystkie assety graficzne projektu znajdują się w folderze [game/assets/images/](../game/assets/images/), pogrupowane tematycznie. Poniżej zestawienie wraz z podglądami.

### 6.1. Grafika — sprity, tekstury, animacje

#### Stany gracza

- Student idle (kierunkowy: right/up/down + flip_h dla left)
- Student run (kierunkowy)
- Student attack (kierunkowy — nożyczki)
- Student dying

Spritesheet gracza: [Player.png](../game/assets/images/player/Player.png)

![Player](../game/assets/images/player/Player.png)

#### Stany roślin

- Rośliny przyjazne (`friendly_plant`): stan suchy/blade (modulate wygaszony, kolor 0.82/0.86/0.70) → podlewana (stopniowe rozjaśnianie do 1.1/1.2/1.0) → rozkwitnięta (osobny sprite `BloomedSprite` z pulsacją 1.48 ↔ 1.55)
- Roślina zepsuta w wroga: animacja flashu + spawn `EnemyPlant` na pozycji rośliny (skala ×2)
- Doniczka rozbita — dekoracja terenu po zepsuciu rośliny

| Sucha / podlewana | Rozkwitnięta | Rozbita doniczka |
| --- | --- | --- |
| ![plant_friendly](../game/assets/images/plant_friendly.png) | ![plant_bloomed](../game/assets/images/plant_bloomed.png) | ![broken_pot](../game/assets/images/broken_pot.png) |

#### Wrogowie i bossy

- **Wroga roślina (`EnemyPlant`)** — podstawowy przeciwnik, animacje idle / chase / spine_attack / die
- **Grzybek halucynek (Mushroom)** — dystansowy, animacje walk_east / walk_south / attack / die
- **Pnącze gniewu (BossVine)** — boss melee (Kuchnia)
- **Grzybek halucynek — boss (BossMushroom)** — boss z aurą gazu (Sypialnia)
- **Palma kokosowa (BossPalm)** — boss 2-fazowy z atakiem dystansowym kokosami (Pokój gamingowy)
- **Kaktus (Cactus)** — animowana dekoracja w menu głównym (walk + attack)
- **Mutant pumpkin** — przeciwnik rezerwowy, na razie nieużywany w rozgrywce
- **Kokos** — pocisk dalekosiężny bossa Palmy

| BossPalm (Palma) | Pumpkin mutant | Cactus (menu) | Mushroom |
| --- | --- | --- | --- |
| ![palm_boss](../game/assets/images/enemies/palm_boss.png) | ![pumpkin_mutant](../game/assets/images/enemies/pumpkin_mutant.png) | ![Cactus](../game/assets/images/enemies/Cactus.png) | ![mushroom_hallu](../game/assets/images/enemies/mushroom_hallu.png) |

Pocisk bossa Palmy:

![coconut](../game/assets/images/coconut.png)

#### Pickupy świata

- **Apteczka** — +30 HP (1 serce)
- **Zgrzewka z butelkami wody** — +25 wody na butelkę, max 6 użyć
- **Piwo (kufel)** — aktywuje buff prędkości ×1.5 na 10 s (Q)
- **Kokos (pickup)** — wariant graficzny do efektów świata

| Apteczka | Butelki wody | Piwo (kufel) | Kokos |
| --- | --- | --- | --- |
| ![medkit](../game/assets/images/pickups/medkit.png) | ![water_bottles](../game/assets/images/pickups/water_bottles.png) | ![beer_mug](../game/assets/images/pickups/beer_mug.png) | ![coconut](../game/assets/images/pickups/coconut.png) |

#### Tła i obiekty

- **Pokój 1 — Przedpokój**: proste tło z drzwiami po prawej, scroll/list na podłodze (`scroll.png`)
- **Pokój 2 — Salon**: kafle podłogowe, kanapa, regał na książki, dywan, telewizor, stolik kawowy, stół jadalny, lodówka, papiery
- **Pokój 3 — Kuchnia**: kafle podłogowe, blat kuchenny (counter + counter_L), kuchenka, stół (prostokątny i okrągły), lodówka kuchenna
- **Pokój 4 — Sypialnia**: łóżko, szafa, biurko, szafka nocna, regał, dywan
- **Pokój 5 — Pokój gamingowy / Balkon**: balustrada (`balcony_railing` / `balcony_railing_new`), ławka, donica (`balcony_planter`)
- Meble jako niezależne obiekty `StaticBody2D` z kolizjami

##### Współdzielone

| Drzwi | Podłoga (kafle) | Papiery | List (scroll) |
| --- | --- | --- | --- |
| ![door](../game/assets/images/door.png) | ![floor_tiles](../game/assets/images/floor_tiles.png) | ![papers](../game/assets/images/papers.png) | ![scroll](../game/assets/images/scroll.png) |

##### Meble — Salon

Folder: [furniture/](../game/assets/images/furniture/)

| Kanapa | Stolik kawowy | Stół jadalny | TV cabinet |
| --- | --- | --- | --- |
| ![living_room_couch](../game/assets/images/furniture/living_room_couch.png) | ![living_room_coffee_table](../game/assets/images/furniture/living_room_coffee_table.png) | ![living_room_dining_table](../game/assets/images/furniture/living_room_dining_table.png) | ![living_room_tv_cabinet](../game/assets/images/furniture/living_room_tv_cabinet.png) |

| Regał | Dywan | Lodówka |
| --- | --- | --- |
| ![living_room_bookshelf](../game/assets/images/furniture/living_room_bookshelf.png) | ![living_room_rug](../game/assets/images/furniture/living_room_rug.png) | ![fridge](../game/assets/images/furniture/fridge.png) |

##### Meble — Kuchnia

Folder: [furniture/kitchen/](../game/assets/images/furniture/kitchen/)

| Blat | Blat narożny (L) | Kuchenka | Lodówka kuchenna |
| --- | --- | --- | --- |
| ![kitchen_counter](../game/assets/images/furniture/kitchen_counter.png) | ![kitchen_counter_L](../game/assets/images/furniture/kitchen_counter_L.png) | ![kitchen_stove](../game/assets/images/furniture/kitchen_stove.png) | ![kitchen_fridge](../game/assets/images/furniture/kitchen_fridge.png) |

| Stół (prostokątny) | Stół (okrągły) |
| --- | --- |
| ![kitchen_table](../game/assets/images/furniture/kitchen_table.png) | ![kitchen_table_round](../game/assets/images/furniture/kitchen_table_round.png) |

##### Meble — Sypialnia

Folder: [furniture/bedroom/](../game/assets/images/furniture/bedroom/)

| Łóżko | Szafa | Biurko | Szafka nocna |
| --- | --- | --- | --- |
| ![bedroom_bed](../game/assets/images/furniture/bedroom_bed.png) | ![bedroom_wardrobe](../game/assets/images/furniture/bedroom_wardrobe.png) | ![bedroom_desk](../game/assets/images/furniture/bedroom_desk.png) | ![bedroom_nightstand](../game/assets/images/furniture/bedroom_nightstand.png) |

##### Meble — Balkon / Pokój gamingowy

Folder: [furniture/balcony/](../game/assets/images/furniture/balcony/)

| Ławka | Donica | Balustrada | Balustrada (nowa) |
| --- | --- | --- | --- |
| ![balcony_bench](../game/assets/images/furniture/balcony_bench.png) | ![balcony_planter](../game/assets/images/furniture/balcony_planter.png) | ![balcony_railing](../game/assets/images/furniture/balcony_railing.png) | ![balcony_railing_new](../game/assets/images/furniture/balcony_railing_new.png) |

##### Tilesety pomieszczeń

Folder: [tilesets/](../game/assets/images/tilesets/)

Wygenerowane spójne tilesety do dekoracji podłóg i ścian z metadanymi w plikach JSON.

| Salon | Kuchnia |
| --- | --- |
| ![living_room_image](../game/assets/images/tilesets/living_room_image.png) | ![kitchen_image](../game/assets/images/tilesets/kitchen_image.png) |

#### UI

- Serduszka HP — rysowane programowo (pixel art grid 7×6, kolor wypełniony/pusty, skalowane ×6, liczba serc dynamiczna: 3 lub 4)
- Paski zbiornika (ProgressBar z kolorami: niebieski/woda, zielony/kwas)
- Paski HP wrogów i nawodnienia roślin (region-based Sprite2D) — tekstury `LifeBarMini*`
- Panel piw + ikona kufla, licznik buffu piwa
- Panel trofeów bossów (3 sloty: vine / mushroom / palm) — wygaszone / aktywne sprite'y wrogów reużyte jako ikony trofeów
- Dialog nagrody za bossa (`boss_reward_dialog`) — overlay z tytułem + opisem bonusu + przyciskiem zamknięcia
- Pixel font: „PixelifySans" + „Press Start 2P" (Google Fonts, open license)

| Pasek HP — wypełnienie | Pasek HP — tło |
| --- | --- |
| ![LifeBarMiniProgress](../game/assets/images/UI/LifeBarMiniProgress.png) | ![LifeBarMiniUnder](../game/assets/images/UI/LifeBarMiniUnder.png) |

#### Narzędzia graficzne

- Aseprite (pixel art i animacje sprite'ów)
- Photoshop (kompozycje, UI)
- Godot SpriteFrames Editor (konfiguracja animacji)
- Skrypt pomocniczy [pixellab_tileset_converter.gd](../game/pixellab_tileset_converter.gd) do konwersji tilesetów wygenerowanych przez PixelLab

### 6.2. Audio

| Kategoria | Opis |
| --- | --- |
| **SFX — Efekty dźwiękowe** | Zaimplementowane: zamach nożyczkami (whoosh.mp3), trafienie wroga (hit_enemy.mp3). Planowane: wystrzał wody (splash), trafienie wodą w roślinę, wystrzał kwasu (hiss), Game Over (smutna melodia 8-bit), feedback od pickupów (medkit, butelka wody, piwo), specjalne SFX dla bossów. |
| **BGM — Muzyka tła** | Planowane: 2–3 tracki (menu — mellow lo-fi, rozgrywka — upbeat chiptune, boss fight — bardziej intensywny chiptune). Źródła: OpenGameArt.org, FreeMusicArchive (CC0/CC-BY). |
| **Narracja / dialogi** | Brak voice actingu. Fabuła przekazana poprzez list (overlay) i tutoriale (toasty tekstowe). |
| **Narzędzia audio** | Godot AudioStreamPlayer2D, BFXR / ChipTone (generowanie SFX), Audacity (edycja). |

## 7. Prototyp (Proof of Concept)

### 7.1. Cel prototypu

Celem prototypu jest weryfikacja głównych mechanik gry w środowisku Godot 4.6: ruch, strzelanie, walka wręcz, system podlewania roślin, AI przeciwników, system drzwi/pokojów i HUD. Prototyp używa docelowych assetów pixel art.

### 7.2. Technologie i zasoby startowe

| Kategoria | Wartość |
| --- | --- |
| **Silnik** | Godot 4.6 |
| **Język** | GDScript |
| **Kontrola wersji** | Git + GitHub |
| **Edytor** | Godot Editor + Visual Studio Code / Cursor |

### 7.3. Kryteria sukcesu prototypu

- ✅ Gracz porusza się płynnie (8 kierunków, 300 px/s), bez przechodzenia przez ściany
- ✅ Zbiornik wystrzeliwuje wodę/kwas (pociski liniowe 750 px/s), z przełączaniem trybu (X)
- ✅ Woda zwiększa pasek nawodnienia rośliny przy trafieniu (+20); kwas zadaje 20 obrażeń wrogowi
- ✅ Nożyczki zadają 20 obrażeń wrogiemu obiektowi (hitbox kierunkowy)
- ✅ Drzwi otwierają się po obsłużeniu wszystkich roślin i pokonaniu wrogów w scenie
- ✅ HP gracza (startowo 90, 3 serca; +1 serce po Grzybku), system obrażeń od wrogów, animacja śmierci, ekran Game Over
- ✅ AI wrogiej rośliny (`EnemyPlant`): pościg, atak kontaktowy, knockback, śmierć
- ✅ Dodatkowy typ przeciwnika: Grzybek halucynek (Mushroom) — dystansowy, strzela zarodnikami
- ✅ HUD: dynamiczne serduszka, panele zbiorników (woda + kwas z cooldown), panel piwa, cele poziomu, trofea bossów
- ✅ Menu główne, ekran wyboru poziomu, intro (letter overlay), system tutoriali (toasty)
- ✅ Przejścia między scenami (Przedpokój → Salon → Kuchnia → Sypialnia → Pokój gamingowy), ekran ukończenia z czasem
- ✅ Wszystkie 5 pokoi zaimplementowane z layoutem, meblami i kolizjami
- ✅ 3 bossów z różnymi mechanikami (Pnącze gniewu — melee slam, Grzybek halucynek — gas slow, Palma kokosowa — 2 fazy + kokosy)
- ✅ Permanentne nagrody za bossów (zasięg nożyczek, +1 serce, trofeum)
- ✅ Pickupy świata: apteczka (+30 HP), zgrzewka z butelkami wody (+25 wody / butelkę), piwo (×1.5 prędkości na 10 s)
- ✅ Lodówka jako źródło piwa (zgrzewka 6 sztuk + dialog)
- ✅ Persystencja stanu między poziomami (singleton `GameState`: HP, max HP, piwa, pokonane bossy)
- ✅ Mechanika zepsucia przyjaznej rośliny w wroga po ataku kwasem/nożyczkami
- ✅ Tryb wyboru pojedynczego poziomu (single-level mode) z toastem po ukończeniu
- 🔲 Muzyka tła (BGM)
- 🔲 Dodatkowe efekty dźwiękowe (SFX dla pickupów, bossów, pocisków)

Plants Rescue — GDD v4.0
