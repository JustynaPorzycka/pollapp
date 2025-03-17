defmodule PollApp.Polls do
  @moduledoc """
  Provides the public API for managing polls.
  """

  alias PollApp.Polls.Poll
  alias PollApp.Storage
  alias PollApp.PollSupervisor

  @spec list_polls() :: list({any(), Poll.t()})
  def list_polls(), do: Storage.list_polls()

  @spec create_poll(map()) :: {:ok, Poll.t()} | {:error, Ecto.Changeset.t()}
  def create_poll(params) do
    case Poll.changeset(%Poll{}, params) |> Ecto.Changeset.apply_action(:update) do
      {:ok, poll} ->
        Storage.add_poll(poll)
        PollSupervisor.start_poll(poll)
        {:ok, poll}
      error -> error
    end
  end

  @spec get_poll(any()) :: Poll.t() | nil
  def get_poll(id), do: Storage.get_poll(id)

  def vote(poll_id, option_id, user) do
    case Storage.get_poll(poll_id) do
      nil -> {:error, :not_found}
      %Poll{} ->
        PollApp.PollProcess.vote(poll_id, option_id, user)
    end
  end

  @spec delete_poll(any()) :: {:error, :not_found} | {:ok, :deleted}
  def delete_poll(id) do
    case Storage.get_poll(id) do
      nil -> {:error, :not_found}
      %Poll{} ->
        PollApp.PollProcess.delete_poll(id)
    end
  end
end
