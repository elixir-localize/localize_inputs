defmodule Localize.Inputs.Visualizer.InputView do
  @moduledoc false

  alias Localize.Inputs.{Components, Formatter, Locale, Parser, Validator}
  alias Localize.Inputs.Visualizer.Render

  def render(params, base) do
    locale = params.locale
    number_input = params.number_input

    number_result = parse_number_result(number_input, locale)
    {:ok, locale_data} = Locale.for_locale(locale)

    body = [
      "<section class=\"li-card\">",
      "<h2>Number Input Component</h2>",
      "<p class=\"li-desc\">Live HEEx render of ",
      "<code>Localize.Inputs.Components.number_input/1</code>.</p>",
      "<form method=\"get\" action=\"",
      Render.escape(base),
      "/input\" class=\"li-form\">",
      ~s(<input type="hidden" name="submitted" value="1">),
      Render.field(
        "Locale",
        Render.locale_select("locale", locale,
          reactive: true,
          always_include: [params.deployment_default_locale]
        )
      ),
      live_number_input_field(locale, number_input),
      "<div class=\"li-actions\">",
      "<button class=\"li-btn\" type=\"submit\">Parse &amp; format</button>",
      "<span class=\"li-hint\">Try ",
      sample_hint(locale_data),
      "</span>",
      "</div>",
      "</form>",
      "</section>",
      result_card("number_input result", number_result),
      code_card(locale),
      locale_card(locale_data),
      bootstrap_script(base)
    ]

    Render.page(title: "Input", active: "input", base: base, body: body)
  end

  defp live_number_input_field(locale, value) do
    form = make_form("number_input", value)

    assigns = %{
      form: form,
      field: :number_input,
      locale: locale,
      __changed__: nil,
      class: nil,
      input_class: nil,
      align: :left,
      integer: false,
      min: nil,
      max: nil,
      decimals: nil,
      placeholder: nil,
      js: true,
      value: nil,
      rest: %{}
    }

    rendered = Components.number_input(assigns)

    [
      "<div class=\"li-field li-field-wide\">",
      "<label>",
      "<span>Number input</span>",
      Phoenix.HTML.Safe.to_iodata(rendered),
      "</label>",
      "<small class=\"li-hint\">phx-hook=\"NumberInput\" — wraps AutoNumeric when present</small>",
      "</div>"
    ]
  end

  defp make_form(field, value) do
    params = %{to_string(field) => value || ""}
    Phoenix.HTML.FormData.to_form(params, as: nil)
  end

  defp result_card(_title, nil), do: ""

  defp result_card(title, rows) when is_list(rows) do
    rendered =
      Enum.map(rows, fn {label, value, css_class} ->
        [
          "<dt>",
          Render.escape(label),
          "</dt>",
          "<dd class=\"",
          Render.escape(css_class || ""),
          "\">",
          Render.escape(value),
          "</dd>"
        ]
      end)

    [
      "<section class=\"li-card\">",
      "<h2>",
      Render.escape(title),
      "</h2>",
      "<dl class=\"li-result\">",
      rendered,
      "</dl>",
      "</section>"
    ]
  end

  defp code_card(locale) do
    code = build_number_call(locale)

    [
      "<section class=\"li-card\">",
      "<h2>Component code</h2>",
      "<p class=\"li-desc\">The HEEx call site that renders the input above. ",
      "Copy straight into a LiveView template.</p>",
      "<pre class=\"li-code\">",
      Render.escape(code),
      "</pre>",
      "</section>"
    ]
  end

  defp build_number_call(locale) do
    """
    <.number_input
      form={@form}
      field={:quantity}
      locale=#{format_locale_attr(locale)}
    />\
    """
  end

  defp format_locale_attr(locale) when is_binary(locale), do: ~s("#{locale}")
  defp format_locale_attr(locale) when is_atom(locale), do: ~s(:#{locale})

  defp locale_card(locale_data) do
    [
      "<section class=\"li-card\">",
      "<h2>Resolved locale data</h2>",
      "<p class=\"li-desc\">What <code>Localize.Inputs.Locale.for_locale/1</code> ",
      "returns for the current locale — the data the JS hook reads from ",
      "<code>data-</code> attributes.</p>",
      Render.code(locale_data)
    ]
  end

  defp parse_number_result(nil, _locale), do: nil
  defp parse_number_result("", _locale), do: nil

  defp parse_number_result(value, locale) do
    case Parser.parse_number(value, locale: locale) do
      {:ok, nil} ->
        nil

      {:ok, parsed} ->
        canonical = Parser.to_canonical(parsed)
        formatted = Formatter.format_number(parsed, locale: locale)
        validation = Validator.validate_number(parsed)

        [
          {"Input", value, nil},
          {"Parsed (Decimal)", inspect(parsed), nil},
          {"Canonical wire value", canonical, nil},
          {"Blur format (#{locale})", formatted, nil},
          {"Validation", inspect(validation), validation_css(validation)}
        ]

      {:error, reason} ->
        [
          {"Input", value, nil},
          {"Error", inspect(reason), "li-bad"}
        ]
    end
  end

  defp validation_css(:ok), do: nil
  defp validation_css(_), do: "li-bad"

  defp sample_hint(%{decimal: dec, group: grp}) do
    "1#{grp}234#{dec}56"
  end

  defp bootstrap_script(base) do
    [
      "<script src=\"https://cdn.jsdelivr.net/npm/autonumeric@4.10.0/dist/autoNumeric.min.js\"></script>",
      "<script type=\"module\">",
      "import Hooks from \"",
      Render.escape(base),
      "/assets/localize_inputs.js\";\n",
      "Hooks.configure({ AutoNumeric: window.AutoNumeric });\n",
      "function mount(selector, hook) {\n",
      "  document.querySelectorAll(selector).forEach(el => {\n",
      "    const instance = Object.assign(Object.create(hook), { el });\n",
      "    instance.mounted();\n",
      "  });\n",
      "}\n",
      "mount('[phx-hook=\"NumberInput\"]', Hooks.NumberInput);\n",
      "document.querySelectorAll('[data-li-reactive]').forEach(el => {\n",
      "  el.addEventListener('change', () => {\n",
      "    const form = el.closest('form');\n",
      "    if (form) form.submit();\n",
      "  });\n",
      "});\n",
      "</script>"
    ]
  end
end
