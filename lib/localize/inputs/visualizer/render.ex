defmodule Localize.Inputs.Visualizer.Render do
  @moduledoc false

  # Shared HTML helpers for the visualizer. Pure functions,
  # iodata in / iodata out. Mirrors the structure of
  # Money.Input.Visualizer.Render so the two apps feel
  # identical.

  @doc "HTML-escapes a binary or iodata."
  @spec escape(iodata() | term()) :: iodata()
  def escape(iodata) when is_list(iodata), do: Enum.map(iodata, &escape/1)

  def escape(binary) when is_binary(binary) do
    binary
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
  end

  def escape(other), do: escape(to_string(other))

  def page(assigns) do
    title = Keyword.fetch!(assigns, :title)
    active = Keyword.fetch!(assigns, :active)
    body = Keyword.fetch!(assigns, :body)
    base = Keyword.fetch!(assigns, :base)
    error = Keyword.get(assigns, :error)

    [
      "<!doctype html><html lang=\"en\">",
      "<head>",
      "<meta charset=\"utf-8\">",
      "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
      "<title>",
      escape(title),
      " — Localize.Inputs.Visualizer</title>",
      "<link rel=\"stylesheet\" href=\"",
      escape(base),
      "/assets/localize_inputs.css\">",
      "<link rel=\"stylesheet\" href=\"",
      escape(base),
      "/assets/style.css\">",
      theme_init_script(),
      "</head><body>",
      header(active, base),
      "<main class=\"li-main\">",
      error_block(error),
      body,
      footer(),
      "</main>",
      theme_toggle_script(),
      "</body></html>"
    ]
  end

  defp header(active, base) do
    tabs = [
      {"input", "Input"},
      {"parse", "Parse"},
      {"format", "Format"},
      {"locale", "Locale"}
    ]

    [
      "<header class=\"li-header\">",
      "<div class=\"li-header-top\">",
      "<a class=\"li-brand\" href=\"",
      escape(base),
      "/\">",
      "<div class=\"li-brand-text\">",
      "<h1>Localize.Inputs.Visualizer</h1>",
      "<p>locale-aware number input — try how it behaves across locales</p>",
      "</div>",
      "</a>",
      theme_toggle(),
      "</div>",
      "<nav class=\"li-tabs\">",
      Enum.map(tabs, fn {path, label} ->
        cls = if path == active, do: "active", else: ""

        [
          "<a href=\"",
          escape(base),
          "/",
          path,
          "\" class=\"",
          cls,
          "\">",
          label,
          "</a>"
        ]
      end),
      "</nav>",
      "</header>"
    ]
  end

  defp error_block(nil), do: ""

  defp error_block(message) do
    ["<div class=\"li-error\">", escape(to_string(message)), "</div>"]
  end

  defp footer do
    [
      "<footer class=\"li-footer\">",
      "<p>Headless API: <code>Localize.Inputs.Parser</code>, ",
      "<code>Localize.Inputs.Formatter</code>, ",
      "<code>Localize.Inputs.Validator</code>, ",
      "<code>Localize.Inputs.Locale</code>.</p>",
      "</footer>"
    ]
  end

  defp theme_toggle do
    """
    <div class="li-theme-toggle" data-li-theme-toggle data-active="system" role="group" aria-label="Theme">
      <button type="button" data-theme-choice="system" aria-pressed="true" aria-label="Use system theme" title="System">
        <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="4" width="18" height="13" rx="2"/><path d="M8 21h8M12 17v4"/></svg>
      </button>
      <button type="button" data-theme-choice="light" aria-pressed="false" aria-label="Use light theme" title="Light">
        <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/></svg>
      </button>
      <button type="button" data-theme-choice="dark" aria-pressed="false" aria-label="Use dark theme" title="Dark">
        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
      </button>
      <span class="li-theme-toggle-thumb" aria-hidden="true"></span>
    </div>
    """
  end

  defp theme_init_script do
    """
    <script>
      (function () {
        try {
          var saved = localStorage.getItem('localize_inputs:theme');
          if (saved === 'light' || saved === 'dark') {
            document.documentElement.setAttribute('data-theme', saved);
          }
        } catch (_) { /* private mode, ignore */ }
      })();
    </script>
    """
  end

  defp theme_toggle_script do
    """
    <script>
      (function () {
        var STORAGE_KEY = 'localize_inputs:theme';
        var toggle = document.querySelector('[data-li-theme-toggle]');
        if (!toggle) return;
        function active() {
          try {
            var saved = localStorage.getItem(STORAGE_KEY);
            return (saved === 'light' || saved === 'dark') ? saved : 'system';
          } catch (_) { return 'system'; }
        }
        function apply(choice) {
          try {
            if (choice === 'system') {
              localStorage.removeItem(STORAGE_KEY);
              document.documentElement.removeAttribute('data-theme');
            } else {
              localStorage.setItem(STORAGE_KEY, choice);
              document.documentElement.setAttribute('data-theme', choice);
            }
          } catch (_) {
            if (choice === 'system') document.documentElement.removeAttribute('data-theme');
            else document.documentElement.setAttribute('data-theme', choice);
          }
          toggle.setAttribute('data-active', choice);
          toggle.querySelectorAll('button').forEach(function (btn) {
            btn.setAttribute('aria-pressed', btn.getAttribute('data-theme-choice') === choice ? 'true' : 'false');
          });
        }
        apply(active());
        toggle.addEventListener('click', function (e) {
          var btn = e.target.closest('button[data-theme-choice]');
          if (!btn) return;
          apply(btn.getAttribute('data-theme-choice'));
        });
      })();
    </script>
    """
  end

  @doc "Render a locale <select>."
  def locale_select(name, selected, options \\ []) do
    reactive = if Keyword.get(options, :reactive, false), do: " data-li-reactive", else: ""
    extras = [selected | Keyword.get(options, :always_include, [])]
    locales = ensure_all_in_list(locale_options(), extras)

    [
      "<select name=\"",
      escape(name),
      "\"",
      reactive,
      ">",
      Enum.map(locales, fn {value, label} ->
        sel = if to_string(value) == to_string(selected), do: " selected", else: ""

        [
          "<option value=\"",
          escape(value),
          "\"",
          sel,
          ">",
          escape(label),
          "</option>"
        ]
      end),
      "</select>"
    ]
  end

  defp ensure_all_in_list(locales, extras) do
    extras
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.map(&to_string/1)
    |> Enum.uniq()
    |> Enum.reverse()
    |> Enum.reduce(locales, &prepend_if_missing/2)
  end

  defp prepend_if_missing(locale_id, locales) do
    if Enum.any?(locales, fn {value, _} -> to_string(value) == locale_id end) do
      locales
    else
      [{locale_id, locale_label_for(locale_id)} | locales]
    end
  end

  defp locale_label_for(locale_id) do
    case locale_display_name(locale_id) do
      {:ok, name} -> name
      _ -> locale_id
    end
  end

  defp locale_display_name(locale_id) do
    Localize.Locale.LocaleDisplay.display_name(locale_id)
  rescue
    _ -> :error
  catch
    _, _ -> :error
  end

  @doc "Curated list of demo locales."
  def locale_options do
    [
      {"en", "English (US)"},
      {"en-GB", "English (UK)"},
      {"en-IN", "English (India)"},
      {"de", "German (Germany)"},
      {"de-CH", "German (Switzerland)"},
      {"fr", "French (France)"},
      {"fr-CH", "French (Switzerland)"},
      {"es", "Spanish (Spain)"},
      {"pt-BR", "Portuguese (Brazil)"},
      {"it", "Italian"},
      {"ja", "Japanese"},
      {"zh-Hans", "Chinese (Simplified)"},
      {"ar", "Arabic"},
      {"fa", "Persian"},
      {"he", "Hebrew"},
      {"ru", "Russian"},
      {"sv", "Swedish"},
      {"pl", "Polish"}
    ]
  end

  @doc "Renders a labelled form row."
  def field(label, control, opts \\ []) do
    hint = Keyword.get(opts, :hint)

    [
      "<div class=\"li-field\">",
      "<label>",
      "<span>",
      escape(label),
      "</span>",
      control,
      "</label>",
      if(hint, do: ["<small class=\"li-hint\">", escape(hint), "</small>"], else: ""),
      "</div>"
    ]
  end

  @doc "Pretty-prints an Elixir term."
  def code(term) do
    ["<pre class=\"li-code\">", escape(inspect(term, pretty: true, width: 60)), "</pre>"]
  end
end
