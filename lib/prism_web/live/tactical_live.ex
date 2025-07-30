defmodule PrismWeb.TacticalLive do
  use PrismWeb, :live_view
  import PrismWeb.TacticalUI
  import PrismWeb.TacticalUI

  @impl true
  def mount(_params, _session, socket) do
    # Initialize tactical state with more comprehensive metrics
    if connected?(socket) do
      :timer.send_interval(1000, self(), :update_metrics)
    end

    {:ok, assign(socket,
      system_status: %{
        cluster_health: 98.7,
        active_agents: 42,
        network_latency: 23,
        federation_status: "OPERATIONAL",
        threat_level: "GREEN",
        active_missions: 7,
        data_throughput: 156.8
      },
      current_time: DateTime.utc_now(),
      agent_list: [
        %{id: "PAC-001", status: "ACTIVE", mission: "Data Collection", uptime: "72h"},
        %{id: "PAC-007", status: "STANDBY", mission: "Network Monitor", uptime: "156h"},
        %{id: "PAC-013", status: "ACTIVE", mission: "Federation Sync", uptime: "23h"},
        %{id: "PAC-042", status: "MAINTENANCE", mission: "System Repair", uptime: "2h"}
      ],
      show_modal: false
    )}
  end

  @impl true
  def handle_info(:update_metrics, socket) do
    # Simulate real-time tactical updates
    status = socket.assigns.system_status
    updated_status = %{status |
      cluster_health: Float.round(status.cluster_health + (:rand.uniform() - 0.5) * 2, 1),
      network_latency: max(1, status.network_latency + :rand.uniform(10) - 5),
      data_throughput: Float.round(status.data_throughput + (:rand.uniform() - 0.5) * 20, 1)
    }

    {:noreply, assign(socket,
      system_status: updated_status,
      current_time: DateTime.utc_now()
    )}
  end

  @impl true
  def handle_event("show_agent_details", _params, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false)}
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
          <div class="text-right space-y-1">
            <div class="text-lg font-bold"><%= format_time(@current_time) %></div>
            <div class="text-sm opacity-70">SYSTEM TIME</div>
            <.status_indicator status={@system_status.threat_level} pulse={@system_status.threat_level != "GREEN"} />
          </div>
        </div>
      </header>

      <!-- Main Content -->
      <main class="p-6">
        <!-- FluxonUI-Ready Alert -->
        <.tactical_alert variant={:info} title="SYSTEM STATUS" class="mb-6">
          🌩️ Tactical interface operational | FluxonUI integration ready when license available
        </.tactical_alert>

        <!-- Enhanced Metrics Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <.metrics_card
            title="CLUSTER HEALTH"
            value={@system_status.cluster_health}
            unit="%"
            status={health_status(@system_status.cluster_health)}
          />

          <.metrics_card
            title="ACTIVE AGENTS"
            value={@system_status.active_agents}
            status={:optimal}
          />

          <.metrics_card
            title="NETWORK LATENCY"
            value={@system_status.network_latency}
            unit="ms"
            status={latency_status(@system_status.network_latency)}
          />

          <.metrics_card
            title="DATA THROUGHPUT"
            value={@system_status.data_throughput}
            unit="MB/s"
            status={:normal}
          />
        </div>

        <!-- Action Buttons -->
        <div class="flex space-x-4 mb-8">
          <.tactical_button variant={:primary} phx-click="show_agent_details">
            🤖 Agent Details
          </.tactical_button>

          <.tactical_button variant={:secondary}>
            📡 Federation Status
          </.tactical_button>

          <.tactical_button variant={:success}>
            ⚡ System Diagnostics
          </.tactical_button>
        </div>

        <!-- Agent Status Table -->
        <div class="mb-8">
          <h2 class="text-xl font-bold mb-4 text-green-400">🤖 ACTIVE PAC AGENTS</h2>
          <.tactical_table
            columns={[
              %{key: :id, label: "AGENT ID"},
              %{key: :status, label: "STATUS"},
              %{key: :mission, label: "MISSION"},
              %{key: :uptime, label: "UPTIME"}
            ]}
            rows={@agent_list}
          />
        </div>

        <!-- Federation Core -->
        <div class="border border-green-400 border-opacity-50 p-6 text-center">
          <h2 class="text-2xl font-bold mb-4">🌩️ THUNDERBLOCK FEDERATION INTERFACE</h2>
          <p class="text-lg mb-4">Bonfire-aligned tactical command center for distributed intelligence networks</p>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
            <div class="text-left space-y-2 text-sm opacity-70">
              <p>✅ Phoenix LiveView tactical interface active</p>
              <p>✅ Real-time system monitoring operational</p>
              <p>✅ FluxonUI-ready component architecture</p>
              <p>🚧 Federation core implementation in progress</p>
            </div>
            <div class="text-left space-y-2 text-sm opacity-70">
              <p>📋 AI agent coordination framework ready</p>
              <p>🔗 ActivityPub protocol preparation complete</p>
              <p>⚡ Premium FluxonUI integration ready</p>
              <p>🌐 Bonfire Networks compatibility confirmed</p>
            </div>
          </div>

          <div class="mt-6 text-xs opacity-50">
            <p>"Through the Prism, all light becomes visible" - High Command Strategic Doctrine</p>
          </div>
        </div>
      </main>

      <!-- Agent Details Modal -->
      <.tactical_modal id="agent-modal" show={@show_modal} title="PAC AGENT INTELLIGENCE">
        <div class="space-y-4">
          <p class="text-sm">Detailed agent monitoring and control interface. FluxonUI premium components will enhance this with advanced data visualization and real-time agent communication channels.</p>

          <div class="border border-green-400 border-opacity-30 p-4">
            <h3 class="font-bold mb-2">AGENT CAPABILITIES</h3>
            <ul class="text-sm space-y-1 opacity-80">
              <li>• Autonomous data collection and analysis</li>
              <li>• Real-time federation protocol management</li>
              <li>• Distributed state synchronization</li>
              <li>• Tactical intelligence processing</li>
            </ul>
          </div>

          <div class="flex space-x-4">
            <.tactical_button variant={:primary} size={:sm}>
              Deploy Agent
            </.tactical_button>

            <.tactical_button variant={:secondary} size={:sm} phx-click="close_modal">
              Close
            </.tactical_button>
          </div>
        </div>
      </.tactical_modal>
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

  defp health_status(health) when health >= 95, do: :optimal
  defp health_status(health) when health >= 80, do: :normal
  defp health_status(health) when health >= 60, do: :warning
  defp health_status(_), do: :critical

  defp latency_status(latency) when latency <= 20, do: :optimal
  defp latency_status(latency) when latency <= 50, do: :normal
  defp latency_status(latency) when latency <= 100, do: :warning
  defp latency_status(_), do: :critical
end
