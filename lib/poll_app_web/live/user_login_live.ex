defmodule PollAppWeb.UserLoginLive do
  use PollAppWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to account
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:username]} type="text" label="Username" required />
        <:actions>
          <button
            phx-disable-with="Logging in..."
            class="w-full bg-teal-500 hover:bg-teal-700 text-white py-2 px-4 rounded">
            Log in <span aria-hidden="true">→</span>
          </button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    form = to_form(%{"username" => nil})
    {:ok, assign(socket, form: form)}
  end
end
