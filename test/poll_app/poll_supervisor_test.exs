defmodule PollApp.PollSupervisorTest do
  use ExUnit.Case, async: true

  alias PollApp.{PollSupervisor, Polls.Poll}


  describe "PollSupervisor" do
    test "starts a poll process successfully" do
      poll_id = "poll1"

      {:ok, pid1} = PollSupervisor.start_poll(poll_id)

      [{pid2, nil}]= Registry.lookup(PollApp.PollRegistry, poll_id)

      assert pid1 == pid2
    end

    test "returns error when trying to stop a non-existing poll" do
      assert PollSupervisor.stop_poll("non_existing_poll_id") == {:error, :not_found}
    end

    test "stops an existing poll process successfully" do
      poll_id = "poll2"

      {:ok, _pid} = PollSupervisor.start_poll(poll_id)

      assert PollSupervisor.stop_poll(poll_id) == :ok

      assert PollSupervisor.stop_poll(poll_id) == {:error, :not_found}
    end
  end
end
