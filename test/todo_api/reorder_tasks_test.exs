defmodule TodoApi.Tasks.ReorderTasksTest do
  use TodoApi.DataCase, async: false
  alias TodoApi.{Accounts, Tasks}

  setup do
    {:ok, user} = Accounts.create_user(%{"username" => "reorder_user", "password" => "123"})

    # Create 5 tasks with well-spaced positions
    tasks =
      for i <- 1..5 do
        {:ok, task} =
          Tasks.create_task(user.id, %{
            "title" => "Task #{i}"
          })

        task
      end

    %{user: user, tasks: tasks}
  end

  test "reorders between two tasks", %{tasks: [_, t2, t3, _, t5]} do
    # Move t5 between t2 and t3
    {:ok, reordered} =
      Tasks.reorder_task(t5, %{"before_task_id" => t2.id, "after_task_id" => t3.id})

    assert Decimal.compare(reordered.position, t2.position) == :gt
    assert Decimal.compare(reordered.position, t3.position) == :lt
  end

  test "reorders to top (before_task_id = nil)", %{tasks: [t1 | _]} do
    {:ok, reordered} = Tasks.reorder_task(t1, %{"after_task_id" => t1.id})
    assert Decimal.compare(reordered.position, t1.position) == :lt
  end

  test "reorders to bottom (after_task_id = nil)", %{tasks: [_, _, _, _, t5]} do
    {:ok, reordered} = Tasks.reorder_task(t5, %{"before_task_id" => t5.id})
    assert Decimal.compare(reordered.position, t5.position) == :gt
  end

  test "triggers async rebalance when positions are too close", %{
    user: user,
    tasks: [t1, t2, t3 | _]
  } do
    # Manually compress task position
    Repo.update_all(from(t in Tasks.Task, where: t.id == ^t2.id), set: [position: "1.00001"])

    # Reordering t3 between t1 and t2 should trigger rebalance
    {:ok, _reordered} =
      Tasks.reorder_task(t3, %{"before_task_id" => t1.id, "after_task_id" => t2.id})

    # Wait for async rebalance to finish
    wait_until(fn ->
      tasks = Tasks.list_tasks(user.id)
      positions = Enum.map(tasks, & &1.position)

      assert Enum.chunk_every(positions, 2, 1, :discard)
             |> Enum.all?(fn [a, b] -> Decimal.compare(Decimal.sub(b, a), "0.9") != :lt end)
    end)
  end

  defp wait_until(fun), do: wait_until(500, fun)

  defp wait_until(0, fun), do: fun.()

  defp wait_until(timeout, fun) do
    try do
      fun.()
    rescue
      ExUnit.AssertionError ->
        :timer.sleep(10)
        wait_until(max(0, timeout - 10), fun)
    end
  end
end
