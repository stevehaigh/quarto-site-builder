-- Trip-plan shortcodes.
--
--   {{< stop TYPE "PLACE" time=… nights=… booking=… cost=… note=… url=… >}}
--   {{< travel MODE "DURATION" >}}
--
-- A stop renders as an icon, the place name linked to Google Maps, and
-- whatever details were supplied. A travel leg renders as a connector between
-- the two stops it sits between, linked to Google Maps directions.
--
-- Shortcodes can't see their neighbours, so `travel` doesn't render anything
-- itself: it records a pending leg, and the *next* stop emits the connector,
-- since only that call knows the destination. Shortcodes are expanded in
-- document order, which is what makes this work.

local ICONS = {
  -- core
  hotel = "🏨", eat = "🍽️", ferry = "⛴️", drive = "🚗",
  flight = "✈️", train = "🚆", see = "👁️",
  -- activity
  ride = "🚴", walk = "🥾", wine = "🍷",
  -- admin
  note = "📝", todo = "☐", cost = "💷",
}

-- Admin entries aren't places: no map link, and they don't break a travel leg
-- (a note between two stops shouldn't become the leg's destination).
local ADMIN = { note = true, todo = true, cost = true }

local TRAVEL_MODES = {
  drive = "driving", walk = "walking", ride = "bicycling",
  train = "transit", ferry = "transit", flight = "transit",
}

-- Details rendered after the place name, in this order.
local DETAIL_KEYS = { "time", "nights", "booking", "cost" }

local state = { doc = nil, last_place = nil, pending = nil }

local function str(v)
  if v == nil then return nil end
  local s = pandoc.utils.stringify(v)
  if s == "" then return nil end
  return s
end

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
  return s
end

-- The unreserved set is spelled out rather than using %w: Lua's character
-- classes are locale-dependent, and under a Latin-1 locale the lead bytes of
-- UTF-8 sequences (0xC3 in "ö", 0xE2 in "→") count as letters and escape
-- encoding, producing a mangled URL.
local function urlencode(s)
  return (s:gsub("[^A-Za-z0-9%-%._~]", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end

local function warn(msg)
  quarto.log.warning("[trips] " .. msg)
end

-- Reset the running state when we move on to a new document, so a page that
-- opens with a travel leg can't pick up the previous page's last stop.
local function sync_doc()
  local ok, current = pcall(function() return quarto.doc.input_file end)
  current = ok and current or "?"
  if current ~= state.doc then
    state.doc = current
    state.last_place = nil
    state.pending = nil
  end
end

local function map_search_url(place)
  return "https://www.google.com/maps/search/?api=1&query=" .. urlencode(place)
end

local function map_dir_url(origin, destination, mode)
  return "https://www.google.com/maps/dir/?api=1"
    .. "&origin=" .. urlencode(origin)
    .. "&destination=" .. urlencode(destination)
    .. "&travelmode=" .. (TRAVEL_MODES[mode] or "driving")
end

local function travel_html(leg, destination)
  local icon = ICONS[leg.mode] or "→"
  local url = map_dir_url(leg.origin, destination, leg.mode)
  return table.concat({
    '<div class="trip-travel">',
    '<span class="trip-icon" aria-hidden="true">', icon, '</span>',
    '<a class="trip-leg" href="', esc(url), '">', esc(leg.duration), '</a>',
    '</div>',
  })
end

local function stop_html(kind, place, kwargs)
  local icon = ICONS[kind]
  if not icon then
    warn('unknown stop type "' .. kind .. '" — using a generic marker')
    icon = "•"
  end

  local parts = {
    '<div class="trip-stop trip-stop-', esc(kind), '">',
    '<span class="trip-icon" aria-hidden="true">', icon, '</span>',
    '<div class="trip-body">',
  }

  -- An explicit url= wins over the generated map link; admin entries get none.
  local href = str(kwargs["url"]) or (not ADMIN[kind] and map_search_url(place) or nil)
  if href then
    parts[#parts + 1] = '<a class="trip-place" href="' .. esc(href) .. '">' .. esc(place) .. '</a>'
  else
    parts[#parts + 1] = '<span class="trip-place">' .. esc(place) .. '</span>'
  end

  local details = {}
  for _, key in ipairs(DETAIL_KEYS) do
    local v = str(kwargs[key])
    if v then
      if key == "nights" then
        v = v .. (v == "1" and " night" or " nights")
      end
      details[#details + 1] = esc(v)
    end
  end
  if #details > 0 then
    parts[#parts + 1] = '<span class="trip-detail">' .. table.concat(details, " · ") .. '</span>'
  end

  local note = str(kwargs["note"])
  if note then
    parts[#parts + 1] = '<span class="trip-note">' .. esc(note) .. '</span>'
  end

  parts[#parts + 1] = '</div></div>'
  return table.concat(parts)
end

function stop(args, kwargs, meta, raw_args, context)
  sync_doc()

  local kind = str(args[1])
  local place = str(args[2])
  if not kind or not place then
    warn('stop needs a type and a place, e.g. {{< stop hotel "Hotel Greif, Bolzano" >}}')
    return pandoc.Null()
  end

  local html = ""
  -- A pending leg only renders once we know where it's going.
  if state.pending and not ADMIN[kind] then
    html = travel_html(state.pending, place)
    state.pending = nil
  end
  html = html .. stop_html(kind, place, kwargs)

  if not ADMIN[kind] then
    state.last_place = place
  end

  if context == "inline" then
    return pandoc.RawInline("html", html)
  end
  return pandoc.RawBlock("html", html)
end

function travel(args, kwargs, meta, raw_args, context)
  sync_doc()

  local mode = str(args[1])
  local duration = str(args[2])
  if not mode or not duration then
    warn('travel needs a mode and a duration, e.g. {{< travel drive "1 h 20" >}}')
    return pandoc.Null()
  end
  if not TRAVEL_MODES[mode] then
    warn('unknown travel mode "' .. mode .. '" — routing as driving')
  end
  if not state.last_place then
    warn('travel leg before any stop — skipping, there is nowhere to route from')
    return pandoc.Null()
  end

  state.pending = { mode = mode, duration = duration, origin = state.last_place }
  return pandoc.Null()
end
