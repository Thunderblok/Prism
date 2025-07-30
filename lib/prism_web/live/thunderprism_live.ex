defmodule PrismWeb.ThunderprismLive do
  use PrismWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # Initialize enhanced tactical state
    if connected?(socket) do
      :timer.send_interval(1000, self(), :update_metrics)
    end

    {:ok, assign(socket,
      system_status: %{
        cluster_health: 98.7,
        active_agents: 42,
        network_latency: 23,
        federation_status: "OPERATIONAL",
        thunderline_status: "ONLINE",
        thunderblock_status: "CONNECTED",
        data_throughput: 1247.3
      },
      current_time: DateTime.utc_now(),
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
    <div class="min-h-screen bg-base-100 text-primary font-mono" data-theme="thunderprism">
      <!-- ⚡ THUNDERPRISM HEADER ⚡ -->
      <header class="navbar bg-base-200 border-b border-primary/30">
        <div class="navbar-start">
          <div class="flex items-center space-x-4">
            <!-- Logo with pulse animation -->
            <div class="w-12 h-12 border-2 border-primary transform rotate-45 flex items-center justify-center logo-pulse">
              <div class="w-6 h-6 bg-primary transform -rotate-45"></div>
            </div>
            <div>
              <h1 class="text-2xl font-bold tracking-wider glow">THUNDERPRISM</h1>
              <p class="text-sm opacity-70">Phoenix Recon Intelligence Systems Matrix</p>
            </div>
          </div>
        </div>

        <div class="navbar-center">
          <!-- Navigation Tabs -->
          <div class="tabs tabs-boxed bg-base-300">
            <a class="tab tab-active glow">DASHBOARD</a>
            <a class="tab hover:text-secondary">TERMINAL</a>
            <a class="tab hover:text-accent">SETTINGS</a>
          </div>
        </div>

        <div class="navbar-end">
          <div class="text-right">
            <div class="text-lg font-bold glow"><%= format_time(@current_time) %></div>
            <div class="text-sm opacity-70">SYSTEM TIME</div>
          </div>
        </div>
      </header>

      <!-- ⚡ MAIN TACTICAL GRID ⚡ -->
      <main class="p-6 node-grid min-h-screen">
        <!-- System Status Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">

          <!-- Thunderline Node Status -->
          <div class="card card-thunderprism fade-in">
            <div class="card-body">
              <div class="flex items-center justify-between">
                <div class="indicator">
                  <span class="indicator-item badge badge-success"></span>
                  <div class="w-8 h-8 bg-info rounded-full flex items-center justify-center">
                    <span class="text-xs">⚡</span>
                  </div>
                </div>
                <span class="status-online">Online</span>
              </div>
              <h3 class="card-title text-info glow">Thunderline Node</h3>
              <p class="text-sm opacity-70">Intelligence, distributed.<br/>Autonomy, embodied.</p>
              <div class="progress progress-glow progress-info w-full mt-2" value={@system_status.cluster_health} max="100"></div>
              <div class="metric-display text-info"><%= @system_status.cluster_health %>%</div>
              <div class="card-actions justify-end">
                <button class="btn btn-glow btn-sm">Manage...</button>
              </div>
            </div>
          </div>

          <!-- Thunderblock Server Status -->
          <div class="card card-thunderprism fade-in">
            <div class="card-body">
              <div class="flex items-center justify-between">
                <div class="indicator">
                  <span class="indicator-item badge badge-warning"></span>
                  <div class="w-8 h-8 bg-accent rounded-full flex items-center justify-center">
                    <span class="text-xs">🔶</span>
                  </div>
                </div>
                <span class="status-connected">Connected</span>
              </div>
              <h3 class="card-title text-accent glow-orange">Thunderblock Server</h3>
              <p class="text-sm opacity-70">Proof, immutable.<br/>Storage, recursive.</p>
              <div class="progress progress-glow progress-accent w-full mt-2" value="85" max="100"></div>
              <div class="metric-display text-accent"><%= @system_status.active_agents %></div>
              <div class="card-actions justify-end">
                <button class="btn btn-glow btn-sm">Configure...</button>
              </div>
            </div>
          </div>

          <!-- Activity Feed -->
          <div class="card card-thunderprism fade-in">
            <div class="card-body">
              <h3 class="card-title glow">Activity</h3>
              <div class="space-y-2 text-xs">
                <div class="flex justify-between items-center">
                  <span class="text-success">11:24 Volcanoer initialized</span>
                  <span class="opacity-50">11:19</span>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-info">11:19 Sonicwave authenticated</span>
                  <span class="opacity-50">11:13</span>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-warning">10:56 User request received</span>
                  <span class="opacity-50">10:56</span>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-accent">10:42 Verifier heartbeat</span>
                  <span class="opacity-50">10:42</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Resource Usage -->
          <div class="card card-thunderprism fade-in">
            <div class="card-body">
              <h3 class="card-title glow">Resource Usage</h3>
              <div class="space-y-3">
                <div>
                  <div class="flex justify-between text-sm">
                    <span>CPU</span>
                    <span class="glow-pink">19%</span>
                  </div>
                  <progress class="progress progress-secondary w-full" value="19" max="100"></progress>
                </div>
                <div>
                  <div class="flex justify-between text-sm">
                    <span>Memory</span>
                    <span class="glow-pink">34%</span>
                  </div>
                  <progress class="progress progress-secondary w-full" value="34" max="100"></progress>
                </div>
                <div>
                  <div class="flex justify-between text-sm">
                    <span>Network</span>
                    <span class="glow-orange"><%= trunc(@system_status.data_throughput) %> Mbps</span>
                  </div>
                  <progress class="progress progress-accent w-full" value="80" max="100"></progress>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- ⚡ THUNDERPRISM MAIN INTERFACE ⚡ -->
        <div class="hero bg-base-200 rounded-lg glow-border">
          <div class="hero-content text-center">
            <div class="max-w-md">
              <h1 class="text-5xl font-bold glow-strong">🌩️ THUNDERPRISM</h1>
              <h2 class="text-2xl font-bold glow-pink mt-4">FEDERATION INTERFACE</h2>
              <p class="py-6 text-lg">
                Bonfire-aligned tactical command center for distributed intelligence networks
              </p>

              <div class="stats stats-vertical lg:stats-horizontal shadow-lg bg-base-300 mt-6">
                <div class="stat">
                  <div class="stat-figure text-success">
                    <div class="w-8 h-8 rounded-full bg-success/20 flex items-center justify-center">
                      ✅
                    </div>
                  </div>
                  <div class="stat-title">LiveView Active</div>
                  <div class="stat-value text-success">100%</div>
                  <div class="stat-desc">Real-time tactical interface</div>
                </div>

                <div class="stat">
                  <div class="stat-figure text-info">
                    <div class="w-8 h-8 rounded-full bg-info/20 flex items-center justify-center">
                      📊
                    </div>
                  </div>
                  <div class="stat-title">System Monitor</div>
                  <div class="stat-value text-info">LIVE</div>
                  <div class="stat-desc">Real-time metrics operational</div>
                </div>

                <div class="stat">
                  <div class="stat-figure text-warning">
                    <div class="w-8 h-8 rounded-full bg-warning/20 flex items-center justify-center">
                      🚧
                    </div>
                  </div>
                  <div class="stat-title">Federation Core</div>
                  <div class="stat-value text-warning">DEV</div>
                  <div class="stat-desc">Implementation in progress</div>
                </div>
              </div>

              <div class="mt-6">
                <button class="btn btn-glow mr-4" phx-click="show_agent_details">Launch Terminal</button>
                <button class="btn btn-outline btn-secondary">View Documentation</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Terminal Section -->
        <div class="mt-8">
          <div class="card card-thunderprism">
            <div class="card-body">
              <h3 class="card-title glow">
                <span class="text-success">TERMINAL</span>
                <span class="text-xs opacity-50">user@volcanoer:~$</span>
                <span class="terminal-cursor">_</span>
              </h3>
              <div class="terminal text-sm">
                <div class="text-success">⚡ Thunderprism Tactical Interface v1.0</div>
                <div class="text-info">📡 Federation protocols loading...</div>
                <div class="text-warning">🧠 AI agent coordination framework initialized</div>
                <div class="text-accent">🔥 "Through the Prism, all light becomes visible" - High Command</div>
                <div class="mt-2 flex items-center">
                  <span class="text-primary">user@thunderprism:~$ </span>
                  <span class="terminal-cursor ml-1">_</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Agent Details Modal -->
        <%= if @show_modal do %>
          <div class="modal modal-open">
            <div class="modal-box bg-base-200 border border-primary/30">
              <h3 class="font-bold text-lg glow">PAC Agent Details</h3>
              <div class="py-4">
                <div class="stats shadow bg-base-300">
                  <div class="stat">
                    <div class="stat-title">Active Agents</div>
                    <div class="stat-value text-primary"><%= @system_status.active_agents %></div>
                    <div class="stat-desc">Distributed across network</div>
                  </div>
                </div>
              </div>
              <div class="modal-action">
                <button class="btn btn-glow" phx-click="close_modal">Close</button>
              </div>
            </div>
          </div>
        <% end %>

        <!-- Footer Quote -->
        <div class="mt-8 text-center">
          <div class="text-xs opacity-50 italic">
            "Through the Prism, all light becomes visible" - High Command Strategic Doctrine
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

  defp health_color(health) when health >= 95, do: "text-success"
  defp health_color(health) when health >= 80, do: "text-warning"
  defp health_color(_), do: "text-error"
end
