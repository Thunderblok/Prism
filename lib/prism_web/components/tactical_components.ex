defmodule PrismWeb.TacticalComponents do
  @moduledoc """
  Tactical interface components for the Thunderline command center.
  Battlezone-inspired UI elements with real-time capabilities.
  """
  use Phoenix.Component

  @doc """
  Renders a tactical status panel with real-time metrics
  """
  attr :title, :string, required: true
  attr :status, :map, required: true
  attr :class, :string, default: ""

  def status_panel(assigns) do
    ~H"""
    <div class={"tactical-border border border-green-400 border-opacity-50 p-4 #{@class}"}>
      <h3 class="text-lg font-bold mb-4 text-center terminal-glow"><%= @title %></h3>
      <div class="space-y-3">
        <%= for {key, value} <- @status do %>
          <div class="flex justify-between">
            <span class="uppercase"><%= format_key(key) %></span>
            <span class={"font-bold #{status_color(key, value)}"}><%= format_value(key, value) %></span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a tactical node grid item
  """
  attr :node, :map, required: true
  attr :selected, :boolean, default: false
  attr :on_click, :string, required: true

  def node_grid_item(assigns) do
    ~H"""
    <div
      class={"tactical-button border border-green-400 border-opacity-30 p-2 flex flex-col items-center justify-center cursor-pointer hover:border-opacity-100 transition-all #{if @selected, do: "border-opacity-100 bg-green-400 bg-opacity-10 tactical-border"}"}
      phx-click={@on_click}
      phx-value-id={@node.id}
    >
      <div class={"w-4 h-4 rounded-full mb-1 #{node_status_indicator(@node.status)}"}></div>
      <span class="text-xs text-center"><%= String.slice(@node.name, 0..7) %></span>
    </div>
    """
  end

  @doc """
  Renders a tactical radar display
  """
  attr :size, :string, default: "w-64 h-64"
  attr :opacity, :string, default: "opacity-20"

  def tactical_radar(assigns) do
    ~H"""
    <div class={"#{@size} #{@opacity}"}>
      <svg class="w-full h-full animate-spin" style="animation-duration: 4s;" viewBox="0 0 100 100">
        <circle cx="50" cy="50" r="45" fill="none" stroke="currentColor" stroke-width="0.5" opacity="0.3"/>
        <circle cx="50" cy="50" r="30" fill="none" stroke="currentColor" stroke-width="0.5" opacity="0.3"/>
        <circle cx="50" cy="50" r="15" fill="none" stroke="currentColor" stroke-width="0.5" opacity="0.3"/>
        <line x1="50" y1="5" x2="50" y2="95" stroke="currentColor" stroke-width="0.5" opacity="0.2"/>
        <line x1="5" y1="50" x2="95" y2="50" stroke="currentColor" stroke-width="0.5" opacity="0.2"/>
        <path d="M 50 50 L 50 5 A 45 45 0 0 1 85 35 Z" fill="currentColor" opacity="0.1"/>
      </svg>
    </div>
    """
  end

  @doc """
  Renders a tactical command button
  """
  attr :text, :string, required: true
  attr :action, :string, required: true
  attr :active, :boolean, default: false
  attr :variant, :string, default: "primary"
  attr :class, :string, default: ""

  def tactical_button(assigns) do
    ~H"""
    <button
      phx-click={@action}
      class={"tactical-button px-4 py-2 border transition-all duration-200 #{button_variant(@variant)} #{if @active, do: active_styles(@variant), else: hover_styles(@variant)} #{@class}"}
    >
      <%= @text %>
    </button>
    """
  end

  @doc """
  Renders a tactical HUD header
  """
  attr :system_name, :string, default: "THUNDERLINE"
  attr :subtitle, :string, default: "TACTICAL COMMAND INTERFACE"
  attr :current_time, :any, required: true

  def tactical_header(assigns) do
    ~H"""
    <header class="relative z-20 flex justify-between items-center p-6 border-b border-green-400 border-opacity-30 scan-line">
      <div class="flex items-center space-x-8">
        <!-- System Logo -->
        <div class="flex items-center space-x-4">
          <div class="w-12 h-12 border-2 border-green-400 transform rotate-45 flex items-center justify-center tactical-border">
            <div class="w-6 h-6 bg-green-400 transform -rotate-45"></div>
          </div>
          <div>
            <h1 class="text-2xl font-bold tracking-wider terminal-glow"><%= @system_name %></h1>
            <p class="text-sm opacity-70"><%= @subtitle %></p>
          </div>
        </div>

        <!-- System Time -->
        <div class="text-right">
          <div class="text-lg font-bold terminal-glow"><%= format_tactical_time(@current_time) %></div>
          <div class="text-sm opacity-70">SYSTEM TIME</div>
        </div>
      </div>

      <slot />
    </header>
    """
  end

  @doc """
  Renders a tactical node list item
  """
  attr :node, :map, required: true
  attr :selected, :boolean, default: false
  attr :on_click, :string, required: true

  def node_list_item(assigns) do
    ~H"""
    <div
      class={"tactical-button flex justify-between items-center p-2 cursor-pointer hover:bg-green-400 hover:bg-opacity-10 transition-colors #{if @selected, do: "bg-green-400 bg-opacity-20 tactical-border"}"}
      phx-click={@on_click}
      phx-value-id={@node.id}
    >
      <span class="font-mono"><%= @node.name %></span>
      <div class="flex items-center space-x-2">
        <div class={"w-2 h-2 rounded-full #{node_status_indicator(@node.status)}"}></div>
        <span class="text-xs uppercase"><%= @node.status %></span>
      </div>
    </div>
    """
  end

  @doc """
  Renders a tactical alert notification
  """
  attr :alerts, :list, required: true
  attr :show, :boolean, required: true

  def alert_panel(assigns) do
    ~H"""
    <%= if @show do %>
      <div class="absolute top-20 right-6 w-96 bg-black border border-red-400 p-4 z-30 tactical-border matrix-bg">
        <h3 class="text-lg font-bold mb-4 text-red-400 terminal-glow">SYSTEM ALERTS</h3>
        <div class="space-y-2 text-sm">
          <%= for alert <- @alerts do %>
            <div class="flex justify-between">
              <span><%= alert.message %></span>
              <span class={"#{alert_severity_color(alert.severity)}"}><%= String.upcase(alert.severity) %></span>
            </div>
          <% end %>
        </div>
      </div>
    <% end %>
    """
  end

  # Helper functions
  defp format_key(:cluster_health), do: "HEALTH"
  defp format_key(:active_agents), do: "AGENTS"
  defp format_key(:memory_usage), do: "MEMORY"
  defp format_key(:network_latency), do: "LATENCY"
  defp format_key(:alerts), do: "ALERTS"
  defp format_key(key), do: key |> to_string() |> String.upcase()

  defp format_value(:cluster_health, value), do: "#{value}%"
  defp format_value(:memory_usage, value), do: "#{value}%"
  defp format_value(:network_latency, value), do: "#{value}ms"
  defp format_value(_, value), do: to_string(value)

  defp status_color(:cluster_health, health) when health >= 95, do: "text-green-400"
  defp status_color(:cluster_health, health) when health >= 80, do: "text-yellow-400"
  defp status_color(:cluster_health, _), do: "text-red-400"
  defp status_color(:memory_usage, usage) when usage >= 80, do: "text-red-400"
  defp status_color(:memory_usage, usage) when usage >= 60, do: "text-yellow-400"
  defp status_color(:memory_usage, _), do: "text-green-400"
  defp status_color(_, _), do: "text-green-400"

  defp node_status_indicator("online"), do: "bg-green-400 status-online"
  defp node_status_indicator("warning"), do: "bg-yellow-400 status-warning"
  defp node_status_indicator("critical"), do: "bg-red-400 status-critical"
  defp node_status_indicator("offline"), do: "bg-gray-400 status-offline"

  defp button_variant("primary"), do: "border-green-400"
  defp button_variant("danger"), do: "border-red-400"
  defp button_variant("warning"), do: "border-yellow-400"

  defp active_styles("primary"), do: "bg-green-400 text-black"
  defp active_styles("danger"), do: "bg-red-400 text-black"
  defp active_styles("warning"), do: "bg-yellow-400 text-black"

  defp hover_styles("primary"), do: "hover:bg-green-400 hover:text-black"
  defp hover_styles("danger"), do: "hover:bg-red-400 hover:text-black"
  defp hover_styles("warning"), do: "hover:bg-yellow-400 hover:text-black"

  defp alert_severity_color("critical"), do: "text-red-400"
  defp alert_severity_color("warning"), do: "text-yellow-400"
  defp alert_severity_color("info"), do: "text-blue-400"
  defp alert_severity_color(_), do: "text-green-400"

  defp format_tactical_time(datetime) do
    datetime
    |> DateTime.to_time()
    |> Time.to_string()
    |> String.slice(0..7)
  end
end
