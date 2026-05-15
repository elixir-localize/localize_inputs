defmodule Localize.Inputs do
  @moduledoc """
  Locale-aware HTML form input components.

  The first component is `Localize.Inputs.Components.number_input/1`
  — a locale-aware plain-number input. The library is structured
  so additional locale-aware inputs (percentages, ratios,
  durations, dimensions, …) can be added under the same
  `Localize.Inputs.Components` namespace over time.

  The package ships three layers:

  1. **Headless** — `Localize.Inputs.Parser`,
     `Localize.Inputs.Validator`, `Localize.Inputs.Locale`.
     Pure Elixir, no Phoenix dependency. Useful from JSON APIs
     or non-LiveView projects. Number formatting goes through
     `Localize.Number.to_string/2` directly — there is no
     wrapper here.

  2. **Phoenix integration** — `Localize.Inputs.Components`
     (HEEx components) and `Localize.Inputs.Changeset` (Ecto
     helpers).

  3. **JS hook** — `priv/static/localize_inputs.js` wraps
     [AutoNumeric](https://autonumeric.org/) for live formatting,
     cursor preservation, paste sanitisation. Drop-in for
     `Phoenix.LiveView` hooks.

  For a Plug-based visualizer that demos the component across
  CLDR locales, see the sibling
  [`localize_inputs_playground`](https://github.com/elixir-localize/localize_inputs_playground)
  package — useful during local development, deployable to Fly.io.

  ## Quick examples

      iex> Localize.Inputs.Parser.parse_number("1.234,56", locale: :de)
      {:ok, Decimal.new("1234.56")}

      iex> Localize.Number.to_string!(Decimal.new("1234.56"), locale: :en)
      "1,234.56"

  """

  @doc """
  Returns the installed package version as a string.

  ### Returns

  * The version string declared in `mix.exs`.

  ### Examples

      iex> Localize.Inputs.version() |> Version.parse!()
      iex> :ok
      :ok

  """
  @spec version() :: String.t()
  def version do
    Application.spec(:localize_inputs, :vsn) |> to_string()
  end
end
