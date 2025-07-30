defmodule PrismWeb.TacticalUI do
  @moduledoc """
  Tactical UI components optimized for FluxonUI migration.
  These components follow FluxonUI patterns and will be easy to replace
  with premium FluxonUI components when license is available.
  """
  use Phoenix.Component

  @doc """
  Tactical metrics card component
  """
  attr :title, :string, required: true
  attr :value, :any, required: true
  attr :unit, :string, default: ""
  attr :status, :atom, default: :normal, values: [:critical, :warning, :normal, :optimal]
  attr :class, :string, default: ""

  def metrics_card(assigns) do
    ~H"""
    <div class={[
      "border border-opacity-50 p-4 bg-black/20 backdrop-blur-sm transition-all duration-300 hover:border-opacity-80",
      status_border_color(@status),
      @class
    ]}>
      <h3 class="text-sm font-bold mb-2 tracking-wider opacity-80 uppercase">
        <%= @title %>
      </h3>
      <div class={[
        "text-3xl font-bold font-mono",
        status_text_color(@status)
      ]}>
        <%= @value %><span class="text-lg opacity-70"><%= @unit %></span>
      </div>
    </div>
    """
  end

  @doc """
  Tactical status indicator
  """
  attr :status, :string, required: true
  attr :pulse, :boolean, default: false
  attr :class, :string, default: ""

  def status_indicator(assigns) do
    ~H"""
    <div class={[
      "inline-flex items-center space-x-2",
      @class
    ]}>
      <div class={[
        "w-3 h-3 rounded-full",
        status_indicator_color(@status),
        @pulse && "animate-pulse"
      ]}>
      </div>
      <span class="text-sm font-mono tracking-wider uppercase">
        <%= @status %>
      </span>
    </div>
    """
  end

  @doc """
  Tactical data table component (FluxonUI table replacement)
  """
  attr :rows, :list, required: true
  attr :columns, :list, required: true
  attr :class, :string, default: ""

  def tactical_table(assigns) do
    ~H"""
    <div class={[
      "border border-green-400 border-opacity-30 overflow-hidden",
      @class
    ]}>
      <!-- Header -->
      <div class="bg-green-400/10 border-b border-green-400 border-opacity-30">
        <div class="grid grid-cols-4 gap-4 p-4">
          <div :for={column <- @columns} class="text-sm font-bold tracking-wider uppercase text-green-400">
            <%= column.label %>
          </div>
        </div>
      </div>

      <!-- Rows -->
      <div class="divide-y divide-green-400 divide-opacity-20">
        <div :for={row <- @rows} class="grid grid-cols-4 gap-4 p-4 hover:bg-green-400/5 transition-colors">
          <div :for={column <- @columns} class="text-sm font-mono">
            <%= get_in(row, [column.key]) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Tactical button (FluxonUI button replacement)
  """
  attr :variant, :atom, default: :primary, values: [:primary, :secondary, :danger, :success]
  attr :size, :atom, default: :md, values: [:sm, :md, :lg]
  attr :disabled, :boolean, default: false
  attr :class, :string, default: ""
  attr :type, :string, default: "button"
  attr :rest, :global, include: ~w(phx-click phx-target phx-value-id)

  slot :inner_block, required: true

  def tactical_button(assigns) do
    ~H"""
    <button
      type={@type}
      disabled={@disabled}
      class={[
        "font-mono font-bold tracking-wider uppercase transition-all duration-200",
        "border-2 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-black",
        button_variant_class(@variant),
        button_size_class(@size),
        @disabled && "opacity-50 cursor-not-allowed",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Tactical modal (FluxonUI modal replacement)
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :title, :string, default: ""
  attr :class, :string, default: ""

  slot :inner_block, required: true

  def tactical_modal(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "fixed inset-0 z-50 transition-all duration-300",
        @show && "opacity-100 pointer-events-auto" || "opacity-0 pointer-events-none"
      ]}
    >
      <!-- Backdrop -->
      <div class="absolute inset-0 bg-black/80 backdrop-blur-sm"></div>

      <!-- Modal -->
      <div class="relative min-h-screen flex items-center justify-center p-4">
        <div class={[
          "bg-black border-2 border-green-400 border-opacity-50 p-6 w-full max-w-2xl",
          "transform transition-all duration-300",
          @show && "scale-100 translate-y-0" || "scale-95 translate-y-4",
          @class
        ]}>
          <!-- Header -->
          <div :if={@title != ""} class="border-b border-green-400 border-opacity-30 pb-4 mb-6">
            <h2 class="text-xl font-bold text-green-400 font-mono tracking-wider uppercase">
              <%= @title %>
            </h2>
          </div>

          <!-- Content -->
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Tactical alert component (FluxonUI alert replacement)
  """
  attr :variant, :atom, default: :info, values: [:info, :success, :warning, :danger]
  attr :title, :string, default: ""
  attr :dismissible, :boolean, default: false
  attr :class, :string, default: ""

  slot :inner_block, required: true

  def tactical_alert(assigns) do
    ~H"""
    <div class={[
      "border-l-4 p-4 mb-4",
      alert_variant_class(@variant),
      @class
    ]}>
      <div class="flex items-start">
        <div class="flex-1">
          <h4 :if={@title != ""} class="font-bold mb-2 text-sm tracking-wider uppercase">
            <%= @title %>
          </h4>
          <div class="text-sm">
            <%= render_slot(@inner_block) %>
          </div>
        </div>
        <button :if={@dismissible} class="ml-4 text-opacity-70 hover:text-opacity-100 transition-opacity">
          ×
        </button>
      </div>
    </div>
    """
  end

  # Helper functions for styling
  defp status_border_color(:critical), do: "border-red-400"
  defp status_border_color(:warning), do: "border-yellow-400"
  defp status_border_color(:normal), do: "border-green-400"
  defp status_border_color(:optimal), do: "border-blue-400"

  defp status_text_color(:critical), do: "text-red-400"
  defp status_text_color(:warning), do: "text-yellow-400"
  defp status_text_color(:normal), do: "text-green-400"
  defp status_text_color(:optimal), do: "text-blue-400"

  defp status_indicator_color("OPERATIONAL"), do: "bg-green-400"
  defp status_indicator_color("WARNING"), do: "bg-yellow-400"
  defp status_indicator_color("CRITICAL"), do: "bg-red-400"
  defp status_indicator_color("OFFLINE"), do: "bg-gray-400"
  defp status_indicator_color(_), do: "bg-blue-400"

  defp button_variant_class(:primary), do: "border-green-400 text-green-400 hover:bg-green-400 hover:text-black focus:ring-green-400"
  defp button_variant_class(:secondary), do: "border-blue-400 text-blue-400 hover:bg-blue-400 hover:text-black focus:ring-blue-400"
  defp button_variant_class(:danger), do: "border-red-400 text-red-400 hover:bg-red-400 hover:text-black focus:ring-red-400"
  defp button_variant_class(:success), do: "border-emerald-400 text-emerald-400 hover:bg-emerald-400 hover:text-black focus:ring-emerald-400"

  defp button_size_class(:sm), do: "px-3 py-1 text-xs"
  defp button_size_class(:md), do: "px-4 py-2 text-sm"
  defp button_size_class(:lg), do: "px-6 py-3 text-base"

  defp alert_variant_class(:info), do: "border-blue-400 bg-blue-400/10 text-blue-400"
  defp alert_variant_class(:success), do: "border-green-400 bg-green-400/10 text-green-400"
  defp alert_variant_class(:warning), do: "border-yellow-400 bg-yellow-400/10 text-yellow-400"
  defp alert_variant_class(:danger), do: "border-red-400 bg-red-400/10 text-red-400"
end
