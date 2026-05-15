# Localize.Inputs

Locale-aware HTML form input components. Today: `<.number_input>`. More inputs will land here over time (percentage, ratio, dimension, …).

Built on top of [`localize`](https://hex.pm/packages/localize). Wraps [AutoNumeric](https://autonumeric.org/) by Alexandre Bonneau (MIT-licensed) for live formatting and cursor preservation — the JS hook is a thin adapter that configures AutoNumeric from the component's locale data and lets it run. Credit where it's due.

For a full end-to-end Phoenix integration walkthrough — Elixir deps, JS deps, asset wiring, schema, LiveView — read the [integration guide](https://hexdocs.pm/localize_inputs/integration.html).

## Installation

```elixir
def deps do
  [
    {:localize_inputs, "~> 0.1"},

    # Activate the HEEx component:
    {:phoenix_html, "~> 4.0"},
    {:phoenix_live_view, "~> 1.0"},

    # Activate the Ecto changeset bridge:
    {:ecto, "~> 3.10"}
  ]
end
```

The `phoenix_html`, `phoenix_live_view`, `ecto`, and `gettext` deps are all optional — the headless parser/validator compile without any of them. Each layer activates when its dep is present.

For a Plug-based visualizer that demos `<.number_input>` across CLDR locales, see the sibling [`localize_inputs_playground`](https://github.com/elixir-localize/localize_inputs_playground) package. A live instance runs at <https://localize-inputs-playground.fly.dev>.

## Layered API

### Headless (no Phoenix dependency)

```elixir
{:ok, %Decimal{} = decimal} = Localize.Inputs.Parser.parse_number("1.234,56", locale: :de)

Localize.Number.to_string!(decimal, locale: :en)
#=> "1,234.56"

:ok = Localize.Inputs.Validator.validate_number(decimal, min: 0)

{:ok, info} = Localize.Inputs.Number.number_for_locale(:de)
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

The submitted value is the *locale-formatted* string (what the user sees), not a canonicalised wire form. See the [integration guide](https://hexdocs.pm/localize_inputs/integration.html#why-the-wire-format-is-locale-formatted-not-canonical) for the rationale and the porting-from-canonical-libraries gotcha.

## Visualizer

A Plug-based development tool that demos the component across CLDR locales lives in the sibling [`localize_inputs_playground`](https://github.com/elixir-localize/localize_inputs_playground) package — clone and `mix run --no-halt`, or deploy to Fly.io. To embed it inside your own Phoenix dev router:

```elixir
# mix.exs
{:localize_inputs_playground, "~> 0.1", only: :dev}

# router.ex
if Mix.env() == :dev do
  forward "/inputs", LocalizeInputsPlayground.Visualizer
end

# config/dev.exs — visualizer is gated to keep it out of prod by accident
config :localize_inputs_playground, visualizer: true
config :localize, allow_runtime_locale_download: true
```

## License

Apache-2.0. See [`LICENSE.md`](https://github.com/elixir-localize/localize_inputs/blob/main/LICENSE.md).
