defmodule TodoApiWeb.UserController do
  use TodoApiWeb, :controller

  use ExUnit.Case, async: false

  alias TodoApi.Accounts
  alias TodoApi.Accounts.User

  action_fallback TodoApiWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def register(conn, %{"username" => _, "password" => _} = params) do
    with {:ok, %User{} = user} <- Accounts.create_user(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def login(conn, %{"username" => username, "password" => password}) do
    with {:ok, %User{} = user} <- Accounts.authenticate_user(username, password),
         {:ok, token, _claims} <- TodoApi.Guardian.encode_and_sign(user) do
      conn
      |> put_status(:ok)
      |> render(:user_token, user: user, token: token)
    end
  end

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

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
