defmodule TodoApi.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias TodoApi.Repo

  alias TodoApi.Tasks.Task

  def list_tasks(user_id) do
    query = from t in Task, where: t.user_id == ^user_id, order_by: t.position

    Repo.all(query)
  end

  def get_task(id), do: Repo.get(Task, id)

  def create_task(user_id, attrs \\ %{}) do
    last_position_query = from t in Task, where: t.user_id == ^user_id, select: max(t.position)
    last_position = Repo.one(last_position_query) || "0.0"

    changeset =
      Task.changeset(
        %Task{},
        Map.merge(attrs, %{
          "user_id" => user_id,
          "position" => Decimal.add(last_position, "1.0")
        })
      )

    Repo.insert(changeset)
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end
end
