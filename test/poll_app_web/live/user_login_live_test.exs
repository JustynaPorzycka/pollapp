defmodule PollAppWeb.UserLoginLiveTest do
  use PollAppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup do
    %{user: %{:username => "username1"}}
  end

  test "renders log in page", %{conn: conn} do
    {:ok, _lv, html} = live(conn, ~p"/users/log_in")

    assert html =~ "Log in"
  end

  test "redirects if already logged in", %{conn: conn, user: user} do
    result =
      conn
      |> log_in_user(user.username)
      |> live(~p"/users/log_in")
      |> follow_redirect(conn, "/polls")

    assert {:ok, _conn} = result
  end

  test "redirects if user login with valid credentials", %{conn: conn, user: user} do
    {:ok, lv, _html} = live(conn, ~p"/users/log_in")

    conn =
      lv
      |> form("#login_form", %{"username" => user.username})
      |> submit_form(conn)

    assert redirected_to(conn) == ~p"/polls"
  end
end
