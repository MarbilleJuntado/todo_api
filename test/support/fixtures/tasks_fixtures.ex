defmodule TodoApi.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoApi.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(user_id, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        "description" => "some description",
        "title" => "some title"
      })

    {:ok, task} =
      TodoApi.Tasks.create_task(user_id, attrs)

    task
  end
end
