defmodule Localize.Inputs.Visualizer.ParseView do
  @moduledoc false

  alias Localize.Inputs.{Formatter, Parser}
  alias Localize.Inputs.Visualizer.Render

  def render(params, base) do
    input = params.input

    rows =
      for {locale, label} <- Render.locale_options() do
        {locale, label, Parser.parse_number(input, locale: locale)}
      end

    body = [
      "<section class=\"li-card\">",
      "<h2>Cross-locale parsing</h2>",
      "<p class=\"li-desc\">Same input, every locale. Demonstrates how ",
      "<code>Localize.Inputs.Parser</code> interprets the decimal and ",
      "grouping separators per locale.</p>",
      "<form method=\"get\" action=\"",
      Render.escape(base),
      "/parse\" class=\"li-form\">",
      "<div class=\"li-field li-field-wide\">",
      "<label><span>Input</span>",
      ~s(<input type="text" name="input" value="),
      Render.escape(input),
      ~s(" autocomplete="off"></label>),
      "</div>",
      "<div class=\"li-actions\">",
      "<button class=\"li-btn\" type=\"submit\">Parse across locales</button>",
      "<span class=\"li-hint\">Try <code>1,234.56</code>, <code>1.234,56</code>, ",
      "<code>1 234,56</code>, <code>(1234.56)</code></span>",
      "</div>",
      "</form>",
      result_table(rows),
      "</section>"
    ]

    Render.page(title: "Parse", active: "parse", base: base, body: body)
  end

  defp result_table(rows) do
    [
      "<table class=\"li-table\"><thead><tr>",
      "<th>Locale</th><th>Result</th><th>Canonical</th><th>Round-trip</th>",
      "</tr></thead><tbody>",
      Enum.map(rows, &result_row/1),
      "</tbody></table>"
    ]
  end

  defp result_row({locale, label, {:ok, nil}}) do
    [
      "<tr><td>",
      Render.escape(locale),
      " <small>(",
      Render.escape(label),
      ")</small></td><td colspan=\"3\"><em>(empty)</em></td></tr>"
    ]
  end

  defp result_row({locale, label, {:ok, value}}) do
    canonical = Parser.to_canonical(value)
    round_trip = Formatter.format_number(value, locale: locale)

    [
      "<tr><td>",
      Render.escape(locale),
      " <small>(",
      Render.escape(label),
      ")</small></td><td class=\"li-mono\">",
      Render.escape(describe_value(value)),
      "</td><td class=\"li-mono\">",
      Render.escape(canonical),
      "</td><td class=\"li-mono\">",
      Render.escape(round_trip),
      "</td></tr>"
    ]
  end

  defp result_row({locale, label, {:error, reason}}) do
    [
      "<tr><td>",
      Render.escape(locale),
      " <small>(",
      Render.escape(label),
      ")</small></td><td colspan=\"3\" class=\"li-bad li-mono\">",
      Render.escape(inspect(reason)),
      "</td></tr>"
    ]
  end

  defp describe_value(%Decimal{} = decimal), do: Decimal.to_string(decimal, :normal)
  defp describe_value(value), do: inspect(value)
end
