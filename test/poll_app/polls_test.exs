defmodule PollApp.PollsTest do
  use ExUnit.Case, async: true
  alias PollApp.Polls
  import PollApp.PollFixtures

  describe "Poll creation" do
    test "creates a poll successfully and ensures it appears in the list of polls" do
      poll =
        %{
          "question" => "What is your favorite color?",
          "options" => [
            %{"text" => "Red"},
            %{"text" => "Blue"},
            %{"text" => "Green"}
          ]
        }
        |> Polls.create_poll()
        |> elem(1)

      listed_polls = Polls.list_polls()
      assert Enum.any?(listed_polls, fn {_, p} -> p.id == poll.id end)

      assert poll.question == "What is your favorite color?"
      assert length(poll.options) == 3
      assert Enum.any?(poll.options, fn option -> option.text == "Red" end)
    end

    test "fails to create a poll with invalid parameters" do
      invalid_params = %{"question" => ""}
      assert {:error, _changeset} = Polls.create_poll(invalid_params)
    end

    test "lists no polls when none are present" do
      true = clear_data()
      assert Polls.list_polls() == []
    end

    test "returns nil when poll does not exist" do
      assert Polls.get_poll(-1) == nil
    end
  end

  describe "Poll voting" do
    setup do
      {:ok, poll: poll_fixture()}
    end

    test "user can vote for a poll option", %{poll: poll} do
      user = %{username: "john_doe"}

      option_id = Enum.at(poll.options, 0).id

      {:ok, updated_poll} = Polls.vote(poll.id, option_id, user)

      voted_option = Enum.find(updated_poll.options, fn option -> option.id == option_id end)
      assert voted_option.votes == 1
    end

    test "user cannot vote twice on the same poll", %{poll: poll} do
      user = %{username: "john_doe"}

      option_id = Enum.at(poll.options, 0).id

      {:ok, _updated_poll} = Polls.vote(poll.id, option_id, user)

      {:error, :user_already_voted} = Polls.vote(poll.id, option_id, user)
    end

    test "fails to vote on a non-existent poll" do
      user = %{username: "john_doe"}
      assert {:error, :not_found} = Polls.vote(-1, 1, user)
    end

  end

  describe "Poll deletion" do
    setup do
      {:ok, poll: poll_fixture()}
    end

    test "deletes a poll successfully, fails to delete a non-existent poll", %{poll: poll} do

      {:ok, :deleted} = Polls.delete_poll(poll.id)

      assert {:error, :not_found} = Polls.delete_poll(poll.id)

      assert nil == Polls.get_poll(poll.id)
    end
  end

end
