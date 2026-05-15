if Code.ensure_loaded?(Bandit) do
  defmodule Localize.Inputs.Visualizer.Standalone do
    @moduledoc """
    Runs `Localize.Inputs.Visualizer` as a standalone Bandit
    web server for local development.

        Localize.Inputs.Visualizer.Standalone.start(port: 4003)
        # Visit http://localhost:4003

    ## Enable flag

    Refuses to start unless the visualizer has been enabled:

        config :localize_inputs, visualizer: true

    or pass `enabled: true` to `start/1` explicitly.

    """

    @doc """
    Starts the visualizer as a standalone Bandit web server.

    ### Arguments

    * `options` is a keyword list of options.

    ### Options

    * `:port` — TCP port. Defaults to `4003`.

    * `:ip` — bind address. `:loopback` (default), `:any`, or a
      `{a, b, c, d}` IPv4 tuple.

    * `:enabled` — pass `true` to override the application-level
      enable flag.

    ### Returns

    * `{:ok, pid()}` when the server starts.

    * `{:error, %Localize.Inputs.VisualizerDisabledError{}}` when
      the enable flag is not set.

    * `{:error, term()}` propagated from `Bandit.start_link/1`.

    ### Examples

        iex> {:error, %Localize.Inputs.VisualizerDisabledError{}} =
        ...>   Localize.Inputs.Visualizer.Standalone.start(enabled: false)
        iex> :ok
        :ok

    """
    @spec start(keyword()) :: {:ok, pid()} | {:error, term()}
    def start(options \\ []) do
      if enabled?(options) do
        port = Keyword.get(options, :port, 4003)
        ip = Keyword.get(options, :ip, :loopback)

        Bandit.start_link(
          plug: Localize.Inputs.Visualizer,
          port: port,
          ip: ip_tuple(ip)
        )
      else
        {:error, Localize.Inputs.VisualizerDisabledError.exception([])}
      end
    end

    @doc """
    Returns a child spec for embedding the visualizer under a
    supervision tree.

    ### Arguments

    * `options` is a keyword list of options. See `start/1`.

    ### Returns

    * A `Supervisor.child_spec/0`. When the visualizer is
      disabled, a temporary no-op spec is returned instead of a
      live listener.

    """
    @spec child_spec(keyword()) :: Supervisor.child_spec()
    def child_spec(options \\ []) do
      if enabled?(options) do
        port = Keyword.get(options, :port, 4003)
        ip = Keyword.get(options, :ip, :loopback)

        %{
          id: __MODULE__,
          start:
            {Bandit, :start_link,
             [[plug: Localize.Inputs.Visualizer, port: port, ip: ip_tuple(ip)]]},
          type: :supervisor
        }
      else
        %{
          id: __MODULE__,
          start: {Task, :start_link, [fn -> :ok end]},
          restart: :temporary,
          type: :worker
        }
      end
    end

    @doc """
    Stops a previously-started visualizer.

    ### Arguments

    * `pid` is the pid returned from `start/1`.

    ### Returns

    * `:ok` once the supervisor has shut down.

    """
    @spec stop(pid()) :: :ok
    def stop(pid) when is_pid(pid) do
      _ = Supervisor.stop(pid)
      :ok
    end

    @doc """
    Returns whether the visualizer is currently enabled.

    ### Arguments

    * `options` is a keyword list of options.

    ### Options

    * `:enabled` — pass `true` to force-enable regardless of
      application config.

    ### Returns

    * `true` when either the application env flag or the option
      is set.

    * `false` otherwise.

    ### Examples

        iex> Localize.Inputs.Visualizer.Standalone.enabled?(enabled: true)
        true

    """
    @spec enabled?(keyword()) :: boolean()
    def enabled?(options \\ []) do
      cond do
        Keyword.get(options, :enabled) == true -> true
        Application.get_env(:localize_inputs, :visualizer) == true -> true
        true -> false
      end
    end

    defp ip_tuple(:loopback), do: {127, 0, 0, 1}
    defp ip_tuple(:any), do: {0, 0, 0, 0}
    defp ip_tuple({_, _, _, _} = tuple), do: tuple
  end
end
