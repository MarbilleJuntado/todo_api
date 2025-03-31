defmodule TodoApi.TasksTest do
  use TodoApi.DataCase

  alias TodoApi.Tasks

  describe "tasks" do
    alias TodoApi.Tasks.Task

    import TodoApi.TasksFixtures
    import TodoApi.AccountsFixtures

    @invalid_attrs %{position: nil, description: nil, title: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      user = user_fixture()

      valid_attrs = %{
        position: "120.5",
        description: "some description",
        title: "some title",
        user_id: user.id
      }

      assert {:ok, %Task{} = task} = Tasks.create_task(valid_attrs)
      assert task.position == Decimal.new("120.5")
      assert task.description == "some description"
      assert task.title == "some title"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()

      update_attrs = %{
        position: "456.7",
        description: "some updated description",
        title: "some updated title"
      }

      assert {:ok, %Task{} = task} = Tasks.update_task(task, update_attrs)
      assert task.position == Decimal.new("456.7")
      assert task.description == "some updated description"
      assert task.title == "some updated title"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end
end
