# Shauni's Shop — context voor Claude Code

Antwoord altijd in het **Nederlands** (Vlaams). Houd uitleg kort en direct; doe het werk zelf.

## Wat is dit
Gedeelde gsm-webapp waarmee Ejnar en Shauni hun online doorverkoop bijhouden: aankopen (stock), verkopen per maand en winst.
- Live: https://ejnarhansen93.github.io/Shauni-Shop/
- Repo: github.com/EjnarHansen93/Shauni-Shop (branch `main`, GitHub Pages serveert `index.html` uit de root)
- Toegangscode in de app: `shauni` (constante `PIN` in index.html, bewaard via localStorage `ss_unlocked`)

## Opbouw
- **Alles zit in één bestand: `index.html`** (HTML + CSS + vanilla JS in een IIFE, geen build-stap, geen dependencies).
- Drie tabs: **Verkoop** (`buildVerkoop`), **Stocklijst** (`buildStock`), **Winst** (`buildWinst`).
- Verkoop-tab: maanden zijn inklapbaar (standaard enkel de bovenste open, `monthOpen`), verkopen staan als één lijn en er is er telkens één open om te bewerken (`openRow`). Stocklijst werkt hetzelfde (`openArt`), uitverkochte artikelen onderaan. Die weergavestatus wordt niet bewaard.
- Na elke wijziging: `render()` + `scheduleSave()` (debounce 700 ms → `doSave`).
- Sync tussen toestellen: `pull(true)` elke 9 s als de pagina zichtbaar is; lokale cache in localStorage `ss_cache`.

## Data (Supabase)
- Project URL: `https://lkzxkovpswyllzunrqks.supabase.co` (anon key staat in index.html als `SUPA_KEY`).
- Tabel `shauni_shop`, **één rij** met `id = 'main'`, kolommen `data jsonb`, `updated_at timestamptz`. Zie `supabase/schema.sql`.
- Opslaan = upsert via REST (`Prefer: resolution=merge-duplicates`).
- Vorm van `data`:
```json
{
  "stock":  [{ "id": "abc123", "name": "Artikel", "qty": "5", "buy": "12.50", "soldOutAt": "2026-09-01" }],
  "months": [{ "id": "m1", "label": "September 2026",
               "rows": [{ "id": "r1", "articleId": "abc123", "qty": "1", "sold": "25" }] }]
}
```
- Getallen worden als tekst bewaard; altijd via `parseNum()` lezen (accepteert komma).
- Berekeningen: winst per rij = `sold − qty × buy` van het gekoppelde artikel; resterende stock = `stock.qty − som(verkochte qty)`; `soldOutAt` wordt automatisch gezet in `syncSoldOut()`.
- Maandlabels zijn `"<Maand> <jaar>"` met de Nederlandse namen uit `MONTHS`.

## Werkafspraken
- Behoud de datastructuur (bestaande data in Supabase moet blijven werken). Nieuwe velden: optioneel maken en in `normalize()` opvangen.
- Test lokaal door `index.html` te openen of `npx serve .` te draaien. Let op: lokaal schrijf je naar de **echte** live database.
- Deployen = committen en pushen naar `main`; GitHub Pages werkt de site binnen ~1 minuut bij.
- Bedragen tonen met `euro()` (nl-BE, EUR).
