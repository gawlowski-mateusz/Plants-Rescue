# Plants Rescue — ewaluacja heurystyczna (grywalność, UX, użyteczność)

| | |
|---|---|
| **Data** | 16.06.2026 |
| **Wersja** | gałąź `main` (Godot 4.6.2, renderer GL Compatibility) |
| **Metoda** | Ewaluacja heurystyczna — inspekcja ekspercka wg 10 heurystyk Nielsena w adaptacji dla gier, uzupełniona o aspekty specyficzne dla gier (sterowanie, feedback, krzywa trudności, immersja, onboarding) |
| **Zakres** | Pełny przebieg kampanii: menu → przedpokój (samouczek) → 4 poziomy → bossowie → zakończenia, a także menu pauzy, ustawienia, ekran sterowania, wybór poziomu, sekretny poziom |
| **Ocena ogólna** | **Dobra–bardzo dobra**; brak błędów krytycznych, pozostały drobne usprawnienia (severity 1–2) |

> To druga iteracja ewaluacji. Pierwsza runda (raport `2026-06-16_ewaluacja-heurystyczna-UX.md`)
> wykryła 10 problemów o wadze 2–3; większość została wdrożona. Niniejszy dokument
> ocenia **aktualny** stan gry i wskazuje, co jeszcze można dopracować.

---

## 1. Cel i metodyka

Celem oceny było sprawdzenie, na ile gra jest zrozumiała, wygodna i satysfakcjonująca
dla nowego gracza oraz na ile chroni go przed błędami i frustracją. Ewaluacja
heurystyczna to inspekcja ekspercka: ewaluator przechodzi interfejs i pętlę rozgrywki,
konfrontując każdy element z 10 regułami Nielsena, identyfikuje naruszenia i nadaje im
wagę (severity), a następnie formułuje rekomendacje.

**Skala wagi błędu (severity, wg Nielsena):**

| Stopień | Znaczenie |
|---|---|
| 0 | Brak problemu |
| 1 | Kosmetyczny — naprawić, gdy zostanie czas |
| 2 | Drobny — niski/średni priorytet |
| 3 | Poważny — wysoki priorytet |
| 4 | Katastrofalny — naprawić bezwzględnie |

---

## 2. Zakres i scenariusze testowe

Przeszło (inspekcyjnie) następujące ścieżki gracza:

1. **Pierwsze uruchomienie** — menu główne → „Nowa gra" → list intro → samouczek w
   przedpokoju → wyjście drzwiami na poziom 1.
2. **Onboarding** — kolejka komunikatów samouczka, przycisk „Pomiń samouczek",
   podpowiedzi kontekstowe przy obiektach.
3. **Rdzeń rozgrywki** — poruszanie (WASD), atak nożyczkami (LPM), strzał wodą/kwasem
   (PPM), przełączanie trybu (X), auto-celowanie (MMB), podlewanie roślin, walka z wrogami.
4. **Pętla poziomu** — zwój z fabułą → karta tytułowa → realizacja celów (licznik
   uratowanych roślin / pokonanych wrogów) → odblokowanie drzwi → przejście dalej.
5. **Walka z bossami** — paski życia bossów, unikatowa muzyka, nagroda po pokonaniu.
6. **Sytuacje błędne** — pusty zbiornik wody, atak na przyjazną roślinę, przegrana
   (ekran Game Over), wyjście/powrót do menu.
7. **Menu pauzy i ustawienia** — ESC, suwaki muzyki/SFX/jasności, ekran „Sterowanie",
   powrót do menu (z potwierdzeniem).
