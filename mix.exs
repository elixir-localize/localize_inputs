defmodule Localize.Inputs.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/elixir-localize/localize_inputs"

  def project do
    [
      app: :localize_inputs,
      version: @version,
      name: "Localize.Inputs",
      source_url: @source_url,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        plt_add_apps: ~w(ecto gettext mix phoenix_html phoenix_live_view plug)a,
        flags: [
          :error_handling,
          :unknown,
          :underspecs,
          :extra_return,
          :missing_return
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Locale-aware HTML form input components. Today: <.number_input>. " <>
      "Ships a headless parser/formatter/validator, an AutoNumeric-backed JS hook, and " <>
      "a Plug-based visualizer for local development."
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache-2.0"],
      links: links(),
      files: ~w(lib priv mix.exs README.md CHANGELOG.md LICENSE.md)
    ]
  end

  defp links do
    %{
      "GitHub" => @source_url,
      "Readme" => "#{@source_url}/blob/v#{@version}/README.md",
      "Changelog" => "#{@source_url}/blob/v#{@version}/CHANGELOG.md"
    }
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"],
      formatters: ["html"],
      groups_for_modules: groups_for_modules(),
      # External-package references that ex_doc can't follow
      # because the host package isn't in this docs build.
      skip_code_autolink_to: [
        "Ecto.Changeset.t/0",
        "Supervisor.child_spec/0",
        "Localize.LanguageTag.t/0"
      ],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp groups_for_modules do
    [
      Components: ~r/^Localize\.Inputs\.Components(\.|$)/,
      "Headless API": [
        Localize.Inputs.Parser,
        Localize.Inputs.Formatter,
        Localize.Inputs.Validator,
        Localize.Inputs.Locale,
        Localize.Inputs.Changeset
      ],
      Visualizer: ~r/^Localize\.Inputs\.Visualizer(\.|$)/
    ]
  end

  defp deps do
    [
      {:localize, "~> 0.27", path: "../localize"},
      {:phoenix_html, "~> 4.0", optional: true},
      {:phoenix_live_view, "~> 1.0", optional: true},
      {:ecto, "~> 3.10", optional: true},
      {:gettext, "~> 1.0", optional: true},
      {:plug, "~> 1.15", optional: true},
      {:bandit, "~> 1.5", optional: true},
      {:ex_doc, "~> 0.30", only: [:dev, :release], runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
