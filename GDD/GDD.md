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
    - [2.3.3. Rośliny wrogie (przeciwnicy)](#233-rośliny-wrogie-przeciwnicy)
    - [2.3.4. Inteligencja NPC (AI roślin)](#234-inteligencja-npc-ai-roślin)
- [3. Rozgrywka i mechaniki](#3-rozgrywka-i-mechaniki)
  - [3.1. Cele i wyzwania](#31-cele-i-wyzwania)
    - [Cel główny każdego poziomu](#cel-główny-każdego-poziomu)
    - [Mechanika paska nawodnienia](#mechanika-paska-nawodnienia)
    - [System ekwipunku](#system-ekwipunku)
  - [3.2. Interakcja i kontrolery](#32-interakcja-i-kontrolery)
- [4. Przebieg gry](#4-przebieg-gry)
  - [4.1. Splash screeny](#41-splash-screeny)
  - [4.2. Cutscenki i narracja](#42-cutscenki-i-narracja)
    - [Opening Crawl (intro)](#opening-crawl-intro)
  - [4.3. Menu, HUD i ekrany pośrednie](#43-menu-hud-i-ekrany-pośrednie)
    - [Menu startowe](#menu-startowe)
    - [HUD (Head-Up Display) — mockup](#hud-head-up-display--mockup)
    - [Ekran pauzy](#ekran-pauzy)
    - [Ekran Game Over](#ekran-game-over)
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
| **Gatunek główny** | 2D Top-down Platformer |
| **Podgatunki** | Casual |
| **Styl graficzny** | Pixel Art 2D, widok z góry |

### 1.3. Odbiorcy

- Młodzi dorośli (18–30 lat)
- Gracze casualowi szukający krótkiej, zabawnej rozrywki
- Fani pixel artu i retro estetyki

### 1.4. Platforma i wymagania sprzętowe

| Parametr | Wartość |
| --- | --- |
| **Platforma docelowa (aktualny prototyp)** | PC (Windows) |
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

| Poziom | Opis |
| --- | --- |
| **Pokój 1 — Przedpokój** | Tutorial. Jedna lub dwie roślinki, brak wrogów. Gracz poznaje sterowanie i mechanikę zbiornika (woda). Drzwi boczne prowadzą do łazienki, gdzie gracz uzupełnia zapas wody po raz pierwszy. |
| **Pokój 2 — Salon** | Kilka roślin do podlania, pierwsza zła roślina (suchy-kaktus). Wprowadzenie kwasu solnego i nożyczek. Drzwi do łazienki umożliwiają uzupełnienie zbiornika. Wprowadzenie nożyczek. |
| **Pokój 3 — Kuchnia** | Kwiaty na parapecie + fermentujące warzywa jako wrogowie. Obecność piwa w lodówce. Drzwi do łazienki dostępne przy wejściu do pokoju. |
| **Pokój 4 — Sypialnia** | Więcej wrogów, wąskie przejścia między meblami. Wyższy poziom trudności. Drzwi do łazienki ukryte za meblem -- gracz musi je znaleźć. |
| **Pokój 5 — Balkon** | Boss końcowy -- Palma kokosowa. Finałowa walka i zakończenie gry. Brak łazienki -- gracz musi wejść z pełnym zbiornikiem. |

### 2.2. Fabuła

#### 2.2.1. Wprowadzenie

Zapracowany student informatyki na pierwszym roku studiów magisterskich wraca po dwutygodniowej sesji egzaminacyjnej do swojego mieszkania. W tym czasie całkowicie zapomniał o swoich licznych roślinach doniczkowych. To, co go wita, to armia zeschniętych, rozgniewanych zielonych stworzeń, które mają dość bycia ignorowanymi.

W lodówce czeka zapomniana zgrzewka piwa, na parapecie leży konewka, a w szufladzie nożyczki do przycinania. Student musi przejść przez całe mieszkanie, pogodzić się z roślinami lub je pokonać, zanim jego koledzy wrócą z Wyspy Słodowej.

#### 2.2.2. Główne wątki fabularne

Przejście przez 5 pokojów, podlanie lub pokonanie wszystkich roślin, dotarcie na balkon i pokonanie finałowego bossa.

### 2.3. Postaci

#### 2.3.1. Bohater — Student

| Cecha | Opis |
| --- | --- |
| **Imię** | „Student” |
| **Wygląd** | Pixel art, student w bluzie z kapturem, jeansach i klapkach z białymi skarpetkami |
| **Statystyki** | HP: 3 serduszka, prędkość: bazowa / +50% po wypiciu piwa |
| **Sterowanie** | WSAD / strzałki — ruch; E / Spacja — użyj przedmiotu; Q — zmień przedmiot |

#### 2.3.2. Rośliny przyjazne (do podlania)

- Kwiaty okienne (proste) — stoją nieruchomo, pasek nawodnienia widoczny nad nimi
- Bluszcz (ruchomy) — pełznie powoli, trudniejszy do podlania

#### 2.3.3. Rośliny wrogie (przeciwnicy)

- Suchy-kaktus — powolny, ale zadaje duże obrażenia przy kontakcie; 1 trafienie nożyczkami wystarczy
- Pnącze gniewu — szybkie, atakuje z dystansu, strzelając kolcami
- Grzybek halucynek — unieruchamia gracza spowalniającym gazem
- Palma kokosowa — faza 1: strzelanie kokosami; faza 2: szarża

#### 2.3.4. Inteligencja NPC (AI roślin)

- Atak: zależny od typu rośliny — bliski lub dystansowy
- Podążanie: po pokonaniu rośliny staje się ona towarzyszem gracza

## 3. Rozgrywka i mechaniki

### 3.1. Cele i wyzwania

#### Cel główny każdego poziomu

- Podlej lub pokonaj wszystkie rośliny w pokoju, aby odblokować drzwi do kolejnego
- Ukończ wszystkie 5 pokojów i pokonaj finałowego bossa

#### Mechanika paska nawodnienia

Każda roślina przyjazna posiada pasek nawodnienia (0--100%). Gracz musi uzupełnić go do 100% używając zbiornika z wodą. Roślina z pełnym paskiem zmienia kolor (szary/brązowy → zielony) i znika jako wróg z listy wymagań pokoju.

#### System ekwipunku

| Przedmiot | Działanie |
| --- | --- |
| **Zbiornik (woda / kwas solny)** |    Broń dystansowa -- gracz mierzy i wystrzeliwuje substancję w łuku. Im większy dystans do celu, tym wyżej należy celować, aby substancja doleciała do celu (fizyka pocisku). Woda służy wyłącznie do podlewania przyjaznych roślin (napełnia pasek +20% na trafienie). Kwas solny służy do atakowania wrogich roślin (zadaje 1 punkt obrażeń na trafienie). Zbiornik posiada dwa osobne wskaźniki poziomu napełnienia: 💧 Woda i 🧪 Kwas solny. Uzupełnianie zapasów możliwe wyłącznie w łazience, do której prowadzą drzwi boczne w każdym pokoju (poziomie). |
| **Nożyczki** | Atak — zadaje 1 punkt obrażeń wrogiemu stworzeniu. Na przyjaznej roślinie: roślina natychmiast staje się wroga. Cooldown: 1 s. |
| **Piwo** | Jednorazowe użycie, zapas w ekwipunku do końca sesji gry. Wypicie: prędkość gracza +50% przez 10 sekund. Efekt wizualny: lekkie rozmazanie ekranu. |

### 3.2. Interakcja i kontrolery

| Akcja | Sterowanie |
| --- | ---   |
| **Ruch** | WSAD (8-kierunkowy top-down movement) |
| **Atak wręcz (nożyczki)** | LPM |
| **Strzał ze zbiornika (woda/kwas)** | PPM |
| **Przełącz substancję (WATER / ACID)** | X |
| **Target lock (auto-aim na przeciwnika)** | Kliknięcie rolki myszy (MMB) |
| **Pauza** | ESC - otwiera menu pauzy |

## 4. Przebieg gry

### 4.1. Splash screeny

Sekwencja ekranów przy uruchomieniu gry (każdy wyświetlany przez 2 sekundy, z możliwością pominięcia):

1. Logo Unity (auto-generowane przez silnik)
2. Logo projektu (prosty pixel art)
3. Ekran tytułowy gry: animowany tytuł „PLANTS RESCUE”, podtytuł, przycisk START

**Opis ekranu tytułowego:**

- Tło: pikselowa tapeta — salon z roślinami w tle
- Centrum góra: logo, tytuł (pixel font)
- Centrum środek: [NOWA GRA] [OPCJE] [WYJŚCIE]
- Dół lewy: imiona twórców
- Dół prawy: v1.0

### 4.2. Cutscenki i narracja

#### Opening Crawl (intro)

Po wybraniu „Nowa Gra”: animowany tekst przewija się od dołu ekranu (styl Star Wars) na czarnym tle z cichą muzyką ambientową:

> *Rok akademicki 2025/2026. Sesja egzaminacyjna dobiegła końca.*  
> *Zmęczony student wraca do swojego mieszkania po dwóch tygodniach intensywnej nauki.*  
> ***Niestety... rośliny nie poczekały cierpliwie.***  
> *Czas naprawić błędy. Czas nawodnić. Czas walczyć.*

### 4.3. Menu, HUD i ekrany pośrednie

#### Menu startowe

- Nowa Gra — uruchamia intro i poziom 1
- Kontynuuj — wczytuje zapis
- Opcje — głośność muzyki/SFX, pełny ekran, język
- Wyjście (tylko build desktopowy)

#### HUD (Head-Up Display) — mockup

- Lewy górny: ❤❤❤ — pasek HP gracza (3 serca pixel art, łącznie 90 HP; serca ciemnieją od prawej do lewej wraz z utratą życia)
- Prawy górny: panel zbiornika:
  - 💧 **WATER TANK** — niebieski pasek poziomu wody + wartość liczbowa
  - 🧪 **ACID TANK** — zielony pasek poziomu kwasu + status cooldown (`Ready` / licznik czasu do odnowienia)
  - wskaźnik aktywnej substancji (`WATER` / `ACID`) z ikoną kolorystyczną
- Nad obiektami w świecie:
  - wrogie slimy: pasek HP
  - przyjazne slimy: pasek nawodnienia + etykieta `Watered` po osiągnięciu 100%

#### Ekran pauzy

- Wznów / Opcje / Wróć do menu

#### Ekran Game Over

Pikselowa animacja: student leży na podłodze otoczony triumfującymi roślinami. Przyciski: Spróbuj ponownie (restart pokoju) / Wróć do menu głównego.

## 5. Zakres projektu

### 5.1. Zespół 2-osobowy — podział prac

- **Mateusz Gawłowski** — mechaniki, integracja assetów, implementacja UI/HUD, WebGL build
- **Wojciech Tobolski** — pixel art, projektowanie poziomów, audio, balans rozgrywki

### 5.2. Harmonogram prac (14 tygodni)

| Tydz. | Data | Zakres prac |
| --- | --- | --- |
| 1 | Tyg. 1 (02–08.03) | Kickoff: założenia projektu, setup repozytorium Git, konfiguracja projektu w Godot, szkic GDD |
| 2 | Tyg. 2 (09–15.03) | Podstawa gry: ruch gracza (WSAD), animacje kierunkowe, scena główna, kolizje |
| 3 | Tyg. 3 (16–22.03) | Walka wręcz: atak nożyczkami (LPM), hitbox gracza, obrażenia i pasek HP przeciwnika |
| 4 | Tyg. 4 (23–29.03) | Strzelanie: pociski, tryby WATER/ACID, cooldown strzału, przełączanie trybu (X), target lock (MMB) |
| 5 | Tyg. 5 (30.03–05.04) | Zasoby i HUD: pasek wody, pasek kwasu z cooldown/timerem, wskaźnik aktywnej substancji, osadzenie HUD w rogach ekranu |
| 6 | Tyg. 6 (06–12.04) | HP gracza i AI: 3 serca (90 HP), animacja śmierci gracza, agresywny roślina (przeciwnik) (pościg + atak 15 dmg), przyjazna roslina z podlewaniem 0–100% |
| 7 | Tyg. 7 (13–19.04) | Room/Level Manager: warunki ukończenia pokoju, blokowanie/odblokowanie przejść po obsłużeniu wszystkich roślin |
| 8 | Tyg. 8 (20–26.04) | Łazienka jako subscena refillu: wejście/wyjście, uzupełnianie zbiorników, integracja z pętlą poziomu |
| 9 | Tyg. 9 (27.04–03.05) | Rozszerzenie ekwipunku: system przełączania przedmiotów (zbiornik/nożyczki/piwo), sloty i podstawowe UI ekwipunku |
| 10 | Tyg. 10 (04–10.05) | Nowe typy przeciwników (pnącze, grzybek), ataki dystansowe NPC, balans obrażeń i prędkości |
| 11 | Tyg. 11 (11–17.05) | Projektowanie poziomów 1–3 (layout, przeszkody, rozmieszczenie roślin), playtest i poprawki kolizji |
| 12 | Tyg. 12 (18–24.05) | Poziomy 4–5 + boss końcowy (fazy), telegraphy ataków, balans finałowej walki |
| 13 | Tyg. 13 (25–31.05) | UX i oprawa: menu główne, pauza, ekran Game Over, intro/outro, szlif HUD i komunikatów |
| 14 | Tyg. 14 (01–07.06) | Finalizacja: audio, optymalizacja, testy regresyjne, build release, dokumentacja końcowa |

## 6. Assety

### 6.1. Grafika — sprity, tekstury, animacje

#### Stany gracza

- Student idle
- Student walk
- Student attack/use
- Student hit / knocked back
<img width="1536" height="1024" alt="student" src="https://github.com/user-attachments/assets/db01d58c-a2cd-4798-a4d6-3bf07c115617" />

#### Stany roślin

- Rośliny przyjazne: 3 warianty × stany (sucha / podlewana / nawodniona)
- Rośliny wrogie: 4 typy × stany (idle / atak / śmierć / konwersja na ducha)
- Palma kokosowa: 2 fazy, animowane przejście
<img width="1536" height="1024" alt="rosliny" src="https://github.com/user-attachments/assets/d0ce3624-0ccc-4509-b101-5118cc8a0c1c" />



#### Tła i obiekty

- 5 map odpowiadających każdemu pokojowi
- Meble jako niezależne obiekty (sofa, stolik, łóżko, lodówka)
<img width="1536" height="1024" alt="pokoj" src="https://github.com/user-attachments/assets/34bfd26e-a813-4e92-8cbf-9283b25674db" />

#### UI

- Ikony ekwipunku (zbiornik z wodą, zbiornik z kwasem, nożyczki, piwo) -- pixel art
- Serduszka (pełne / puste) — pixel art
- Pasek nawodnienia
- Pixel font (np. „Press Start 2P” — Google Fonts, open license)
  ![czcionkajpg](https://github.com/user-attachments/assets/0e51ceb9-c0ea-454c-ab2c-d4d23ebf7171)
<img width="1600" height="840" alt="czcionka3" src="https://github.com/user-attachments/assets/7c24dfaf-afdd-4a02-a1c6-efd745b77e00" />


#### Narzędzia graficzne

- Aseprite (pixel art i animacje sprite’ów)
- Photoshop (kompozycje, UI)
- Unity Sprite Editor (slicing, pivot points)

### 6.2. Audio

| Kategoria | Opis |
| --- | --- |
| **BGM — Muzyka tła** | 3 tracki: Intro/Menu (mellow lo-fi), Pokoje 1–3 (upbeat chiptune), Pokoje 4–5/Boss (intensywna chiptune). Źródła: OpenGameArt.org, FreeMusicArchive (CC0/CC-BY). |
| **SFX — Efekty dźwiękowe** | Wystrzał wody (splash), trafienie wodą w roślinę (sizzle+nawodnienie), wystrzał kwasu solnego (hiss), trafienie kwasem (dissolve), cięcie nożyczkami (snip), hit gracza (ouch), picie piwa (gulp + bełkot), otwarcie drzwi łazienki (creak+kapanie), uzupełnianie zbiornika (filling sound), Game Over (smutna melodia 8-bit). |
| **Narracja / dialogi** | Brak voice actingu, teksty wyświetlane jako dialog boxes z pixel-art bubbles. |
| **Narzędzia audio** | Unity Audio Mixer (balans SFX/muzyki), BFXR / ChipTone (generowanie SFX), Audacity (edycja). |

## 7. Prototyp (Proof of Concept)

### 7.1. Cel prototypu

Celem prototypu jest weryfikacja głównej mechaniki gry w środowisku Unity oraz upewnienie się, że konwersja do WebGL działa poprawnie. Prototyp nie musi być dopracowany graficznie — może używać placeholder assetów (kolorowe kwadraty, Unity default sprites).

### 7.2. Technologie i zasoby startowe

| Kategoria | Wartość |
| --- | --- |
| **Silnik** | Godot 4.6 |
| **Język** | GDScript |
| **Kontrola wersji** | Git + GitHub |
| **Edytor** | Godot Editor + Visual Studio Code |

### 7.3. Kryteria sukcesu prototypu

- Gracz porusza się płynnie, bez przechodzenia przez ściany
- Zbiornik wystrzeliwuje wodę/kwas w łuku, substancja leci po krzywej balistycznej
- Woda zwiększa pasek nawodnienia rośliny przy trafieniu; kwas solny zadaje obrażenia wrogiej roślinie
- Drzwi do łazienki przenoszą gracza do subsceny uzupełniania zbiornika i z powrotem
- Nożyczki zadają obrażenia wrogiemu obiektowi
- Drzwi otwierają się po obsłużeniu wszystkich roślin w scenie
- Build WebGL uruchamia się w Chrome bez błędów w konsoli
- FPS utrzymuje się powyżej 30 w trybie WebGL na testowej maszynie

**Plants Rescue — GDD v1.0**
