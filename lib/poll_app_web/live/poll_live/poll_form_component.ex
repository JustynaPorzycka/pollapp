defmodule PollAppWeb.PollLive.PollFormComponent do
  use PollAppWeb, :live_component

  alias PollApp.{Polls, Polls.Poll}

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("add_option", _, socket) do
    options = Ecto.Changeset.get_field(socket.assigns.form.source, :options, []) ++ [%{}]
    changeset = Ecto.Changeset.change(socket.assigns.form.source, %{options: options})
    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("remove_option", %{"index" => index}, socket) do
    index = String.to_integer(index)
    options = Ecto.Changeset.get_field(socket.assigns.form.source, :options, [])

    updated_options = List.delete_at(options, index)
    changeset = Ecto.Changeset.change(socket.assigns.form.source, %{options: updated_options})
    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"poll" => poll_params}, socket) do
    changeset =
      %Poll{}
      |> Poll.changeset(poll_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"poll" => poll_params}, socket) do
    new_poll_params = Map.merge(poll_params, %{"created_by" => socket.assigns.current_user})
    case Polls.create_poll(new_poll_params) do
      {:ok, poll} ->
        notify_parent({:saved, poll})
        socket =
          socket
          |> put_flash(:info, "Poll added successfully")
          |> push_patch(to: socket.assigns.path)
        {:noreply, socket}

      {:error, changeset} ->
        socket
        |> put_flash(:info, "Something went wrong")
        |> push_patch(to: socket.assigns.path)
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp notify_parent(msg) do
    send(self(), {__MODULE__, msg})
  end
end
