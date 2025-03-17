defmodule PollAppWeb.PollLive.Show do
  use PollAppWeb, :live_view

  alias PollApp.Polls
  alias PollApp.Charts.PollChart

  @polls_topic "polls_topic"
  @new_vote_event "new_vote_event"
  @poll_deleted_event "poll_deleted_event"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Polls.get_poll(id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Poll not found.")
         |> push_navigate(to: "/polls")}

      poll ->
        chart_svg = PollChart.generate_chart(poll)
        PollAppWeb.Endpoint.subscribe(@polls_topic)
        {:ok, assign(socket, poll: poll, chart_svg: chart_svg)}
    end
  end

  @impl true
  def handle_event("vote", %{"option-id" => option_id}, socket) do
    if is_nil(socket.assigns.current_user) do
      socket =
        socket
        |> put_flash(:error, "Only logged in users can vote.")
        |> redirect(to: ~p"/users/log_in")
      {:noreply, socket}
    else
      poll = socket.assigns.poll
      case Polls.vote(poll.id, option_id, socket.assigns.current_user) do
        {:ok, updated_poll} ->
          PollAppWeb.Endpoint.broadcast(@polls_topic, @new_vote_event, updated_poll)
          socket =
            socket
            |> assign(:poll, updated_poll)
            |> assign(:already_voted, true)
          {:noreply, socket}
        {:error, :user_already_voted} ->
          {:noreply, put_flash(socket, :error, "You already voted")}
        {:error, _message} ->
          {:noreply, socket}
      end
    end
  end

  @impl true
  def handle_event("delete_poll", %{"poll-id" => id}, socket) do
    case Polls.delete_poll(id) do
      {:ok, :deleted} ->
        PollAppWeb.Endpoint.broadcast(@polls_topic, @poll_deleted_event, %{poll_id: id})
        socket =
          socket
          |> push_navigate(to: "/polls")
          |> put_flash(:info, "Poll deleted successfully")
        {:noreply, socket}
      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%{topic: @polls_topic, event: @new_vote_event, payload: _state}, socket) do
    updated_poll = Polls.get_poll(socket.assigns.poll.id)
    {:noreply, assign(socket, poll: updated_poll, chart_svg: PollChart.generate_chart(updated_poll))}
  end

  @impl true
  def handle_info(%{topic: @polls_topic, event: @poll_deleted_event, payload: %{poll_id: poll_id}}, socket) do
    if socket.assigns.poll.id == poll_id do
      socket =
        socket
        |> push_navigate(to: "/polls")
        |> put_flash(:error, "This poll has been deleted, redirect to active polls")
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%{topic: @polls_topic, payload: _state}, socket) do
    {:noreply, socket}
  end

  defp format_time(time) do
    year = time.year
    month = time.month |> pad_zero()
    day = time.day |> pad_zero()
    hour = time.hour |> pad_zero()
    minute = time.minute |> pad_zero()

    "#{year}-#{month}-#{day}: #{hour}:#{minute}"
  end

  defp pad_zero(value) when value < 10, do: "0#{value}"
  defp pad_zero(value), do: Integer.to_string(value)
end
