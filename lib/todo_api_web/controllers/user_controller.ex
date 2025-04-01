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

  def update(conn, %{
        "id" => id,
        "user" => %{"current_password" => current_password} = user_params
      }) do
    with %TodoApi.Accounts.User{} = user <- Accounts.get_user(id),
         true <- Argon2.verify_pass(current_password, user.hashed_password),
         {:ok, %TodoApi.Accounts.User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    else
      false ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Unauthorized or incorrect current password"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Could not update user"})
    end
  end

  defp translate_error({msg, opts} = _error) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
