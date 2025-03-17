defmodule PollAppWeb.IndexTest do
  use PollAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import PollApp.PollFixtures

  @user1 "username1"
  @user2 "username2"
  @question "What is your favorite framework?"

  setup %{conn: conn} do
    clear_data()
    {:ok, conn: log_in_user(conn, @user1)}
  end

  describe "Index" do

    test "lists all polls", %{conn: conn} do
      polls = polls_fixture()
      {:ok, _index_live, html} = live(conn, ~p"/polls")

      assert html =~ "Active Polls"
      for poll <- polls do
        assert html =~ poll.question
      end
    end

    test "opens the new poll form when clicking New Poll button", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/polls")

      index_live
      |> element("a", "New Poll")
      |> render_click()

      assert_redirect(index_live, ~p"/polls/new")
    end

    test "new poll appears on the index for other users", %{conn: conn} do
      conn2 = log_in_user(build_conn(), @user2)

      {:ok, _index_live_user2, html_user2} = live(conn2, ~p"/polls")
      refute html_user2 =~ @question

      {:ok, live_user1, _html} = live(conn, ~p"/polls/new")

      live_user1
      |> form("#poll-form", %{"poll" => %{"question" => @question}})
      |> render_submit()

      assert_receive %Phoenix.Socket.Broadcast{
        topic: "polls_topic",
        event: "new_poll_event"
      }, 1000

      Process.sleep(1000)

      {:ok, _index_live_user2, html_user2} = live(conn2, ~p"/polls")
      assert html_user2 =~ @question
    end

    test "poll disappears after deletion by the creator", %{conn: conn} do
      poll = poll_fixture_created_by(@user1)
      conn2 = log_in_user(build_conn(), @user2)

      {:ok, _index_live_user2, html_user2} = live(conn2, ~p"/polls")
      assert html_user2 =~ poll.question

      # The poll creator deletes the poll
      {:ok, show_live, _html} = live(conn, ~p"/polls/#{poll.id}")
      show_live
      |> element("button", "Delete Poll")
      |> render_click()

      assert_receive %Phoenix.Socket.Broadcast{
        topic: "polls_topic",
        event: "poll_deleted_event"
      }, 1000

      Process.sleep(1000)

      {:ok, _index_live_user2, html_user2} = live(conn2, ~p"/polls")
      refute html_user2 =~ poll.question
    end
  end
end
