defmodule PollAppWeb.PollLive.PollFormComponentTest do
  use PollAppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @user1 "username1"
  @question "What is your favorite framework?"
  @options [%{"text" => "Phoenix"}, %{"text" => "Rails"}, %{"text" => "Django"}]

  describe "Poll Form Component" do
    setup %{conn: conn} do
      {:ok, conn: log_in_user(conn, @user1)}
    end

    test "renders the form correctly", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/polls/new")

      assert html =~ "New Poll"
      assert html =~ "Question"
      assert html =~ "Add Option"
      assert html =~ "Save"
    end

    test "validates and prevents submission of empty form", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/polls/new")

      live
      |> form("#poll-form", poll: %{})
      |> render_change()

      assert render(live) =~ "can&#39;t be blank"
    end

    test "successfully creates a poll", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/polls/new")

      live
      |> form("#poll-form", %{"poll" => %{"question" => @question}})
      |> render_submit(%{"poll" => %{"options" => @options}})

      assert_patch(live, ~p"/polls")
      assert render(live) =~ "Poll added successfully"
    end

    test "adds and removes options dynamically", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/polls/new")

      live
      |> element("button[phx-click=add_option]")
      |> render_click()

      assert render(live) =~ "Remove"

      live
      |> element("button[phx-click=remove_option]")
      |> render_click()

      refute render(live) =~ "Remove"
    end
  end
end
