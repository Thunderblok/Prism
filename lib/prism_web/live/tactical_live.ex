defmodule PrismWeb.TacticalLive do
  use PrismWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # Initialize basic tactical state
    if connected?(socket) do
      :timer.send_interval(1000, self(), :update_metrics)
    end

    {:ok, assign(socket,
      system_status: %{
        cluster_health: 98.7,
        active_agents: 42,
        network_latency: 23,
        federation_status: "OPERATIONAL"
      },
      current_time: DateTime.utc_now()
    )}
  end

  @impl true
  def handle_info(:update_metrics, socket) do
    # Simulate real-time updates
    status = socket.assigns.system_status
    updated_status = %{status |
      cluster_health: Float.round(status.cluster_health + (:rand.uniform() - 0.5) * 2, 1),
      network_latency: status.network_latency + :rand.uniform(10) - 5
    }

    {:noreply, assign(socket,
      system_status: updated_status,
      current_time: DateTime.utc_now()
    )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-black text-green-400 font-mono">
      <!-- Header -->
      <header class="border-b border-green-400 border-opacity-30 p-6">
        <div class="flex justify-between items-center">
          <div class="flex items-center space-x-4">
            <div class="w-12 h-12 border-2 border-green-400 transform rotate-45 flex items-center justify-center">
              <div class="w-6 h-6 bg-green-400 transform -rotate-45"></div>
            </div>
            <div>
              <h1 class="text-2xl font-bold tracking-wider">PRISM</h1>
              <p class="text-sm opacity-70">Phoenix Recon Intelligence Systems Matrix</p>
            </div>
          </div>
          <div class="text-right">
            <div class="text-lg font-bold"><%= format_time(@current_time) %></div>
            <div class="text-sm opacity-70">SYSTEM TIME</div>
          </div>
        </div>
      </header>

      <!-- Main Content -->
      <main class="p-6">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <!-- System Health -->
          <div class="border border-green-400 border-opacity-50 p-4">
            <h3 class="text-lg font-bold mb-2">CLUSTER HEALTH</h3>
            <div class={"text-3xl font-bold " <> health_color(@system_status.cluster_health)}>
              <%= @system_status.cluster_health %>%
            </div>
          </div>

          <!-- Active Agents -->
          <div class="border border-green-400 border-opacity-50 p-4">
            <h3 class="text-lg font-bold mb-2">ACTIVE AGENTS</h3>
            <div class="text-3xl font-bold text-green-400">
              <%= @system_status.active_agents %>
            </div>
          </div>

          <!-- Network Latency -->
          <div class="border border-green-400 border-opacity-50 p-4">
            <h3 class="text-lg font-bold mb-2">NETWORK LATENCY</h3>
            <div class="text-3xl font-bold text-blue-400">
              <%= @system_status.network_latency %>ms
            </div>
          </div>

          <!-- Federation Status -->
          <div class="border border-green-400 border-opacity-50 p-4">
            <h3 class="text-lg font-bold mb-2">FEDERATION</h3>
            <div class="text-lg font-bold text-green-400">
              <%= @system_status.federation_status %>
            </div>
          </div>
        </div>

        <!-- Welcome Message -->
        <div class="border border-green-400 border-opacity-50 p-6 text-center">
          <h2 class="text-2xl font-bold mb-4">🌩️ THUNDERBLOCK FEDERATION INTERFACE</h2>
          <p class="text-lg mb-4">Bonfire-aligned tactical command center for distributed intelligence networks</p>
          <div class="space-y-2 text-sm opacity-70">
            <p>✅ Phoenix LiveView tactical interface active</p>
            <p>✅ Real-time system monitoring operational</p>
            <p>🚧 Federation core implementation in progress</p>
            <p>📋 AI agent coordination planned</p>
          </div>
          <div class="mt-6 text-xs opacity-50">
            <p>"Through the Prism, all light becomes visible" - High Command Strategic Doctrine</p>
          </div>
        </div>
      </main>
    </div>
    """
  end

  # Helper functions
  defp format_time(datetime) do
    datetime
    |> DateTime.to_time()
    |> Time.to_string()
    |> String.slice(0..7)
  end

  defp health_color(health) when health >= 95, do: "text-green-400"
  defp health_color(health) when health >= 80, do: "text-yellow-400"
  defp health_color(_), do: "text-red-400"
end
