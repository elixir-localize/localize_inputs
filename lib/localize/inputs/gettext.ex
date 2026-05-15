if Code.ensure_loaded?(Gettext.Backend) do
  defmodule Localize.Inputs.Gettext do
    @moduledoc """
    Gettext backend for `localize_inputs` UI strings.

    Hosts the small message catalog used by the unit picker
    (section headings, search placeholder, etc.). The catalog
    lives in `priv/gettext/`. Activated only when the host
    project depends on `:gettext`; the components module gates
    its `use Localize.Message.Sigils` call on this backend being
    available.

    Uses `Localize.Gettext.Interpolation` so all messages can use
    MF2 (MessageFormat 2) syntax for placeholders, plural/select
    selectors, and inline markup — consistent with the rest of
    the Localize ecosystem.
    """
    use Gettext.Backend,
      otp_app: :localize_inputs,
      interpolation: Localize.Gettext.Interpolation
  end
end
