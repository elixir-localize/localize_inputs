if Code.ensure_loaded?(Plug.Router) do
  defmodule Localize.Inputs.Visualizer do
    @moduledoc """
    A web-based visualizer for `Localize.Inputs`.

    `Plug.Router` that can be mounted inside a Phoenix or Plug
    application, or run standalone during development via
    `Localize.Inputs.Visualizer.Standalone`.

    ## Views

    * `/input` — interactive number input demo.
    * `/parse` — cross-locale parsing table.
    * `/format` — cross-locale formatting table.
    * `/locale` — locale display data table.

    ## Enable flag

    `Localize.Inputs.Visualizer.Standalone.start/1` refuses to
    boot unless `:localize_inputs, :visualizer` is set to `true`
    in config (or `enabled: true` is passed explicitly).
    Mounting under `forward/2` in a Phoenix router is not gated.

    """

    use Plug.Router

    plug(Plug.Logger, log: :debug)
    plug(:match)
    plug(Plug.Parsers, parsers: [:urlencoded], pass: ["text/*"])
    plug(:dispatch)

    alias Localize.Inputs.Visualizer.Assets
    alias Localize.Inputs.Visualizer.FormatView
    alias Localize.Inputs.Visualizer.InputView
    alias Localize.Inputs.Visualizer.LocaleView
    alias Localize.Inputs.Visualizer.ParseView

    get "/" do
      base = base_path(conn)

      conn
      |> Plug.Conn.put_resp_header("location", base <> "/input")
      |> Plug.Conn.send_resp(302, "")
    end

    get "/input" do
      params = parse_params(conn, :input)
      html(conn, InputView.render(params, base_path(conn)))
    end

    get "/parse" do
      params = parse_params(conn, :parse)
      html(conn, ParseView.render(params, base_path(conn)))
    end

    get "/format" do
      params = parse_params(conn, :format)
      html(conn, FormatView.render(params, base_path(conn)))
    end

    get "/locale" do
      params = parse_params(conn, :locale)
      html(conn, LocaleView.render(params, base_path(conn)))
    end

    get "/assets/style.css" do
      conn
      |> Plug.Conn.put_resp_content_type("text/css")
      |> Plug.Conn.put_resp_header("cache-control", "public, max-age=31536000, immutable")
      |> Plug.Conn.send_resp(200, Assets.css())
    end

    get "/assets/localize_inputs.css" do
      conn
      |> Plug.Conn.put_resp_content_type("text/css")
      |> Plug.Conn.put_resp_header("cache-control", "public, max-age=31536000, immutable")
      |> Plug.Conn.send_resp(200, Assets.component_css())
    end

    get "/assets/localize_inputs.js" do
      conn
      |> Plug.Conn.put_resp_content_type("application/javascript")
      |> Plug.Conn.put_resp_header("cache-control", "public, max-age=31536000, immutable")
      |> Plug.Conn.send_resp(200, Assets.component_js())
    end

    match _ do
      send_resp(conn, 404, "Not found")
    end

    # ---- helpers ---------------------------------------------------------

    defp html(conn, iodata) do
      conn
      |> Plug.Conn.put_resp_content_type("text/html")
      |> Plug.Conn.send_resp(200, IO.iodata_to_binary(iodata))
    end

    defp base_path(%Plug.Conn{script_name: []}), do: ""
    defp base_path(%Plug.Conn{script_name: segments}), do: "/" <> Enum.join(segments, "/")

    defp parse_params(%Plug.Conn{} = conn, view),
      do: parse_params(conn.params, view, conn.assigns)

    defp parse_params(params, :input, assigns) do
      deployment_default = default_locale(assigns)
      locale = param_locale(params, "locale", deployment_default)

      %{
        locale: locale,
        deployment_default_locale: deployment_default,
        number_input: blank_default(Map.get(params, "number_input"), nil)
      }
    end

    defp parse_params(params, :parse, _assigns) do
      %{input: blank_default(Map.get(params, "input"), "1,234.56")}
    end

    defp parse_params(params, :format, _assigns) do
      %{amount: blank_default(Map.get(params, "amount"), "1234567.89")}
    end

    defp parse_params(_params, :locale, _assigns) do
      %{}
    end

    defp param_locale(params, key, default) do
      case Map.get(params, key) do
        nil -> default
        "" -> default
        value when is_binary(value) -> validate_locale(value) || default
      end
    end

    defp blank_default(nil, default), do: default
    defp blank_default("", default), do: default
    defp blank_default(value, _), do: value

    defp default_locale(assigns) do
      validate_locale(stringify_locale(assigns[:locale])) ||
        stringify_locale(safe_get_locale())
    end

    defp safe_get_locale do
      Localize.get_locale()
    rescue
      _ -> nil
    end

    defp stringify_locale(nil), do: nil
    defp stringify_locale(locale) when is_binary(locale), do: locale
    defp stringify_locale(locale) when is_atom(locale), do: Atom.to_string(locale)
    defp stringify_locale(%{canonical_locale_id: id}) when is_binary(id), do: id
    defp stringify_locale(_), do: nil

    defp validate_locale(nil), do: nil

    defp validate_locale(locale) do
      case Localize.validate_locale(locale) do
        {:ok, _tag} -> locale
        _ -> nil
      end
    rescue
      _ -> nil
    end
  end
end
