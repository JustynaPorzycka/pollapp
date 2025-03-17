defmodule PollAppWeb.PollLive.Index do
  use PollAppWeb, :live_view

  alias PollApp.Polls
  alias PollApp.Polls.Poll
  alias PollAppWeb.PollLive.PollFormComponent

  @topic "polls_topic"
  @new_poll_event "new_poll_event"

  @impl true
  def mount(_params, _session, socket) do
    PollAppWeb.Endpoint.subscribe(@topic)
    polls = Polls.list_polls()
    {:ok, assign(socket, :polls, polls)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info(%{topic: @topic, payload: _state}, socket) do
    {:noreply, update(socket, :polls, fn _polls -> Polls.list_polls() end)}
  end

  @impl true
  def handle_info({PollAppWeb.PollLive.PollFormComponent, {:saved, poll}}, socket) do
    PollAppWeb.Endpoint.broadcast(@topic, @new_poll_event, poll)
    socket =
      socket
      |> update(:polls, fn _polls -> Polls.list_polls() end)
      |> assign(:live_action, :index)
    {:noreply, socket}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Active Polls")
    |> assign(:poll, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Poll")
    |> assign(:poll, %Poll{})
    |> assign(:form, to_form(Poll.changeset(%Poll{})))
  end
end
