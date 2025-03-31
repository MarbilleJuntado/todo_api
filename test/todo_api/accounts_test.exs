defmodule TodoApi.AccountsTest do
  use TodoApi.DataCase
  use ExUnit.Case, async: true

  alias TodoApi.Accounts

  describe "users" do
    alias TodoApi.Accounts.User

    import TodoApi.AccountsFixtures

    @invalid_attrs %{username: 1234, password: 5678}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert [%User{id: id}] = Accounts.list_users()
      assert user.id == id
    end

    test "does not return the user if the username does not exist" do
      refute Accounts.get_user_by_username("unknown")
    end

    test "returns the user if the username exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user_by_username(user.username)
    end

    test "get_user/1 returns the user with given id" do
      %{username: username} = user = user_fixture()
      assert %User{username: ^username} = Accounts.get_user(user.id)
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{username: "some username", password: "some password"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.username == "some username"
      assert true == Argon2.verify_pass("some password", user.hashed_password)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        username: "some updated username",
        password: "some updated password"
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.username == "some updated username"
      assert true == Argon2.verify_pass("some updated password", user.hashed_password)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert old_user = Accounts.get_user(user.id)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert current_user = Accounts.get_user(user.id)
      assert old_user == current_user
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      refute Accounts.get_user(user.id)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
