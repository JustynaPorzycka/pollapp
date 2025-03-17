defmodule PollApp.Storage do
  @moduledoc """
  Manages poll data using an in-memory ETS (Erlang Term Storage) table.

  Supports concurrent reads and writes, allowing multiple processes to
  interact with the data simultaneously.

  All operations are inherently atomic, preventing race conditions due
  to the atomic nature of ETS operations.

  ## Notes:
  - The poll data is stored in-memory, meaning the data will be lost
  when the application is restarted.
  """

  alias PollApp.Polls.Poll

  @polls :polls

  def init() do
    :ets.new(@polls, [:public, :named_table, write_concurrency: true, read_concurrency: true])
    {:ok, nil}
  end

  @spec list_polls() :: list({any(), Poll.t()})
  def list_polls(), do: :ets.tab2list(@polls)

  @spec get_poll(any()) :: Poll.t() | nil
  def get_poll(id) do
    case :ets.lookup(@polls, id) do
      [{_key, poll}] -> poll
      [] -> nil
    end
  end

  @spec get_option(Poll.t(), any()) :: Poll.Option.t() | nil
  def get_option(%Poll{options: options}, option_id),
    do: Enum.find(options, &(&1.id == option_id))

  @spec add_poll(Poll.t()) :: {:ok, Poll.t()}
  def add_poll(%Poll{} = poll) do
    true = :ets.insert_new(@polls, {poll.id, poll})
    {:ok, poll}
  end

  @spec update_poll(Poll.t()) :: :ok
  def update_poll(%Poll{} = poll) do
    :ets.insert(@polls, {poll.id, poll})
    :ok
  end

  @spec delete_poll(any()) :: true
  def delete_poll(poll) do
    :ets.delete_object(@polls, poll)
  end
end
