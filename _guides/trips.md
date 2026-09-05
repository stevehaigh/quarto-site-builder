# Writing a trip page

Trip pages live in `trips/`, one directory per trip. They're ordinary Quarto
pages with two extra shortcodes for plan entries. The directory is prefixed
with `_` so Quarto ignores it — this guide is for you, not the site.

## Start a trip

```bash
bin/new-trip.sh dolomites-2027 "Dolomites 2027"
```

That creates `trips/dolomites-2027/index.qmd` with the frontmatter filled in
and a cheat sheet in a comment. Set `date:` to the **start of the trip** — it
drives the ordering on `/trips` and whether the trip files under Upcoming or
Past. The page goes live on the next push; there's no draft step, because a
plan is most useful while you're still making it.

## Write the plan

Days are `##` headings. Everything else is normal prose — the shortcodes drop
into it wherever you want them.

```markdown
## Sat 14 May — into the Dolomites

Easy first day, arrive by train from Verona.

{{< stop train "Verona Porta Nuova → Bolzano" time="08:12" booking="9K22H" >}}

{{< travel train "1 h 35" >}}

{{< stop hotel "Hotel Greif, Bolzano" nights=2 booking="BK-83321" cost="€240" >}}

Anything on the Piazza Walther works for dinner:

{{< travel walk "8 min" >}}

{{< stop eat "Vögele, Bolzano" note="trad. Tyrolean, book ahead" >}}
```

## `stop` — one entry in the plan

```
{{< stop TYPE "PLACE" >}}
```

The place name is linked to a Google Maps search, so write it the way you'd
type it into Maps. Types:

| Group    | Types                                          |
|----------|------------------------------------------------|
| Core     | `hotel` `eat` `ferry` `drive` `flight` `train` `see` |
| Activity | `ride` `walk` `wine`                           |
| Admin    | `note` `todo` `cost`                           |

Admin entries are for things that aren't places — a parking reminder, a
booking deadline, a running total. They get no map link and they don't
interrupt a travel leg, so a note between two stops won't become the leg's
destination.

Optional details, all of them free text:

| Attribute | Example              | Notes                                    |
|-----------|----------------------|------------------------------------------|
| `time`    | `time="09:40"`       |                                          |
| `nights`  | `nights=2`           | Pluralised for you                       |
| `booking` | `booking="BK-83321"` |                                          |
| `cost`    | `cost="€240"`        |                                          |
| `note`    | `note="book ahead"`  | Rendered italic on its own line          |
| `url`     | `url="https://…"`    | Links the place here instead of Maps     |

`time`, `nights`, `booking` and `cost` render as one dot-separated line under
the place, in that order, whichever ones you supply.

## `travel` — a leg between two stops

```
{{< travel MODE "DURATION" >}}
```

Modes: `drive` `walk` `ride` `train` `ferry` `flight`.

Put it *between* two stops. It renders as a light connector linked to Google
Maps directions, with the origin and destination taken from the stops either
side — you never type the places twice.

You type the duration yourself, copied from Maps while you're planning. That's
deliberate: no API key, no billing, no build-time network calls, and nothing
that silently goes stale in a way the page can't show you.

A leg with no stop after it renders nothing, so a trailing `travel` while
you're mid-edit is harmless.

## When something's wrong

The build warns rather than fails, and always renders something:

- unknown stop type → generic `•` marker
- unknown travel mode → routed as driving
- `travel` before any stop → skipped, nothing to route from
- `stop` missing its type or place → skipped

Warnings appear in the `quarto render` output prefixed `[trips]`.

## Preview

```bash
quarto preview
```

`quarto render --profile production` is what CI runs; it skips `blog/drafts`
and `hidden`, but not `trips` — trips are live from the moment you push.

## Where things live

| Path                          | What                                    |
|-------------------------------|-----------------------------------------|
| `trips/<slug>/index.qmd`      | One trip                                |
| `trips/index.qmd`             | Listing, splits Upcoming/Past by date   |
| `trips/_metadata.yml`         | Shared defaults for every trip page     |
| `partials/trip-list.ejs`      | Listing template                        |
| `_extensions/trips/trips.lua` | The two shortcodes                      |
| `bin/new-trip.sh`             | Scaffold                                |
| styling                       | `.trip-*` rules in `styles.css`         |

## Adding a stop type

Add the icon to `ICONS` in `_extensions/trips/trips.lua`. If it's a
non-place entry, add it to `ADMIN` as well. Travel modes additionally need an
entry in `TRAVEL_MODES` mapping to a Google Maps `travelmode`
(`driving`, `walking`, `bicycling`, `transit`).
