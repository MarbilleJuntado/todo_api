defmodule TodoApiWeb.Policies.UserPolicyTest do
  use ExUnit.Case

  alias TodoApiWeb.Policies.UserPolicy
  alias TodoApi.Accounts.User

  setup do
    user = %User{id: Ecto.UUID.generate()}
    user2 = %User{id: Ecto.UUID.generate()}

    %{user: user, user2: user2}
  end

  test "users can view themselves", %{user: user} do
    assert UserPolicy.can?(user, :show, %{resource: user})
  end

  test "users cannot view others", %{user: user, user2: user2} do
    refute UserPolicy.can?(user, :show, %{resource: user2})
  end

  test "users can update themselves", %{user: user} do
    assert UserPolicy.can?(user, :update, %{resource: user})
  end

  test "users cannot update others", %{user: user, user2: user2} do
    refute UserPolicy.can?(user, :update, %{resource: user2})
  end
end
