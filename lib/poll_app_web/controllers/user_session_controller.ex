defmodule PollAppWeb.UserSessionController do
  use PollAppWeb, :controller

  alias PollAppWeb.UserAuth

  def create(conn, params) do
    create(conn, params, "Logged in successfully!")
  end

  defp create(conn, user_params, info) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user_params)
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
