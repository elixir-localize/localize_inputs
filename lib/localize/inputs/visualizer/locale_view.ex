defmodule Localize.Inputs.Visualizer.LocaleView do
  @moduledoc false

  alias Localize.Inputs.Locale
  alias Localize.Inputs.Visualizer.Render

  def render(_params, base) do
    rows =
      for {locale, label} <- Render.locale_options() do
        {locale, label, Locale.for_locale(locale)}
      end

    body = [
      "<section class=\"li-card\">",
      "<h2>Locale display data</h2>",
      "<p class=\"li-desc\">For every demo locale, the snapshot that ",
      "<code>Localize.Inputs.Locale.for_locale/1</code> returns.</p>",
      table(rows),
      "</section>"
    ]

    Render.page(title: "Locale", active: "locale", base: base, body: body)
  end

  defp table(rows) do
    [
      "<table class=\"li-table\"><thead><tr>",
      "<th>Locale</th><th>Decimal</th><th>Group</th><th>Minus</th><th>Digits</th>",
      "</tr></thead><tbody>",
      Enum.map(rows, &row/1),
      "</tbody></table>"
    ]
  end

  defp row({locale, label, {:ok, data}}) do
    [
      "<tr><td>",
      Render.escape(locale),
      " <small>(",
      Render.escape(label),
      ")</small></td><td class=\"li-mono\">",
      Render.escape(data.decimal),
      "</td><td class=\"li-mono\">",
      Render.escape(data.group),
      "</td><td class=\"li-mono\">",
      Render.escape(data.minus_sign),
      "</td><td class=\"li-mono\">",
      Render.escape(to_string(data.number_system)),
      "</td></tr>"
    ]
  end

  defp row({locale, label, {:error, reason}}) do
    [
      "<tr><td>",
      Render.escape(locale),
      " <small>(",
      Render.escape(label),
      ")</small></td><td colspan=\"4\" class=\"li-bad li-mono\">",
      Render.escape(inspect(reason)),
      "</td></tr>"
    ]
  end
end
