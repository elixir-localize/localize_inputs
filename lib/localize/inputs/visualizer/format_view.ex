defmodule Localize.Inputs.Visualizer.FormatView do
  @moduledoc false

  alias Localize.Inputs.Formatter
  alias Localize.Inputs.Visualizer.Render

  def render(params, base) do
    amount = params.amount

    rows =
      for {locale, label} <- Render.locale_options() do
        decimal = parse_decimal(amount)
        {locale, label, decimal && Formatter.format_number(decimal, locale: locale)}
      end

    body = [
      "<section class=\"li-card\">",
      "<h2>Cross-locale formatting</h2>",
      "<p class=\"li-desc\">Same parsed value, every locale.</p>",
      "<form method=\"get\" action=\"",
      Render.escape(base),
      "/format\" class=\"li-form\">",
      Render.field(
        "Amount (canonical form)",
        [
          ~s(<input type="text" name="amount" value="),
          Render.escape(amount),
          ~s(" autocomplete="off">)
        ],
        hint: "Period as decimal, no grouping — e.g. 1234567.89"
      ),
      "<div class=\"li-actions\">",
      "<button class=\"li-btn\" type=\"submit\">Format across locales</button>",
      "</div>",
      "</form>",
      result_table(rows),
      "</section>"
    ]

    Render.page(title: "Format", active: "format", base: base, body: body)
  end

  defp result_table(rows) do
    [
      "<table class=\"li-table\"><thead><tr><th>Locale</th><th>",
      "Localize.Number.to_string/2",
      "</th></tr></thead><tbody>",
      Enum.map(rows, &result_row/1),
      "</tbody></table>"
    ]
  end

  defp result_row({locale, label, nil}) do
    [
      "<tr><td>",
      Render.escape(locale),
      " <small>(",
      Render.escape(label),
      ")</small></td><td><em>(invalid input)</em></td></tr>"
    ]
  end

  defp result_row({locale, label, formatted}) do
    [
      "<tr><td>",
      Render.escape(locale),
      " <small>(",
      Render.escape(label),
      ")</small></td><td class=\"li-mono\">",
      Render.escape(formatted),
      "</td></tr>"
    ]
  end

  defp parse_decimal(""), do: nil
  defp parse_decimal(nil), do: nil

  defp parse_decimal(value) when is_binary(value) do
    case Decimal.parse(value) do
      {decimal, ""} -> decimal
      _ -> nil
    end
  end
end
