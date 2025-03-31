defmodule TodoApiWeb.AuthJSON do
  alias TodoApi.Accounts.User

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      username: user.username
    }
  end

  @doc """
  Renders a single user with a valid token.
  """
  def user_token(%{user: user, token: token}) do
    %{
      id: user.id,
      username: user.username,
      token: token
    }
  end
end
