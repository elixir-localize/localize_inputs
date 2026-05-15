# Changelog

## [v0.2.0] — 2026-05-16

* `Localize.Inputs.Formatter` removed — number formatting was a pure pass-through to `Localize.Number.to_string/2`. Callers should use `Localize.Number.to_string/2` directly.

* `Localize.Inputs.Components.number_input/1` now uses `Localize.Number.to_string/2` directly (no Formatter indirection) and gracefully handles empty / unparseable values without raising — renders an empty input value instead of crashing the page.

* `Localize.Inputs.Visualizer` and the standalone helper have moved to the sibling [`localize_inputs_playground`](https://github.com/elixir-localize/localize_inputs_playground) package (under the `LocalizeInputsPlayground.Visualizer` namespace). Drops the `:plug` and `:bandit` optional deps from this package. If you embedded the visualizer via `forward "/inputs", Localize.Inputs.Visualizer`, add `{:localize_inputs_playground, "~> 0.1", only: :dev}` and update the forward target to `LocalizeInputsPlayground.Visualizer`.

* `:localize` dep bumped to `~> 0.36` to match the rest of the localize ecosystem.

## v0.1.0 (initial release)

* `Localize.Inputs.Components.number_input/1` — locale-aware plain-number HEEx component backed by an AutoNumeric JS hook, with a headless parser/formatter/validator and Ecto changeset bridge.

* `Localize.Inputs.Visualizer` — Plug-based development tool with light/dark theme toggle that demonstrates the component across CLDR locales.
