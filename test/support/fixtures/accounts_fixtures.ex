defmodule TodoApi.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoApi.Accounts` context.
  """

  @doc """
  Generate a unique user username.
  """
  def unique_user_username, do: "someUsername#{System.unique_integer([:positive])}"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        password: "somePassword1",
        username: unique_user_username()
      })
      |> TodoApi.Accounts.create_user()

    user
  end
end