8. **Meta-progresja** — wybór poziomu ze znacznikami ukończenia, sekretny poziom
   („Wąż"), trzy zakończenia zależne od stylu gry.

---

## 3. Wynik techniczny (smoke test)

Sprawdzono, że wszystkie kluczowe sceny startują bez błędów (import + uruchomienie
nagłówkowe, filtr `SCRIPT ERROR / Parse Error / Invalid / null instance`):

| Scena | Wynik |
|---|---|
| `main_menu.tscn` | ✅ czysto |
| `main.tscn` (przedpokój) | ✅ czysto |
| `living_room.tscn` / `kitchen.tscn` / `bedroom.tscn` / `balcony.tscn` | ✅ czysto |
| `snake_minigame.tscn` | ✅ czysto |
| `ending.tscn` | ✅ czysto |

Import zasobów: `exit=0`, bez błędów. Brak regresji technicznych.

---

## 4. Ocena wg 10 heurystyk Nielsena

### H1 — Widoczność statusu systemu · **Bardzo dobra**

**Mocne strony:** czytelny HUD (serca „ZDROWIE", paski WODA/KWAS z etykietą aktywnego
trybu „(AKTYWNA)"), trwały licznik celów („Rośliny podlane: x/N", „Wrogowie pokonani:
x/N"), paski życia bossów, zielona poświata odblokowanych drzwi, delikatny puls
nieuratowanych roślin oraz **strzałka krawędziowa** prowadząca do najbliższej rośliny
poza kadrem.

**Słabe strony:** brak potwierdzenia zapisu postępu w momencie ukończenia poziomu
(znacznik ✓ widoczny dopiero w „Wyborze poziomu") — *severity 1*. Strzałka krawędziowa
nie prowadzi do wyjścia, gdy drzwi są poza kadrem — *severity 1*.

### H2 — Zgodność ze światem rzeczywistym · **Bardzo dobra**

Metafory są intuicyjne i spójne z tematem (podlewanie = ratowanie, kwas = broń, piwo =
przyspieszenie, zgrzewka = uzupełnienie wody, apteczka = leczenie). Język polski,
naturalny, z humorem studenckim. *Brak istotnych problemów.*

### H3 — Kontrola i swoboda użytkownika · **Dobra**

**Mocne strony:** pauza (ESC) na każdym poziomie i w przedpokoju; nakładki zamykane
ESC/przyciskiem; możliwość pominięcia samouczka; zwój z fabułą do pominięcia (E/Spacja);
dialogi potwierdzenia przy akcjach nieodwracalnych.

**Słabe strony:** brak opcji **„Restartuj poziom"** w menu pauzy — ponowną próbę można
podjąć dopiero po przegranej lub przez powrót do menu — *severity 2*. Brak remapowania
klawiszy — *severity 2* (patrz H7).

### H4 — Spójność i standardy · **Bardzo dobra**

Jednolity styl pixel-art i UI: pergaminowe zwoje dla narracji (list intro + opisy
poziomów), złoto obramowane panele dla menu/dialogów, spójne podpowiedzi kontekstowe nad
obiektami, spójne karty tytułowe „POZIOM N — Nazwa". Klawisz ESC zawsze otwiera/zamyka
pauzę. *Brak istotnych problemów.*

### H5 — Zapobieganie błędom · **Dobra**

**Mocne strony:** dialogi potwierdzenia („Wyjść z gry?", „Wrócić do menu głównego?")
z domyślnym fokusem na bezpiecznej opcji; podpowiedź „Brak wody!" zapobiega
dezorientacji; zablokowane drzwi sygnalizują stan, zamiast „nic nie robić".

**Słabe strony:** **przypadkowe zepsucie przyjaznej rośliny** — trafienie celu ratunku
kwasem/nożyczkami zamienia go we wroga; informacja pojawia się dopiero *po* fakcie
(dialog rośliny + toast). Nowy gracz może nieświadomie stracić cel — *severity 2*.

### H6 — Rozpoznawanie zamiast przypominania · **Bardzo dobra**

Stała, osiągalna z pauzy ściąga „Sterowanie"; podpowiedzi kontekstowe pojawiają się
dokładnie przy obiektach (lodówka, zgrzewka, apteczka, drzwi) i przy roślinach
(„PPM — podlej wodą"); HUD pokazuje aktywny tryb broni. Gracz nie musi pamiętać
mechanik z głowy. *Brak istotnych problemów.*

### H7 — Elastyczność i efektywność · **Dobra**

**Mocne strony:** pomijanie samouczka; wybór poziomu (skok do dowolnego ukończonego);
auto-celowanie (MMB) dla wygody; jednoczesne chodzenie i atak; obsługa myszy + klawiatury.

**Słabe strony:** brak **remapowania klawiszy** i brak **poziomów trudności** —
*severity 2*. Zwój z fabułą pojawia się także przy każdym restarcie poziomu, bez opcji
„nie pokazuj ponownie" — *severity 1*.

### H8 — Estetyka i minimalizm · **Bardzo dobra**

Spójna, czytelna oprawa; onboarding ograniczony do 6 komunikatów; nakładki i panele
auto-dopasowują rozmiar do treści (zwoje fabularne, panel zakończenia). Brak nadmiaru
elementów na ekranie. *Brak istotnych problemów.*

### H9 — Pomoc w rozpoznaniu i naprawie błędów · **Dobra**

Diagnostyczne komunikaty: „Brak wody — uzupełnij przy zgrzewce", „Zaatakowana roślina
zbuntowała się…", sygnalizacja zablokowanych drzwi, ekran Game Over z opcjami
„Spróbuj ponownie" / „Menu". *Drobne:* komunikaty są reaktywne (po błędzie), brak
elementu prewencyjnego przy ataku na przyjazną roślinę (zob. H5) — *severity 1–2*.

### H10 — Pomoc i dokumentacja · **Bardzo dobra**

List wprowadzający, samouczek krok-po-kroku, opisy fabularne poziomów na zwojach, stała
ściąga „Sterowanie", podpowiedzi kontekstowe. **Słabe strony:** ekran „Sterowanie"
wymienia klawisze, lecz nie przypomina **celu gry** („podlej przyjazne, pokonaj wrogie")
— cel jest tylko na liczniku HUD; warto dodać 1 zdanie celu — *severity 1*.

---

## 5. Zbiorcza lista problemów (priorytetyzowana)

| # | Heurystyka | Problem | Severity | Rekomendacja |
|---|---|---|---|---|
| P1 | H5/H9 | Atak na przyjazną roślinę zamienia ją we wroga; ostrzeżenie dopiero po fakcie | 2 | Wczesny sygnał: np. czerwony „X"/brak celownika na przyjaznej roślinie w trybie kwasu, lub krótka pierwsza-szansa („Uważaj — to przyjazna roślina!") |
| P2 | H3 | Brak „Restartuj poziom" w menu pauzy | 2 | Dodać przycisk „Restartuj poziom" w nakładce pauzy (obok „Wznów"/„Menu") |
| P3 | H7 | Brak remapowania klawiszy i poziomów trudności | 2 | Sekcja „Sterowanie" z przypisaniem klawiszy; opcjonalnie łatwy/normalny |
| P4 | H7/H8 | Zwój z fabułą pokazywany przy każdym restarcie poziomu | 1 | Pomijać narrację przy ponownym wejściu w tej samej sesji / opcja „nie pokazuj ponownie" |
| P5 | H1/H6 | Brak naprowadzania na wyjście, gdy drzwi są poza kadrem | 1 | Rozszerzyć wskaźnik krawędziowy o cel „wyjście", gdy cele poziomu są ukończone |
| P6 | H10 | Ekran „Sterowanie" nie przypomina celu gry | 1 | Dodać 1 zdanie celu na górze ekranu sterowania |
| P7 | H1 | Brak potwierdzenia zapisu po ukończeniu poziomu | 1 | Krótki toast „Postęp zapisany" / znacznik na ekranie ukończenia |
| P8 | Dostępność | Brak trybu dla daltonistów; kodowanie kolorem (woda/kwas/HP) | 1 | Dodać ikony/kształty wspierające kolor; suwak jasności już istnieje |
| P9 | (playtest) | Czytelność telegrafowania ataków bossów i hitboxów | — | Zweryfikować w teście z graczami (poza zakresem inspekcji eksperckiej) |

Brak problemów o wadze 3–4. Pozostałe to dopracowania (severity 1–2).

---

## 6. Aspekty specyficzne dla gier

- **Sterowanie i sprawczość:** responsywne; jednoczesne chodzenie i atak, knockback i
  czerwony błysk przy trafieniu dają wyraźny feedback dotykowy/wizualny. Auto-celowanie
  obniża barierę wejścia. *Ocena: dobra.*
- **Feedback i czytelność akcji:** dźwięki SFX dla czynności, muzyka kontekstowa (menu,
  rozgrywka, unikatowa na bossów), animacje trafień, paski zasobów. *Ocena: bardzo dobra.*
- **Krzywa trudności i tempo:** narastający poziom przez 4 pomieszczenia, skalowane
  paski życia bossów; ryzyko frustracji ogranicza pauza, leczenie i uzupełnianie wody.
  *Do walidacji z graczami:* balans obrażeń bossów i gęstość wrogów.
- **Onboarding:** wzorowy — samouczek krok-po-kroku, pomijalny, plus podpowiedzi
  kontekstowe zamiast jednorazowego „zrzutu" instrukcji. *Ocena: bardzo dobra.*
- **Immersja i narracja:** list intro, opisy poziomów na zwojach, trzy zróżnicowane
  zakończenia (z grafiką i statystykami) budują spójną, humorystyczną historię.
  *Ocena: bardzo dobra.*
- **Meta-progresja:** trwały zapis ukończonych poziomów, wybór poziomu, sekretny poziom
  jako nagroda za 100% — dobra motywacja do powrotu. *Ocena: dobra.*

---

## 7. Co poprawiono od poprzedniej ewaluacji

| Wcześniejszy problem | Status |
|---|---|
| Brak ekranu pomocy / referencji sterowania | ✅ Dodano (osiągalny z pauzy i menu) |
| Akcje nieodwracalne bez potwierdzenia | ✅ Dialogi „Tak/Nie" (fokus na „Nie") |
| Samouczek nie do pominięcia | ✅ Przycisk „Pomiń samouczek" |
| „Nic się nie dzieje" przy pustej wodzie / buncie rośliny | ✅ Komunikaty diagnostyczne |
| Nieoczywiste cele / brak naprowadzania | ✅ Puls roślin + strzałka krawędziowa |
| Brak podpowiedzi przy obiektach | ✅ Podpowiedzi kontekstowe (lodówka, drzwi, zgrzewka, apteczka, rośliny) |
| Brak narracji poziomów | ✅ Opisy fabularne na zwojach pergaminu |

---

## 8. Podsumowanie i ocena ogólna

Gra jest **dojrzała pod względem UX**: spójna wizualnie, dobrze onboardująca, z bogatym
feedbackiem i przemyślaną ochroną przed błędami. W bieżącej inspekcji **nie znaleziono
problemów krytycznych ani poważnych (severity 3–4)**; wszystkie sceny startują bez
błędów. Pozostałe uwagi to dopracowania o wadze 1–2.

**Rekomendowana kolejność wdrożeń (największy zysk/koszt):**

1. „Restartuj poziom" w menu pauzy (P2) i przypomnienie celu na ekranie sterowania (P6) —
   tanie, wyraźnie poprawiają kontrolę i orientację.
2. Wczesny sygnał przy ataku na przyjazną roślinę (P1) — usuwa najczęstsze „nieświadome"
   pomyłki.
3. Pomijanie narracji przy restarcie (P4) i naprowadzanie na wyjście (P5).
4. Remapowanie klawiszy / poziomy trudności (P3) oraz wsparcie dostępności (P8) —
   większy nakład, do rozważenia w dalszej kolejności.

Końcowa ocena użyteczności: **4/5** — solidna, gotowa do prezentacji gra z drobnym
potencjałem do dalszego szlifu.
