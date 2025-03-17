defmodule PollApp.PollProcess do
  @moduledoc """
  Manages the lifecycle of a single poll in a concurrent environment using a `GenServer`.

  Both the `vote` and `delete_poll` operations require synchronization because multiple
  users can interact with the same poll concurrently. Using a `GenServer` ensures that these
  operations are handled atomically, preventing race conditions. By serializing access to the
  poll state, `GenServer` guarantees that only one operation is performed at a time, and the
  poll state remains consistent.
  """
  use GenServer

  alias PollApp.Polls.Poll
  alias PollApp.Storage

  ## --- API ---

  def start_link(%Poll{id: poll_id} = poll) do
    GenServer.start_link(__MODULE__, poll, name: via_tuple(poll_id))
  end

  def vote(poll_id, option_id, user) do
    GenServer.call(via_tuple(poll_id), {:vote, option_id, user})
  end

  @spec delete_poll(any()) :: {:error, :not_found} | {:ok, :deleted}
  def delete_poll(poll_id) do
    GenServer.call(via_tuple(poll_id), :delete_poll)
  end

  ## --- Callbacks ---

  def init(poll) do
    {:ok, poll}
  end

  def handle_call({:vote, option_id, user}, _from, %Poll{} = poll) do
    case get_option(poll, option_id) do
      nil ->
        {:reply, {:error, :option_not_found}, poll}

      %Poll.Option{} = _option ->
        if user in poll.voters do
          {:reply, {:error, :user_already_voted}, poll}
        else
          updated_poll =
            %Poll{
              poll
              | options: Enum.map(poll.options, fn
                  opt when opt.id == option_id -> %Poll.Option{opt | votes: opt.votes + 1}
                  opt -> opt
                end),
                voters: [user | poll.voters],
                total_votes: poll.total_votes + 1
            }

          Storage.update_poll(updated_poll)
          {:reply, {:ok, updated_poll}, updated_poll}
        end
    end
  end

  def handle_call(:delete_poll, _from, %Poll{id: poll_id} = poll) do
    Storage.delete_poll({poll_id, poll})
    {:stop, :normal, {:ok, :deleted}, poll}
  end

  ## --- Helpers ---

  defp get_option(%Poll{options: options}, option_id),
    do: Enum.find(options, &(&1.id == option_id))

  defp via_tuple(poll_id), do: {:via, Registry, {PollApp.PollRegistry, poll_id}}
end
