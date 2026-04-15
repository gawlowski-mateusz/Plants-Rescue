# PLANTS RESCUE

Game Design Document

Gry Komputerowe — Projekt, środa 9:15

## Spis treści

- [1. Informacje ogólne](#1-informacje-ogólne)
  - [1.1. Tytuł](#11-tytuł)
  - [1.2. Gatunek](#12-gatunek)
  - [1.3. Odbiorcy](#13-odbiorcy)
  - [1.4. Platforma i wymagania sprzętowe](#14-platforma-i-wymagania-sprzętowe)
  - [1.5. Monetyzacja (model biznesowy)](#15-monetyzacja-model-biznesowy)
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

**Plants Rescue**

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
| **Pokój 2 — Salon (Living Room)** | Główny poziom rozgrywki. 3 rośliny do podlania + 4 zmutowane potwory (Slime). Gracz uczy się strzelania wodą (LPM), przełączania na kwas (X), ataku nożyczkami oraz target-locka (PPM). Po wykonaniu wszystkich celów drzwi wyjściowe się odblokowują. Czas przejścia jest mierzony i wyświetlany na ekranie ukończenia. | ✅ Zaimplementowany |
| **Pokój 3 — Kuchnia** | Kwiaty na parapecie + fermentujące warzywa jako wrogowie. Wyższy poziom trudności. | 🔲 Planowany |
| **Pokój 4 — Sypialnia** | Więcej wrogów, wąskie przejścia między meblami. Wyższy poziom trudności. | 🔲 Planowany |
| **Pokój 5 — Balkon** | Boss końcowy. Finałowa walka i zakończenie gry. | 🔲 Planowany |

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
| **HP** | 90 (wyświetlane jako 3 pikselowe serduszka po 30 HP każde) |
| **Prędkość** | 300 px/s |
| **Atak wręcz (nożyczki)** | 20 obrażeń, z animacją i hitboxem kierunkowym |
| **Zbiornik wody** | Pojemność: 100, koszt strzału: 10, regeneracja: 18/s po 2,5 s bez obrażeń (tylko gdy opróżniony) |
| **Zbiornik kwasu** | Pojemność: 100, koszt strzału: 10, cooldown po opróżnieniu: 7 s (auto-refill do 100) |
| **Animacje** | idle, run, attack (kierunkowe: right/up/down, flip_h dla left), dying |

#### 2.3.2. Rośliny przyjazne (do podlania)

Rośliny przyjazne (`FriendlyPlant`) — stoją nieruchomo, pasek nawodnienia widoczny nad nimi (0–100%). Rozpoczynają z wygaszonym kolorem (blade/suche). W miarę podlewania jaśnieją. Po osiągnięciu 100% roślina „rozkwita" — animacja flashu + zmiana sprite'a na kwitnącą wersję z delikatną pulsacją.

#### 2.3.3. Zmutowane potwory (przeciwnicy)

Aktualnie w grze zaimplementowany jest jeden typ przeciwnika:

- **Slime (Śluz)** — zmutowana roślina-potwór. HP: 100, prędkość: 100 px/s, obrażenia: 15 przy kontakcie (co 0,8 s). Posiada stany: idle, pościg (chase), atak kontaktowy (spine_attack), śmierć. Reaguje na obrażenia: czerwony flash + knockback. Nad głową wyświetla pasek HP.

Planowani przeciwnicy (nie zaimplementowani):
- Pnącze gniewu — szybkie, atakuje z dystansu
- Grzybek halucynek — spowalniający gaz
- Palma kokosowa — boss końcowy (fazy)

#### 2.3.4. Inteligencja NPC (AI przeciwników)

Slime posiada trzy strefy detekcji:
- **Sight** (strefa widzenia) — gdy gracz wejdzie w zasięg, Slime zaczyna go gonić
- **AttackHitbox** (strefa ataku) — gdy gracz jest wystarczająco blisko, Slime zatrzymuje się i atakuje (animacja spine_attack, 15 dmg co 0,8 s)
- Po śmierci — wyłączenie kolizji, animacja die, emisja sygnału `died`

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
| **Zbiornik (woda / kwas)** | Broń dystansowa — gracz strzela w kierunku kursora myszy (pocisk liniowy, prędkość 750 px/s, czas życia 1,2 s). Przełączanie trybu klawiszem X. **Woda** (niebieski pocisk): służy wyłącznie do podlewania przyjaznych roślin (+20% na trafienie). **Kwas** (zielony pocisk): zadaje 20 obrażeń wrogim potworom. Zbiornik wody (pojemność 100, koszt 10/strzał) regeneruje się automatycznie po 2,5 s bez obrażeń — tylko gdy zostanie całkowicie opróżniony (18 jednostek/s). Zbiornik kwasu (pojemność 100, koszt 10/strzał) po opróżnieniu wchodzi w cooldown 7 s, po czym automatycznie uzupełnia się do 100. |
| **Nożyczki** | Atak wręcz z hitboxem kierunkowym — zadaje 20 obrażeń wrogim potworom. Podczas ataku gracz jest unieruchomiony. Atak tylko na wrogach (body.name musi zaczynać się od „Slime"). |

#### Target lock (auto-celowanie)

Gracz może kliknąć PPM na wrogu aby zablokować celownik — pociski będą leciały automatycznie w kierunku zaznaczonego celu. Ponowne kliknięcie PPM wyłącza lock. Lock automatycznie się wyłącza gdy cel zostanie pokonany.

### 3.2. Interakcja i kontrolery

| Akcja | Sterowanie |
| --- | --- |
| **Ruch** | WASD (8-kierunkowy top-down movement) |
| **Strzał ze zbiornika (woda/kwas)** | LPM (lewy przycisk myszy) — ciągły ogień przy przytrzymaniu |
| **Atak wręcz (nożyczki)** | Dedykowany klawisz (action: attack) |
| **Przełącz substancję (WATER / ACID)** | X |
| **Target lock (auto-aim na przeciwnika)** | PPM (prawy przycisk myszy) |
| **Interakcja (drzwi)** | E / SPACJA |
| **Pauza** | ESC — otwiera menu pauzy |

## 4. Przebieg gry

### 4.1. Ekran tytułowy

Po uruchomieniu gry wyświetla się menu główne (`main_menu.tscn`):

- Tło: ciemne, pikselowe
- Centrum: animowany tytuł „PLANTS RESCUE" z pulsującą zmianą koloru (zielony ↔ żółty)
- Przycisk PLAY + migający hint „Naciśnij ENTER / SPACJA"
- Na dole ekranu: animowany kaktus (sprite z gry) chodzi tam i z powrotem, co kilka sekund wykonując atak — ożywia scenę i zapowiada przeciwników

### 4.2. Intro — list

Po kliknięciu PLAY gracz trafia do Pokoju 1 (Przedpokój). Na ekranie wyświetla się overlay z listem — wprowadzenie fabularne. Gracz klika przycisk „Kontynuuj" aby zamknąć list, po czym HUD staje się widoczny i sterowanie zostaje odblokowane. Pojawiają się tutoriale (toasty) z podpowiedziami sterownia.

### 4.3. Menu, HUD i ekrany pośrednie

#### Menu startowe

- PLAY — uruchamia grę od Pokoju 1

#### HUD (Head-Up Display)

- Lewy górny: ❤❤❤ — pasek HP gracza (3 serca pixel art rysowane programowo, łącznie 90 HP; serca ciemnieją od prawej do lewej wraz z utratą życia — każde serce = 30 HP, częściowe wypełnienie kolumnowe)
- Prawy górny: panel zbiornika:
  - 💧 **WODA** — niebieski pasek (ProgressBar) + wartość liczbowa „X / 100" + tag `[AKTYWNA]` gdy woda jest aktywnym trybem
  - 🧪 **KWAS** — zielony pasek (ProgressBar) + status cooldown (`Gotowy` / licznik czasu do odnowienia np. `5.2s`)
  - Wizualne wyciszanie nieaktywnego trybu (zmiana koloru tytułu na brązowy)
- Nad obiektami w świecie:
  - wrogie Slime'y: pasek HP (czerwony, zmniejsza się proporcjonalnie)
  - przyjazne rośliny: pasek nawodnienia (niebieski, rośnie z podlewaniem)
- Cele poziomu (Salon): etykiety „Rośliny podlane: X / 3" i „Wrogowie pokonani: X / 4"

#### Ekran Game Over

Wyświetlany po śmierci gracza (HP = 0) z opóźnieniem 1,2 s. Przyciski:
- **Spróbuj ponownie** — restart aktualnego pokoju
- **Wróć do menu** — powrót do menu głównego

#### Ekran ukończenia poziomu

Wyświetlany po spełnieniu wszystkich celów i przejściu przez drzwi wyjściowe. Pokazuje czas przejścia (format MM:SS). Przycisk:
- **Menu** — powrót do menu głównego

#### System tutoriali (toasty)

Komunikaty pojawiające się jako animowane panele (fade-in → wyświetlanie → fade-out). Kolejkowane — wyświetlają się jeden po drugim. Przykłady:
- Przedpokój: „WASD — ruch", „Znajdź drzwi po prawej i wciśnij SPACJA lub E aby je otworzyć"
- Salon: „LPM — strzelaj wodą / Podlej rośliny aby je uratować", „X — przełącz między wodą a kwasem / Kwas rani wrogów", „Prawy przycisk myszy — auto-celowanie w wroga pod kursorem", „Uratuj wszystkie 3 rośliny i pokonaj 4 zmutowane potwory"

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
| 6 | Tyg. 6 (06–12.04) | HP gracza i AI: 3 serca (90 HP), animacja śmierci gracza, Slime (przeciwnik) z AI (pościg + atak 15 dmg + knockback), przyjazna roślina z podlewaniem 0–100% i efektem bloom |
| 7 | Tyg. 7 (13–19.04) | Room/Level Manager: system drzwi (lock/unlock/open), warunki ukończenia pokoju (podlanie + zabicie), przejścia między scenami, ekran ukończenia z czasem, system Game Over |
| 8 | Tyg. 8 (20–26.04) | Menu główne: ekran tytułowy z animowanym kaktusem, intro (letter overlay), system tutoriali (toasty), regeneracja zbiorników (auto-refill wody po opróżnieniu, cooldown kwasu) |
| 9 | Tyg. 9 (27.04–03.05) | Projektowanie Pokoju 1 (Przedpokój — tutorial) i Pokoju 2 (Salon — pełna rozgrywka), layout, rozmieszczenie roślin i wrogów, playtest |
| 10 | Tyg. 10 (04–10.05) | Nowe typy przeciwników (nowe odmiany Slime), balans obrażeń i prędkości, dodatkowe assety pixel art |
| 11 | Tyg. 11 (11–17.05) | Projektowanie poziomów 3–4 (layout, przeszkody, rozmieszczenie), playtest i poprawki kolizji |
| 12 | Tyg. 12 (18–24.05) | Poziom 5 + boss końcowy (fazy), telegraphy ataków, balans finałowej walki |
| 13 | Tyg. 13 (25–31.05) | UX i oprawa: szlif HUD i komunikatów, dodatkowe SFX, muzyka, polish animacji |
| 14 | Tyg. 14 (01–07.06) | Finalizacja: audio, optymalizacja, testy regresyjne, build release, dokumentacja końcowa |

## 6. Assety

### 6.1. Grafika — sprity, tekstury, animacje

#### Stany gracza

- Student idle (kierunkowy: right/up/down + flip)
- Student run (kierunkowy)
- Student attack (kierunkowy — nożyczki)
- Student dying
<img width="1536" height="1024" alt="student" src="https://github.com/user-attachments/assets/db01d58c-a2cd-4798-a4d6-3bf07c115617" />

#### Stany roślin

- Rośliny przyjazne: stan suchy/blade (modulate wygaszony) → podlewana (stopniowe rozjaśnianie) → rozkwitnięta (osobny sprite z pulsacją)
- Slime (przeciwnik): idle, attack (pościg), spine_attack (atak kontaktowy), die
<img width="1536" height="1024" alt="rosliny" src="https://github.com/user-attachments/assets/d0ce3624-0ccc-4509-b101-5118cc8a0c1c" />



#### Tła i obiekty

- Pokój 1 — Przedpokój: proste tło z drzwiami po prawej, scroll/list na podłodze
- Pokój 2 — Salon: kafle podłogowe, kanapa, papiery, rozbite doniczki, rośliny, wrogowie rozmieszczeni w pokoju
- Meble jako niezależne obiekty z kolizjami (sofa, stolik)
<img width="1536" height="1024" alt="pokoj" src="https://github.com/user-attachments/assets/34bfd26e-a813-4e92-8cbf-9283b25674db" />

#### UI

- Serduszka HP — rysowane programowo (pixel art grid 7×6, kolor wypełniony/pusty, skalowane ×6)
- Paski zbiornika (ProgressBar z kolorami: niebieski/woda, zielony/kwas)
- Paski HP wrogów i nawodnienia roślin (region-based Sprite2D)
- Pixel font: „PixelifySans" + „Press Start 2P" (Google Fonts, open license)
  ![czcionkajpg](https://github.com/user-attachments/assets/0e51ceb9-c0ea-454c-ab2c-d4d23ebf7171)
<img width="1600" height="840" alt="czcionka3" src="https://github.com/user-attachments/assets/7c24dfaf-afdd-4a02-a1c6-efd745b77e00" />


#### Narzędzia graficzne

- Aseprite (pixel art i animacje sprite'ów)
- Photoshop (kompozycje, UI)
- Godot SpriteFrames Editor (konfiguracja animacji)

### 6.2. Audio

| Kategoria | Opis |
| --- | --- |
| **SFX — Efekty dźwiękowe** | Zamach nożyczkami (whoosh.mp3), trafienie wroga (hit_enemy.mp3). Dodatkowe SFX planowane: wystrzał wody (splash), trafienie wodą w roślinę, wystrzał kwasu (hiss), Game Over (smutna melodia 8-bit). |
| **BGM — Muzyka tła** | Planowane: 2–3 tracki (menu — mellow lo-fi, rozgrywka — upbeat chiptune). Źródła: OpenGameArt.org, FreeMusicArchive (CC0/CC-BY). |
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
- ✅ Woda zwiększa pasek nawodnienia rośliny przy trafieniu (+20%); kwas zadaje 20 obrażeń wrogowi
- ✅ Nożyczki zadają 20 obrażeń wrogiemu obiektowi (hitbox kierunkowy)
- ✅ Drzwi otwierają się po obsłużeniu wszystkich roślin i pokonaniu wrogów w scenie
- ✅ HP gracza (90, 3 serca), system obrażeń od wrogów, animacja śmierci, ekran Game Over
- ✅ AI Slime: pościg, atak kontaktowy, knockback, śmierć
- ✅ HUD: serduszka, panele zbiorników (woda + kwas z cooldown), cele poziomu
- ✅ Menu główne, intro (letter overlay), system tutoriali (toasty)
- ✅ Przejścia między scenami (Przedpokój → Salon), ekran ukończenia z czasem
- 🔲 Dodatkowe typy przeciwników
- 🔲 Kolejne pokoje (3–5)
- 🔲 Muzyka tła (BGM)
- 🔲 Dodatkowe efekty dźwiękowe

**Plants Rescue — GDD v2.0**
