defmodule Localize.Inputs.Validator do
  @moduledoc """
  Server-side validation for parsed number values.

  Pure Elixir, no Ecto dependency. The Ecto changeset bridge is
  in `Localize.Inputs.Changeset`.

  """

  alias Localize.Inputs.ValidationError

  @doc """
  Validates a parsed number against bounds, precision, and
  required-ness.

  ### Arguments

  * `value` is a `Decimal`, integer, or `nil`.

  * `options` is a keyword list of options.

  ### Options

  * `:required` — when `true`, `nil` is rejected.

  * `:min` — minimum allowed value (any numeric form the parser
    accepts).

  * `:max` — maximum allowed value.

  * `:decimals` — maximum number of fractional digits.

  ### Returns

  * `:ok` when every check passes.

  * `{:error, %Localize.Inputs.ValidationError{errors: [{atom(),
    String.t()}]}}` with one entry per failing check, in the
    order `:required`, `:min`, `:max`, `:decimals`.
    `Localize.Inputs.Changeset.validate_number/3` unpacks the
    entries into per-field changeset errors.

  ### Examples

      iex> Localize.Inputs.Validator.validate_number(Decimal.new("5"), min: 1, max: 10)
      :ok

      iex> {:error, %Localize.Inputs.ValidationError{errors: errors}} =
      ...>   Localize.Inputs.Validator.validate_number(Decimal.new("15"), max: 10)
      iex> errors
      [{:max, "must be at most 10"}]

      iex> {:error, %Localize.Inputs.ValidationError{errors: errors}} =
      ...>   Localize.Inputs.Validator.validate_number(nil, required: true)
      iex> errors
      [{:required, "is required"}]

  """
  @spec validate_number(term(), Keyword.t()) :: :ok | {:error, ValidationError.t()}
  def validate_number(value, options \\ []) do
    errors =
      []
      |> check_required(value, options)
      |> check_range(value, options)
      |> check_decimals(value, options)
      |> Enum.reverse()

    if errors == [], do: :ok, else: {:error, ValidationError.exception(errors: errors)}
  end

  defp check_required(errors, nil, options) do
    if Keyword.get(options, :required, false) do
      [{:required, "is required"} | errors]
    else
      errors
    end
  end

  defp check_required(errors, _value, _options), do: errors

  defp check_range(errors, nil, _options), do: errors

  defp check_range(errors, value, options) do
    errors
    |> maybe_check_min(value, Keyword.get(options, :min))
    |> maybe_check_max(value, Keyword.get(options, :max))
  end

  defp maybe_check_min(errors, _value, nil), do: errors

  defp maybe_check_min(errors, value, min) do
    if compare(value, min) == :lt do
      [{:min, "must be at least #{describe(min)}"} | errors]
    else
      errors
    end
  end

  defp maybe_check_max(errors, _value, nil), do: errors

  defp maybe_check_max(errors, value, max) do
    if compare(value, max) == :gt do
      [{:max, "must be at most #{describe(max)}"} | errors]
    else
      errors
    end
  end

  defp check_decimals(errors, nil, _options), do: errors

  defp check_decimals(errors, value, options) do
    case Keyword.get(options, :decimals) do
      nil ->
        errors

      max_decimals ->
        if decimal_places(value) > max_decimals do
          [{:decimals, "must have at most #{max_decimals} fractional digits"} | errors]
        else
          errors
        end
    end
  end

  defp compare(%Decimal{} = a, %Decimal{} = b), do: Decimal.compare(a, b)
  defp compare(%Decimal{} = a, b), do: Decimal.compare(a, to_decimal(b))
  defp compare(a, %Decimal{} = b), do: Decimal.compare(to_decimal(a), b)

  defp compare(a, b) when is_integer(a) and is_integer(b) do
    cond do
      a < b -> :lt
      a > b -> :gt
      true -> :eq
    end
  end

  defp compare(a, b), do: Decimal.compare(to_decimal(a), to_decimal(b))

  defp to_decimal(value) when is_integer(value), do: Decimal.new(value)
  defp to_decimal(value) when is_binary(value), do: Decimal.new(value)
  defp to_decimal(value) when is_float(value), do: Decimal.from_float(value)

  defp describe(value), do: to_string(value)

  defp decimal_places(%Decimal{exp: exp}) when exp < 0, do: -exp
  defp decimal_places(%Decimal{}), do: 0
  defp decimal_places(value) when is_integer(value), do: 0

  defp decimal_places(value) when is_binary(value) do
    case String.split(value, ".") do
      [_, fraction] -> String.length(fraction)
      _ -> 0
    end
  end

  defp decimal_places(_), do: 0
end
