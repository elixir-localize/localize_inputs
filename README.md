# Localize.Inputs

Locale-aware HTML form input components. Today: `<.number_input>`. More inputs will land here over time (percentage, ratio, dimension, …).

Built on top of [`localize`](https://hex.pm/packages/localize). Wraps [AutoNumeric](https://autonumeric.org/) by Alexandre Bonneau (MIT-licensed) for live formatting and cursor preservation — the JS hook is a thin adapter that configures AutoNumeric from the component's locale data and lets it run. Credit where it's due.

## Installation

```elixir
def deps do
  [
    {:localize_inputs, "~> 0.1"},

    # Activate the HEEx component:
    {:phoenix_html, "~> 4.0"},
    {:phoenix_live_view, "~> 1.0"},

    # Activate the Ecto changeset bridge:
    {:ecto, "~> 3.10"},

    # Activate the visualizer:
    {:plug, "~> 1.15", only: :dev},
    {:bandit, "~> 1.5",  only: :dev}
  ]
end
```

The `phoenix_html`, `phoenix_live_view`, `ecto`, `plug`, `bandit` and `gettext` deps are all optional — the headless parser/formatter/validator compile without any of them. Each layer activates when its dep is present.

## Layered API

### Headless (no Phoenix dependency)

```elixir
{:ok, %Decimal{} = decimal} = Localize.Inputs.Parser.parse_number("1.234,56", locale: :de)

Localize.Inputs.Formatter.format_number(decimal, locale: :en)
#=> "1,234.56"

:ok = Localize.Inputs.Validator.validate_number(decimal, min: 0)

{:ok, info} = Localize.Inputs.Locale.resolve(:de)
info.decimal   #=> ","
info.group     #=> "."
```

### Ecto changeset

```elixir
changeset
|> Localize.Inputs.Changeset.validate_number(:quantity, min: 1, max: 999)
|> Localize.Inputs.Changeset.validate_number(:rating,   min: 0, max: 5, decimals: 1)
```

### HEEx component

```heex
<.number_input form={@form} field={:quantity} integer={true} min={1} max={999} />
<.number_input form={@form} field={:rating}   min={0} max={5} decimals={1} />
```

Import the component via `import Localize.Inputs.Components` in your view module.

### JS hook (AutoNumeric)

Install AutoNumeric as a peer dependency:

```bash
npm install autonumeric
```

In `assets/js/app.js`:

```javascript
import AutoNumeric from "autonumeric"
import Hooks from "localize_inputs"

Hooks.configure({ AutoNumeric })

new LiveSocket("/live", Socket, {
  hooks: { NumberInput: Hooks.NumberInput }
})
```

Without AutoNumeric loaded the input still works — the server-side parser accepts whatever the user typed on submit. Live formatting and cursor preservation are off in that fallback.

## Why the wire format is locale-formatted (not canonical)

Some form-input libraries take a different approach: the JS hook rewrites the input value to a canonical form (`"1234.56"`, dot decimal, no grouping) immediately before submit, so the server always receives the same shape regardless of locale. Call that **Option B**. It's a reasonable choice, but it has costs:

* The server needs two parsers — one for the canonical wire format, one for whatever the user actually typed if JS is disabled, broken, or hadn't booted yet. The two paths drift.

* The decimal and group separators in one locale are often each other in another (`de` uses `.` for grouping and `,` for decimal; `en` is the inverse). A bug in the canonicaliser silently produces a 1000× wrong number.

* The "canonical" shape is a hidden third format that exists only on the wire. It isn't what the user sees, isn't what the server stores, and isn't what tests assert against.

This library uses **Option A**: the JS hook never touches the value at submit time. Whatever AutoNumeric is currently displaying — locale-formatted, exactly as the user reads it — is what the form serialises. The server parses it with the locale you already have. The fallback path (no JS) and the AutoNumeric path produce *byte-identical* submissions for the same input.

Trade-off: the server must know the locale to parse the number. In practice you already do (it's in the session, assigns, or process dictionary via `Localize.get_locale/0`), so this is rarely a real cost.

If you're porting from an Option B library, the thing to double-check is that the locale you parse with matches the locale the form was rendered in.

## Visualizer

A Plug-based development tool that demos the component across CLDR locales with a light/dark theme toggle. Refuses to start unless the enable flag is set:

```elixir
# In config/dev.exs:
config :localize_inputs, visualizer: true

# Standalone (zero-config):
{:ok, _pid} = Localize.Inputs.Visualizer.Standalone.start(port: 4003)

# Or mount into a host Phoenix app:
forward "/inputs", Localize.Inputs.Visualizer
```

Tabs:

* **`/input`** — interactive `<.number_input>` demo with locale + AutoNumeric mounted.
* **`/parse`** — same input, every locale, side-by-side (separator inversion, paste tolerance).
* **`/format`** — same parsed value, every locale.
* **`/locale`** — the `Localize.Inputs.Locale.resolve/1` snapshot per locale.

## License

Apache-2.0. See [`LICENSE.md`](https://github.com/elixir-localize/localize_inputs/blob/main/LICENSE.md).
