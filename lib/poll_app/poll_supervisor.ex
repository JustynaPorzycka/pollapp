defmodule PollApp.PollSupervisor do
  @moduledoc """
  A dynamic supervisor responsible for managing the lifecycle of poll processes.
  """
  use DynamicSupervisor

  alias PollApp.PollProcess

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_poll(poll) do
    DynamicSupervisor.start_child(__MODULE__, {PollProcess, poll})
  end

  def stop_poll(poll_id) do
    case whereis_poll(poll_id) do
      nil -> {:error, :not_found}
      pid -> DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end

  defp whereis_poll(poll_id) do
    case Registry.lookup(PollApp.PollRegistry, poll_id) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end
end
