if Code.ensure_loaded?(Phoenix.Component) do
  defmodule Localize.Inputs.Components do
    @moduledoc """
    HEEx components for locale-aware form input.

    Today: `number_input/1`. More inputs (percentage, ratio,
    dimension, …) will land here over time under the same
    namespace.

    ## Setup

    Add the JS hook in your `assets/js/app.js`:

        import Hooks from "localize_inputs"
        let liveSocket = new LiveSocket("/live", Socket, {
          hooks: { NumberInput: Hooks.NumberInput }
        })

    Install AutoNumeric as a peer dep:

        npm install autonumeric

    """

    use Phoenix.Component

    alias Localize.Inputs.{Formatter, Locale}

    @doc """
    Locale-aware plain-number input.

    Renders an `<input type="text" inputmode="decimal">` wrapped
    in a `<div>` that carries `data-` attributes the JS hook
    reads (locale, separators, minus sign, min/max, decimals).
    With AutoNumeric loaded the input live-formats as the user
    types; without it, the server-side parser
    (`Localize.Inputs.Parser`) accepts whatever the user typed
    on submit.

    The form value submits as the canonical period-decimal form
    on submit (e.g. `"1234.56"`), suitable for casting straight
    into a `Decimal` or `:integer` Ecto field.

    ### Arguments

    * `assigns` — see the per-attribute documentation below.

    ### Attributes

    * `:form` — the `Phoenix.HTML.Form` the field belongs to.

    * `:field` — the form field as an atom.

    * `:locale` — display locale. Defaults to
      `Localize.get_locale/0`.

    * `:integer` — when `true`, accept integers only and emit
      `inputmode="numeric"`.

    * `:min`, `:max` — value bounds.

    * `:decimals` — maximum fractional digits.

    * `:align` — `:left` (default), `:right`, or `:center`.

    * `:placeholder` — placeholder text.

    * `:js` — set to `false` to skip the `phx-hook` attribute.

    * `:class`, `:input_class` — extra classes for the wrapper
      and the input.

    ### Returns

    * A `Phoenix.LiveView.Rendered` struct containing the input
      markup.

    ### Examples

        <.number_input form={@form} field={:quantity} integer={true} min={1} max={999} />
        <.number_input form={@form} field={:rating} min={0} max={5} decimals={1} />

    """
    attr(:form, Phoenix.HTML.Form, required: true)
    attr(:field, :atom, required: true)
    attr(:value, :any, default: nil)
    attr(:locale, :string, default: nil)
    attr(:integer, :boolean, default: false)
    attr(:min, :any, default: nil)
    attr(:max, :any, default: nil)
    attr(:decimals, :integer, default: nil)
    attr(:align, :atom, default: :left, values: [:left, :right, :center])
    attr(:placeholder, :string, default: nil)
    attr(:js, :boolean, default: true)
    attr(:class, :string, default: nil)
    attr(:input_class, :string, default: nil)
    attr(:rest, :global, include: ~w(disabled readonly required autofocus))

    def number_input(assigns) do
      assigns = assigns |> assign_common() |> assign_number_value()

      ~H"""
      <div
        class={["number-input-wrapper", @class]}
        data-locale-input="number"
        data-locale={@locale_data.locale}
        data-decimal={@locale_data.decimal}
        data-group={@locale_data.group}
        data-number-system={@locale_data.number_system}
        data-minus={@locale_data.minus_sign}
        data-integer={to_string(@integer)}
        data-decimals={@decimals}
        data-min={value_attr(@min)}
        data-max={value_attr(@max)}
        phx-hook={if @js, do: "NumberInput"}
        id={"#{@id}-wrapper"}
      >
        <input
          type="text"
          inputmode={if @integer, do: "numeric", else: "decimal"}
          name={@name}
          id={@id}
          value={@formatted_value}
          class={["number-input-field", text_align_class(@align), @input_class]}
          autocomplete="off"
          dir="ltr"
          placeholder={@placeholder}
          {@rest}
        />
      </div>
      """
    end

    # ── Internal: shared assigns ──────────────────────────────

    defp assign_common(assigns) do
      locale = assigns[:locale] || Localize.get_locale()

      {:ok, locale_data} = Locale.for_locale(locale)

      field_struct = assigns.form[assigns.field]
      name = field_struct.name
      id = field_struct.id

      assigns
      |> assign(:locale, locale)
      |> assign(:locale_data, locale_data)
      |> assign(:name, name)
      |> assign(:id, id)
      |> assign_new(:placeholder, fn -> nil end)
      |> assign_new(:class, fn -> nil end)
      |> assign_new(:input_class, fn -> nil end)
    end

    defp assign_number_value(assigns) do
      explicit = assigns.value
      form_value = (assigns.form[assigns.field] || %{}).value

      raw = explicit || form_value
      formatted = Formatter.format_number(raw, locale: assigns.locale)

      assign(assigns, :formatted_value, formatted)
    end

    defp value_attr(nil), do: nil
    defp value_attr(value), do: to_string(value)

    defp text_align_class(:left), do: "text-left"
    defp text_align_class(:center), do: "text-center"
    defp text_align_class(:right), do: "text-right"
  end
end
