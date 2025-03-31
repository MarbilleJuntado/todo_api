defmodule TodoApi.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoApi.Tasks` context.
  """

  import TodoApi.AccountsFixtures

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, task} =
      attrs
      |> Enum.into(%{
        user_id: user.id,
        description: "some description",
        position: "120.5",
        title: "some title"
      })
      |> TodoApi.Tasks.create_task()

    task
  end
end
