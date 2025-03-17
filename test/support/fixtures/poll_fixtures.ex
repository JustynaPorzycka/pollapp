defmodule PollApp.PollFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PollApp.Polls` context.
  """
  alias PollApp.Polls

  @table :polls
  @doc """
  Generates a poll.
  """
  def poll_fixture do
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
  end

  @doc """
  Generates a poll with a specified creator.
  """
  def poll_fixture_created_by(creator) do
    %{
      "question" => "What is your favorite color?",
      "created_by" => creator,
      "options" => [
        %{"text" => "Red"},
        %{"text" => "Blue"},
        %{"text" => "Green"}
      ]
    }
    |> Polls.create_poll()
    |> elem(1)
  end

  @doc """
  Creates and returns a list of 3 different poll fixtures.
  Each poll contains a unique question and a set of options.
  """
  def polls_fixture do
    [
      %{
        "question" => "What is your favorite programming language?",
        "options" => [
          %{"text" => "Elixir"},
          %{"text" => "Python"},
          %{"text" => "JavaScript"}
        ]
      },
      %{
        "question" => "Which sport do you enjoy the most?",
        "options" => [
          %{"text" => "Soccer"},
          %{"text" => "Basketball"},
          %{"text" => "Tennis"}
        ]
      },
      %{
        "question" => "What is your favorite type of music?",
        "options" => [
          %{"text" => "Rock"},
          %{"text" => "Pop"},
          %{"text" => "Jazz"}
        ]
      }
    ]
    |> Enum.map(fn poll_data -> Polls.create_poll(poll_data) |> elem(1) end)
  end

  @doc """
  Generates a poll with custom parameters.
  """
  def poll_fixture_with_params(poll_params) do
    poll_params
    |> Polls.create_poll()
    |> elem(1)
  end

  @doc """
  Clears ETS table.
  """
  def clear_data do
    :ets.delete_all_objects(@table)
  end
end
