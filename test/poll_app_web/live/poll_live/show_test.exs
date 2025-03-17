defmodule PollAppWeb.ShowTest do
  use PollAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import PollApp.PollFixtures

  @user1 "username1"
  @user2 "username2"
  @question "What is your favorite framework?"

  setup %{conn: conn} do
    clear_data()
    {:ok, conn: log_in_user(conn, @user1), poll: poll_fixture_created_by(@user1)}
  end

  describe "Show" do

    test "displays poll and voting options", %{conn: conn, poll: poll} do
      {:ok, _show_live, html} = live(conn, ~p"/polls/#{poll.id}")

      assert html =~ poll.question

      for option <- poll.options do
        assert html =~ option.text
        assert html =~ Integer.to_string(option.votes)
      end
    end

    test "allows voting and updates the poll within the modal", %{conn: conn, poll: poll} do
      {:ok, show_live, _html} = live(conn, ~p"/polls/#{poll.id}")

      option = hd(poll.options)

      show_live
      |> element("button[phx-value-option-id='#{option.id}']", "Vote")
      |> render_click()

      assert_receive %Phoenix.Socket.Broadcast{
        topic: "polls_topic",
        event: "new_vote_event"
      }

      updated_poll = PollApp.Polls.get_poll(poll.id)
      assert updated_poll.options |> Enum.any?(fn option -> option.votes > 0 end)

      html = render(show_live)
      assert html =~ "Voting Results"
      for option <- updated_poll.options do
        assert html =~ Integer.to_string(option.votes)
      end
    end

    test "allows poll deletion if the current user is the poll creator", %{conn: conn, poll: poll} do
      {:ok, show_live, _html} = live(conn, ~p"/polls/#{poll.id}")

      # The "Delete Poll" button should be shown
      assert show_live |> element("button", "Delete Poll") != nil

      show_live
      |> element("button", "Delete Poll")
      |> render_click()

      assert_redirect(show_live, ~p"/polls")
      assert_receive %Phoenix.Socket.Broadcast{
        topic: "polls_topic",
        event: "poll_deleted_event"
      }
    end

    test "does not show delete button for non-creator users", %{conn: conn, poll: poll} do
      # Log in as a different user who is NOT the poll creator
      conn = log_in_user(conn, @user2)

      {:ok, show_live, _html} = live(conn, ~p"/polls/#{poll.id}")

      # The "Delete Poll" button should NOT be visible
      refute show_live |> has_element?("button", "Delete Poll")
    end

    test "new poll event", %{conn: conn, poll: poll} do
      conn2 = log_in_user(build_conn(), @user2)

      {:ok, _user2_live, _html2} = live(conn2, ~p"/polls/#{poll.id}")
      {:ok, user1_live, _html2} = live(conn, ~p"/polls/new")

      user1_live
      |> form("#poll-form", %{"poll" => %{"question" => @question}})
      |> render_submit()

      assert_receive %Phoenix.Socket.Broadcast{
        topic: "polls_topic",
        event: "new_poll_event"
      }
    end

    test "poll results update", %{conn: conn, poll: poll} do
      conn2 = log_in_user(build_conn(), @user2)

      {:ok, user1_live, _html1} = live(conn, ~p"/polls/#{poll.id}")
      {:ok, user2_live, _html2} = live(conn2, ~p"/polls/#{poll.id}")

      option = hd(poll.options)

      user1_live
      |> element("button[phx-value-option-id='#{option.id}']", "Vote")
      |> render_click()

      assert render(user2_live) =~ Integer.to_string(option.votes + 1)
    end

    test "multiple users can vote", %{poll: poll} do
      users = for i <- 1..10, do: "user#{i}"

      live_views =
        for user <- users do
          conn = log_in_user(build_conn(), user)
          {:ok, lv, _html} = live(conn, ~p"/polls/#{poll.id}")
          lv
        end

      option = hd(poll.options)

      Enum.each(live_views, fn lv ->
        spawn(fn ->
          lv
          |> element("button[phx-value-option-id='#{option.id}']", "Vote")
          |> render_click()
        end)
      end)

      Process.sleep(500)

      updated_poll = PollApp.Polls.get_poll(poll.id)

      assert Enum.find(updated_poll.options, &(&1.id == option.id)).votes == length(users)
    end

    test "users cannot vote more than once", %{conn: conn, poll: poll} do
      {:ok, show_live, _html} = live(conn, ~p"/polls/#{poll.id}")

      option = hd(poll.options)

      show_live
      |> element("button[phx-value-option-id='#{option.id}']", "Vote")
      |> render_click()

      updated_poll = PollApp.Polls.get_poll(poll.id)
      assert Enum.find(updated_poll.options, &(&1.id == option.id)).votes == 1

      show_live
      |> element("button[phx-value-option-id='#{option.id}']", "Vote")
      |> render_click()

      final_poll = PollApp.Polls.get_poll(poll.id)

      # The vote count should remain 1, as second vote is not allowed
      assert Enum.find(final_poll.options, &(&1.id == option.id)).votes == 1
    end

    test "chart updates after voting", %{conn: conn, poll: poll} do
      {:ok, show_live, _html} = live(conn, ~p"/polls/#{poll.id}")

      option = hd(poll.options)

      initial_chart_svg = show_live |> element("#poll-chart") |> render()

      show_live
      |> element("button[phx-value-option-id='#{option.id}']", "Vote")
      |> render_click()

      updated_chart_svg = show_live |> element("#poll-chart") |> render()

      assert initial_chart_svg != updated_chart_svg
    end


  end
end
