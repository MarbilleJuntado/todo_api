defmodule TodoApi.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias TodoApi.Repo

  alias TodoApi.Tasks.Task

  def list_tasks(user_id, opts \\ []) do
    limit = Keyword.get(opts, :limit) || 100
    query = from t in Task, where: t.user_id == ^user_id, order_by: t.position, limit: ^limit

    Repo.all(query)
  end

  def get_task(id), do: Repo.get(Task, id)

  def create_task(user_id, attrs \\ %{}) do
    # flag to check if task is to be added at the top of the list;
    # otherwise, add new task to bottom
    top? = Map.get(attrs, "top?") || false

    base_query =
      case top? do
        true -> from t in Task, where: t.user_id == ^user_id, select: min(t.position)
        false -> from t in Task, where: t.user_id == ^user_id, select: max(t.position)
      end

    default = if top?, do: Decimal.new("1.0"), else: Decimal.new("0.0")
    base = Repo.one(base_query) || default

    new_position =
      if top? do
        Decimal.sub(base, "1.0")
      else
        Decimal.add(base, "1.0")
      end

    changeset =
      Task.changeset(
        %Task{},
        Map.merge(attrs, %{
          "user_id" => user_id,
          "position" => new_position
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

  def rebalance_positions(user_id) do
    tasks = list_tasks(user_id)

    updated_tasks =
      Enum.with_index(tasks, 1)
      |> Enum.map(fn {task, i} ->
        %{id: task.id, position: Decimal.mult(i, "1.0")}
      end)

    Repo.transaction(fn ->
      Enum.each(updated_tasks, fn %{id: id, position: pos} ->
        from(t in Task, where: t.id == ^id)
        |> Repo.update_all(set: [position: pos])
      end)
    end)
  end

  def reorder_task(%Task{} = task, attrs) do
    before_task_id = Map.get(attrs, "before_task_id")
    after_task_id = Map.get(attrs, "after_task_id")

    before_pos = get_task_position(before_task_id)
    after_pos = get_task_position(after_task_id)

    new_pos =
      cond do
        before_pos && after_pos ->
          before_pos
          |> Decimal.add(after_pos)
          |> Decimal.div("2.0")

        before_pos ->
          Decimal.add(before_pos, "1.0")

        after_pos ->
          Decimal.sub(after_pos, "1.0")

        true ->
          task.position
      end

    if small_gap?(before_pos, after_pos), do: TodoApi.RebalanceWorker.rebalance(task.user_id)

    task
    |> Task.reorder_changeset(%{"position" => new_pos})
    |> Repo.update()
  end

  defp get_task_position(nil), do: nil

  defp get_task_position(task_id) do
    case get_task(task_id) do
      nil -> nil
      task -> task.position
    end
  end

  defp small_gap?(pos1, pos2) when is_nil(pos1) or is_nil(pos2), do: false

  defp small_gap?(pos1, pos2) do
    gap =
      pos1
      |> Decimal.sub(pos2)
      |> Decimal.abs()

    # less or equal to 1.0e^-5
    Decimal.compare(gap, "1.0e-5") != :gt
  end
end
