defmodule PollApp.PollSupervisorTest do
  use ExUnit.Case, async: true

  alias PollApp.{PollSupervisor, Polls.Poll}


  describe "PollSupervisor" do
    test "starts a poll process successfully" do
      poll = %Poll{id: "poll1", options: [], voters: []}

      {:ok, pid1} = PollSupervisor.start_poll(poll)

      [{pid2, nil}]= Registry.lookup(PollApp.PollRegistry, "poll1")

      assert pid1 == pid2
    end

    test "returns error when trying to stop a non-existing poll" do
      assert PollSupervisor.stop_poll("non_existing_poll_id") == {:error, :not_found}
    end

    test "stops an existing poll process successfully" do
      poll = %Poll{id: "poll2", options: [], voters: []}

      {:ok, _pid} = PollSupervisor.start_poll(poll)

      assert PollSupervisor.stop_poll("poll2") == :ok

      assert PollSupervisor.stop_poll("poll2") == {:error, :not_found}
    end
  end
end
