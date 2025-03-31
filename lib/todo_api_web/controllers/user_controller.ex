defmodule TodoApiWeb.UserController do
  use TodoApiWeb, :controller

  alias TodoApi.Accounts
  alias TodoApi.Accounts.User

  action_fallback TodoApiWeb.FallbackController

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end
end
