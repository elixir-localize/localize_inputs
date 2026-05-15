# Integrating Localize.Inputs into a Phoenix app

This guide walks through adding `localize_inputs` to an existing Phoenix 1.7+ / LiveView 1.0+ project, end-to-end: Elixir deps, JavaScript deps, asset wiring, a schema with a number field, a LiveView using the component, and a quick smoke test.

If you only need the headless parser / validator (no Phoenix), skip to [Headless API](#headless-api-no-phoenix) at the bottom.

---

## 1. Elixir dependencies

Add the package and its optional partners to `mix.exs`. Only the first line is strictly required; the others are pulled in automatically by a Phoenix project but listed here for clarity.

```elixir
def deps do
  [
    {:localize_inputs, "~> 0.2"},

    # The component is activated when these are present:
    {:phoenix_html,      "~> 4.0"},
    {:phoenix_live_view, "~> 1.0"},

    # The changeset helper activates when this is present:
    {:ecto,              "~> 3.10"}
  ]
end
```

Run `mix deps.get`.

> Each optional dep is gated by `Code.ensure_loaded?/1`, so the headless layer compiles cleanly without any of them. You won't get "missing module" warnings.

---

## 2. JavaScript dependencies

The live-formatting JS hook wraps [AutoNumeric](https://autonumeric.org/) by Alexandre Bonneau (MIT-licensed) — battle-tested cursor preservation, paste sanitisation, and per-locale separator handling. We don't reimplement any of that; the hook is a thin adapter that configures AutoNumeric from the component's locale data and lets it run. Credit where it's due.

Install it in your `assets/` directory:

```bash
cd assets
npm install autonumeric
```

> AutoNumeric is **~50 KB minified, gzipped**. If you object to that and prefer the no-JS fallback (server-side blur formatting only), skip this step — the component still works, you just don't get cursor-preserving live formatting.

---

## 3. Wire the JS hook into `app.js`

In `assets/js/app.js`:

```javascript
import {Socket}           from "phoenix"
import {LiveSocket}       from "phoenix_live_view"
import AutoNumeric        from "autonumeric"
import LocalizeInputHooks from "localize_inputs"

// Tell the hooks where to find AutoNumeric. If you skip this
// the hook degrades to the no-JS baseline (no live formatting).
LocalizeInputHooks.configure({ AutoNumeric })

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    NumberInput: LocalizeInputHooks.NumberInput
  }
})

liveSocket.connect()
window.liveSocket = liveSocket
```

The `localize_inputs` package ships ESM. Most projects already have `esbuild` configured to pull `node_modules` resolution — if yours doesn't, point esbuild at the file path:

```javascript
import LocalizeInputHooks from "../../deps/localize_inputs/priv/static/localize_inputs.js"
```

---

## 4. Wire the CSS

The component ships a small CSS file with sensible defaults (uses CSS custom properties — easy to theme). Import it in `assets/css/app.css`:

```css
@import "../../deps/localize_inputs/priv/static/localize_inputs.css";
```

The file defines a small palette of CSS variables you can override in your own stylesheet to match your design system. The component emits semantic class names (`number-input-wrapper`, `number-input-field`) so a Tailwind project can also rebuild the styles from scratch.

---

## 5. Configure your schema

For an `Ecto` schema with number fields, plain `:integer` and `:decimal` field types are fine — the submitted form value is a *locale-formatted string* (see §7), which `Localize.Inputs.Changeset.validate_number/3` knows how to parse before validating.

```elixir
defmodule MyApp.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name,     :string
    field :quantity, :integer
    field :rating,   :decimal

    timestamps()
  end

  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :quantity, :rating])
    |> validate_required([:name, :quantity])
    |> Localize.Inputs.Changeset.validate_number(:quantity, min: 1, max: 999)
    |> Localize.Inputs.Changeset.validate_number(:rating,   min: 0, max: 5, decimals: 1)
  end
end
```

`Localize.Inputs.Changeset.validate_number/3` wraps `Localize.Inputs.Validator.validate_number/2` — `:required`, `:min`, `:max`, `:decimals` options.

> If your form posts a locale-formatted value (which is what `<.number_input>` submits — see §7), parse it explicitly with `Localize.Inputs.Parser.parse_number/2` before `cast/3`, OR cast through a virtual field that holds the string then run `validate_number/3`. The validator itself expects a numeric value (`Decimal`/integer/nil), not the raw locale string. A future release may collapse the parse + validate step.

---

## 6. Render the component in a LiveView

```elixir
defmodule MyAppWeb.ProductFormLive do
  use MyAppWeb, :live_view
  import Localize.Inputs.Components

  alias MyApp.Catalog.{Product, Products}

  def mount(_params, _session, socket) do
    changeset = Products.change_product(%Product{})
    {:ok, assign(socket, form: to_form(changeset))}
  end

  def handle_event("validate", %{"product" => attrs}, socket) do
    changeset =
      %Product{}
      |> Products.change_product(attrs)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"product" => attrs}, socket) do
    case Products.create_product(attrs) do
      {:ok, _} ->
        {:noreply, put_flash(socket, :info, "Saved")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <.form for={@form} phx-change="validate" phx-submit="save">
      <.input field={@form[:name]} label="Name" />

      <.number_input form={@form} field={:quantity} integer={true} min={1} max={999} />
      <.number_input form={@form} field={:rating}   min={0} max={5} decimals={1} />

      <button type="submit">Save</button>
    </.form>
    """
  end
end
```

---

## 7. What gets submitted

The `<.number_input>` field submits a **single string value** — exactly what the user sees in the input box, locale-formatted:

```
params["product"] = %{
  "quantity" => "1.234",        # de locale: "1,234" in en
  "rating"   => "4,5"           # de locale: "4.5" in en
}
```

This is the same shape whether AutoNumeric is loaded (Path B) or not (Path A). The server parses it using the locale you pass to `Localize.Inputs.Parser.parse_number/2` or `Localize.Inputs.Changeset.validate_number/3`. There's no canonical-vs-locale ambiguity on the wire — one shape, parsed once.

---

## 7a. Why the wire format is locale-formatted (not canonical)

Some form-input libraries take a different approach: the JS hook rewrites the input value to a canonical form (`"1234.56"`, dot decimal, no grouping) immediately before submit, so the server always receives the same shape regardless of locale. Call that **Option B**. It's a reasonable choice, but it has costs:

* The server needs two parsers — one for the canonical wire format, one for whatever the user actually typed if JS is disabled, broken, or hadn't booted yet. The two paths drift.

* In some locales the decimal and group separators are each other's mirror (`de` uses `.` for grouping and `,` for decimal; `en` is the inverse). A bug in the canonicaliser silently produces a 1000× wrong number.

* The "canonical" shape is a hidden third format that exists only on the wire. It isn't what the user sees, isn't what the server stores, and isn't what tests assert against.

This library uses **Option A**: the JS hook never touches the value at submit time. Whatever AutoNumeric is currently displaying — locale-formatted, exactly as the user reads it — is what the form serialises. The server parses it with the locale you already have. Path A (no JS) and Path B (AutoNumeric loaded) produce *byte-identical* submissions for the same input.

Trade-off: the server must know the locale to parse the value. In practice you already do (it's in the session, assigns, or `Localize.get_locale/0`), so this is rarely a real cost.

If you're porting from an Option B library, the thing to double-check is that you're passing `:locale` to `Localize.Inputs.Parser.parse_number/2` — without it the parser falls back to `Localize.get_locale/0`, which may not match the form's displayed locale.

---

## 8. Try the visualizer (optional)

Want to preview the component across every CLDR locale without setting up a project? The sibling [`localize_inputs_playground`](https://github.com/elixir-localize/localize_inputs_playground) package is a Plug.Router + Bandit wrapper around the visualizer.

To run it locally, clone the playground repo and:

```bash
cd localize_inputs_playground
mix deps.get
mix run --no-halt
# Visit http://localhost:8080
```

To mount it inside your own Phoenix dev router, add the playground as a dev-only dep and forward to its visualizer:

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

---

## 9. Smoke test

A quick LiveViewTest that verifies the form round-trips a locale-formatted value:

```elixir
defmodule MyAppWeb.ProductFormLiveTest do
  use MyAppWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "submits quantity as the locale-formatted string", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/products/new")

    view
    |> form("#product-form", product: %{
        name: "Widget",
        quantity: "1.234",  # de-formatted = 1234
        rating: "4,5"       # de-formatted = 4.5
      })
    |> render_submit()

    [product] = MyApp.Catalog.list_products()
    assert product.quantity == 1234
    assert Decimal.equal?(product.rating, Decimal.new("4.5"))
  end
end
```

---

## Headless API (no Phoenix)

If you don't need the component, the package's parser/validator/number-display modules work standalone. Formatting goes through `Localize.Number.to_string/2` directly — there's no wrapper:

```elixir
{:ok, %Decimal{} = decimal} =
  Localize.Inputs.Parser.parse_number("1.234,56", locale: :de)
#=> {:ok, Decimal.new("1234.56")}

Localize.Number.to_string!(decimal, locale: :en)
#=> "1,234.56"

:ok = Localize.Inputs.Validator.validate_number(decimal, min: 0, max: 9999)

{:ok, info} = Localize.Inputs.Number.number_for_locale(:de)
info.decimal        #=> ","
info.group          #=> "."
info.number_system  #=> :latn
info.minus_sign     #=> "-"
```

No Phoenix, no Ecto, no JS — just the locale-aware data layer.

---

## Troubleshooting

**AutoNumeric isn't formatting.** Check the browser console: you should see no errors and the input should have an `autonumeric` class added by AutoNumeric. If neither, confirm `LocalizeInputHooks.configure({ AutoNumeric })` runs **before** `new LiveSocket(...)`.

**The server receives an unparseable value in dev.** Make sure `config :localize, allow_runtime_locale_download: true` is set in `config/dev.exs` if the user is on a locale that wasn't pre-compiled into your build. Without it, an unknown locale can produce an empty separator set and `parse_number/2` will struggle to recognise the input.

**My visualizer shows `nil` for some locales.** Same fix — set `allow_runtime_locale_download` so CLDR data is fetched on demand.

**Negative numbers from copy-paste don't parse.** `Localize.Inputs.Parser.parse_number/2` accepts the locale's canonical minus character plus common typographic variants (en-dash, em-dash, true Unicode minus). Accounting parens (`(1234.56)` → `-1234.56`) are also supported. If you see something else slipping through, file an issue.
