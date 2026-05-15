defmodule Localize.Inputs.VisualizerTest do
  use ExUnit.Case, async: false

  alias Localize.Inputs.Visualizer

  setup do
    conn = fn path, query ->
      :get
      |> Plug.Test.conn(path <> "?" <> URI.encode_query(query))
      |> Visualizer.call(Visualizer.init([]))
    end

    {:ok, conn: conn}
  end

  test "/ redirects to /input", %{conn: conn} do
    response = conn.("/", %{})
    assert response.status == 302
    assert Plug.Conn.get_resp_header(response, "location") == ["/input"]
  end

  test "/input renders form", %{conn: conn} do
    response = conn.("/input", %{"locale" => "en", "number_input" => "1,234.56"})
    assert response.status == 200
    assert response.resp_body =~ "Number Input Component"
    assert response.resp_body =~ "1234.56"
  end

  test "/parse renders the cross-locale table", %{conn: conn} do
    response = conn.("/parse", %{"input" => "1.234,56"})
    assert response.status == 200
    assert response.resp_body =~ "Cross-locale parsing"
    assert response.resp_body =~ "1234.56"
  end

  test "/format renders the cross-locale table", %{conn: conn} do
    response = conn.("/format", %{"amount" => "1234567.89"})
    assert response.status == 200
    assert response.resp_body =~ "Cross-locale formatting"
    assert response.resp_body =~ "1,234,567.89"
  end

  test "/locale renders per-locale table", %{conn: conn} do
    response = conn.("/locale", %{})
    assert response.status == 200
    assert response.resp_body =~ "Locale display data"
  end

  test "/assets/style.css served", %{conn: conn} do
    response = conn.("/assets/style.css", %{})
    assert response.status == 200
    assert response.resp_body =~ ".li-header"
  end

  test "/assets/localize_inputs.css served", %{conn: conn} do
    response = conn.("/assets/localize_inputs.css", %{})
    assert response.status == 200
    assert response.resp_body =~ ".number-input-wrapper"
  end

  test "/assets/localize_inputs.js served", %{conn: conn} do
    response = conn.("/assets/localize_inputs.js", %{})
    assert response.status == 200
    assert response.resp_body =~ "NumberInput"
  end

  test "unknown route 404s", %{conn: conn} do
    response = conn.("/does-not-exist", %{})
    assert response.status == 404
  end
end
