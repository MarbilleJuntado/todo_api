defmodule TodoApiWeb.Policies.TaskPolicyTest do
  use ExUnit.Case

  alias TodoApiWeb.Policies.TaskPolicy
  alias TodoApi.Accounts.User
  alias TodoApi.Tasks.Task

  setup do
    user = %User{id: Ecto.UUID.generate()}
    user2 = %User{id: Ecto.UUID.generate()}
    task = %Task{user_id: user.id}
    task2 = %Task{user_id: user2.id}

    %{user: user, task: task, task2: task2}
  end

  test "users can view their own task", %{user: user, task: task} do
    assert TaskPolicy.can?(user, :show, %{resource: task})
  end

  test "users cannot view another user's task", %{user: user, task2: task} do
    refute TaskPolicy.can?(user, :show, %{resource: task})
  end

  test "users can update their own task", %{user: user, task: task} do
    assert TaskPolicy.can?(user, :update, %{resource: task})
  end

  test "users cannot update another user's task", %{user: user, task2: task} do
    refute TaskPolicy.can?(user, :update, %{resource: task})
  end

  test "users can delete their own task", %{user: user, task: task} do
    assert TaskPolicy.can?(user, :delete, %{resource: task})
  end

  test "users cannot delete another user's task", %{user: user, task2: task} do
    refute TaskPolicy.can?(user, :delete, %{resource: task})
  end

  test "users can reorder their own task", %{user: user, task: task} do
    assert TaskPolicy.can?(user, :reorder, %{resource: task})
  end

  test "users cannot reorder another user's task", %{user: user, task2: task} do
    refute TaskPolicy.can?(user, :reorder, %{resource: task})
  end
end
