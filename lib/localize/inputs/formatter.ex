defmodule Localize.Inputs.Formatter do
  @moduledoc """
  Server-side formatter for parsed number values.

  This is the *blur* formatter — what the server renders into
  the input's `value` attribute after a round-trip when the JS
  hook isn't active (Path A fallback) or for the initial server
  render. Live, as-you-type formatting is the JS hook's job.

  Delegates to `Localize.Number.to_string/2`; this module does
  no formatting of its own.

  """

  @doc """
  Formats a parsed value for display in a number input.

  ### Arguments

  * `value` is a `Decimal`, integer, float, locale-formatted
    string, or `nil`.

  * `options` is a keyword list of options.

  ### Options

  * `:locale` — the locale to format under. Defaults to
    `Localize.get_locale/0`.

  * All other options are passed through to
    `Localize.Number.to_string/2`.

  ### Returns

  * The locale-formatted string.

  * `""` when the value is `nil` or empty.

  ### Examples

      iex> Localize.Inputs.Formatter.format_number(Decimal.new("1234.56"), locale: :en)
      "1,234.56"

      iex> Localize.Inputs.Formatter.format_number(Decimal.new("1234.56"), locale: :de)
      "1.234,56"

      iex> Localize.Inputs.Formatter.format_number(nil)
      ""

  """
  @spec format_number(term(), Keyword.t()) :: String.t()
  def format_number(value, options \\ [])
  def format_number(nil, _options), do: ""
  def format_number("", _options), do: ""

  def format_number(value, options) when is_binary(value) do
    case Localize.Inputs.Parser.parse_number(value, options) do
      {:ok, nil} -> ""
      {:ok, parsed} -> format_number(parsed, options)
      {:error, _} -> value
    end
  end

  def format_number(value, options) do
    case Localize.Number.to_string(value, options) do
      {:ok, formatted} -> formatted
      _ -> to_string(value)
    end
  end
end
