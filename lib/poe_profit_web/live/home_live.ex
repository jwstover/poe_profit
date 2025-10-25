defmodule PoeProfitWeb.HomeLive do
  use PoeProfitWeb, :live_view

  on_mount {PoeProfitWeb.LiveUserAuth, :live_user_optional}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-10 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl">
        <h1 class="text-4xl font-bold">Welcome</h1>
        <p class="mt-4 text-lg text-base-content/70">
          Start building your application here.
        </p>
      </div>
    </div>
    """
  end
end
