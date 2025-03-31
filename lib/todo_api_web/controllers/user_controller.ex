defmodule TodoApiWeb.UserController do
  use TodoApiWeb, :controller

  alias TodoApi.Accounts

  plug Dictator

  action_fallback TodoApiWeb.FallbackController

  def show(conn, %{"id" => id}) do
    with %TodoApi.Accounts.User{} = user <- Accounts.get_user(id) do
      render(conn, :show, user: user)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    with %TodoApi.Accounts.User{} = user <- Accounts.get_user(id),
         {:ok, %TodoApi.Accounts.User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end
end
