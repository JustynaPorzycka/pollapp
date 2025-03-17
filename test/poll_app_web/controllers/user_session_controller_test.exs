defmodule PollAppWeb.UserSessionControllerTest do
  use PollAppWeb.ConnCase, async: true

  setup do
    %{user: %{:username => "username1"}}
  end

  describe "POST /users/log_in" do
    test "logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log_in", %{"username" => user.username})

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/polls"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/polls")
      response = html_response(conn, 200)
      assert response =~ ~p"/users/log_out"
    end

    test "logs the user in with return to", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(~p"/users/log_in", %{"username" => user.username})

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged in successfully!"
    end

  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/users/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/users/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
